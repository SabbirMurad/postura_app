package com.sabbir.postura

import android.app.Activity
import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.*
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.Image
import android.os.Bundle
import android.util.Log
import android.util.Size
import android.view.View
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import com.google.mediapipe.framework.image.BitmapExtractor
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class PoseDetectionActivity : AppCompatActivity() {

    companion object {
        /**
         * Activity-result extra: a JSON object string of the whole capture, grouped as
         *   { "side_captures": [ { image_path, rosa_score {…}, body_angles {…} }, … ],
         *     "front_capture": { image_path, abduction_angle, wrist_deviation_angle } }
         * front_capture is omitted when the answers say no front photo can be taken.
         * All keys are snake_case — this is the Flutter-facing contract.
         */
        const val EXTRA_RESULT  = "result"
        /** Launch extra: JSON object string of the manual workstation questionnaire answers. */
        const val EXTRA_WORKSTATION_ANSWERS = "workstation_answers"
        /** Launch extra: the app's language code ("en", "de", "es", "nl") for the
         *  on-screen text; missing or unsupported falls back to English. */
        const val EXTRA_LANGUAGE = "language"

        /** Pose landmark indices omitted in the front view (both the baked photo and
         *  the live overlay): face/eyes/ears/mouth (0..10), wrist/palm (15..22) — the
         *  hand landmarker supplies those on the photo — and legs (25..32). */
        val FRONT_SKELETON_EXCLUDE = ((0..10) + (15..22) + (25..32)).toSet()
    }

    // FRONT is a 4th phase entered after the 3 side shots: the holder moves to
    // the front of the person (behind the monitor) and a single extra photo is
    // taken once the face, shoulders and hands are visible.
    // DONE: every photo is taken; frames are ignored while the photos are processed.
    private enum class AppState { LIGHT_CHECK, DETECTING, POSE, FRONT, DONE }

    // -------------------------------------------------------------------------
    // Views
    // -------------------------------------------------------------------------
    private lateinit var previewView: PreviewView
    private lateinit var poseOverlayView: PoseOverlayView
    private lateinit var cameraLevel: CameraLevelView
    private lateinit var statusPanel: LinearLayout
    private lateinit var tvCaptureStatus: TextView
    private lateinit var flashOverlay: View
    private lateinit var tvLightStatus: TextView
    private lateinit var tvPersonStatus: TextView
    private lateinit var tvMonitorStatus: TextView
    private lateinit var confirmProgress: ProgressBar
    private lateinit var tvStatusMessage: TextView
    private lateinit var tvTiltStatus: TextView
    private lateinit var tvRotationStatus: TextView
    private lateinit var tvDistanceStatus: TextView
    private lateinit var tvSideViewStatus: TextView

    // -------------------------------------------------------------------------
    // Tilt
    // -------------------------------------------------------------------------
    private lateinit var tiltMonitor: TiltMonitor

    // -------------------------------------------------------------------------
    // ML
    // -------------------------------------------------------------------------
    private lateinit var cameraExecutor: ExecutorService
    @Volatile private var poseLandmarker: PoseLandmarker? = null

    // Hand landmarker — IMAGE mode, used only once on the captured FRONT still to
    // overlay finger/palm points. Never runs on live frames. Created lazily when
    // the front phase begins (the settle delay absorbs the one-time setup cost).
    @Volatile private var handLandmarker: HandLandmarker? = null

    // Pose landmarker in IMAGE mode, run once on each captured still. The live
    // landmarks are smoothed for a steady overlay, so they lag the body; the
    // measurements come from this fresh, unsmoothed detection instead. Uses the
    // heavy model when it is bundled, otherwise the full one. It runs after the
    // live landmarker is closed, so it can have the GPU; it is created, used and
    // closed on cameraExecutor (a GPU delegate is tied to the thread that made it).
    @Volatile private var stillPoseLandmarker: PoseLandmarker? = null
    private var stillPoseOnGpu = false
    // A still detection whose shoulders sit further than this (normalised) from
    // the live tracking is someone else in the frame; the live pose is used then.
    private val STILL_POSE_MAX_SHIFT = 0.1f
    // The model's raw landmarks for each side shot and the front shot (x, y, z,
    // visibility per point), sent on with the scan so cutoffs can be re-fitted
    // later from real data.
    private val capturedRawPoses = CopyOnWriteArrayList<org.json.JSONObject?>()

    /** A captured frame waiting to be processed once every photo is taken: the
     *  clean frame plus the live pose it was captured with (the fallback when
     *  the still detection finds nothing). */
    private class PendingShot(
        val frame: Bitmap,
        val livePoints: List<LandmarkPoint>,
        val liveRaw: List<NormalizedLandmark>?,
    )
    private val pendingSideShots = CopyOnWriteArrayList<PendingShot>()
    @Volatile private var pendingFrontShot: PendingShot? = null
    @Volatile private var frontRawPose: org.json.JSONObject? = null
    private var yoloDetector: YoloDetector? = null

    // -------------------------------------------------------------------------
    // Camera
    // -------------------------------------------------------------------------
    private var cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
    @Volatile private var cameraProvider: ProcessCameraProvider? = null
    @Volatile private var lastImageWidth: Int  = 1
    @Volatile private var lastImageHeight: Int = 1

    // Set once from the first frame: anchors the preview to the top of the
    // screen (sized to the video aspect) instead of vertically centered.
    @Volatile private var previewLaidOut = false
    private val previewTopGapDp = 48f

    // Camera2 optics — read once per camera bind, used for distance estimation
    @Volatile private var focalLengthMm: Float  = 4.25f  // sensible fallback
    @Volatile private var sensorWidthMm: Float  = 6.4f   // landscape sensor width
    @Volatile private var sensorHeightMm: Float = 4.8f   // landscape sensor height
    private var frameCounter = 0
    private val processEveryNFrames = 1
    // Last timestamp handed to the pose landmarker (ms). MediaPipe needs strictly
    // increasing millisecond timestamps. Only touched on cameraExecutor.
    private var lastPoseTimestampMs = 0L
    // Set when the pose landmarker can't be created on either delegate, so the
    // detection phase stops retrying on every frame.
    @Volatile private var poseInitFailed = false

    // -------------------------------------------------------------------------
    // Smoother + leg estimator
    // -------------------------------------------------------------------------
    private val landmarkSmoother = LandmarkSmoother(minCutoff = 0.5f, beta = 0.5f)
    private val legEstimator     = LegEstimator()

    // -------------------------------------------------------------------------
    // State machine  (only written on cameraExecutor thread except resets)
    // -------------------------------------------------------------------------
    @Volatile private var appState = AppState.LIGHT_CHECK
    private var confirmationCount = 0
    private val REQUIRED_CONFIRMATIONS = 4

    // ── Multi-shot capture sequence ───────────────────────────────────────────
    // Once conditions are met, captures TOTAL_SHOTS_NEEDED photos, each at least
    // CAPTURE_COOLDOWN_MS apart and only while every condition is currently OK.
    // The 3 side shots only. The front shot is held separately (frontPhoto).
    // The capture lists are written on the pose result-listener thread and read on
    // the UI thread, hence the copy-on-write lists (at most 3 entries each).
    private val capturedPhotos = CopyOnWriteArrayList<Bitmap>()
    // Per-side-shot ROSA angles, kept so the shots can be scored *after* the front
    // shot — the front view supplies the armrest-too-wide modifier (elbow abduction),
    // which isn't known until then.
    private val capturedAngles = CopyOnWriteArrayList<RosaAnglesCalculator.Angles?>()

    // The front (4th) shot and its two raw measured angles (degrees). These feed the
    // armrest-too-wide / keyboard-deviation modifiers and are also surfaced to Flutter.
    @Volatile private var frontPhoto: Bitmap? = null
    // Clean (un-blurred, un-annotated) model-sized copies of the side shots,
    // checked for a monitor once all photos are taken (see finishWithCaptures).
    private val sideMonitorFrames = CopyOnWriteArrayList<Bitmap>()
    // Height of the eye-level line in each side photo, as a fraction of the
    // photo's height from the top (the same line that is drawn on the photo).
    // Null when the eye wasn't found. Sent with the monitor's box so the backend
    // can read where the top of the monitor sits relative to eye level.
    private val capturedEyeLevelY = CopyOnWriteArrayList<Float?>()
    // Null = could not be measured on the front photo (e.g. no hand found). That is
    // not the same as 0° and must never be scored or reported as "no problem".
    @Volatile private var frontAbductionAngle: Double? = null
    @Volatile private var frontWristDeviationAngle: Double? = null

    /** Manual checklist answers gathered by the Flutter questionnaire before launch. */
    private lateinit var workstationModifiers: RosaScorer.WorkstationModifiers
    // False when the user said a front-view photo can't be taken: the front phase
    // is skipped and armrestTooWide / keyboardDeviation come from the answers.
    private var frontPhotoAvailable = true
    private val TOTAL_SHOTS_NEEDED = 3

    /** The app's language for the on-screen text (see CaptureStrings). Text baked
     *  into the saved photos stays English. */
    private var language = CaptureStrings.DEFAULT_LANGUAGE

    private fun tr(key: CaptureStrings.Key, vararg args: Pair<String, Any>): String =
        CaptureStrings.get(key, language, *args)

    // Elbow abduction (front-view shoulder→elbow angle from vertical) at or above
    // this many degrees is scored as "armrests too wide / elbows pushed outward".
    private val ARMREST_ABDUCTION_MAX_DEG = 20.0
    // Wrist bend away from straight (front-view forearm→hand angle deviating from
    // 180°) at or above this many degrees is scored as "wrist deviates while typing".
    private val WRIST_DEVIATION_MAX_DEG = 15.0
    // Wrist extension (elbow.y - wrist.y, side view) at or above this value is
    // scored as "wrists extended while typing" (C_WRIST_EXT, Action Report v1.3).
    // Reuses RosaScorer's own "elevated risk" keyboard/mouse cutoff (RosaScorer.kt)
    // as the finding-flag threshold, rather than a new unvalidated number.
    private val WRIST_EXTENSION_FINDING_THRESHOLD = 0.03f
    private val CAPTURE_COOLDOWN_MS = 2000L

    // Reference width the baked-in skeleton's stroke widths / dot radii are tuned
    // against (see bakeSkeletonOntoPhoto). Using a fixed constant — instead of the
    // capturing device's screen size — makes the skeleton's proportions relative
    // to the photo a fixed, intrinsic property of the image itself: the same photo
    // resolution always bakes the same skeleton, regardless of which phone took
    // it or what screen it's later viewed on. That matters because these photos
    // get sent to Flutter and on to the server for storage, where they must look
    // consistent no matter where they came from or where they're displayed.
    private val SKELETON_REFERENCE_WIDTH = 1080f
    @Volatile private var nextCaptureEarliestAtMs = 0L

    // ── Front-view (4th) shot ─────────────────────────────────────────────────
    // Captured once face (nose), both shoulders and both wrists clear this
    // visibility bar AND the phone is upright/level. The settle delay stops a
    // premature capture while the holder is still walking the phone to the front.
    private val FRONT_VISIBILITY_THRESHOLD = 0.5f
    private val FRONT_READY_DELAY_MS = 1500L
    // The front photo is only taken when the person actually faces the camera:
    // shoulder width must be at least this multiple of the nose→shoulder height
    // (both in pixels). Face-on it is roughly 1.4; in the side view the holder
    // starts from it is well under 0.5, so the shot can't fire before they move.
    private val FRONT_FACING_MIN_RATIO = 0.9f
    @Volatile private var frontReadyEarliestAtMs = 0L

    // Phone-steadiness gate for the front shot: dynamic acceleration (m/s²) above
    // PHONE_MOTION_MAX counts as movement, and the capture waits until the phone has
    // been quiet for PHONE_STEADY_SETTLE_MS afterwards.
    private val PHONE_MOTION_MAX = 0.8
    private val PHONE_STEADY_SETTLE_MS = 400L
    @Volatile private var lastShakeAtMs = 0L

    // Hip spread / torso height ratio threshold for side-view detection.
    // Accepts camera within ~30° of true side view; unaffected by torso lean.
    // Measured in pixels. 0.26 is the old 0.35 (normalised units) on the 3:4
    // frames it was tuned on, so Android behaves as before and iOS now matches.
    private val SIDE_VIEW_THRESHOLD = 0.26f

    // ── All-green success detection ───────────────────────────────────────────
    // Shows confirmation overlay when every condition holds for ~1.5 s (~45 frames)
    @Volatile private var tiltIsOk         = false
    @Volatile private var rotationIsOk     = false
    // Stricter roll gate for the front shot: its angles are measured against the
    // image's vertical, so every degree of phone roll is a degree of error.
    @Volatile private var frontRotationIsOk = false
    private val FRONT_MAX_ROLL_DEG = 5.0
    @Volatile private var sideIsOk         = false
    @Volatile private var heightIsOk       = false
    @Volatile private var distanceIsOk     = false
    @Volatile private var lastFrameBitmap: Bitmap? = null
    // The hold-steady gates are timed, not counted in frames, so a slow phone
    // (few frames per second) doesn't wait several times longer than a fast one.
    private val SIDE_STEADY_MS  = 700L
    private val FRONT_STEADY_MS = 1000L
    // When every capture condition last became true (0 = not currently true).
    // Only touched on the pose result-listener thread and in resets.
    @Volatile private var okSinceMs = 0L

    // Light thresholds (same as live_guidence project)
    private val MIN_LUMINANCE = 0.25
    private val MAX_LUMINANCE = 0.85

    // -------------------------------------------------------------------------
    // Colors
    // -------------------------------------------------------------------------
    private val COLOR_DETECTED     = Color.parseColor("#43A047") // green
    private val COLOR_NOT_DETECTED = Color.parseColor("#E53935") // red
    private val COLOR_NEUTRAL      = Color.parseColor("#9E9E9E") // grey

    // =========================================================================
    // Lifecycle
    // =========================================================================

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setupEdgeToEdge()

        language = CaptureStrings.normalize(intent.getStringExtra(EXTRA_LANGUAGE))

        val answersJson = intent.getStringExtra(EXTRA_WORKSTATION_ANSWERS)
        workstationModifiers = if (!answersJson.isNullOrEmpty()) {
            val obj = org.json.JSONObject(answersJson)
            val map = mutableMapOf<String, Any>()
            obj.keys().forEach { key -> map[key] = obj.get(key) }
            frontPhotoAvailable = obj.optBoolean("front_photo_available", true)
            RosaScorer.WorkstationModifiers.fromMap(map)
        } else {
            RosaScorer.WorkstationModifiers()
        }

        previewView      = findViewById(R.id.previewCam)
        poseOverlayView  = findViewById(R.id.poseOverlay)
        statusPanel      = findViewById(R.id.statusPanel)
        tvLightStatus    = findViewById(R.id.tvLightStatus)
        tvPersonStatus   = findViewById(R.id.tvPersonStatus)
        tvMonitorStatus  = findViewById(R.id.tvMonitorStatus)
        confirmProgress  = findViewById(R.id.confirmProgress)
        tvStatusMessage  = findViewById(R.id.tvStatusMessage)
        tvTiltStatus          = findViewById(R.id.tvTiltStatus)
        tvRotationStatus      = findViewById(R.id.tvRotationStatus)
        tvDistanceStatus      = findViewById(R.id.tvDistanceStatus)
        tvSideViewStatus      = findViewById(R.id.tvSideViewStatus)
        tvCaptureStatus         = findViewById(R.id.tvCaptureStatus)
        flashOverlay            = findViewById(R.id.flashOverlay)
        cameraLevel             = findViewById(R.id.cameraLevel)

        // Initial chip text in the app's language (the layout holds English
        // placeholders only).
        poseOverlayView.language = language
        tvLightStatus.text    = tr(CaptureStrings.Key.CHIP_LIGHT)
        tvPersonStatus.text   = tr(CaptureStrings.Key.CHIP_PERSON)
        tvMonitorStatus.text  = tr(CaptureStrings.Key.CHIP_MONITOR)
        tvRotationStatus.text = tr(CaptureStrings.Key.CHIP_ROTATION_IDLE)
        tvTiltStatus.text     = tr(CaptureStrings.Key.CHIP_TILT_IDLE)
        tvDistanceStatus.text = tr(CaptureStrings.Key.CHIP_DISTANCE_IDLE)
        tvSideViewStatus.text = tr(CaptureStrings.Key.CHIP_SIDE_IDLE)
        findViewById<View>(R.id.btnSwitchCamera).contentDescription =
            tr(CaptureStrings.Key.SWITCH_CAMERA)

        tiltMonitor = TiltMonitor(this) { tiltAngle, rollAngle, pitchAngle, motion ->
            val tOk = TiltMonitor.isTiltAcceptable(tiltAngle)
            val rOk = TiltMonitor.isRollAcceptable(rollAngle)
            tiltIsOk     = tOk
            rotationIsOk = rOk
            frontRotationIsOk = kotlin.math.abs(rollAngle) <= FRONT_MAX_ROLL_DEG
            // Latch the last time the phone was shaken/moved; the front capture waits
            // for a quiet window after this before firing.
            if (motion > PHONE_MOTION_MAX) lastShakeAtMs = android.os.SystemClock.elapsedRealtime()
            cameraLevel.update(rollAngle, pitchAngle)

            val tiltStr = "%.1f".format(tiltAngle)
            tvTiltStatus.setTextColor(if (tOk) COLOR_DETECTED else COLOR_NOT_DETECTED)
            tvTiltStatus.text = tr(
                if (tOk) CaptureStrings.Key.CHIP_TILT_OK else CaptureStrings.Key.CHIP_TILT_BAD,
                "value" to tiltStr)

            val rollStr = "%.1f".format(kotlin.math.abs(rollAngle))
            tvRotationStatus.setTextColor(if (rOk) COLOR_DETECTED else COLOR_NOT_DETECTED)
            tvRotationStatus.text = if (rOk) tr(CaptureStrings.Key.CHIP_ROTATION_OK)
                                    else     tr(CaptureStrings.Key.CHIP_ROTATION_BAD, "value" to rollStr)
        }

        cameraExecutor = Executors.newSingleThreadExecutor()
        // Load YOLO model on the executor thread so it's ready for the first frame
        cameraExecutor.execute { yoloDetector = YoloDetector(this) }

        // Show initial panel state (all neutral, checking light)
        updatePanel(lightOk = null)

        findViewById<View>(R.id.btnSwitchCamera).setOnClickListener {
            cameraSelector = if (cameraSelector == CameraSelector.DEFAULT_BACK_CAMERA)
                CameraSelector.DEFAULT_FRONT_CAMERA else CameraSelector.DEFAULT_BACK_CAMERA
            // fullReset restarts the camera itself once the teardown is done.
            fullReset()
        }

        requestCameraPermission()
    }

    /**
     * Resets the whole capture (used when switching camera) and restarts the camera.
     *
     * The camera is unbound first so no new frames arrive, then everything is torn
     * down on cameraExecutor — the thread that calls detectAsync — so closing the
     * landmarkers can't race a frame in flight (closing mid-detect crashes
     * MediaPipe). close() also waits for pending results, so the result listener
     * is finished before the capture state is cleared.
     */
    private fun fullReset() {
        cameraProvider?.unbindAll()
        cameraExecutor.execute {
            poseLandmarker?.close()
            poseLandmarker = null
            handLandmarker?.close()
            handLandmarker = null
            stillPoseLandmarker?.close()
            stillPoseLandmarker = null
            yoloDetector?.dispose()
            yoloDetector = null

            appState = AppState.LIGHT_CHECK
            confirmationCount = 0
            poseInitFailed = false
            capturedPhotos.clear()
            sideMonitorFrames.clear()
            capturedEyeLevelY.clear()
            capturedAngles.clear()
            capturedRawPoses.clear()
            frontRawPose = null
            pendingSideShots.clear()
            pendingFrontShot = null
            frontPhoto = null
            frontAbductionAngle = null
            frontWristDeviationAngle = null
            nextCaptureEarliestAtMs = 0L
            frontReadyEarliestAtMs = 0L
            lastFrameBitmap = null
            okSinceMs = 0L
            distanceIsOk = false
            landmarkSmoother.reset()
            legEstimator.reset()
            yoloDetector = YoloDetector(this)

            runOnUiThread {
                resetUi()
                setupCamera()
            }
        }
    }

    private fun resetUi() {
        tvCaptureStatus.visibility = View.GONE
        flashOverlay.visibility = View.GONE
        flashOverlay.alpha = 0f
        // Restore the condition chips the front phase hides, in case we reset
        // (e.g. camera switch) while in that phase.
        tvLightStatus.visibility    = View.VISIBLE
        tvPersonStatus.visibility   = View.VISIBLE
        tvMonitorStatus.visibility  = View.VISIBLE
        tvRotationStatus.visibility = View.VISIBLE
        tvTiltStatus.visibility     = View.VISIBLE
        tvDistanceStatus.visibility = View.VISIBLE
        poseOverlayView.updateLandmarks(emptyList(), 1, 1)
        poseOverlayView.setHeightGuide(PoseOverlayView.HeightGuideState.HIDDEN)
        poseOverlayView.setExcludedIndices(emptySet())
        poseOverlayView.setShowShoulderAngles(false)
        updatePanel(lightOk = null)
        poseOverlayView.updateRosaAngles(null)
    }

    // =========================================================================
    // Pose landmarker — created only after detection confirms both targets
    // =========================================================================

    /** Creates the pose landmarker on the GPU, falling back to the CPU on devices
     *  where the GPU delegate isn't supported. Returns false if neither works. */
    private fun initializePoseLandmarker(): Boolean {
        poseLandmarker = try {
            createPoseLandmarker(Delegate.GPU)
        } catch (t: Throwable) {
            Log.w("PoseLandmarker", "GPU delegate unavailable (${t.message}), falling back to CPU")
            try {
                createPoseLandmarker(Delegate.CPU)
            } catch (t2: Throwable) {
                Log.e("PoseLandmarker", "Failed to create pose landmarker", t2)
                null
            }
        }
        return poseLandmarker != null
    }

    /** Creates the IMAGE-mode pose landmarker used on captured stills: the heavy
     *  model if bundled, else the full one; on the GPU when [allowGpu] and the
     *  device supports it, else the CPU. Without it, captures use the live pose. */
    private fun initializeStillPoseLandmarker(allowGpu: Boolean = true) {
        if (stillPoseLandmarker != null) return
        val delegates = if (allowGpu) listOf(Delegate.GPU, Delegate.CPU) else listOf(Delegate.CPU)
        for (model in listOf("pose_landmarker_heavy.task", "pose_landmarker_full.task")) {
            for (delegate in delegates) {
                try {
                    val options = PoseLandmarker.PoseLandmarkerOptions.builder()
                        .setBaseOptions(
                            BaseOptions.builder()
                                .setModelAssetPath(model)
                                .setDelegate(delegate)
                                .build()
                        )
                        .setRunningMode(RunningMode.IMAGE)
                        .setNumPoses(1)
                        .build()
                    stillPoseLandmarker = PoseLandmarker.createFromOptions(this, options)
                    stillPoseOnGpu = delegate == Delegate.GPU
                    Log.d("PoseLandmarker", "Still-image pose model: $model on $delegate")
                    return
                } catch (t: Throwable) {
                    Log.w("PoseLandmarker", "Still-image pose model $model on $delegate unavailable: ${t.message}")
                }
            }
        }
    }

    /** Re-detects the pose on a captured still. Null when the landmarker isn't
     *  available, finds nobody, or finds someone other than the person the live
     *  tracking ([live]) is following. */
    private fun detectStillPose(
        frame: Bitmap,
        live: List<NormalizedLandmark>?,
    ): List<NormalizedLandmark>? {
        fun run(): List<NormalizedLandmark>? =
            stillPoseLandmarker?.detect(BitmapImageBuilder(frame).build())?.landmarks()?.firstOrNull()
        val still = try {
            run()
        } catch (e: Exception) {
            Log.e("PoseLandmarker", "Still-image detection failed", e)
            if (!stillPoseOnGpu) null else {
                // A GPU delegate can load and still fail at run time: retry on CPU.
                try {
                    stillPoseLandmarker?.close()
                } catch (_: Exception) {}
                stillPoseLandmarker = null
                initializeStillPoseLandmarker(allowGpu = false)
                try { run() } catch (e2: Exception) { null }
            }
        }
        if (still == null || still.size < 33) return null
        if (live != null && live.size >= 13) {
            val dx = (still[11].x() + still[12].x() - live[11].x() - live[12].x()) / 2f
            val dy = (still[11].y() + still[12].y() - live[11].y() - live[12].y()) / 2f
            if (kotlin.math.hypot(dx, dy) > STILL_POSE_MAX_SHIFT) return null
        }
        return still
    }

    /** Every photo is taken: stop the camera and process the photos behind a
     *  loading message. Called on the result-listener thread. */
    private fun finishCapturing() {
        appState = AppState.DONE
        runOnUiThread {
            triggerCaptureFlash()
            tvCaptureStatus.visibility = View.VISIBLE
            tvCaptureStatus.text = tr(CaptureStrings.Key.PROCESSING_PHOTOS)
            // pauseCameraPipeline queues the live landmarker's close on
            // cameraExecutor; the processing is queued behind it, so it starts
            // only once the live pipeline (and its GPU context) is gone.
            pauseCameraPipeline()
            cameraExecutor.execute { processCaptures() }
        }
    }

    /**
     * Turns the captured frames into the final photos and measurements: re-detects
     * the pose on each still, blurs the face, bakes the skeleton, measures the
     * angles and scores the scan. Runs on cameraExecutor after the camera stops.
     */
    private fun processCaptures() {
        try {
            initializeStillPoseLandmarker()

            for (shot in pendingSideShots) {
                val frame = shot.frame
                // Measure from a fresh detection on this exact still (before it is
                // blurred or drawn on); the smoothed live pose is only the fallback.
                val still = detectStillPose(frame, shot.liveRaw)
                val captured = if (still != null) {
                    legEstimator.estimate(
                        still, still.map { LandmarkPoint(it.x(), it.y()) },
                        frame.width.toFloat() / frame.height)
                } else shot.livePoints
                capturedRawPoses.add((still ?: shot.liveRaw)?.let {
                    rawPoseRecord(it, frame.width, frame.height, still != null)
                })
                sideMonitorFrames.add(YoloDetector.thumbnail(frame))
                val blurred = FaceBlurrer.blurFace(frame, captured)
                val angles = RosaAnglesCalculator.compute(
                    captured, frame.width, frame.height,
                    // Every shot of a scan measures the same body side.
                    forceLeft = capturedAngles.firstOrNull { it != null }?.isLeftSide)
                capturedPhotos.add(bakeSkeletonOntoPhoto(blurred, captured, angles))
                capturedAngles.add(angles)
                // Same landmark the eye-level line is drawn through (drawAngles).
                capturedEyeLevelY.add(angles?.let {
                    captured.getOrNull(if (it.isLeftSide) 2 else 5)?.y?.takeIf { y -> y in 0f..1f }
                })
                if (angles != null && angles.lowerBodyConfidence == RosaAnglesCalculator.LowerBodyConfidence.LOW) {
                    Log.d("RosaScorer", "Shot ${capturedPhotos.size}: knee occluded, seat-height score is a best-effort guess (kneeAngle=${angles.kneeAngle})")
                }
            }

            // Armrest-too-wide and wrist-deviation are measured on the front photo
            // and applied to every side shot's score. Without a front photo the
            // questionnaire answers (already in workstationModifiers) stand.
            var mods = workstationModifiers
            pendingFrontShot?.let { shot ->
                val frame = shot.frame
                val still = detectStillPose(frame, shot.liveRaw)
                val captured = still?.map { LandmarkPoint(it.x(), it.y()) } ?: shot.livePoints
                (still ?: shot.liveRaw)?.let {
                    frontRawPose = rawPoseRecord(it, frame.width, frame.height, still != null)
                }
                // Detect hands on the CLEAN frame first (before face blur /
                // skeleton bake mutate it), then draw them on the baked photo.
                val handResult = detectHands(frame)
                val blurred = FaceBlurrer.blurFace(frame, captured, FaceBlurrer.FRONT_DOWNSCALE_FACTOR)
                // Front view is upper-body only: no legs (25+), no face/ear points
                // (0..10, the face is blurred) and no pose wrist/palm points
                // (15..22) — the hand landmarker supplies those, and the elbow is
                // joined straight to the hand's point 0.
                val photo = bakeSkeletonOntoPhoto(
                    blurred, captured.take(25), null, excludeIndices = FRONT_SKELETON_EXCLUDE)
                drawHandsOntoPhoto(photo, handResult, captured)
                drawShoulderAnglesOntoPhoto(photo, captured)
                frontPhoto = photo

                val abduction = frontAbductionAngleDeg(captured, frame.width, frame.height)
                val wristDeviation = frontWristDeviationDeg(
                    handsToPoints(handResult), captured, frame.width, frame.height)
                frontAbductionAngle = abduction
                frontWristDeviationAngle = wristDeviation
                // A measurement that couldn't be taken (e.g. no hand found) keeps
                // the questionnaire answer instead of being scored as "no problem".
                mods = workstationModifiers.copy(
                    armrestTooWide = abduction?.let { it >= ARMREST_ABDUCTION_MAX_DEG }
                        ?: workstationModifiers.armrestTooWide,
                    keyboardDeviation = wristDeviation?.let { it >= WRIST_DEVIATION_MAX_DEG }
                        ?: workstationModifiers.keyboardDeviation,
                )
            }

            val scores = capturedAngles.map { if (it != null) RosaScorer.score(it, mods) else null }
            val photos = capturedPhotos.toList()
            runOnUiThread {
                if (!isFinishing && !isDestroyed) finishWithCaptures(photos, scores)
            }
        } catch (t: Throwable) {
            Log.e("PoseDetection", "Processing the captured photos failed", t)
            runOnUiThread {
                if (isFinishing || isDestroyed) return@runOnUiThread
                Toast.makeText(this, tr(CaptureStrings.Key.PROCESS_FAILED), Toast.LENGTH_LONG).show()
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
        } finally {
            try {
                stillPoseLandmarker?.close()
            } catch (_: Exception) {}
            stillPoseLandmarker = null
            pendingSideShots.clear()
            pendingFrontShot = null
        }
    }

    /** The raw landmarks of one shot, in the shape sent on to Flutter. */
    private fun rawPoseRecord(
        landmarks: List<NormalizedLandmark>,
        width: Int, height: Int, fromStill: Boolean,
    ): org.json.JSONObject {
        val points = org.json.JSONArray()
        for (lm in landmarks) {
            points.put(
                org.json.JSONArray()
                    .put(lm.x().toDouble())
                    .put(lm.y().toDouble())
                    .put(lm.z().toDouble())
                    .put(lm.visibility().orElse(0f).toDouble())
            )
        }
        return org.json.JSONObject()
            .put("landmarks", points)
            .put("image_width", width)
            .put("image_height", height)
            .put("source", if (fromStill) "still" else "live")
    }

    /** The exact frame a pose result was computed from, so the baked skeleton and
     *  the face blur line up with the pixels they were measured on. The live
     *  stream is asynchronous, so the latest camera frame can already be a newer
     *  one; it is only the fallback. */
    private fun frameFor(input: MPImage): Bitmap? =
        try {
            BitmapExtractor.extract(input)
        } catch (e: Exception) {
            Log.w("PoseLandmarker", "Result frame unavailable, using latest frame", e)
            lastFrameBitmap
        }

    private fun createPoseLandmarker(delegate: Delegate): PoseLandmarker {
        val options = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(
                    BaseOptions.builder()
                        .setModelAssetPath("pose_landmarker_full.task")
                        .setDelegate(delegate)
                        .build()
                )
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setErrorListener { e -> Log.e("PoseLandmarker", "Pose detection error", e) }
                .setResultListener { result, input ->
                val currentState = appState
                val landmarks = result.landmarks()
                val w = input.width
                val h = input.height
                // Frame time (not callback-arrival time) so the smoother's velocity
                // estimate isn't skewed by inference jitter.
                val tSec = result.timestampMs() / 1000.0
                val sm = if (landmarks.isNotEmpty()) {
                    landmarkSmoother.smooth(landmarks[0], tSec)
                } else {
                    landmarkSmoother.reset(); null
                }

                // Check side view on the raw-smoothed landmarks (before estimation)
                val sideOk = sm != null &&
                             currentState == AppState.POSE &&
                             checkSideView(sm, w, h)
                sideIsOk = sideOk

                // Only apply leg estimation in a confirmed seated side view —
                // prevents bogus leg lines when the person faces the camera
                val smoothed = when {
                    sm == null -> emptyList()
                    sideOk     -> legEstimator.estimate(landmarks[0], sm, w.toFloat() / h)
                    else       -> sm
                }

                // ── Continuous side view + height guide ───────────────────────
                if (currentState == AppState.POSE) {
                    // Height guide is only meaningful when the phone is held upright (tilt OK).
                    // A tilted phone skews the shoulder y position, producing false readings.
                    val guideState: PoseOverlayView.HeightGuideState
                    if (tiltIsOk && rotationIsOk) {
                        val shoulderY = if (smoothed.size >= 13) (smoothed[11].y + smoothed[12].y) / 2f else -1f
                        val hOk = shoulderY in 0.43f..0.57f
                        heightIsOk = hOk
                        guideState = when {
                            shoulderY < 0f    -> PoseOverlayView.HeightGuideState.HIDDEN
                            shoulderY > 0.57f -> PoseOverlayView.HeightGuideState.TOO_HIGH
                            shoulderY < 0.43f -> PoseOverlayView.HeightGuideState.TOO_LOW
                            else              -> PoseOverlayView.HeightGuideState.OK
                        }
                    } else {
                        heightIsOk = false
                        guideState = PoseOverlayView.HeightGuideState.HIDDEN
                    }
                    runOnUiThread {
                        tvSideViewStatus.setTextColor(if (sideOk) COLOR_DETECTED else COLOR_NOT_DETECTED)
                        tvSideViewStatus.text = tr(
                            if (sideOk) CaptureStrings.Key.CHIP_SIDE_OK else CaptureStrings.Key.CHIP_SIDE_ADJUST)
                        poseOverlayView.setHeightGuide(guideState)
                    }
                }

                // ── Multi-shot capture sequence ───────────────────────────────
                // Captures TOTAL_SHOTS_NEEDED photos: each requires every condition
                // to hold steady for SIDE_STEADY_MS AND at least
                // CAPTURE_COOLDOWN_MS to have passed since the previous shot. If
                // conditions drop, the steady-frame count simply resets and we wait
                // for them to come back — the cooldown clock keeps running regardless.
                // The phone must also be still, so the shot isn't motion-blurred.
                val sidePhoneSteady = android.os.SystemClock.elapsedRealtime() - lastShakeAtMs >= PHONE_STEADY_SETTLE_MS
                val allOk     = sideOk && tiltIsOk && rotationIsOk && heightIsOk && distanceIsOk && sidePhoneSteady
                val capturing = currentState == AppState.POSE && pendingSideShots.size < TOTAL_SHOTS_NEEDED
                if (capturing) runOnUiThread { updateCaptureCue(allOk) }

                if (capturing && allOk) {
                    val now = android.os.SystemClock.elapsedRealtime()
                    if (okSinceMs == 0L) okSinceMs = now
                    if (now - okSinceMs >= SIDE_STEADY_MS && now >= nextCaptureEarliestAtMs) {
                        okSinceMs = 0L
                        val frameCopy = frameFor(input)?.copy(Bitmap.Config.ARGB_8888, true)
                        if (frameCopy != null) {
                            // Only the clean frame and the live pose are kept here.
                            // The photos are measured and drawn after the last shot
                            // (processCaptures), so the camera never stalls between
                            // shots.
                            pendingSideShots.add(PendingShot(frameCopy, smoothed.toList(), landmarks[0]))
                            nextCaptureEarliestAtMs = now + CAPTURE_COOLDOWN_MS
                            val shotNumber = pendingSideShots.size
                            if (shotNumber >= TOTAL_SHOTS_NEEDED && !frontPhotoAvailable) {
                                // No front photo possible — finish now; scoring uses
                                // the questionnaire's armrest-width / wrist-deviation
                                // answers (already in workstationModifiers).
                                finishCapturing()
                            } else if (shotNumber >= TOTAL_SHOTS_NEEDED) {
                                // Side shots done — switch to the front-view phase
                                // instead of finishing. enterFrontPhase resets the
                                // smoother/leg estimator; it must run on this
                                // (result-listener) thread, not the UI thread.
                                enterFrontPhase()
                                runOnUiThread { triggerCaptureFlash() }
                            } else {
                                runOnUiThread {
                                    triggerCaptureFlash()
                                    updateCaptureCue(allOk = true)
                                }
                            }
                        }
                    }
                } else if (capturing) {
                    okSinceMs = 0L
                }

                // ── Front-view capture (4th shot, after the 3 side shots) ─────
                // Condition: face/shoulders/hands visible AND the phone is not
                // rotated (roll OK) AND the phone is held steady (no recent shake).
                // No tilt gate — the front shot doesn't need the phone held perfectly
                // upright, only un-rotated and still. Uses the raw
                // (un-leg-estimated) smoothed landmarks and bakes the skeleton with
                // no ROSA arcs. The photo carries no score.
                if (currentState == AppState.FRONT) {
                    val raw = landmarks.getOrNull(0)
                    val frontVisible = raw != null && frontLandmarksVisible(raw)
                    val nowF = android.os.SystemClock.elapsedRealtime()
                    val phoneSteady = nowF - lastShakeAtMs >= PHONE_STEADY_SETTLE_MS
                    val frontFacing = sm != null && isFacingCamera(sm, w, h)
                    val frontRotOk = frontRotationIsOk
                    val frontOk = frontVisible && frontFacing && frontRotOk && phoneSteady
                    runOnUiThread { updateFrontCue(frontVisible, frontFacing, frontRotOk, phoneSteady) }
                    if (frontOk && nowF >= frontReadyEarliestAtMs) {
                        // Capture once the condition has held for FRONT_STEADY_MS
                        // consecutive frames past the entry settle.
                        if (okSinceMs == 0L) okSinceMs = nowF
                        if (nowF - okSinceMs >= FRONT_STEADY_MS) {
                            okSinceMs = 0L
                            val frameCopy = frameFor(input)?.copy(Bitmap.Config.ARGB_8888, true)
                            if (frameCopy != null) {
                                pendingFrontShot = PendingShot(
                                    frameCopy, (sm ?: emptyList()).toList(), raw)
                                finishCapturing()
                            }
                        }
                    } else {
                        // Visibility dropped (or still in the entry settle) — restart the hold.
                        okSinceMs = 0L
                    }
                }

                // ── Distance (POSE only) ──────────────────────────────────────
                val distanceM = if (currentState == AppState.POSE && smoothed.size >= 25) {
                    val hipMidY = (smoothed[23].y + smoothed[24].y) / 2f
                    val sensorDimForY = if (h > w) sensorWidthMm else sensorHeightMm
                    DistanceEstimator.estimate(
                        noseY          = smoothed[0].y,
                        hipMidY        = hipMidY,
                        imageHeightPx  = h,
                        focalMm        = focalLengthMm,
                        sensorHeightMm = sensorDimForY,
                    )
                } else null

                val rosaAngles = if (currentState == AppState.POSE && smoothed.size >= 29)
                    RosaAnglesCalculator.compute(smoothed, w, h) else null

                distanceIsOk = distanceM != null && distanceM in 1.7f..2.1f

                runOnUiThread {
                    poseOverlayView.updateLandmarks(smoothed, w, h)
                    poseOverlayView.updateRosaAngles(rosaAngles)
                    if (distanceM != null) {
                        val dOk = distanceM in 1.7f..2.1f
                        val key = when {
                            distanceM < 1.7f -> CaptureStrings.Key.CHIP_DISTANCE_TOO_CLOSE
                            distanceM > 2.1f -> CaptureStrings.Key.CHIP_DISTANCE_TOO_FAR
                            else             -> CaptureStrings.Key.CHIP_DISTANCE_OK
                        }
                        tvDistanceStatus.text = tr(key, "value" to "%.2f".format(distanceM))
                        tvDistanceStatus.setTextColor(if (dOk) COLOR_DETECTED else COLOR_NOT_DETECTED)
                    } else {
                        distanceIsOk = false
                        tvDistanceStatus.text = tr(CaptureStrings.Key.CHIP_DISTANCE_IDLE)
                        tvDistanceStatus.setTextColor(COLOR_NEUTRAL)
                    }
                }
            }.build()

        return PoseLandmarker.createFromOptions(this, options)
    }

    /** Creates the IMAGE-mode hand landmarker if not already created. Runs CPU
     *  delegate to avoid contending with the pose landmarker's GPU context — it
     *  only ever fires once, on a single still, so throughput doesn't matter. */
    private fun initializeHandLandmarker() {
        if (handLandmarker != null) return
        try {
            val options = HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(
                    BaseOptions.builder()
                        .setModelAssetPath("hand_landmarker.task")
                        .setDelegate(Delegate.CPU)
                        .build()
                )
                .setRunningMode(RunningMode.IMAGE)
                .setNumHands(2)
                .build()
            handLandmarker = HandLandmarker.createFromOptions(this, options)
        } catch (e: Exception) {
            Log.e("HandLandmarker", "Failed to create hand landmarker", e)
        }
    }

    // =========================================================================
    // Camera
    // =========================================================================

    private val cameraPermissionLauncher: ActivityResultLauncher<String> =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) setupCamera()
            else Toast.makeText(this, tr(CaptureStrings.Key.CAMERA_PERMISSION_REQUIRED), Toast.LENGTH_SHORT).show()
        }

    private fun requestCameraPermission() {
        if (hasCameraPermission()) setupCamera()
        else cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
    }

    private fun hasCameraPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun readCameraCharacteristics() {
        try {
            val mgr = getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val facing = if (cameraSelector == CameraSelector.DEFAULT_BACK_CAMERA)
                CameraCharacteristics.LENS_FACING_BACK else CameraCharacteristics.LENS_FACING_FRONT
            val id = mgr.cameraIdList.firstOrNull { cid ->
                mgr.getCameraCharacteristics(cid).get(CameraCharacteristics.LENS_FACING) == facing
            } ?: return
            val chars = mgr.getCameraCharacteristics(id)
            chars.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
                ?.firstOrNull()?.let { focalLengthMm = it }
            chars.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)?.let { sz ->
                // SizeF is always landscape (width > height) regardless of phone orientation
                sensorWidthMm  = sz.width
                sensorHeightMm = sz.height
            }
            Log.d("CameraChars", "focal=${focalLengthMm}mm  sensor=${sensorWidthMm}×${sensorHeightMm}mm")
        } catch (e: Exception) {
            Log.w("CameraChars", "Could not read characteristics: ${e.message}")
        }
    }

    private fun setupCamera() {
        readCameraCharacteristics()
        val future = ProcessCameraProvider.getInstance(this)
        future.addListener({
            val provider = future.get()
            cameraProvider = provider
            val preview  = Preview.Builder().build().apply { setSurfaceProvider(previewView.surfaceProvider) }
            // Without this CameraX analyses at 640×480, so the saved photos were
            // 480×640 and hands were too small for the hand landmarker. 1440×1080
            // (sensor orientation) gives 1080×1440 portrait frames, in line with
            // iOS, and keeps the 4:3 shape the preview uses so the overlay stays
            // aligned.
            val analysisResolution = ResolutionSelector.Builder()
                .setAspectRatioStrategy(AspectRatioStrategy.RATIO_4_3_FALLBACK_AUTO_STRATEGY)
                .setResolutionStrategy(
                    ResolutionStrategy(
                        Size(1440, 1080),
                        ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER,
                    )
                )
                .build()
            val analyzer = ImageAnalysis.Builder()
                .setResolutionSelector(analysisResolution)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build().apply { setAnalyzer(cameraExecutor, ::analyzeImage) }
            try {
                provider.unbindAll()
                provider.bindToLifecycle(this, cameraSelector, preview, analyzer)
            } catch (e: Exception) {
                Log.e("CameraSetup", "Bind failed", e)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    /**
     * Stops the camera feed and closes the pose landmarker once all shots are
     * captured — there's nothing left to detect while the photo review screen
     * is up, so keep it from burning CPU/battery in the background.
     *
     * unbindAll() must run on the main thread (camera lifecycle). The landmarker
     * close is posted onto cameraExecutor — the same single-thread executor that
     * calls detectAsync — so it's serialized after any in-flight frame analysis
     * instead of racing with it (closing while detectAsync is in flight crashes
     * MediaPipe; this also avoids closing it from inside its own result callback).
     */
    private fun pauseCameraPipeline() {
        cameraProvider?.unbindAll()
        cameraExecutor.execute {
            poseLandmarker?.close()
            poseLandmarker = null
        }
    }

    // =========================================================================
    // Frame analysis
    // =========================================================================

    @OptIn(ExperimentalGetImage::class)
    private fun analyzeImage(imageProxy: ImageProxy) {
        if (++frameCounter % processEveryNFrames != 0) { imageProxy.close(); return }

        val mediaImage = imageProxy.image
        if (mediaImage == null || imageProxy.format != ImageFormat.YUV_420_888) {
            Log.e("AnalyzeImage", "Unsupported format"); imageProxy.close(); return
        }

        if (!previewLaidOut) {
            // Upright (portrait) display dimensions, same basis the overlay uses.
            val rotated = imageProxy.imageInfo.rotationDegrees.let { it == 90 || it == 270 }
            val dispW = if (rotated) imageProxy.height else imageProxy.width
            val dispH = if (rotated) imageProxy.width else imageProxy.height
            previewLaidOut = true
            runOnUiThread { applyTopPreviewLayout(dispW, dispH) }
        }

        when (appState) {
            AppState.LIGHT_CHECK    -> runLightCheckPhase(mediaImage, imageProxy)
            AppState.DETECTING      -> runDetectionPhase(mediaImage, imageProxy)
            // FRONT also needs live pose frames, so it shares the pose pipeline.
            AppState.POSE, AppState.FRONT -> runPosePhase(imageProxy)
            AppState.DONE -> imageProxy.close()
        }
    }

    // -------------------------------------------------------------------------
    // Phase 1: Light check
    // -------------------------------------------------------------------------

    private fun runLightCheckPhase(mediaImage: Image, imageProxy: ImageProxy) {
        val luminance = computeLuminance(mediaImage)
        when {
            luminance < MIN_LUMINANCE -> runOnUiThread {
                updatePanel(lightOk = false, message = tr(CaptureStrings.Key.LIGHT_TOO_DARK))
            }
            luminance > MAX_LUMINANCE -> runOnUiThread {
                updatePanel(lightOk = false, message = tr(CaptureStrings.Key.LIGHT_TOO_BRIGHT))
            }
            else -> {
                // Light is good — start YOLO detection
                appState = AppState.DETECTING
                runOnUiThread { updatePanel(lightOk = true) }
            }
        }
        imageProxy.close()
    }

    // Average the Y (luma) plane, sampling every 20th pixel — same algorithm as live_guidence
    private fun computeLuminance(image: Image): Double {
        val yPlane    = image.planes[0]
        val yBuf      = yPlane.buffer
        val rowStride = yPlane.rowStride
        val width     = image.width
        val height    = image.height
        val step      = 20
        var sum   = 0L
        var count = 0
        var row = 0
        while (row < height) {
            var col = 0
            while (col < width) {
                sum += yBuf.get(row * rowStride + col).toInt() and 0xFF
                count++
                col += step
            }
            row += step
        }
        return if (count == 0) 0.5 else (sum.toDouble() / count) / 255.0
    }

    // -------------------------------------------------------------------------
    // Phase 2: YOLO detection
    // -------------------------------------------------------------------------

    private fun runDetectionPhase(mediaImage: Image, imageProxy: ImageProxy) {
        if (poseInitFailed) { imageProxy.close(); return }
        val result = yoloDetector?.detect(mediaImage, imageProxy.imageInfo.rotationDegrees)
            ?: run { imageProxy.close(); return }

        if (result.personDetected && result.monitorDetected) {
            confirmationCount++

            if (confirmationCount >= REQUIRED_CONFIRMATIONS) {
                runOnUiThread {
                    updatePanel(
                        lightOk         = true,
                        personDetected  = true,
                        monitorDetected = true,
                        confirmCount    = REQUIRED_CONFIRMATIONS,
                        message         = tr(CaptureStrings.Key.LOADING)
                    )
                }
                if (!initializePoseLandmarker()) {
                    poseInitFailed = true
                    runOnUiThread {
                        updatePanel(
                            lightOk         = true,
                            personDetected  = true,
                            monitorDetected = true,
                            message         = tr(CaptureStrings.Key.POSE_INIT_FAILED)
                        )
                    }
                    imageProxy.close()
                    return
                }
                appState = AppState.POSE
                yoloDetector?.dispose()
                yoloDetector = null
                runOnUiThread {
                    // Entering pose phase: keep the condition list visible but
                    // clear the detection-only progress bar and message.
                    confirmProgress.visibility = View.INVISIBLE
                    tvStatusMessage.visibility = View.GONE
                }
            } else {
                runOnUiThread {
                    updatePanel(
                        lightOk         = true,
                        personDetected  = true,
                        monitorDetected = true,
                        confirmCount    = confirmationCount,
                        message         = tr(CaptureStrings.Key.HOLD_STILL)
                    )
                }
            }
        } else {
            confirmationCount = 0
            runOnUiThread {
                updatePanel(
                    lightOk         = true,
                    personDetected  = result.personDetected,
                    monitorDetected = result.monitorDetected,
                    confirmCount    = 0
                )
            }
        }
        imageProxy.close()
    }

    // -------------------------------------------------------------------------
    // Phase 3: Pose detection
    // -------------------------------------------------------------------------

    private fun runPosePhase(imageProxy: ImageProxy) {
        // CameraX's own converter: handles any row/pixel stride layout and avoids
        // the lossy JPEG round-trip of a hand-rolled NV21 copy.
        val bitmap = imageProxy.toBitmap()
        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
            if (cameraSelector == CameraSelector.DEFAULT_FRONT_CAMERA)
                postScale(-1f, 1f, bitmap.width.toFloat(), bitmap.height.toFloat())
        }
        val rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        lastImageWidth  = rotated.width
        lastImageHeight = rotated.height
        lastFrameBitmap = rotated
        // CameraX timestamps are nanoseconds; MediaPipe wants strictly increasing
        // milliseconds.
        val timestampMs = maxOf(imageProxy.imageInfo.timestamp / 1_000_000L, lastPoseTimestampMs + 1)
        lastPoseTimestampMs = timestampMs
        try {
            poseLandmarker?.detectAsync(BitmapImageBuilder(rotated).build(), timestampMs)
        } catch (e: Exception) {
            Log.e("PoseLandmarker", "detectAsync failed", e)
        }
        imageProxy.close()
    }

    // =========================================================================
    // Side view check
    // =========================================================================

    /**
     * Returns true when the camera is at a side-on angle to the subject.
     *
     * Uses only hip spread relative to torso height. Hips stay planted in the
     * chair regardless of how much the person leans forward — making this
     * signal stable for typical seated office postures.
     *
     * Shoulder spread is intentionally excluded: when someone leans over a desk
     * MediaPipe shifts the shoulder landmarks, causing false "not side-on" reads.
     * Ears are intentionally excluded: the far ear can be occluded by hair or
     * head angle even when the camera is not truly side-on.
     *
     * Geometry: hipSpread ≈ hipWidth × cos(angleFromFrontal) / torsoHeight.
     * With typical proportions (hip width ≈ 70 % of torso height) a threshold
     * of 0.35 accepts angles within ~30° of true side view.
     */
    private fun checkSideView(smoothed: List<LandmarkPoint>, w: Int, h: Int): Boolean {
        if (smoothed.size < 25) return false
        val lHip = smoothed[23]; val rHip = smoothed[24]
        val lShoulder = smoothed[11]; val rShoulder = smoothed[12]
        val torsoH = kotlin.math.abs(
            (lShoulder.y + rShoulder.y) / 2f - (lHip.y + rHip.y) / 2f
        ) * h
        if (torsoH < 1f) return false
        return kotlin.math.abs(lHip.x - rHip.x) * w / torsoH < SIDE_VIEW_THRESHOLD
    }

    // =========================================================================
    // Panel UI helper
    // =========================================================================

    /**
     * Single method that drives all panel indicator states.
     *
     * lightOk  = null  → neutral grey (not yet checked)
     * lightOk  = false → red  (out of range, message shown)
     * lightOk  = true  → green (passed, locked)
     *
     * During LIGHT_CHECK: pass lightOk only; person/monitor stay neutral.
     * During DETECTING:   pass lightOk=true + person/monitorDetected + confirmCount.
     */
    private fun updatePanel(
        lightOk: Boolean?,
        personDetected: Boolean  = false,
        monitorDetected: Boolean = false,
        confirmCount: Int        = 0,
        message: String?         = null,
    ) {
        // Light
        tvLightStatus.setTextColor(when (lightOk) {
            null  -> COLOR_NEUTRAL
            true  -> COLOR_DETECTED
            false -> COLOR_NOT_DETECTED
        })

        // Person / monitor — grey until light passes
        val yoloActive = lightOk == true
        tvPersonStatus.setTextColor(when {
            !yoloActive    -> COLOR_NEUTRAL
            personDetected -> COLOR_DETECTED
            else           -> COLOR_NOT_DETECTED
        })
        tvMonitorStatus.setTextColor(when {
            !yoloActive     -> COLOR_NEUTRAL
            monitorDetected -> COLOR_DETECTED
            else            -> COLOR_NOT_DETECTED
        })

        // Progress bar
        val showProgress = yoloActive && personDetected && monitorDetected && confirmCount > 0
        confirmProgress.visibility = if (showProgress) View.VISIBLE else View.INVISIBLE
        confirmProgress.progress   = confirmCount

        // Status message
        if (message != null) {
            tvStatusMessage.text       = message
            tvStatusMessage.visibility = View.VISIBLE
        } else {
            tvStatusMessage.visibility = View.GONE
        }
    }

    /**
     * Writes the captured photos (skeleton already baked in) to the cache dir as JPEGs
     * and serialises the whole capture — grouped as `side_captures` (image + score +
     * angles per side shot) and one `front_capture` (image + the two raw front-view
     * angles) — to a single JSON object, handed back to MainActivity for Flutter.
     */
    private fun finishWithCaptures(sidePhotos: List<Bitmap>, scores: List<RosaScorer.Result?>) {
        // Before the review screen, run the monitor detector again on each side
        // photo and record whether it finds a monitor in it. The live
        // detector was released after the detection phase, so load it once
        // here, off the UI thread. A failed check leaves the value out.
        tvCaptureStatus.text = tr(CaptureStrings.Key.CHECKING_PHOTOS)
        val sideFrames = sideMonitorFrames.toList()
        Thread {
            val detector = try {
                YoloDetector(this)
            } catch (t: Throwable) {
                Log.e("YoloDetector", "monitor check unavailable", t)
                null
            }
            fun check(frame: Bitmap): YoloResult? {
                if (detector == null) return null
                return try {
                    detector.detect(frame)
                } catch (t: Throwable) {
                    Log.e("YoloDetector", "monitor check failed", t)
                    null
                }
            }
            val results = sideFrames.map { check(it) }
            detector?.dispose()
            val sideMonitor = results.map { it?.monitorDetected }
            val sideBoxes = results.map { it?.monitorBox }
            // Draw the monitor's box (split into three bands) on each side photo,
            // next to the eye-level line already on it.
            sidePhotos.forEachIndexed { i, photo ->
                sideBoxes.getOrNull(i)?.let { box ->
                    try {
                        drawMonitorBoxOntoPhoto(photo, box)
                    } catch (t: Throwable) {
                        Log.e("YoloDetector", "could not draw the monitor box", t)
                    }
                }
            }
            runOnUiThread { writeCaptures(sidePhotos, scores, sideMonitor, sideBoxes) }
        }.start()
    }

    /**
     * Draws the detected monitor's bounding box on a side photo, split into
     * three equal horizontal bands. Together with the eye-level line this shows
     * where the top of the monitor sits relative to the eyes: the line over the
     * box (monitor below eye level), in the top band (at eye level), or lower
     * (monitor above eye level).
     */
    private fun drawMonitorBoxOntoPhoto(photo: Bitmap, box: MonitorBox) {
        if (!photo.isMutable) return
        val canvas = Canvas(photo)
        val w = photo.width.toFloat()
        val h = photo.height.toFloat()
        val scale = w / SKELETON_REFERENCE_WIDTH

        val left = box.left * w; val right = box.right * w
        val top = box.top * h; val bottom = box.bottom * h
        if (right - left < 2f || bottom - top < 2f) return

        val color = Color.parseColor("#FFD600")
        val boxPaint = Paint().apply {
            this.color = color; style = Paint.Style.STROKE
            strokeWidth = 4f * scale; isAntiAlias = true
        }
        val bandPaint = Paint(boxPaint).apply {
            strokeWidth = 2.5f * scale
            pathEffect = android.graphics.DashPathEffect(floatArrayOf(14f * scale, 10f * scale), 0f)
        }
        canvas.drawRect(left, top, right, bottom, boxPaint)
        val third = (bottom - top) / 3f
        canvas.drawLine(left, top + third, right, top + third, bandPaint)
        canvas.drawLine(left, top + 2 * third, right, top + 2 * third, bandPaint)

        val labelPaint = Paint().apply {
            this.color = color; textSize = 30f * scale; isAntiAlias = true
            setShadowLayer(4f * scale, 0f, 0f, Color.BLACK)
        }
        // Above the box when there is room, otherwise just inside its top edge.
        val labelY = if (top > labelPaint.textSize * 1.4f) top - labelPaint.textSize * 0.4f
            else top + labelPaint.textSize * 1.1f
        canvas.drawText("Monitor", left + 6f * scale, labelY, labelPaint)
    }

    private fun writeCaptures(
        sidePhotos: List<Bitmap>,
        scores: List<RosaScorer.Result?>,
        sideMonitor: List<Boolean?>,
        sideBoxes: List<MonitorBox?>,
    ) {
        val dir = File(cacheDir, "posture_photos").apply { mkdirs() }

        fun write(bitmap: Bitmap, name: String): String {
            val file = File(dir, name)
            FileOutputStream(file).use { out -> bitmap.compress(Bitmap.CompressFormat.JPEG, 92, out) }
            return file.absolutePath
        }

        // The front camera's frames are mirrored before pose detection, which swaps
        // the model's left/right labels relative to the person's real body side.
        val mirrored = cameraSelector == CameraSelector.DEFAULT_FRONT_CAMERA

        val sideCaptures = org.json.JSONArray().also { arr ->
            sidePhotos.forEachIndexed { i, bitmap ->
                val obj = org.json.JSONObject()
                obj.put("image_path", write(bitmap, "side_${i + 1}.jpg"))
                capturedRawPoses.getOrNull(i)?.let { obj.put("raw_pose", it) }
                obj.put("rosa_score", scores.getOrNull(i)?.let { org.json.JSONObject(it.toMap()) }
                    ?: org.json.JSONObject())
                obj.put("body_angles", capturedAngles.getOrNull(i)?.let { org.json.JSONObject(it.toMap(mirrored)) }
                    ?: org.json.JSONObject())
                sideMonitor.getOrNull(i)?.let { obj.put("monitor_detected", it) }
                // Fractions of the photo. The backend derives "top of the monitor
                // relative to eye level" from these two, so the rule lives in
                // one place for both platforms.
                sideBoxes.getOrNull(i)?.let { box ->
                    obj.put("monitor_box", org.json.JSONObject().apply {
                        put("left", box.left.toDouble()); put("top", box.top.toDouble())
                        put("right", box.right.toDouble()); put("bottom", box.bottom.toDouble())
                    })
                }
                capturedEyeLevelY.getOrNull(i)?.let { obj.put("eye_level_y", it.toDouble()) }
                arr.put(obj)
            }
        }

        // wristExtension / shrugGap are measured per side-view shot (not the front
        // view) but were never surfaced (RosaAnglesCalculator.Angles doc comment).
        // Use the first valid side-shot's reading, same "first with data" choice
        // Flutter already makes for body_angles (BodyAngles.firstWithData).
        // The median of the side shots, so one odd frame doesn't decide it.
        fun median(values: List<Float>): Float {
            if (values.isEmpty()) return 0f
            val s = values.sorted()
            return if (s.size % 2 == 1) s[s.size / 2] else (s[s.size / 2 - 1] + s[s.size / 2]) / 2f
        }
        val measured = capturedAngles.filterNotNull()
        val wristExtensionFinding =
            median(measured.map { it.wristExtension }) >= WRIST_EXTENSION_FINDING_THRESHOLD
        val shrugGapValue = median(measured.map { it.shrugGap }).toDouble()

        val frontCapture = org.json.JSONObject().also { obj ->
            frontPhoto?.let { obj.put("image_path", write(it, "front.jpg")) }
            frontRawPose?.let { obj.put("raw_pose", it) }
            // Left out when it couldn't be measured — never reported as 0°.
            frontAbductionAngle?.let { obj.put("abduction_angle", it) }
            frontWristDeviationAngle?.let { obj.put("wrist_deviation_angle", it) }
            obj.put("wrist_extension", wristExtensionFinding)
            obj.put("shrug_gap", shrugGapValue)
        }

        // No front photo (skipped) → omit front_capture entirely; Flutter and the
        // backend both treat it as optional.
        val result = org.json.JSONObject()
            .put("side_captures", sideCaptures)
        if (frontPhoto != null) result.put("front_capture", frontCapture)

        setResult(Activity.RESULT_OK, Intent().putExtra(EXTRA_RESULT, result.toString()))
        finish()
    }

    // =========================================================================
    // Capture sequence — visual cues + skeleton baking
    // =========================================================================

    /** Draws the pose skeleton and ROSA angle arcs onto the photo so each still image is self-contained. */
    private fun bakeSkeletonOntoPhoto(
        photo: Bitmap,
        landmarks: List<LandmarkPoint>,
        angles: RosaAnglesCalculator.Angles?,
        excludeIndices: Set<Int> = emptySet(),
    ): Bitmap {
        val canvas = Canvas(photo)
        val w = photo.width.toFloat()
        val h = photo.height.toFloat()

        // The line/dot sizes below are tuned to look right at SKELETON_REFERENCE_WIDTH.
        // Scaling by (photo width / reference width) makes the skeleton's size a
        // fixed proportion of the photo's own resolution — a property "baked in"
        // and intrinsic to the image, not dependent on the capturing device's
        // screen size. That keeps the result identical across devices and stable
        // if the camera's capture resolution ever changes.
        val bakeScale = w / SKELETON_REFERENCE_WIDTH

        val linePaint = Paint().apply {
            color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 6f * bakeScale; isAntiAlias = true
        }
        val estimatedLinePaint = Paint().apply {
            color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 4f * bakeScale; isAntiAlias = true
            pathEffect = DashPathEffect(floatArrayOf(14f * bakeScale, 9f * bakeScale), 0f)
        }
        val dotPaint = Paint().apply { color = Color.GREEN; style = Paint.Style.FILL; isAntiAlias = true }
        val estimatedDotPaint = Paint().apply {
            color = Color.argb(160, 0, 220, 0); style = Paint.Style.FILL; isAntiAlias = true
        }

        for ((start, end) in PoseOverlayView.POSE_CONNECTIONS) {
            if (start in excludeIndices || end in excludeIndices) continue
            if (start < landmarks.size && end < landmarks.size) {
                val s = landmarks[start]
                val e = landmarks[end]
                val paint = if (s.estimated || e.estimated) estimatedLinePaint else linePaint
                canvas.drawLine(s.x * w, s.y * h, e.x * w, e.y * h, paint)
            }
        }
        for ((i, lm) in landmarks.withIndex()) {
            if (i in excludeIndices) continue
            val paint = if (lm.estimated) estimatedDotPaint else dotPaint
            val radius = (if (lm.estimated) 5f else 7f) * bakeScale
            canvas.drawCircle(lm.x * w, lm.y * h, radius, paint)
        }

        if (angles != null) {
            val arcPaint = Paint().apply {
                color = Color.parseColor("#FF5722"); style = Paint.Style.STROKE
                strokeWidth = 4f * bakeScale; isAntiAlias = true
            }
            val vertRefPaint = Paint().apply {
                color = Color.argb(200, 255, 87, 34); style = Paint.Style.STROKE
                strokeWidth = 3f * bakeScale; isAntiAlias = true
                pathEffect = DashPathEffect(floatArrayOf(12f * bakeScale, 8f * bakeScale), 0f)
            }
            val labelPaint = Paint().apply {
                color = Color.parseColor("#FF5722"); textSize = 36f * bakeScale; isAntiAlias = true
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                textAlign = Paint.Align.CENTER
            }
            PoseOverlayView.drawAngles(canvas, landmarks, angles, { x -> x * w }, { y -> y * h },
                arcPaint, vertRefPaint, labelPaint)
        }

        return photo
    }

    /** Runs the hand landmarker on a single still (IMAGE mode). Returns null if the
     *  landmarker isn't available or detection fails — the overlay is then simply
     *  skipped, never blocking the capture. */
    private fun detectHands(bitmap: Bitmap): HandLandmarkerResult? {
        val hl = handLandmarker ?: return null
        return try {
            hl.detect(BitmapImageBuilder(bitmap).build())
        } catch (e: Exception) {
            Log.e("HandLandmarker", "detect failed", e)
            null
        }
    }

    /** Draws each detected hand's 21-point skeleton (finger joints + palm) onto the
     *  photo, and joins each hand's wrist (point 0) to the nearest pose elbow with a
     *  white arm-style bone so the arm flows seamlessly into the detected hand.
     *  Uses the same white lines / green dots as the body skeleton so the hand reads
     *  as a continuation of the arm. [poseLandmarks] supplies the elbows (13/14). */
    private fun drawHandsOntoPhoto(
        photo: Bitmap,
        result: HandLandmarkerResult?,
        poseLandmarks: List<LandmarkPoint>,
    ) {
        val hands = handsToPoints(result)
        if (hands.isEmpty()) return

        val canvas = Canvas(photo)
        val w = photo.width.toFloat()
        val h = photo.height.toFloat()
        val bakeScale = w / SKELETON_REFERENCE_WIDTH

        // Same paints as the baked body skeleton (white bones, green joints).
        val linePaint = Paint().apply {
            color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 6f * bakeScale; isAntiAlias = true
        }
        val dotPaint = Paint().apply { color = Color.GREEN; style = Paint.Style.FILL; isAntiAlias = true }
        // Orange arc + label for the wrist angle, matching the side-view ROSA angles.
        val arcPaint = Paint().apply {
            color = Color.parseColor("#FF5722"); style = Paint.Style.STROKE
            strokeWidth = 4f * bakeScale; isAntiAlias = true
        }
        val labelPaint = Paint().apply {
            color = Color.parseColor("#FF5722"); textSize = 36f * bakeScale; isAntiAlias = true
            typeface = android.graphics.Typeface.DEFAULT_BOLD; textAlign = Paint.Align.CENTER
        }

        PoseOverlayView.drawHands(canvas, hands, poseLandmarks,
            { x -> x * w }, { y -> y * h }, linePaint, dotPaint, 7f * bakeScale, arcPaint, labelPaint)
    }

    /** Converts a hand-landmarker result into normalised [LandmarkPoint] lists (one
     *  per hand), the shape both the live overlay and the baked photo render. */
    private fun handsToPoints(result: HandLandmarkerResult?): List<List<LandmarkPoint>> =
        result?.landmarks()?.map { hand -> hand.map { LandmarkPoint(it.x(), it.y()) } } ?: emptyList()

    /** Bakes the front-view shoulder verticals + shoulder→elbow angle onto the photo,
     *  using the same dashed-orange reference / arc / label style as the ROSA arcs. */
    private fun drawShoulderAnglesOntoPhoto(photo: Bitmap, landmarks: List<LandmarkPoint>) {
        val canvas = Canvas(photo)
        val w = photo.width.toFloat()
        val h = photo.height.toFloat()
        val bakeScale = w / SKELETON_REFERENCE_WIDTH

        val vertPaint = Paint().apply {
            color = Color.argb(200, 255, 87, 34); style = Paint.Style.STROKE
            strokeWidth = 3f * bakeScale; isAntiAlias = true
            pathEffect = DashPathEffect(floatArrayOf(12f * bakeScale, 8f * bakeScale), 0f)
        }
        val arcPaint = Paint().apply {
            color = Color.parseColor("#FF5722"); style = Paint.Style.STROKE
            strokeWidth = 4f * bakeScale; isAntiAlias = true
        }
        val labelPaint = Paint().apply {
            color = Color.parseColor("#FF5722"); textSize = 36f * bakeScale; isAntiAlias = true
            typeface = android.graphics.Typeface.DEFAULT_BOLD; textAlign = Paint.Align.CENTER
        }
        PoseOverlayView.drawShoulderVerticals(canvas, landmarks,
            { x -> x * w }, { y -> y * h }, vertPaint, arcPaint, labelPaint)
    }

    /** Camera-shutter flash — brief white flash so the phone holder feels each shot register. */
    private fun triggerCaptureFlash() {
        flashOverlay.visibility = View.VISIBLE
        flashOverlay.alpha = 1f
        flashOverlay.animate().alpha(0f).setDuration(350)
            .withEndAction { flashOverlay.visibility = View.GONE }
            .start()
    }

    /** Drives tvCaptureStatus through the multi-shot sequence so the phone holder always
     *  knows: how many shots are done, whether to hold steady, or to adjust position. */
    private fun updateCaptureCue(allOk: Boolean) {
        val done = pendingSideShots.size
        if (done == 0 && !allOk) {
            tvCaptureStatus.visibility = View.GONE
            return
        }
        tvCaptureStatus.visibility = View.VISIBLE
        tvCaptureStatus.text = when {
            done >= TOTAL_SHOTS_NEEDED ->
                tr(CaptureStrings.Key.SHOTS_ALL_DONE, "total" to TOTAL_SHOTS_NEEDED)
            android.os.SystemClock.elapsedRealtime() < nextCaptureEarliestAtMs ->
                tr(CaptureStrings.Key.SHOT_DONE, "done" to done, "total" to TOTAL_SHOTS_NEEDED)
            allOk ->
                tr(CaptureStrings.Key.SHOT_CAPTURING, "number" to done + 1, "total" to TOTAL_SHOTS_NEEDED)
            else ->
                tr(CaptureStrings.Key.SHOT_GET_READY, "number" to done + 1, "total" to TOTAL_SHOTS_NEEDED)
        }
    }

    // =========================================================================
    // Front-view (4th) shot
    // =========================================================================

    /** Transitions from the side-shot phase to the front-view phase. Resets the
     *  smoother/leg estimator (the view is changing entirely) and arms the settle
     *  delay. Must be called on the result-listener thread — the same thread that
     *  reads the smoother — so the resets don't race a frame in flight. */
    private fun enterFrontPhase() {
        appState = AppState.FRONT
        okSinceMs = 0L
        frontReadyEarliestAtMs = android.os.SystemClock.elapsedRealtime() + FRONT_READY_DELAY_MS
        landmarkSmoother.reset()
        legEstimator.reset()
        // Prepare the hand landmarker now so it's ready to run on the front still.
        initializeHandLandmarker()
        runOnUiThread {
            poseOverlayView.setHeightGuide(PoseOverlayView.HeightGuideState.HIDDEN)
            // Live overlay mirrors the captured front photo: drop face/ears,
            // wrist/palm and legs from the skeleton, and show the shoulder verticals.
            poseOverlayView.setExcludedIndices(FRONT_SKELETON_EXCLUDE)
            poseOverlayView.setShowShoulderAngles(true)
            // None of the side-view conditions apply to the front shot — hide them
            // all and keep only the repurposed Side→Front chip.
            tvLightStatus.visibility    = View.GONE
            tvPersonStatus.visibility   = View.GONE
            tvMonitorStatus.visibility  = View.GONE
            tvRotationStatus.visibility = View.GONE
            tvTiltStatus.visibility     = View.GONE
            tvDistanceStatus.visibility = View.GONE
            tvCaptureStatus.visibility  = View.VISIBLE
            tvCaptureStatus.text = tr(CaptureStrings.Key.SIDE_PHOTOS_DONE)
        }
    }

    /** Max elbow abduction (shoulder→elbow angle from vertical, degrees) across both
     *  arms — the front-view "armrests too wide" measurement. Compared against
     *  ARMREST_ABDUCTION_MAX_DEG at the call site; the raw angle is also surfaced to
     *  Flutter. Uses the same angle drawn on the photo, in the image's pixel aspect
     *  ([w]×[h]). */
    private fun frontAbductionAngleDeg(landmarks: List<LandmarkPoint>, w: Int, h: Int): Double? {
        var maxAngle: Double? = null
        for ((shIdx, elIdx) in listOf(11 to 13, 12 to 14)) {
            if (shIdx >= landmarks.size || elIdx >= landmarks.size) continue
            val dx = (landmarks[elIdx].x - landmarks[shIdx].x) * w
            val dy = (landmarks[elIdx].y - landmarks[shIdx].y) * h
            val len = kotlin.math.hypot(dx.toDouble(), dy.toDouble())
            if (len < 1.0) continue
            val angle = Math.toDegrees(kotlin.math.acos(dy / len))
            if (maxAngle == null || angle > maxAngle) maxAngle = angle
        }
        return maxAngle
    }

    /** Max wrist deviation (front-view forearm→hand angle away from a straight 180°,
     *  degrees) across both hands — the "wrists deviate while typing" measurement.
     *  Compared against WRIST_DEVIATION_MAX_DEG at the call site; the raw angle is also
     *  surfaced to Flutter. Uses the forearm (elbow→wrist) vs hand axis (wrist→
     *  middle-finger MCP) angle drawn on the photo. [hands] are the hand-landmarker
     *  points; [poseLandmarks] supply the elbows (13/14). Returns null when no hand is
     *  usable — "not measured", which is not the same as a straight wrist. */
    private fun frontWristDeviationDeg(
        hands: List<List<LandmarkPoint>>,
        poseLandmarks: List<LandmarkPoint>,
        w: Int, h: Int,
    ): Double? {
        val elbows = listOfNotNull(poseLandmarks.getOrNull(13), poseLandmarks.getOrNull(14))
        if (elbows.isEmpty()) return null
        var maxDeviation: Double? = null
        for (hand in hands) {
            if (hand.size <= 9) continue
            val wrist = hand[0]; val mcp = hand[9]
            val nearest = elbows.minByOrNull {
                val dx = (it.x - wrist.x) * w; val dy = (it.y - wrist.y) * h
                dx * dx + dy * dy
            }!!
            val v1x = (nearest.x - wrist.x).toDouble() * w; val v1y = (nearest.y - wrist.y).toDouble() * h
            val v2x = (mcp.x - wrist.x).toDouble() * w;     val v2y = (mcp.y - wrist.y).toDouble() * h
            val m1 = kotlin.math.hypot(v1x, v1y); val m2 = kotlin.math.hypot(v2x, v2y)
            if (m1 < 1.0 || m2 < 1.0) continue
            val cosA = ((v1x * v2x + v1y * v2y) / (m1 * m2)).coerceIn(-1.0, 1.0)
            val deviation = 180.0 - Math.toDegrees(kotlin.math.acos(cosA))
            if (maxDeviation == null || deviation > maxDeviation) maxDeviation = deviation
        }
        return maxDeviation
    }

    /** Face (nose), both shoulders and both wrists all above the visibility bar. */
    private fun frontLandmarksVisible(raw: List<NormalizedLandmark>): Boolean {
        if (raw.size < 17) return false
        fun vis(i: Int) = raw[i].visibility().orElse(0f)
        val face      = vis(0)  >= FRONT_VISIBILITY_THRESHOLD
        val shoulders = vis(11) >= FRONT_VISIBILITY_THRESHOLD && vis(12) >= FRONT_VISIBILITY_THRESHOLD
        val hands     = vis(15) >= FRONT_VISIBILITY_THRESHOLD && vis(16) >= FRONT_VISIBILITY_THRESHOLD
        return face && shoulders && hands
    }

    /** True when the person faces the camera: shoulders spread wide relative to
     *  the nose→shoulder height, measured in pixels ([w]×[h]) so it doesn't depend
     *  on the frame's aspect ratio. Hips are not used — from the front they are
     *  usually hidden by the desk. */
    private fun isFacingCamera(landmarks: List<LandmarkPoint>, w: Int, h: Int): Boolean {
        if (landmarks.size < 13) return false
        val shoulderWidth = kotlin.math.abs(landmarks[11].x - landmarks[12].x) * w
        val neckHeight = kotlin.math.abs((landmarks[11].y + landmarks[12].y) / 2f - landmarks[0].y) * h
        if (neckHeight < 1f) return false
        return shoulderWidth / neckHeight >= FRONT_FACING_MIN_RATIO
    }

    /** Drives the capture banner + (repurposed) side chip during the front phase. */
    private fun updateFrontCue(
        frontVisible: Boolean, frontFacing: Boolean, rotationOk: Boolean, phoneSteady: Boolean,
    ) {
        tvCaptureStatus.visibility = View.VISIBLE
        val settling = android.os.SystemClock.elapsedRealtime() < frontReadyEarliestAtMs
        tvCaptureStatus.text = when {
            settling         -> tr(CaptureStrings.Key.FRONT_MOVE)
            !frontVisible    -> tr(CaptureStrings.Key.FRONT_SHOW_BODY)
            !frontFacing     -> tr(CaptureStrings.Key.FRONT_MOVE)
            !rotationOk      -> tr(CaptureStrings.Key.FRONT_STRAIGHTEN)
            !phoneSteady     -> tr(CaptureStrings.Key.FRONT_HOLD_PHONE_STILL)
            else             -> tr(CaptureStrings.Key.FRONT_CAPTURING)
        }
        val ok = frontVisible && frontFacing && rotationOk && phoneSteady
        tvSideViewStatus.setTextColor(if (ok) COLOR_DETECTED else COLOR_NOT_DETECTED)
        tvSideViewStatus.text = when {
            !frontVisible -> tr(CaptureStrings.Key.CHIP_FRONT_SHOW_BODY)
            !frontFacing  -> tr(CaptureStrings.Key.CHIP_FRONT_MOVE)
            !rotationOk   -> tr(CaptureStrings.Key.CHIP_FRONT_STRAIGHTEN)
            !phoneSteady  -> tr(CaptureStrings.Key.CHIP_FRONT_HOLD_STILL)
            else          -> tr(CaptureStrings.Key.CHIP_FRONT_OK)
        }
    }

    private fun setupEdgeToEdge() {
        // #181818 status/navigation bars (overrides the Material3 theme's default
        // purple status bar), with light icons so they stay visible. On Android 15
        // the bars are transparent and the root background shows through instead;
        // setting the colors covers older API levels where they're opaque.
        val barColor = Color.parseColor("#181818")
        window.statusBarColor = barColor
        window.navigationBarColor = barColor
        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = false
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom)
            insets
        }
    }

    /**
     * Anchors the camera preview (and its pose overlay + shutter flash) to the
     * top of the content area, [previewTopGapDp] below the status bar, sized to
     * the video's aspect ratio so it isn't vertically centered. The root already
     * pads for the status bar via [setupEdgeToEdge], so the gap is a plain top
     * margin. Giving all three views the same width:height ratio keeps the
     * skeleton overlay pixel-aligned with the preview.
     */
    private fun applyTopPreviewLayout(displayWidth: Int, displayHeight: Int) {
        if (displayWidth <= 0 || displayHeight <= 0) return
        val gap = (previewTopGapDp * resources.displayMetrics.density).toInt()
        val ratio = "$displayWidth:$displayHeight" // W:H
        for (id in intArrayOf(R.id.previewCam, R.id.poseOverlay, R.id.flashOverlay)) {
            val view = findViewById<View>(id)
            val lp = view.layoutParams as ConstraintLayout.LayoutParams
            lp.topToTop = ConstraintLayout.LayoutParams.PARENT_ID
            lp.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
            lp.startToStart = ConstraintLayout.LayoutParams.PARENT_ID
            lp.endToEnd = ConstraintLayout.LayoutParams.PARENT_ID
            lp.width = 0
            lp.height = 0
            lp.topMargin = gap
            lp.dimensionRatio = ratio
            view.layoutParams = lp
        }
    }

    override fun onResume() {
        super.onResume()
        tiltMonitor.start()
    }

    override fun onPause() {
        super.onPause()
        tiltMonitor.stop()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Stop new frames on the main thread, then free the native TFLite /
        // MediaPipe resources on the camera executor so the closes are serialized
        // after any in-flight frame analysis. Closing them directly on the main
        // thread races with inference still running on the executor and crashes in
        // native code (SIGSEGV in libtensorflowlite_jni when the interpreter is
        // freed mid-run — e.g. when the user swipes back during capture).
        cameraProvider?.unbindAll()
        cameraExecutor.execute {
            poseLandmarker?.close()
            poseLandmarker = null
            handLandmarker?.close()
            handLandmarker = null
            stillPoseLandmarker?.close()
            stillPoseLandmarker = null
            yoloDetector?.dispose()
            yoloDetector = null
        }
        cameraExecutor.shutdown()
    }
}
