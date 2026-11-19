import UIKit
import AVFoundation
import CoreImage
import CoreVideo
import simd
import MediaPipeTasksVision

/// iOS counterpart of the Android `PoseDetectionActivity`.
///
/// Drives the three-phase pipeline — ambient-light check → YOLO person/monitor
/// detection → MediaPipe pose + ROSA scoring — then captures three guided photos
/// (face blurred, skeleton + angle arcs baked in) and hands the file paths and
/// ROSA scores back through `onComplete`.
///
/// All mutable detection state is touched only on `captureQueue`; the camera
/// delegate, the MediaPipe live-stream callback and the tilt callback all funnel
/// onto it, so there are no data races and no locks. UI work is dispatched to main.
final class PoseDetectionViewController: UIViewController {

    /// Result is `["side_captures": [[String: Any]], "front_capture": [String: Any]]`
    /// (see finishWithCaptures; `front_capture` is omitted when no front photo can
    /// be taken), or `nil` if the user cancelled — matching what the
    /// Android MainActivity returns.
    var onComplete: (([String: Any]?) -> Void)?

    private let workstationModifiers: RosaScorer.WorkstationModifiers
    /// False when the user said a front-view photo can't be taken: the front phase
    /// is skipped and armrestTooWide / keyboardDeviation come from the answers.
    private let frontPhotoAvailable: Bool
    /// The app's language for the on-screen text (see CaptureStrings). Text baked
    /// into the saved photos stays English.
    private let language: String

    init(workstationModifiers: RosaScorer.WorkstationModifiers, frontPhotoAvailable: Bool = true,
         language: String? = nil) {
        self.workstationModifiers = workstationModifiers
        self.frontPhotoAvailable = frontPhotoAvailable
        self.language = CaptureStrings.normalize(language)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        // Let this screen drive the status bar (light icons over the black view)
        // while presented over the Flutter view controller.
        modalPresentationCapturesStatusBarAppearance = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func tr(_ key: CaptureStrings.Key, _ args: [String: CustomStringConvertible] = [:]) -> String {
        CaptureStrings.get(key, language, args)
    }

    // MARK: - State machine

    // `front` is a 4th phase entered after the 3 side shots: the holder moves to
    // the front of the person (behind the monitor) and a single extra photo is
    // taken once the face, shoulders and hands are visible.
    // `done`: every photo is taken; frames are ignored while the photos are processed.
    private enum AppState { case lightCheck, detecting, pose, front, done }
    private var appState: AppState = .lightCheck

    private var confirmationCount = 0
    private let REQUIRED_CONFIRMATIONS = 4

    // MARK: - Camera

    private let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var cameraPosition: AVCaptureDevice.Position = .back
    private let captureQueue = DispatchQueue(label: "posture.capture")
    private let ciContext = CIContext(options: nil)

    // Aspect ratio (height / width) of the upright portrait video. Used to size
    // the preview so it sits at the top of the screen rather than centered.
    private var videoPortraitAspect: CGFloat = 0
    private let previewTopGap: CGFloat = 48

    private var lastImageWidth = 1
    private var lastImageHeight = 1
    private var lastFrameImage: UIImage?
    private var focalLengthPx: Float = 0      // from camera intrinsics; 0 = unknown
    private var fallbackFocalPx: Float = 0    // derived from field of view

    // MARK: - ML

    private var poseLandmarker: PoseLandmarker?
    /// IMAGE-mode hand landmarker — runs once on the captured FRONT still to overlay
    /// finger/palm points. Never runs on live frames. Created when the front phase begins.
    private var handLandmarker: HandLandmarker?
    private var yoloDetector: YoloDetector?

    /// Pose landmarker in IMAGE mode, run once on each captured still. The live
    /// landmarks are smoothed for a steady overlay, so they lag the body; the
    /// measurements come from this fresh, unsmoothed detection instead. Uses the
    /// heavy model when it is bundled, otherwise the full one. It runs after the
    /// live landmarker is released, so it can have the GPU.
    private var stillPoseLandmarker: PoseLandmarker?
    private var stillPoseOnGpu = false
    /// A still detection whose shoulders sit further than this (normalised) from
    /// the live tracking is someone else in the frame; the live pose is used then.
    private let STILL_POSE_MAX_SHIFT: Float = 0.1
    /// The model's raw landmarks for each side shot and the front shot (x, y, z,
    /// visibility per point), sent on with the scan so cutoffs can be re-fitted
    /// later from real data.
    private var capturedRawPoses: [[String: Any]] = []

    /// A captured frame waiting to be processed once every photo is taken: the
    /// clean frame plus the live pose it was captured with (the fallback when the
    /// still detection finds nothing).
    private struct PendingShot {
        let frame: UIImage
        let livePoints: [LandmarkPoint]
        let liveRaw: [RawLandmark]
    }
    private var pendingSideShots: [PendingShot] = []
    private var pendingFrontShot: PendingShot?
    private var frontRawPose: [String: Any]?
    // Last timestamp handed to the pose landmarker (ms); MediaPipe needs them
    // strictly increasing.
    private var lastPoseTimestampMs = 0
    // Frames handed to the (asynchronous) pose landmarker, keyed by the timestamp
    // they were sent with, so a result can be paired with the exact frame it was
    // computed from — the latest camera frame may already be a newer one.
    private var pendingFrames: [Int: UIImage] = [:]
    private let MAX_PENDING_FRAMES = 4

    private let landmarkSmoother = LandmarkSmoother(minCutoff: 0.5, beta: 0.5)
    private let legEstimator = LegEstimator()

    // MARK: - Tilt

    private var tiltMonitor: TiltMonitor!

    // MARK: - Capture sequence

    // The 3 side shots only. The front shot is held separately (frontPhoto).
    private var capturedPhotos: [UIImage] = []
    // Per-side-shot ROSA angles, kept so the shots can be scored *after* the front
    // shot — the front view supplies the armrest-too-wide modifier (elbow abduction).
    private var capturedAngles: [RosaAnglesCalculator.Angles?] = []

    // The front (4th) shot and its two raw measured angles (degrees). These feed the
    // armrest-too-wide / keyboard-deviation modifiers and are also surfaced to Flutter.
    private var frontPhoto: UIImage?
    // Clean (un-blurred, un-annotated) model-sized copies of the side shots,
    // checked for a monitor once all photos are taken (see finishWithCaptures).
    private var sideMonitorFrames: [UIImage] = []
    // Height of the eye-level line in each side photo, as a fraction of the
    // photo's height from the top (the same line that is drawn on the photo).
    // nil when the eye wasn't found. Sent with the monitor's box so the backend
    // can read where the top of the monitor sits relative to eye level.
    private var capturedEyeLevelY: [Float?] = []
    // Nil = could not be measured on the front photo (e.g. no hand found). That is
    // not the same as 0° and must never be scored or reported as "no problem".
    private var frontAbductionAngle: Double?
    private var frontWristDeviationAngle: Double?

    private let TOTAL_SHOTS_NEEDED = 3
    private let CAPTURE_COOLDOWN_MS: Double = 2000
    // Elbow abduction (front-view shoulder→elbow angle from vertical) at or above
    // this many degrees is scored as "armrests too wide / elbows pushed outward".
    private let ARMREST_ABDUCTION_MAX_DEG: Double = 20
    // Wrist bend away from straight (front-view forearm→hand angle deviating from
    // 180°) at or above this many degrees is scored as "wrist deviates while typing".
    private let WRIST_DEVIATION_MAX_DEG: Double = 15
    // Wrist extension (elbow.y - wrist.y, side view) at or above this value is
    // scored as "wrists extended while typing" (C_WRIST_EXT, Action Report v1.3).
    // Reuses RosaScorer's own "elevated risk" keyboard/mouse cutoff as the
    // finding-flag threshold, rather than a new unvalidated number.
    private let WRIST_EXTENSION_FINDING_THRESHOLD: Double = 0.03
    private var nextCaptureEarliestAtMs: Double = 0
    private let SKELETON_REFERENCE_WIDTH: CGFloat = 1080
    // Measured in pixels. 0.26 is the old 0.35 (normalised units) on the 3:4
    // Android frames it was tuned on, so both platforms now accept the same angles.
    private let SIDE_VIEW_THRESHOLD: Float = 0.26

    // ── Front-view (4th) shot ─────────────────────────────────────────────────
    // Captured once face (nose), both shoulders and both wrists clear this
    // visibility bar AND the phone is upright/level. The settle delay stops a
    // premature capture while the holder is still walking the phone to the front.
    private let FRONT_VISIBILITY_THRESHOLD: Float = 0.5
    private let FRONT_READY_DELAY_MS: Double = 1500
    // The front photo is only taken when the person actually faces the camera:
    // shoulder width must be at least this multiple of the nose→shoulder height
    // (both in pixels). Face-on it is roughly 1.4; in the side view the holder
    // starts from it is well under 0.5, so the shot can't fire before they move.
    private let FRONT_FACING_MIN_RATIO: Float = 0.9
    private var frontReadyEarliestAtMs: Double = 0
    // True while the front-photo guide covers the camera after the side photos.
    // Front capture waits until the photographer taps Continue.
    private var frontGuideShowing = false
    private var frontGuideView: UIView?

    // Phone-steadiness gate for the front shot: dynamic acceleration (m/s²) above
    // PHONE_MOTION_MAX counts as movement, and the capture waits until the phone has
    // been quiet for PHONE_STEADY_SETTLE_MS afterwards.
    private let PHONE_MOTION_MAX: Double = 0.8
    private let PHONE_STEADY_SETTLE_MS: Double = 400
    private var lastShakeAtMs: Double = 0
    /// Pose landmark indices omitted in the front view (baked photo and live overlay):
    /// face/eyes/ears/mouth (0...10), wrist/palm (15...22) — the hand landmarker
    /// supplies those on the photo — and legs (25...32).
    private let FRONT_SKELETON_EXCLUDE: Set<Int> = Set(0...10).union(Set(15...22)).union(Set(25...32))

    private var tiltIsOk = false
    private var rotationIsOk = false
    // Stricter roll gate for the front shot: its angles are measured against the
    // image's vertical, so every degree of phone roll is a degree of error.
    private var frontRotationIsOk = false
    private let FRONT_MAX_ROLL_DEG = 5.0
    private var sideIsOk = false
    private var heightIsOk = false
    private var distanceIsOk = false
    // The hold-steady gates are timed, not counted in frames, so a slow phone
    // (few frames per second) doesn't wait several times longer than a fast one.
    private let SIDE_STEADY_MS: Double = 700
    private let FRONT_STEADY_MS: Double = 1000
    // When every capture condition last became true (0 = not currently true).
    private var okSinceMs: Double = 0

    private let MIN_LUMINANCE = 0.25
    private let MAX_LUMINANCE = 0.85

    // MARK: - Colors

    private let colorDetected = UIColor(red: 0x43 / 255, green: 0xA0 / 255, blue: 0x47 / 255, alpha: 1)
    private let colorNotDetected = UIColor(red: 0xE5 / 255, green: 0x39 / 255, blue: 0x35 / 255, alpha: 1)
    private let colorNeutral = UIColor(red: 0x9E / 255, green: 0x9E / 255, blue: 0x9E / 255, alpha: 1)

    // MARK: - Views

    private var overlayView: PoseOverlayView!
    private let levelView = CameraLevelView()
    private var statusStack: UIStackView!
    private let tvLightStatus = UILabel()
    private let tvPersonStatus = UILabel()
    private let tvMonitorStatus = UILabel()
    private let confirmProgress = UIProgressView(progressViewStyle: .default)
    private let tvStatusMessage = UILabel()
    private let tvTiltStatus = UILabel()
    private let tvRotationStatus = UILabel()
    private let tvDistanceStatus = UILabel()
    private let tvSideViewStatus = UILabel()
    private let tvCaptureStatus = UILabel()
    private let flashOverlay = UIView()

    // =========================================================================
    // Lifecycle
    // =========================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        // #181818 — fills the status-bar area and the letterbox around the
        // top-anchored camera preview.
        view.backgroundColor = UIColor(white: 24.0 / 255.0, alpha: 1)
        buildUI()

        tiltMonitor = TiltMonitor { [weak self] tiltAngle, rollAngle, pitchAngle, motion in
            self?.handleTilt(tiltAngle: tiltAngle, rollAngle: rollAngle, pitchAngle: pitchAngle, motion: motion)
        }

        captureQueue.async { [weak self] in
            self?.yoloDetector = YoloDetector()
        }

        updatePanel(lightOk: nil)
        requestCameraPermissionAndStart()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = previewRect()
        previewLayer?.frame = rect
        flashOverlay.frame = rect
        overlayView?.frame = rect
        levelView.bounds = CGRect(x: 0, y: 0, width: 240, height: 220)
        levelView.center = CGPoint(x: rect.midX, y: rect.midY)
    }

    /// The frame for the (aspect-fitted) camera preview and its pose overlay,
    /// anchored to the top of the screen `previewTopGap` points below the safe
    /// area instead of being vertically centered. Until the video aspect ratio
    /// is known it falls back to the full bounds.
    private func previewRect() -> CGRect {
        let topInset = view.safeAreaInsets.top + previewTopGap
        let fullWidth = view.bounds.width
        let availableHeight = view.bounds.height - topInset
        guard videoPortraitAspect > 0, fullWidth > 0, availableHeight > 0 else {
            return view.bounds
        }
        var w = fullWidth
        var h = w * videoPortraitAspect
        if h > availableHeight {
            h = availableHeight
            w = h / videoPortraitAspect
        }
        let x = (view.bounds.width - w) / 2
        return CGRect(x: x, y: topInset, width: w, height: h)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tiltMonitor.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tiltMonitor.stop()
    }

    // =========================================================================
    // Permissions + camera setup
    // =========================================================================

    private func requestCameraPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted { self.setupCamera() }
                    else { self.showToast(self.tr(.cameraPermissionRequired)) }
                }
            }
        default:
            showToast(tr(.cameraPermissionRequired))
        }
    }

    private func setupCamera() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            self.session.inputs.forEach { self.session.removeInput($0) }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: self.cameraPosition),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.showToast(self.tr(.cameraUnavailable)) }
                return
            }
            self.session.addInput(input)
            self.computeFallbackFocal(device: device)

            // Portrait display aspect (height/width). The active format's
            // dimensions are landscape (width >= height); rotated to the portrait
            // connection, the on-screen height/width ratio is width/height.
            let dims = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
            if dims.width > 0 && dims.height > 0 {
                let aspect = CGFloat(dims.width) / CGFloat(dims.height)
                DispatchQueue.main.async {
                    self.videoPortraitAspect = aspect
                    self.view.setNeedsLayout()
                }
            }

            if self.session.outputs.isEmpty {
                self.videoOutput.videoSettings =
                    [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                }
            }

            if let conn = self.videoOutput.connection(with: .video) {
                if conn.isVideoOrientationSupported { conn.videoOrientation = .portrait }
                if conn.isCameraIntrinsicMatrixDeliverySupported {
                    conn.isCameraIntrinsicMatrixDeliveryEnabled = true
                }
                conn.isVideoMirrored = (self.cameraPosition == .front) && conn.isVideoMirroringSupported
            }

            self.session.commitConfiguration()
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    /// Horizontal FOV → focal length in pixels, used when the camera doesn't deliver
    /// an intrinsic matrix. The portrait image height equals the sensor's landscape
    /// width, so the *horizontal* FOV is the right one for the vertical pixel span.
    private func computeFallbackFocal(device: AVCaptureDevice) {
        let hfovDeg = device.activeFormat.videoFieldOfView   // degrees, horizontal
        if hfovDeg > 0 {
            let hfovRad = Float(hfovDeg) * .pi / 180
            // imageHeight (portrait) is filled in per-frame; store the angular term.
            // focalPx = (imageHeightPortrait) / (2 * tan(hfov/2)); applied lazily.
            fallbackFocalPx = 1 / (2 * tan(hfovRad / 2))   // multiply by portrait height
        } else {
            fallbackFocalPx = 0
        }
    }

    private func effectiveFocalPx() -> Float {
        if focalLengthPx > 0 { return focalLengthPx }
        if fallbackFocalPx > 0 { return fallbackFocalPx * Float(lastImageHeight) }
        // last-ditch constant: ~26mm-equiv phone lens on a typical 1080-tall frame
        return Float(lastImageHeight) * 1.2
    }

    private func fullReset() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            self.appState = .lightCheck
            self.confirmationCount = 0
            self.capturedPhotos.removeAll()
            self.capturedAngles.removeAll()
            self.capturedRawPoses.removeAll()
            self.pendingSideShots.removeAll()
            self.pendingFrontShot = nil
            self.frontRawPose = nil
            self.stillPoseLandmarker = nil
            self.frontPhoto = nil
            self.sideMonitorFrames.removeAll()
            self.capturedEyeLevelY.removeAll()
            self.frontAbductionAngle = nil
            self.frontWristDeviationAngle = nil
            self.nextCaptureEarliestAtMs = 0
            self.frontReadyEarliestAtMs = 0
            self.frontGuideShowing = false
            // Views belong to the main thread.
            DispatchQueue.main.async {
                self.frontGuideView?.removeFromSuperview()
                self.frontGuideView = nil
            }
            self.lastFrameImage = nil
            self.pendingFrames.removeAll()
            self.okSinceMs = 0
            self.distanceIsOk = false
            self.poseLandmarker = nil
            self.handLandmarker = nil
            self.landmarkSmoother.reset()
            self.legEstimator.reset()
            self.yoloDetector = YoloDetector()
            if !self.session.isRunning { self.session.startRunning() }
            DispatchQueue.main.async {
                self.tvCaptureStatus.isHidden = true
                self.flashOverlay.isHidden = true
                self.flashOverlay.alpha = 0
                // Restore the condition chips the front phase hides, in case we
                // reset (e.g. camera switch) while in that phase.
                for chip in [self.tvLightStatus, self.tvPersonStatus, self.tvMonitorStatus,
                             self.tvRotationStatus, self.tvTiltStatus, self.tvDistanceStatus] {
                    chip.isHidden = false
                }
                self.overlayView.updateLandmarks([], imgWidth: 1, imgHeight: 1)
                self.overlayView.setHeightGuide(.hidden)
                self.overlayView.setExcludedIndices([])
                self.overlayView.setShowShoulderAngles(false)
                self.overlayView.updateRosaAngles(nil)
                self.updatePanel(lightOk: nil)
            }
        }
    }

    // =========================================================================
    // Pose landmarker
    // =========================================================================

    private func initializePoseLandmarker() {
        guard let modelPath = Bundle.main.path(forResource: "pose_landmarker_full", ofType: "task") else {
            NSLog("pose_landmarker_full.task not found in bundle")
            return
        }
        let options = PoseLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .liveStream
        options.numPoses = 1
        options.poseLandmarkerLiveStreamDelegate = self
        do {
            poseLandmarker = try PoseLandmarker(options: options)
        } catch {
            NSLog("Failed to create PoseLandmarker: \(error)")
        }
    }

    /// Creates the IMAGE-mode pose landmarker used on captured stills: the heavy
    /// model if bundled, else the full one; on the GPU when `allowGpu` and it is
    /// supported, else the CPU. Without it, captures use the live pose.
    private func initializeStillPoseLandmarker(allowGpu: Bool = true) {
        if stillPoseLandmarker != nil { return }
        let delegates: [Delegate] = allowGpu ? [.GPU, .CPU] : [.CPU]
        for model in ["pose_landmarker_heavy", "pose_landmarker_full"] {
            guard let path = Bundle.main.path(forResource: model, ofType: "task") else { continue }
            for delegate in delegates {
                let options = PoseLandmarkerOptions()
                options.baseOptions.modelAssetPath = path
                options.baseOptions.delegate = delegate
                options.runningMode = .image
                options.numPoses = 1
                do {
                    stillPoseLandmarker = try PoseLandmarker(options: options)
                    stillPoseOnGpu = delegate == .GPU
                    NSLog("Still-image pose model: \(model), GPU: \(stillPoseOnGpu)")
                    return
                } catch {
                    NSLog("Still-image pose model \(model) unavailable: \(error)")
                }
            }
        }
    }

    /// Re-detects the pose on a captured still. Nil when the landmarker isn't
    /// available, finds nobody, or finds someone other than the person the live
    /// tracking (`live`) is following.
    private func detectStillPose(_ frame: UIImage, live: [RawLandmark]) -> [RawLandmark]? {
        guard let mpImage = try? MPImage(uiImage: frame) else { return nil }
        var result = try? stillPoseLandmarker?.detect(image: mpImage)
        if result == nil && stillPoseOnGpu {
            // A GPU delegate can load and still fail at run time: retry on CPU.
            stillPoseLandmarker = nil
            initializeStillPoseLandmarker(allowGpu: false)
            result = try? stillPoseLandmarker?.detect(image: mpImage)
        }
        guard let pose = result?.landmarks.first, pose.count >= 33 else { return nil }
        let still = pose.map {
            RawLandmark(x: $0.x, y: $0.y, visibility: $0.visibility?.floatValue, z: $0.z)
        }
        if live.count >= 13 {
            let dx = (still[11].x + still[12].x - live[11].x - live[12].x) / 2
            let dy = (still[11].y + still[12].y - live[11].y - live[12].y) / 2
            if hypotf(dx, dy) > STILL_POSE_MAX_SHIFT { return nil }
        }
        return still
    }

    /// Every photo is taken: stop the camera and process the photos behind a
    /// loading message. Called on captureQueue.
    private func finishCapturing() {
        appState = .done
        pauseCameraPipeline()
        DispatchQueue.main.async {
            self.triggerCaptureFlash()
            self.tvCaptureStatus.isHidden = false
            self.tvCaptureStatus.text = self.tr(.processingPhotos)
        }
        // Queued behind this callback, after the live landmarker is released.
        captureQueue.async { [weak self] in self?.processCaptures() }
    }

    /// Turns the captured frames into the final photos and measurements: re-detects
    /// the pose on each still, blurs the face, bakes the skeleton, measures the
    /// angles and scores the scan. Runs on captureQueue after the camera stops.
    private func processCaptures() {
        initializeStillPoseLandmarker()

        for shot in pendingSideShots {
            let frame = shot.frame
            let w = frame.cgImage?.width ?? 1
            let h = frame.cgImage?.height ?? 1
            // Measure from a fresh detection on this exact still; the smoothed
            // live pose is only the fallback.
            let still = detectStillPose(frame, live: shot.liveRaw)
            let captured: [LandmarkPoint]
            if let still = still {
                captured = legEstimator.estimate(
                    raw: still, smoothed: still.map { LandmarkPoint(x: $0.x, y: $0.y) },
                    aspect: Float(w) / Float(max(h, 1)))
            } else {
                captured = shot.livePoints
            }
            capturedRawPoses.append(rawPoseRecord(
                still ?? shot.liveRaw, width: w, height: h, fromStill: still != nil))
            sideMonitorFrames.append(YoloDetector.thumbnail(frame))
            let blurred = FaceBlurrer.blurFace(frame, landmarks: captured)
            // Every shot of a scan measures the same body side.
            let lockedSide = capturedAngles.compactMap { $0 }.first?.isLeftSide
            let angles = RosaAnglesCalculator.compute(captured, imageWidth: w, imageHeight: h,
                                                      forceLeft: lockedSide)
            capturedPhotos.append(bakeSkeletonOntoPhoto(blurred, landmarks: captured, angles: angles))
            capturedAngles.append(angles)
            // Same landmark the eye-level line is drawn through (drawAngles).
            var eyeLevelY: Float? = nil
            if let angles = angles {
                let eyeIndex = angles.isLeftSide ? 2 : 5
                if captured.indices.contains(eyeIndex) {
                    let y = captured[eyeIndex].y
                    if y >= 0 && y <= 1 { eyeLevelY = y }
                }
            }
            capturedEyeLevelY.append(eyeLevelY)
        }

        // Armrest-too-wide and wrist-deviation are measured on the front photo and
        // applied to every side shot's score. Without a front photo the
        // questionnaire answers (already in workstationModifiers) stand.
        var mods = workstationModifiers
        if let shot = pendingFrontShot {
            let frame = shot.frame
            let wPx = frame.cgImage?.width ?? 1
            let hPx = frame.cgImage?.height ?? 1
            // A still fit that is upside down (see isUprightFrontPose) is discarded;
            // the live pose that passed the capture check is used instead.
            let still = detectStillPose(frame, live: shot.liveRaw).flatMap { s in
                isUprightFrontPose(s.map { LandmarkPoint(x: $0.x, y: $0.y) }) ? s : nil
            }
            let captured = still?.map { LandmarkPoint(x: $0.x, y: $0.y) } ?? shot.livePoints
            frontRawPose = rawPoseRecord(still ?? shot.liveRaw, width: wPx, height: hPx,
                                         fromStill: still != nil)
            // Detect hands on the clean frame, then draw them on the baked photo.
            let handResult = detectHands(frame)
            let blurred = FaceBlurrer.blurFace(frame, landmarks: captured,
                                                 downscale: FaceBlurrer.FRONT_DOWNSCALE_FACTOR)
            // Front view is upper-body only: no legs (25+), no face/ear points
            // (0...10, the face is blurred) and no pose wrist/palm points
            // (15...22) — the hand landmarker supplies those, and the elbow is
            // joined straight to the hand's point 0.
            let baked = bakeSkeletonOntoPhoto(blurred, landmarks: Array(captured.prefix(25)),
                                              angles: nil, excludeIndices: FRONT_SKELETON_EXCLUDE)
            let withHands = drawHandsOntoPhoto(baked, handResult, poseLandmarks: captured)
            frontPhoto = drawShoulderAnglesOntoPhoto(withHands, poseLandmarks: captured)

            let w = CGFloat(wPx), h = CGFloat(hPx)
            let abduction = frontAbductionAngleDeg(captured, width: w, height: h)
            let wristDeviation = frontWristDeviationDeg(
                handsToPoints(handResult), poseLandmarks: captured, width: w, height: h)
            frontAbductionAngle = abduction
            frontWristDeviationAngle = wristDeviation
            // A measurement that couldn't be taken (e.g. no hand found) keeps the
            // questionnaire answer instead of being scored as "no problem".
            if let a = abduction { mods.armrestTooWide = a >= ARMREST_ABDUCTION_MAX_DEG }
            if let d = wristDeviation { mods.keyboardDeviation = d >= WRIST_DEVIATION_MAX_DEG }
        }

        let scores = capturedAngles.map { $0 != nil ? RosaScorer.score($0!, mods: mods) : nil }
        let sidePhotos = capturedPhotos
        stillPoseLandmarker = nil
        handLandmarker = nil
        pendingSideShots.removeAll()
        pendingFrontShot = nil
        DispatchQueue.main.async {
            self.finishWithCaptures(sidePhotos, scores: scores)
        }
    }

    /// The raw landmarks of one shot, in the shape sent on to Flutter.
    private func rawPoseRecord(_ landmarks: [RawLandmark], width: Int, height: Int,
                               fromStill: Bool) -> [String: Any] {
        [
            "landmarks": landmarks.map {
                [Double($0.x), Double($0.y), Double($0.z), Double($0.visibility ?? 0)]
            },
            "image_width": width,
            "image_height": height,
            "source": fromStill ? "still" : "live",
        ]
    }

    /// Creates the IMAGE-mode hand landmarker if not already created. Only ever runs
    /// once, on a single still, so it stays on CPU to avoid GPU contention with pose.
    private func initializeHandLandmarker() {
        if handLandmarker != nil { return }
        guard let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") else {
            NSLog("hand_landmarker.task not found in bundle")
            return
        }
        let options = HandLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .image
        options.numHands = 2
        do {
            handLandmarker = try HandLandmarker(options: options)
        } catch {
            NSLog("Failed to create HandLandmarker: \(error)")
        }
    }

    // =========================================================================
    // Frame analysis  (runs on captureQueue via the delegate)
    // =========================================================================

    fileprivate func analyze(sampleBuffer: CMSampleBuffer) {
        // The front-photo guide covers the camera: drop frames without running
        // the pose model. The session stays running so front capture can start
        // straight away after Continue.
        if frontGuideShowing { return }
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        readIntrinsics(from: sampleBuffer)

        switch appState {
        case .lightCheck: runLightCheckPhase(pb)
        case .detecting: runDetectionPhase(pb)
        // FRONT also needs live pose frames, so it shares the pose pipeline.
        case .pose, .front:
            runPosePhase(pb, presentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        case .done:
            break
        }
    }

    private func readIntrinsics(from sampleBuffer: CMSampleBuffer) {
        guard let raw = CMGetAttachment(sampleBuffer,
                                        key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix,
                                        attachmentModeOut: nil) as? Data,
              raw.count >= MemoryLayout<matrix_float3x3>.size else { return }
        // Copy into an aligned value — `Data`'s storage isn't guaranteed to meet
        // matrix_float3x3's 16-byte alignment, so a direct `load(as:)` can trap.
        var m = matrix_float3x3()
        _ = withUnsafeMutableBytes(of: &m) { raw.copyBytes(to: $0, count: MemoryLayout<matrix_float3x3>.size) }
        // Column-major: columns.0 = (fx, 0, 0). The intrinsics describe the
        // landscape sensor; fx is the focal length along the axis that becomes the
        // portrait image's vertical, which is exactly what the distance math wants.
        focalLengthPx = m.columns.0.x
    }

    // -------------------------------------------------------------------------
    // Phase 1: Light check
    // -------------------------------------------------------------------------

    private func runLightCheckPhase(_ pb: CVPixelBuffer) {
        let luminance = computeLuminance(pb)
        if luminance < MIN_LUMINANCE {
            DispatchQueue.main.async {
                self.updatePanel(lightOk: false, message: self.tr(.lightTooDark))
            }
        } else if luminance > MAX_LUMINANCE {
            DispatchQueue.main.async {
                self.updatePanel(lightOk: false, message: self.tr(.lightTooBright))
            }
        } else {
            appState = .detecting
            DispatchQueue.main.async { self.updatePanel(lightOk: true) }
        }
    }

    // Average a strided sample of luma over the BGRA buffer — analogue of the
    // Android Y-plane average, every 20th pixel.
    private func computeLuminance(_ pb: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(pb, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pb) else { return 0.5 }
        let ptr = base.assumingMemoryBound(to: UInt8.self)
        let width = CVPixelBufferGetWidth(pb)
        let height = CVPixelBufferGetHeight(pb)
        let rowStride = CVPixelBufferGetBytesPerRow(pb)
        let step = 20
        var sum: Double = 0
        var count = 0
        var row = 0
        while row < height {
            var col = 0
            while col < width {
                let p = row * rowStride + col * 4
                let b = Double(ptr[p + 0]), g = Double(ptr[p + 1]), r = Double(ptr[p + 2])
                sum += 0.299 * r + 0.587 * g + 0.114 * b
                count += 1
                col += step
            }
            row += step
        }
        return count == 0 ? 0.5 : (sum / Double(count)) / 255.0
    }

    // -------------------------------------------------------------------------
    // Phase 2: YOLO detection
    // -------------------------------------------------------------------------

    private func runDetectionPhase(_ pb: CVPixelBuffer) {
        guard let result = yoloDetector?.detect(pixelBuffer: pb) else { return }

        if result.personDetected && result.monitorDetected {
            confirmationCount += 1
            if confirmationCount >= REQUIRED_CONFIRMATIONS {
                DispatchQueue.main.async {
                    self.updatePanel(lightOk: true, personDetected: true, monitorDetected: true,
                                     confirmCount: self.REQUIRED_CONFIRMATIONS, message: self.tr(.loading))
                }
                initializePoseLandmarker()
                appState = .pose
                yoloDetector = nil
                DispatchQueue.main.async {
                    // Entering pose phase: keep the condition list visible but
                    // clear the detection-only progress bar and message.
                    self.confirmProgress.isHidden = true
                    self.tvStatusMessage.isHidden = true
                }
            } else {
                let c = confirmationCount
                DispatchQueue.main.async {
                    self.updatePanel(lightOk: true, personDetected: true, monitorDetected: true,
                                     confirmCount: c, message: self.tr(.holdStill))
                }
            }
        } else {
            confirmationCount = 0
            let p = result.personDetected, m = result.monitorDetected
            DispatchQueue.main.async {
                self.updatePanel(lightOk: true, personDetected: p, monitorDetected: m, confirmCount: 0)
            }
        }
    }

    // -------------------------------------------------------------------------
    // Phase 3: Pose detection
    // -------------------------------------------------------------------------

    private func runPosePhase(_ pb: CVPixelBuffer, presentationTime: CMTime) {
        // The buffer is already upright (portrait connection) and front-mirrored if
        // needed, so no rotation/flip is required here — unlike the Android path.
        guard let cg = ciContext.createCGImage(CIImage(cvPixelBuffer: pb),
                                               from: CGRect(x: 0, y: 0,
                                                            width: CVPixelBufferGetWidth(pb),
                                                            height: CVPixelBufferGetHeight(pb))) else { return }
        let image = UIImage(cgImage: cg)
        lastImageWidth = cg.width
        lastImageHeight = cg.height
        lastFrameImage = image

        guard let landmarker = poseLandmarker, let mpImage = try? MPImage(uiImage: image) else { return }
        // The frame's real capture time, kept strictly increasing for MediaPipe.
        let seconds = CMTimeGetSeconds(presentationTime)
        let frameMs = seconds.isFinite ? Int((seconds * 1000).rounded()) : 0
        let timestampMs = max(frameMs, lastPoseTimestampMs + 1)
        lastPoseTimestampMs = timestampMs

        // Results for dropped frames never arrive, so cap what is held.
        if pendingFrames.count >= MAX_PENDING_FRAMES, let oldest = pendingFrames.keys.min() {
            pendingFrames.removeValue(forKey: oldest)
        }
        pendingFrames[timestampMs] = image
        do {
            try landmarker.detectAsync(image: mpImage, timestampInMilliseconds: timestampMs)
        } catch {
            pendingFrames.removeValue(forKey: timestampMs)
            NSLog("detectAsync failed: \(error)")
        }
    }

    // Funnelled from the MediaPipe callback onto captureQueue.
    private func handlePoseResult(_ result: PoseLandmarkerResult?, timestampMs: Int) {
        let currentState = appState
        // The frame this result was computed from, so the baked skeleton and the
        // face blur line up with the pixels they were measured on.
        let frameImage = pendingFrames[timestampMs] ?? lastFrameImage
        pendingFrames = pendingFrames.filter { $0.key > timestampMs }
        let w = frameImage?.cgImage?.width ?? lastImageWidth
        let h = frameImage?.cgImage?.height ?? lastImageHeight
        // Wall clock for the capture gates; frame time for the smoother, so its
        // velocity estimate isn't skewed by inference jitter.
        let tSec = CACurrentMediaTime()
        let frameSec = Double(timestampMs) / 1000

        let rawLandmarks: [RawLandmark]
        if let pose = result?.landmarks.first {
            rawLandmarks = pose.map { RawLandmark(x: $0.x, y: $0.y, visibility: $0.visibility?.floatValue, z: $0.z) }
        } else {
            rawLandmarks = []
        }

        let sm: [LandmarkPoint]?
        if rawLandmarks.isEmpty {
            landmarkSmoother.reset()
            sm = nil
        } else {
            sm = landmarkSmoother.smooth(rawLandmarks, timestampSec: frameSec)
        }

        let sideOk = sm != nil && currentState == .pose && checkSideView(sm!, width: w, height: h)
        sideIsOk = sideOk

        let smoothed: [LandmarkPoint]
        if let sm = sm {
            smoothed = sideOk ? legEstimator.estimate(raw: rawLandmarks, smoothed: sm, aspect: Float(w) / Float(max(h, 1))) : sm
        } else {
            smoothed = []
        }

        // ── Continuous side view + height guide ───────────────────────────────
        if currentState == .pose {
            let guideState: PoseOverlayView.HeightGuideState
            if tiltIsOk && rotationIsOk {
                let shoulderY = smoothed.count >= 13 ? (smoothed[11].y + smoothed[12].y) / 2 : -1
                heightIsOk = shoulderY >= 0.43 && shoulderY <= 0.57
                if shoulderY < 0 { guideState = .hidden }
                else if shoulderY > 0.57 { guideState = .tooHigh }
                else if shoulderY < 0.43 { guideState = .tooLow }
                else { guideState = .ok }
            } else {
                heightIsOk = false
                guideState = .hidden
            }
            DispatchQueue.main.async {
                self.tvSideViewStatus.textColor = sideOk ? self.colorDetected : self.colorNotDetected
                self.tvSideViewStatus.text = self.tr(sideOk ? .chipSideOk : .chipSideAdjust)
                self.overlayView.setHeightGuide(guideState)
            }
        }

        // ── Multi-shot capture sequence ───────────────────────────────────────
        // The phone must also be still, so the shot isn't motion-blurred.
        let sidePhoneSteady = tSec * 1000 - lastShakeAtMs >= PHONE_STEADY_SETTLE_MS
        let allOk = sideOk && tiltIsOk && rotationIsOk && heightIsOk && distanceIsOk && sidePhoneSteady
        let capturing = currentState == .pose && pendingSideShots.count < TOTAL_SHOTS_NEEDED
        if capturing { DispatchQueue.main.async { self.updateCaptureCue(allOk: allOk) } }

        if capturing && allOk {
            let nowMs = tSec * 1000
            if okSinceMs == 0 { okSinceMs = nowMs }
            if nowMs - okSinceMs >= SIDE_STEADY_MS && nowMs >= nextCaptureEarliestAtMs {
                okSinceMs = 0
                if let frame = frameImage {
                    // Only the clean frame and the live pose are kept here. The
                    // photos are measured and drawn after the last shot
                    // (processCaptures), so the camera never stalls between shots.
                    pendingSideShots.append(PendingShot(frame: frame, livePoints: smoothed,
                                                        liveRaw: rawLandmarks))
                    nextCaptureEarliestAtMs = nowMs + CAPTURE_COOLDOWN_MS
                    let shotNumber = pendingSideShots.count
                    if shotNumber >= TOTAL_SHOTS_NEEDED && !frontPhotoAvailable {
                        // No front photo possible — finish now; scoring uses the
                        // questionnaire's armrest-width / wrist-deviation answers
                        // (already in workstationModifiers).
                        finishCapturing()
                    } else if shotNumber >= TOTAL_SHOTS_NEEDED {
                        // Side shots done — switch to the front-view phase instead
                        // of finishing. (handlePoseResult runs on captureQueue, so
                        // the smoother/leg-estimator resets in enterFrontPhase are
                        // serialized with frame analysis.)
                        enterFrontPhase()
                        DispatchQueue.main.async { self.triggerCaptureFlash() }
                    } else {
                        DispatchQueue.main.async {
                            self.triggerCaptureFlash()
                            self.updateCaptureCue(allOk: true)
                        }
                    }
                }
            }
        } else if capturing {
            okSinceMs = 0
        }

        // ── Front-view capture (4th shot, after the 3 side shots) ──────────────
        // Condition: face/shoulders/hands visible. No tilt/level gate — the front
        // shot doesn't need the phone held perfectly upright. Uses the raw
        // (un-leg-estimated) smoothed landmarks and bakes the skeleton with no
        // ROSA arcs. The photo carries no score.
        if currentState == .front && !frontGuideShowing {
            let frontVisible = frontLandmarksVisible(rawLandmarks)
            let nowMs = tSec * 1000
            let phoneSteady = nowMs - lastShakeAtMs >= PHONE_STEADY_SETTLE_MS
            let frontFacing = isFacingCamera(smoothed, width: w, height: h)
            let frontUpright = isUprightFrontPose(smoothed)
            let rotationOk = frontRotationIsOk
            let frontOk = frontVisible && frontUpright && frontFacing && rotationOk && phoneSteady
            DispatchQueue.main.async {
                self.updateFrontCue(frontVisible: frontVisible, frontUpright: frontUpright,
                                    frontFacing: frontFacing,
                                    rotationOk: rotationOk, phoneSteady: phoneSteady)
            }
            if frontOk && nowMs >= frontReadyEarliestAtMs {
                // Capture once the condition has held for FRONT_STEADY_MS past
                // the entry settle.
                if okSinceMs == 0 { okSinceMs = nowMs }
                if nowMs - okSinceMs >= FRONT_STEADY_MS {
                    okSinceMs = 0
                    if let frame = frameImage {
                        pendingFrontShot = PendingShot(frame: frame, livePoints: smoothed,
                                                       liveRaw: rawLandmarks)
                        finishCapturing()
                    }
                }
            } else {
                // Visibility dropped (or still in the entry settle) — reset the count.
                okSinceMs = 0
            }
        }

        // ── Distance ──────────────────────────────────────────────────────────
        let distanceM: Float?
        if currentState == .pose && smoothed.count >= 25 {
            let hipMidY = (smoothed[23].y + smoothed[24].y) / 2
            distanceM = DistanceEstimator.estimate(noseY: smoothed[0].y, hipMidY: hipMidY,
                                                    imageHeightPx: h, focalLengthPx: effectiveFocalPx())
        } else {
            distanceM = nil
        }

        let rosaAngles = (currentState == .pose && smoothed.count >= 29)
            ? RosaAnglesCalculator.compute(smoothed, imageWidth: w, imageHeight: h) : nil

        distanceIsOk = distanceM != nil && distanceM! >= 1.7 && distanceM! <= 2.1

        let capturedSnapshot = smoothed
        DispatchQueue.main.async {
            self.overlayView.updateLandmarks(capturedSnapshot, imgWidth: w, imgHeight: h)
            self.overlayView.updateRosaAngles(rosaAngles)
            if let d = distanceM {
                let dOk = d >= 1.7 && d <= 2.1
                let key: CaptureStrings.Key = d < 1.7 ? .chipDistanceTooClose
                    : (d > 2.1 ? .chipDistanceTooFar : .chipDistanceOk)
                self.tvDistanceStatus.text = self.tr(key, ["value": String(format: "%.2f", d)])
                self.tvDistanceStatus.textColor = dOk ? self.colorDetected : self.colorNotDetected
            } else {
                self.tvDistanceStatus.text = self.tr(.chipDistanceIdle)
                self.tvDistanceStatus.textColor = self.colorNeutral
            }
        }
    }

    private func pauseCameraPipeline() {
        session.stopRunning()
        poseLandmarker = nil
        pendingFrames.removeAll()
    }

    // =========================================================================
    // Side view check
    // =========================================================================

    private func checkSideView(_ smoothed: [LandmarkPoint], width: Int, height: Int) -> Bool {
        if smoothed.count < 25 { return false }
        let lHip = smoothed[23], rHip = smoothed[24]
        let lShoulder = smoothed[11], rShoulder = smoothed[12]
        let torsoH = abs((lShoulder.y + rShoulder.y) / 2 - (lHip.y + rHip.y) / 2) * Float(height)
        if torsoH < 1 { return false }
        return abs(lHip.x - rHip.x) * Float(width) / torsoH < SIDE_VIEW_THRESHOLD
    }

    // =========================================================================
    // Tilt
    // =========================================================================

    private func handleTilt(tiltAngle: Double, rollAngle: Double, pitchAngle: Double, motion: Double) {
        let tOk = TiltMonitor.isTiltAcceptable(tiltAngle)
        let rOk = TiltMonitor.isRollAcceptable(rollAngle)
        captureQueue.async {
            self.tiltIsOk = tOk
            self.rotationIsOk = rOk
            self.frontRotationIsOk = abs(rollAngle) <= self.FRONT_MAX_ROLL_DEG
            // Latch the last time the phone was moved/shaken; the front capture waits
            // for a quiet window after this before firing.
            if motion > self.PHONE_MOTION_MAX { self.lastShakeAtMs = CACurrentMediaTime() * 1000 }
        }
        levelView.update(roll: rollAngle, pitch: pitchAngle)
        tvTiltStatus.textColor = tOk ? colorDetected : colorNotDetected
        tvTiltStatus.text = tr(tOk ? .chipTiltOk : .chipTiltBad,
                               ["value": String(format: "%.1f", tiltAngle)])
        tvRotationStatus.textColor = rOk ? colorDetected : colorNotDetected
        tvRotationStatus.text = rOk ? tr(.chipRotationOk)
                                    : tr(.chipRotationBad, ["value": String(format: "%.1f", abs(rollAngle))])
    }

    // =========================================================================
    // Capture: baking + finishing
    // =========================================================================

    private func bakeSkeletonOntoPhoto(_ photo: UIImage,
                                       landmarks: [LandmarkPoint],
                                       angles: RosaAnglesCalculator.Angles?,
                                       excludeIndices: Set<Int> = []) -> UIImage {
        guard let cg = photo.cgImage else { return photo }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let bakeScale = w / SKELETON_REFERENCE_WIDTH

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        return renderer.image { rctx in
            let ctx = rctx.cgContext
            photo.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            PoseRenderer.drawScene(in: ctx, landmarks: landmarks, angles: angles,
                                   sx: { CGFloat($0) * w }, sy: { CGFloat($0) * h }, scale: bakeScale,
                                   exclude: excludeIndices)
        }
    }

    /// Runs the hand landmarker on a single still (IMAGE mode). Returns nil if the
    /// landmarker isn't available or detection fails — the overlay is then skipped.
    private func detectHands(_ image: UIImage) -> HandLandmarkerResult? {
        guard let hl = handLandmarker, let mpImage = try? MPImage(uiImage: image) else { return nil }
        do {
            return try hl.detect(image: mpImage)
        } catch {
            NSLog("HandLandmarker detect failed: \(error)")
            return nil
        }
    }

    /// Converts a hand-landmarker result into normalised `LandmarkPoint` lists (one
    /// per hand), the shape both the live overlay and the baked photo render.
    private func handsToPoints(_ result: HandLandmarkerResult?) -> [[LandmarkPoint]] {
        guard let hands = result?.landmarks else { return [] }
        return hands.map { hand in hand.map { LandmarkPoint(x: $0.x, y: $0.y) } }
    }

    /// Draws the detected hands onto the photo via the shared renderer — same white
    /// lines / green dots as the body skeleton, with each wrist joined to its nearest
    /// elbow. `poseLandmarks` supplies the elbows. Returns the photo unchanged if no
    /// hands found.
    private func drawHandsOntoPhoto(_ photo: UIImage, _ result: HandLandmarkerResult?,
                                    poseLandmarks: [LandmarkPoint]) -> UIImage {
        let hands = handsToPoints(result)
        guard !hands.isEmpty, let cg = photo.cgImage else { return photo }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let bakeScale = w / SKELETON_REFERENCE_WIDTH

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        return renderer.image { rctx in
            let ctx = rctx.cgContext
            photo.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            PoseRenderer.drawHands(in: ctx, hands: hands, poseLandmarks: poseLandmarks,
                                   sx: { CGFloat($0) * w }, sy: { CGFloat($0) * h }, scale: bakeScale)
        }
    }

    /// Bakes the front-view shoulder verticals + shoulder→elbow angle onto the photo.
    private func drawShoulderAnglesOntoPhoto(_ photo: UIImage, poseLandmarks: [LandmarkPoint]) -> UIImage {
        guard let cg = photo.cgImage else { return photo }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let bakeScale = w / SKELETON_REFERENCE_WIDTH

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        return renderer.image { rctx in
            let ctx = rctx.cgContext
            photo.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            PoseRenderer.drawShoulderVerticals(in: ctx, landmarks: poseLandmarks,
                                               sx: { CGFloat($0) * w }, sy: { CGFloat($0) * h }, scale: bakeScale)
        }
    }

    /// Writes the captured photos and hands the whole capture back to Flutter, grouped
    /// as `side_captures` (image + score + angles per side shot) and one `front_capture`
    /// (image + the two raw front-view angles). All keys snake_case.
    private func finishWithCaptures(_ sidePhotos: [UIImage], scores: [RosaScorer.Result?]) {
        // Before the review screen, run the monitor detector again on each side
        // photo and record whether it finds a monitor in it. The live
        // detector was released after the detection phase, so load it once
        // here, off the main thread. A failed check leaves the value out.
        tvCaptureStatus.isHidden = false
        tvCaptureStatus.text = tr(.checkingPhotos)
        let sideFrames = sideMonitorFrames
        DispatchQueue.global(qos: .userInitiated).async {
            let detector = YoloDetector()
            func check(_ frame: UIImage) -> YoloResult? {
                guard let detector = detector else { return nil }
                return detector.detect(image: frame)
            }
            let results = sideFrames.map { check($0) }
            let sideMonitor: [Bool?] = results.map { $0?.monitorDetected }
            let sideBoxes: [MonitorBox?] = results.map { $0?.monitorBox }
            // Draw the monitor's box (split into three bands) on each side photo,
            // next to the eye-level line already on it.
            var photos = sidePhotos
            for i in photos.indices {
                if i < sideBoxes.count, let box = sideBoxes[i] {
                    photos[i] = self.drawMonitorBoxOntoPhoto(photos[i], box: box)
                }
            }
            DispatchQueue.main.async {
                self.writeCaptures(photos, scores: scores, sideMonitor: sideMonitor,
                                   sideBoxes: sideBoxes)
            }
        }
    }

    /// Draws the detected monitor's bounding box on a side photo, split into
    /// three equal horizontal bands. Together with the eye-level line this shows
    /// where the top of the monitor sits relative to the eyes: the line over the
    /// box (monitor below eye level), in the top band (at eye level), or lower
    /// (monitor above eye level).
    private func drawMonitorBoxOntoPhoto(_ photo: UIImage, box: MonitorBox) -> UIImage {
        guard let cg = photo.cgImage else { return photo }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let scale = w / SKELETON_REFERENCE_WIDTH

        let rect = CGRect(x: CGFloat(box.left) * w, y: CGFloat(box.top) * h,
                          width: CGFloat(box.right - box.left) * w,
                          height: CGFloat(box.bottom - box.top) * h)
        guard rect.width >= 2, rect.height >= 2 else { return photo }

        let color = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        return renderer.image { rctx in
            let ctx = rctx.cgContext
            photo.draw(in: CGRect(x: 0, y: 0, width: w, height: h))

            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(4 * scale)
            ctx.stroke(rect)

            ctx.setLineWidth(2.5 * scale)
            ctx.setLineDash(phase: 0, lengths: [14 * scale, 10 * scale])
            let third = rect.height / 3
            for k in 1...2 {
                let y = rect.minY + third * CGFloat(k)
                ctx.move(to: CGPoint(x: rect.minX, y: y))
                ctx.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
            ctx.strokePath()
            ctx.setLineDash(phase: 0, lengths: [])

            let fontSize = 30 * scale
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowBlurRadius = 4 * scale
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                .foregroundColor: color,
                .shadow: shadow,
            ]
            // Above the box when there is room, otherwise just inside its top edge.
            let labelY = rect.minY > fontSize * 1.4
                ? rect.minY - fontSize * 1.3
                : rect.minY + fontSize * 0.2
            ("Monitor" as NSString).draw(at: CGPoint(x: rect.minX + 6 * scale, y: labelY),
                                         withAttributes: attributes)
        }
    }

    private func writeCaptures(_ sidePhotos: [UIImage], scores: [RosaScorer.Result?],
                               sideMonitor: [Bool?], sideBoxes: [MonitorBox?]) {
        let dir = (NSTemporaryDirectory() as NSString).appendingPathComponent("posture_photos")
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        func write(_ image: UIImage, _ name: String) -> String? {
            let path = (dir as NSString).appendingPathComponent(name)
            guard let data = image.jpegData(compressionQuality: 0.92) else { return nil }
            try? data.write(to: URL(fileURLWithPath: path))
            return path
        }

        // The front camera's frames are mirrored before pose detection, which swaps
        // the model's left/right labels relative to the person's real body side.
        let mirrored = cameraPosition == .front

        var sideCaptures: [[String: Any]] = []
        for (i, photo) in sidePhotos.enumerated() {
            var obj: [String: Any] = [
                "rosa_score": scores.indices.contains(i) ? (scores[i]?.toMap() ?? [:]) : [:],
                "body_angles": capturedAngles.indices.contains(i)
                    ? (capturedAngles[i]?.toMap(mirrored: mirrored) ?? [:]) : [:],
            ]
            if let path = write(photo, "side_\(i + 1).jpg") { obj["image_path"] = path }
            if capturedRawPoses.indices.contains(i) { obj["raw_pose"] = capturedRawPoses[i] }
            if i < sideMonitor.count, let seen = sideMonitor[i] { obj["monitor_detected"] = seen }
            // Fractions of the photo. The backend derives "top of the monitor
            // relative to eye level" from these two, so the rule lives in one
            // place for both platforms.
            if i < sideBoxes.count, let box = sideBoxes[i] {
                obj["monitor_box"] = [
                    "left": Double(box.left), "top": Double(box.top),
                    "right": Double(box.right), "bottom": Double(box.bottom),
                ]
            }
            if i < capturedEyeLevelY.count, let eyeY = capturedEyeLevelY[i] {
                obj["eye_level_y"] = Double(eyeY)
            }
            sideCaptures.append(obj)
        }

        // wristExtension / shrugGap are measured per side-view shot (not the front
        // view) but were never surfaced (RosaAnglesCalculator.Angles doc comment).
        // Use the first valid side-shot's reading, same "first with data" choice
        // Flutter already makes for body_angles (BodyAngles.firstWithData).
        // The median of the side shots, so one odd frame doesn't decide it.
        func median(_ values: [Float]) -> Float {
            if values.isEmpty { return 0 }
            let s = values.sorted()
            return s.count % 2 == 1 ? s[s.count / 2] : (s[s.count / 2 - 1] + s[s.count / 2]) / 2
        }
        let measured = capturedAngles.compactMap { $0 }
        let wristExtensionFinding =
            median(measured.map { $0.wristExtension }) >= Float(WRIST_EXTENSION_FINDING_THRESHOLD)
        let shrugGapValue = Double(median(measured.map { $0.shrugGap }))

        var frontCapture: [String: Any] = [
            "wrist_extension": wristExtensionFinding,
            "shrug_gap": shrugGapValue,
        ]
        // Left out when it couldn't be measured — never reported as 0°.
        if let a = frontAbductionAngle { frontCapture["abduction_angle"] = a }
        if let d = frontWristDeviationAngle { frontCapture["wrist_deviation_angle"] = d }
        if let raw = frontRawPose { frontCapture["raw_pose"] = raw }
        if let front = frontPhoto, let path = write(front, "front.jpg") {
            frontCapture["image_path"] = path
        }

        // No front photo (skipped) → omit front_capture entirely; Flutter and the
        // backend both treat it as optional.
        var result: [String: Any] = ["side_captures": sideCaptures]
        if frontPhoto != nil { result["front_capture"] = frontCapture }
        finish(with: result)
    }

    private func finish(with result: [String: Any]?) {
        let completion = onComplete
        onComplete = nil
        dismiss(animated: true) { completion?(result) }
    }

    // =========================================================================
    // Capture cues
    // =========================================================================

    private func triggerCaptureFlash() {
        flashOverlay.isHidden = false
        flashOverlay.alpha = 1
        UIView.animate(withDuration: 0.35, animations: { self.flashOverlay.alpha = 0 },
                       completion: { _ in self.flashOverlay.isHidden = true })
    }

    private func updateCaptureCue(allOk: Bool) {
        let done = pendingSideShots.count
        if done == 0 && !allOk { tvCaptureStatus.isHidden = true; return }
        tvCaptureStatus.isHidden = false
        let nowMs = CACurrentMediaTime() * 1000
        if done >= TOTAL_SHOTS_NEEDED {
            tvCaptureStatus.text = tr(.shotsAllDone, ["total": TOTAL_SHOTS_NEEDED])
        } else if nowMs < nextCaptureEarliestAtMs {
            tvCaptureStatus.text = tr(.shotDone, ["done": done, "total": TOTAL_SHOTS_NEEDED])
        } else if allOk {
            tvCaptureStatus.text = tr(.shotCapturing, ["number": done + 1, "total": TOTAL_SHOTS_NEEDED])
        } else {
            tvCaptureStatus.text = tr(.shotGetReady, ["number": done + 1, "total": TOTAL_SHOTS_NEEDED])
        }
    }

    // =========================================================================
    // Front-view (4th) shot
    // =========================================================================

    /// Transitions from the side-shot phase to the front-view phase. Resets the
    /// smoother/leg estimator (the view is changing entirely) and arms the settle
    /// delay. Called on captureQueue, so the resets are serialized with analysis.
    private func enterFrontPhase() {
        appState = .front
        okSinceMs = 0
        frontReadyEarliestAtMs = CACurrentMediaTime() * 1000 + FRONT_READY_DELAY_MS
        landmarkSmoother.reset()
        legEstimator.reset()
        // Prepare the hand landmarker now so it's ready to run on the front still.
        initializeHandLandmarker()
        // Front capture waits behind the guide until Continue is tapped.
        frontGuideShowing = true
        DispatchQueue.main.async {
            self.showFrontGuide()
            self.overlayView.setHeightGuide(.hidden)
            // Live overlay mirrors the captured front photo: drop face/ears,
            // wrist/palm and legs from the skeleton, and show the shoulder verticals.
            self.overlayView.setExcludedIndices(self.FRONT_SKELETON_EXCLUDE)
            self.overlayView.setShowShoulderAngles(true)
            // None of the side-view conditions apply to the front shot — hide them
            // all (the stack collapses) and keep only the repurposed Side→Front chip.
            for chip in [self.tvLightStatus, self.tvPersonStatus, self.tvMonitorStatus,
                         self.tvRotationStatus, self.tvTiltStatus, self.tvDistanceStatus] {
                chip.isHidden = true
            }
            self.tvCaptureStatus.isHidden = false
            self.tvCaptureStatus.text = self.tr(.sidePhotosDone)
        }
    }

    /// Full-screen guide shown after the side photos and before the front photo:
    /// the front-view illustration plus what the worker (A) and the photographer
    /// (B) should do. It has only a Continue button, no back button. Continue
    /// removes it and arms the usual settle delay before front capture starts.
    private func showFrontGuide() {
        guard frontGuideView == nil else { return }
        let textColor = UIColor(red: 0x20 / 255.0, green: 0x20 / 255.0, blue: 0x20 / 255.0, alpha: 1)
        let primary = UIColor(red: 33 / 255.0, green: 128 / 255.0, blue: 230 / 255.0, alpha: 1)

        func label(_ text: String, size: CGFloat, weight: UIFont.Weight) -> UILabel {
            let l = UILabel()
            l.text = text
            l.textColor = textColor
            l.font = .systemFont(ofSize: size, weight: weight)
            l.numberOfLines = 0
            return l
        }

        func card(_ header: String, _ items: [String]) -> UIView {
            let box = UIView()
            box.backgroundColor = .white
            box.layer.cornerRadius = 12
            box.layer.borderWidth = 1
            box.layer.borderColor = UIColor(white: 0.29, alpha: 0.15).cgColor
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 12
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(label(header, size: 16, weight: .bold))
            for (i, item) in items.enumerated() {
                let number = UILabel()
                number.text = "\(i + 1)"
                number.textColor = textColor
                number.font = .systemFont(ofSize: 12)
                number.textAlignment = .center
                number.backgroundColor = UIColor(white: 0xED / 255.0, alpha: 1)
                number.layer.cornerRadius = 10
                number.clipsToBounds = true
                number.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    number.widthAnchor.constraint(equalToConstant: 20),
                    number.heightAnchor.constraint(equalToConstant: 20),
                ])
                let row = UIStackView(arrangedSubviews: [number, label(item, size: 14, weight: .regular)])
                row.axis = .horizontal
                row.alignment = .center
                row.spacing = 8
                stack.addArrangedSubview(row)
            }
            box.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 16),
                stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16),
                stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
            ])
            return box
        }

        let overlay = UIView()
        overlay.backgroundColor = UIColor(red: 0xF7 / 255.0, green: 0xF8 / 255.0, blue: 0xFA / 255.0, alpha: 1)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let title = label(tr(.frontGuideTitle), size: 24, weight: .semibold)
        title.textAlignment = .center

        let imageView = UIImageView()
        if let path = Bundle.main.path(forResource: "guide_frontview", ofType: "jpg") {
            imageView.image = UIImage(contentsOfFile: path)
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        let ratio: CGFloat = imageView.image.map { $0.size.height / max($0.size.width, 1) } ?? 0.56
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio).isActive = true

        let content = UIStackView(arrangedSubviews: [
            title,
            imageView,
            card(tr(.frontGuideWorker), [tr(.frontGuideA1), tr(.frontGuideA2), tr(.frontGuideA3), tr(.frontGuideA4)]),
            card(tr(.frontGuidePhotographer), [tr(.frontGuideB1), tr(.frontGuideB2), tr(.frontGuideB3), tr(.frontGuideB4)]),
        ])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let button = UIButton(type: .system)
        button.setTitle(tr(.frontGuideContinue), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = primary
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissFrontGuide), for: .touchUpInside)

        overlay.addSubview(scroll)
        overlay.addSubview(button)
        view.addSubview(overlay)
        let safe = overlay.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: safe.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -12),
            scroll.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: safe.trailingAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),

            button.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 52),
        ])
        frontGuideView = overlay
    }

    /// Removes the front-photo guide and starts the front capture's settle delay.
    @objc private func dismissFrontGuide() {
        frontGuideView?.removeFromSuperview()
        frontGuideView = nil
        captureQueue.async {
            self.okSinceMs = 0
            self.frontReadyEarliestAtMs = CACurrentMediaTime() * 1000 + self.FRONT_READY_DELAY_MS
            self.frontGuideShowing = false
        }
    }

    /// Face (nose), both shoulders and both wrists all above the visibility bar.
    private func frontLandmarksVisible(_ raw: [RawLandmark]) -> Bool {
        if raw.count < 17 { return false }
        func vis(_ i: Int) -> Float { raw[i].visibility ?? 0 }
        let face = vis(0) >= FRONT_VISIBILITY_THRESHOLD
        let shoulders = vis(11) >= FRONT_VISIBILITY_THRESHOLD && vis(12) >= FRONT_VISIBILITY_THRESHOLD
        let hands = vis(15) >= FRONT_VISIBILITY_THRESHOLD && vis(16) >= FRONT_VISIBILITY_THRESHOLD
        return face && shoulders && hands
    }

    /// Max elbow abduction (shoulder→elbow angle from vertical, degrees) across both
    /// arms — the front-view "armrests too wide" measurement. Compared against
    /// ARMREST_ABDUCTION_MAX_DEG at the call site; the raw angle is also surfaced to
    /// Flutter. Uses the same angle drawn on the photo, in the image's pixel aspect.
    private func frontAbductionAngleDeg(_ landmarks: [LandmarkPoint], width: CGFloat, height: CGFloat) -> Double? {
        var maxAngle: Double?
        for (shIdx, elIdx) in [(11, 13), (12, 14)] {
            guard shIdx < landmarks.count, elIdx < landmarks.count else { continue }
            let dx = Double(landmarks[elIdx].x - landmarks[shIdx].x) * Double(width)
            let dy = Double(landmarks[elIdx].y - landmarks[shIdx].y) * Double(height)
            let len = (dx * dx + dy * dy).squareRoot()
            if len < 1 { continue }
            let angle = acos(dy / len) * 180 / .pi
            if angle > (maxAngle ?? -Double.infinity) { maxAngle = angle }
        }
        return maxAngle
    }

    /// Max wrist deviation (front-view forearm→hand angle away from a straight 180°,
    /// degrees) across both hands — the "wrists deviate while typing" measurement.
    /// Compared against WRIST_DEVIATION_MAX_DEG at the call site; the raw angle is also
    /// surfaced to Flutter. `hands` are the hand-landmarker points; `poseLandmarks`
    /// supply the elbows (13/14). Returns nil when no hand is usable — "not
    /// measured", which is not the same as a straight wrist.
    private func frontWristDeviationDeg(_ hands: [[LandmarkPoint]], poseLandmarks: [LandmarkPoint],
                                        width: CGFloat, height: CGFloat) -> Double? {
        var elbows: [LandmarkPoint] = []
        if poseLandmarks.count > 13 { elbows.append(poseLandmarks[13]) }
        if poseLandmarks.count > 14 { elbows.append(poseLandmarks[14]) }
        if elbows.isEmpty { return nil }

        let w = Double(width), h = Double(height)
        var maxDeviation: Double?
        for hand in hands {
            guard hand.count > 9 else { continue }
            let wrist = hand[0], mcp = hand[9]
            let nearest = elbows.min(by: {
                let d0x = Double($0.x - wrist.x) * w, d0y = Double($0.y - wrist.y) * h
                let d1x = Double($1.x - wrist.x) * w, d1y = Double($1.y - wrist.y) * h
                return (d0x * d0x + d0y * d0y) < (d1x * d1x + d1y * d1y)
            })!
            let v1x = Double(nearest.x - wrist.x) * w, v1y = Double(nearest.y - wrist.y) * h
            let v2x = Double(mcp.x - wrist.x) * w, v2y = Double(mcp.y - wrist.y) * h
            let m1 = (v1x * v1x + v1y * v1y).squareRoot(), m2 = (v2x * v2x + v2y * v2y).squareRoot()
            if m1 < 1 || m2 < 1 { continue }
            let cosA = max(-1, min(1, (v1x * v2x + v1y * v2y) / (m1 * m2)))
            let deviation = 180 - acos(cosA) * 180 / .pi
            if deviation > (maxDeviation ?? -Double.infinity) { maxDeviation = deviation }
        }
        return maxDeviation
    }

    /// True when the person faces the camera: shoulders spread wide relative to the
    /// nose→shoulder height, measured in pixels so it doesn't depend on the frame's
    /// aspect ratio. Hips are not used — from the front they are usually hidden by
    /// the desk.
    private func isFacingCamera(_ landmarks: [LandmarkPoint], width: Int, height: Int) -> Bool {
        if landmarks.count < 13 { return false }
        let shoulderWidth = abs(landmarks[11].x - landmarks[12].x) * Float(width)
        // Signed: the shoulders must be BELOW the nose. The absolute value used
        // before also accepted shoulders above the nose (an upside-down fit).
        let neckHeight = ((landmarks[11].y + landmarks[12].y) / 2 - landmarks[0].y) * Float(height)
        if neckHeight < 1 { return false }
        return shoulderWidth / neckHeight >= FRONT_FACING_MIN_RATIO
    }

    /// The pose is the right way up for a seated person seen from the front:
    /// nose above the shoulders, each elbow below its shoulder, and the hips
    /// below the shoulders. The hips are usually hidden behind the desk, but the
    /// model still places them, and where it places them gives a failed
    /// detection away.
    ///
    /// When the phone looks down steeply on someone whose lower body is hidden,
    /// the model can fit the skeleton upside down: shoulders at the top of the
    /// head, elbows at the real shoulders, hips above the frame. The photo then
    /// looks wrong and the abduction and wrist-deviation angles measured from it
    /// are meaningless, so such a pose must never be captured.
    private func isUprightFrontPose(_ lm: [LandmarkPoint]) -> Bool {
        if lm.count < 25 { return false }
        let shoulderY = (lm[11].y + lm[12].y) / 2
        let hipY = (lm[23].y + lm[24].y) / 2
        return lm[0].y < min(lm[11].y, lm[12].y)
            && lm[13].y > lm[11].y && lm[14].y > lm[12].y
            && hipY > shoulderY
    }

    /// Drives the capture banner + (repurposed) side chip during the front phase.
    private func updateFrontCue(frontVisible: Bool, frontUpright: Bool, frontFacing: Bool,
                                rotationOk: Bool, phoneSteady: Bool) {
        tvCaptureStatus.isHidden = false
        let settling = CACurrentMediaTime() * 1000 < frontReadyEarliestAtMs
        if settling {
            tvCaptureStatus.text = tr(.frontMove)
        } else if !frontVisible {
            tvCaptureStatus.text = tr(.frontShowBody)
        } else if !frontUpright {
            // An upside-down fit almost always comes from looking down steeply.
            tvCaptureStatus.text = tr(.frontHoldLower)
        } else if !frontFacing {
            tvCaptureStatus.text = tr(.frontMove)
        } else if !rotationOk {
            tvCaptureStatus.text = tr(.frontStraighten)
        } else if !phoneSteady {
            tvCaptureStatus.text = tr(.frontHoldPhoneStill)
        } else {
            tvCaptureStatus.text = tr(.frontCapturing)
        }
        let ok = frontVisible && frontUpright && frontFacing && rotationOk && phoneSteady
        tvSideViewStatus.textColor = ok ? colorDetected : colorNotDetected
        if !frontVisible {
            tvSideViewStatus.text = tr(.chipFrontShowBody)
        } else if !frontUpright {
            tvSideViewStatus.text = tr(.chipFrontHoldLower)
        } else if !frontFacing {
            tvSideViewStatus.text = tr(.chipFrontMove)
        } else if !rotationOk {
            tvSideViewStatus.text = tr(.chipFrontStraighten)
        } else if !phoneSteady {
            tvSideViewStatus.text = tr(.chipFrontHoldStill)
        } else {
            tvSideViewStatus.text = tr(.chipFrontOk)
        }
    }

    // =========================================================================
    // UI construction
    // =========================================================================

    private func buildUI() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        overlayView = PoseOverlayView(frame: view.bounds)
        overlayView.language = language
        view.addSubview(overlayView)

        // Level indicator, centered on the preview (positioned in layout).
        view.addSubview(levelView)

        flashOverlay.frame = view.bounds
        flashOverlay.backgroundColor = .white
        flashOverlay.alpha = 0
        flashOverlay.isHidden = true
        flashOverlay.isUserInteractionEnabled = false
        view.addSubview(flashOverlay)

        tvCaptureStatus.font = .boldSystemFont(ofSize: 14)
        tvCaptureStatus.textColor = .white
        tvCaptureStatus.textAlignment = .center
        tvCaptureStatus.numberOfLines = 0
        tvCaptureStatus.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        tvCaptureStatus.layer.cornerRadius = 6
        tvCaptureStatus.clipsToBounds = true
        tvCaptureStatus.isHidden = true
        tvCaptureStatus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tvCaptureStatus)

        buildStatusStack()

        let switchImage = UIImage(named: "ic_switch_camera")?.withRenderingMode(.alwaysTemplate)
        let switchBtn = makeCircleIconButton(image: switchImage, action: #selector(onSwitchCamera))
        switchBtn.accessibilityLabel = tr(.switchCamera)
        let closeBtn = makeButton("✕", action: #selector(onClose))
        view.addSubview(switchBtn)
        view.addSubview(closeBtn)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // All status conditions sit at the bottom-left in a single column (the
            // camera preview is anchored to the top). 16pt from the leading edge
            // mirrors the switch-camera button's 16pt from the trailing edge.
            statusStack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            statusStack.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -48),

            tvCaptureStatus.bottomAnchor.constraint(equalTo: statusStack.topAnchor, constant: -8),
            tvCaptureStatus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tvCaptureStatus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            // 66 = previewTopGap (48) + 18, so the control sits 18pt below the
            // top edge of the camera preview.
            switchBtn.topAnchor.constraint(equalTo: g.topAnchor, constant: 66),
            switchBtn.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            closeBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeBtn.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -8),
        ])
    }

    /// Builds the single bottom column listing every status condition, in order:
    /// Light, Person, Monitor, Rotation, Tilt, Distance, Side — followed by the
    /// confirmation progress bar and the general status message.
    private func buildStatusStack() {
        tvLightStatus.text = tr(.chipLight)
        tvPersonStatus.text = tr(.chipPerson)
        tvMonitorStatus.text = tr(.chipMonitor)
        tvRotationStatus.text = tr(.chipRotationIdle)
        tvTiltStatus.text = tr(.chipTiltIdle)
        tvDistanceStatus.text = tr(.chipDistanceIdle)
        tvSideViewStatus.text = tr(.chipSideIdle)

        let conditions: [UILabel] = [tvLightStatus, tvPersonStatus, tvMonitorStatus,
                                     tvRotationStatus, tvTiltStatus,
                                     tvDistanceStatus, tvSideViewStatus]
        for label in conditions { styleStatusChip(label) }

        confirmProgress.progressTintColor = colorDetected
        confirmProgress.trackTintColor = UIColor(white: 1, alpha: 0.2)
        confirmProgress.progress = 0
        confirmProgress.isHidden = true
        confirmProgress.widthAnchor.constraint(equalToConstant: 160).isActive = true

        tvStatusMessage.font = .systemFont(ofSize: 12)
        tvStatusMessage.textColor = UIColor(white: 1, alpha: 0.8)
        tvStatusMessage.textAlignment = .center
        tvStatusMessage.numberOfLines = 0
        tvStatusMessage.isHidden = true

        var arranged = [UIView]()
        arranged.append(contentsOf: conditions)
        arranged.append(confirmProgress)
        arranged.append(tvStatusMessage)
        statusStack = UIStackView(arrangedSubviews: arranged)
        statusStack.axis = .vertical
        statusStack.alignment = .leading
        statusStack.spacing = 6
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusStack)
    }

    private func styleStatusChip(_ label: UILabel) {
        label.font = .systemFont(ofSize: 13)
        label.textColor = colorNeutral
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 0, alpha: 0.67)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        // padding via attributed insets is fiddly; a little width slack is enough here
        label.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func makeButton(_ title: String, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.backgroundColor = UIColor(white: 0, alpha: 0.5)
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        b.layer.cornerRadius = 6
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    /// A 48pt semi-transparent white circle holding a (template) icon image.
    private func makeCircleIconButton(image: UIImage?, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(image, for: .normal)
        b.tintColor = .white
        b.imageView?.contentMode = .scaleAspectFit
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        b.backgroundColor = UIColor(white: 1, alpha: 0.25)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: 48).isActive = true
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    /// Mirrors the Android `updatePanel` indicator logic.
    private func updatePanel(lightOk: Bool?,
                             personDetected: Bool = false,
                             monitorDetected: Bool = false,
                             confirmCount: Int = 0,
                             message: String? = nil) {
        switch lightOk {
        case nil: tvLightStatus.textColor = colorNeutral
        case .some(true): tvLightStatus.textColor = colorDetected
        case .some(false): tvLightStatus.textColor = colorNotDetected
        }

        let yoloActive = (lightOk == true)
        tvPersonStatus.textColor = !yoloActive ? colorNeutral : (personDetected ? colorDetected : colorNotDetected)
        tvMonitorStatus.textColor = !yoloActive ? colorNeutral : (monitorDetected ? colorDetected : colorNotDetected)

        let showProgress = yoloActive && personDetected && monitorDetected && confirmCount > 0
        confirmProgress.isHidden = !showProgress
        confirmProgress.progress = Float(confirmCount) / Float(REQUIRED_CONFIRMATIONS)

        if let message = message {
            tvStatusMessage.text = message
            tvStatusMessage.isHidden = false
        } else {
            tvStatusMessage.isHidden = true
        }
    }

    private func showToast(_ text: String) {
        tvStatusMessage.text = text
        tvStatusMessage.isHidden = false
    }

    // MARK: - Button actions

    @objc private func onSwitchCamera() {
        cameraPosition = (cameraPosition == .back) ? .front : .back
        fullReset()
        setupCamera()
    }

    @objc private func onClose() { finish(with: nil) }
}

// =========================================================================
// Camera + MediaPipe delegates
// =========================================================================

extension PoseDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        analyze(sampleBuffer: sampleBuffer)   // already on captureQueue
    }
}

extension PoseDetectionViewController: PoseLandmarkerLiveStreamDelegate {
    func poseLandmarker(_ poseLandmarker: PoseLandmarker,
                        didFinishDetection result: PoseLandmarkerResult?,
                        timestampInMilliseconds: Int,
                        error: Error?) {
        if let error = error { NSLog("pose detection error: \(error)"); return }
        captureQueue.async { [weak self] in
            self?.handlePoseResult(result, timestampMs: timestampInMilliseconds)
        }
    }
}

// =========================================================================
// Level / horizon indicator
// =========================================================================

/// Camera level indicator (like the Pixel camera's "Level"). A fixed pair of
/// side ticks plus a centre line that rotates with the phone's roll and shifts
/// vertically with its forward/back pitch. Everything turns green when the phone
/// is held upright and level (within `TiltMonitor`'s acceptable ranges).
final class CameraLevelView: UIView {

    private var roll: CGFloat = 0    // degrees, 0 = level
    private var pitch: CGFloat = 0   // degrees, 0 = upright

    // Match TiltMonitor's acceptable ranges.
    private let rollTolerance: CGFloat = 15
    private let pitchTolerance: CGFloat = 5

    // Flip these if the motion feels reversed on device.
    private let rollSign: CGFloat = -1
    private let pitchSign: CGFloat = -1     // forward tilt → line moves up

    private let pxPerDegree: CGFloat = 0.6  // small, proportional travel
    private let maxOffset: CGFloat = 18
    private let centerHalf: CGFloat = 36   // half-length of the wide centre / moving line
    private let sideGap: CGFloat = 14      // gap between the centre line and each side tick
    private let sideLen: CGFloat = 14      // length of the short side ticks
    private let lineWidth: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(roll: Double, pitch: Double) {
        self.roll = CGFloat(roll)
        self.pitch = CGFloat(pitch)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let cx = bounds.midX, cy = bounds.midY

        let aligned = abs(roll) <= rollTolerance && abs(pitch) <= pitchTolerance
        let color: UIColor = aligned
            ? UIColor(red: 0x43 / 255.0, green: 0xA0 / 255.0, blue: 0x47 / 255.0, alpha: 1)
            : UIColor(white: 1, alpha: 0.95)

        ctx.setLineCap(.round)
        ctx.setShadow(offset: .zero, blur: 3, color: UIColor(white: 0, alpha: 0.6).cgColor)
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(lineWidth)

        // Fixed reference: a wide centre line plus two shorter side ticks (3 lines,
        // all horizontal and centred).
        ctx.move(to: CGPoint(x: cx - centerHalf, y: cy))
        ctx.addLine(to: CGPoint(x: cx + centerHalf, y: cy))
        let tickInnerL = cx - centerHalf - sideGap
        let tickInnerR = cx + centerHalf + sideGap
        ctx.move(to: CGPoint(x: tickInnerL - sideLen, y: cy))
        ctx.addLine(to: CGPoint(x: tickInnerL, y: cy))
        ctx.move(to: CGPoint(x: tickInnerR, y: cy))
        ctx.addLine(to: CGPoint(x: tickInnerR + sideLen, y: cy))
        ctx.strokePath()

        // Moving line: same width as the centre line, shifted vertically by pitch
        // and rotated by roll. Overlaps the centre line when the phone is level.
        let dy = max(-maxOffset, min(maxOffset, pitchSign * pitch * pxPerDegree))
        // Deadzone: no rotation while roll is within the acceptable range, then
        // rotate smoothly past it (so there's no jump at the threshold).
        let effRoll: CGFloat = abs(roll) <= rollTolerance
            ? 0 : roll - (roll < 0 ? -rollTolerance : rollTolerance)
        let angle = rollSign * effRoll * .pi / 180
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy + dy)
        ctx.rotate(by: angle)
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.move(to: CGPoint(x: -centerHalf, y: 0))
        ctx.addLine(to: CGPoint(x: centerHalf, y: 0))
        ctx.strokePath()
        ctx.restoreGState()
    }
}
