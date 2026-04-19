import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/rosa_constants.dart';
import '../../../../services/accelerometer_service.dart';
import '../../../../services/camera_service.dart';
import '../../../step1_detection/data/ml_detector.dart';
import '../../../step1_detection/domain/detection_result.dart';
import '../../../step2_pose/data/pose_detector.dart';
import '../../../step2_pose/domain/pose_result.dart';
import '../../data/face_blurrer.dart';
import '../../data/luminance_analyzer.dart';
import '../../data/rosa_scorer.dart';
import '../../data/storage_service.dart';
import '../../domain/capture_questionnaire.dart';
import '../../domain/capture_readiness.dart';
import '../../domain/gate_state.dart';
import 'capture_bloc_state.dart';
import 'capture_event.dart';

/// Manages the 7-condition autocapture flow for Step 3.
///
/// Conditions are evaluated **in order**:
/// 1. Framing (YOLO) — person + monitor visible
/// 2. Side profile — single ear visible (shoulder x-gap)
/// 3. Roll — phone level (accelerometer)
/// 4. Pitch — phone vertical (accelerometer)
/// 5. Lighting — luminance in range
/// 6. Final YOLO re-check (silent)
/// 7. Stability buffer — all conditions hold for 1.5s
class CaptureBloc extends Bloc<CaptureEvent, CaptureBlocState> {
  CaptureBloc({
    required MlDetector mlDetector,
    required PoseDetector poseDetector,
    required CameraService cameraService,
    required AccelerometerService accelerometerService,
    StorageService? storageService,
  }) : _mlDetector = mlDetector,
       _poseDetector = poseDetector,
       _cameraService = cameraService,
       _accelerometer = accelerometerService,
       _storage = storageService ?? StorageService(),
       super(const CaptureLoading()) {
    on<CaptureStarted>(_onStarted);
    on<CaptureFrameReceived>(_onFrameReceived);
    on<CaptureRetry>(_onRetry);
    on<CaptureStopped>(_onStopped);
  }

  final MlDetector _mlDetector;
  final PoseDetector _poseDetector;
  final CameraService _cameraService;
  final AccelerometerService _accelerometer;
  final StorageService _storage;
  final RosaScorer _scorer = RosaScorer();
  late CaptureQuestionnaire _questionnaire;

  CaptureReadiness _readiness = CaptureReadiness.initial();
  PoseResult? _lastPose;
  DetectionResult? _lastYolo;
  double _luminance = 0.5;

  bool _isProcessing = false;
  bool _stopped = false;
  DateTime? _processingStartedAt;

  // Stability timer.
  DateTime? _allGreenSince;

  // Timeout timer.
  Timer? _timeoutTimer;

  // YOLO state for pause/resume between conditions 1→5 and 6.
  bool _yoloPausedForMiddleGates = false;

  Future<void> _onStarted(
    CaptureStarted event,
    Emitter<CaptureBlocState> emit,
  ) async {
    try {
      _questionnaire = event.questionnaire;
      emit(const CaptureLoading());

      // Initialize YOLO (may already be initialized from Step 1).
      // Resume if paused.
      if (_mlDetector.isPaused) {
        _mlDetector.resume();
      }

      // Initialize pose detector.
      await _poseDetector.initialize();

      // Start accelerometer.
      _accelerometer.start();

      // Activate first gate.
      _readiness = CaptureReadiness.initial();
      _updateGate(CaptureGate.framing, GateStatus.checking);

      emit(
        CaptureGuiding(
          readiness: _readiness,
          guidanceText: CaptureGate.framing.guidanceText,
        ),
      );

      // Start timeout timer.
      _timeoutTimer = Timer(RosaConstants.conditionTimeout, () {
        if (!_stopped && state is CaptureGuiding) {
          add(const CaptureStopped());
          // We can't emit from timer — use a flag checked in next frame.
        }
      });
    } catch (e) {
      emit(CaptureError('Failed to initialize capture: $e'));
    }
  }

  /// ML inference timeout / watchdog limits.
  static const _mlTimeout = Duration(seconds: 4);
  static const _watchdogLimit = Duration(seconds: 5);

  Future<void> _onFrameReceived(
    CaptureFrameReceived event,
    Emitter<CaptureBlocState> emit,
  ) async {
    // ── Watchdog: force-reset if ML inference got stuck ──────────
    if (_isProcessing && _processingStartedAt != null) {
      final stuck = DateTime.now().difference(_processingStartedAt!);
      if (stuck > _watchdogLimit) {
        dev.log(
          'Watchdog: resetting stuck frame processing '
          '(${stuck.inMilliseconds}ms)',
          name: 'CaptureBloc',
        );
        _isProcessing = false;
      }
    }

    if (_isProcessing || _stopped) return;
    if (state is CaptureComplete || state is CaptureProcessing) return;

    _isProcessing = true;
    _processingStartedAt = DateTime.now();

    try {
      final frame = event.frame;

      // Measure luminance (sync, <5ms).
      _luminance = LuminanceAnalyzer.analyze(frame);

      // Run YOLO + Pose in PARALLEL when both needed.
      // Wrapped in timeout so a hung native call can't block forever.
      final activeGate = _readiness.activeGate;
      final needsYolo =
          activeGate == CaptureGate.framing ||
          activeGate == CaptureGate.finalYolo;

      try {
        if (needsYolo) {
          if (_yoloPausedForMiddleGates) {
            _mlDetector.resume();
            _yoloPausedForMiddleGates = false;
          }
          final results = await Future.wait([
            _poseDetector.processFrame(frame),
            _mlDetector.processFrame(frame),
          ]).timeout(_mlTimeout);
          _lastPose = results[0] as PoseResult;
          _lastYolo = results[1] as DetectionResult;
        } else {
          _lastPose = await _poseDetector
              .processFrame(frame)
              .timeout(_mlTimeout);
        }
      } on TimeoutException {
        dev.log(
          'ML inference timeout — evaluating gates with stale data',
          name: 'CaptureBloc',
        );
      }

      // Evaluate gates — always runs, even after ML timeout.
      _evaluateGates();

      // Check stability.
      if (_readiness.allPassed) {
        _allGreenSince ??= DateTime.now();
        final elapsed = DateTime.now()
            .difference(_allGreenSince!)
            .inMilliseconds;

        if (elapsed >= RosaConstants.stabilityBuffer.inMilliseconds) {
          await _triggerCapture(emit);
          return;
        }

        emit(
          CaptureStabilizing(
            readiness: _readiness,
            elapsedMs: elapsed,
            lastPoseResult: _lastPose,
          ),
        );
      } else {
        _allGreenSince = null;

        String guidanceText;
        if (_readiness.activeGate == CaptureGate.lighting) {
          guidanceText =
              LuminanceAnalyzer.guidanceFor(_luminance) ??
              _readiness.activeGate!.guidanceText;
        } else {
          guidanceText = _readiness.activeGate?.guidanceText ?? '';
        }
        emit(
          CaptureGuiding(
            readiness: _readiness,
            guidanceText: guidanceText,
            lastPoseResult: _lastPose,
            luminance: _luminance,
          ),
        );
      }
    } catch (e, stack) {
      dev.log('Capture frame error: $e\n$stack', name: 'CaptureBloc');
    } finally {
      _isProcessing = false;
      _processingStartedAt = null;
    }
  }

  /// Evaluate all 7 gates in order.
  void _evaluateGates() {
    // Gate 1: Framing (YOLO).
    if (_gateStatus(CaptureGate.framing) != GateStatus.passed) {
      final yoloOk = _lastYolo?.bothDetected ?? false;
      if (yoloOk) {
        _updateGate(CaptureGate.framing, GateStatus.passed);
        // Pause YOLO for conditions 2-5.
        _mlDetector.pause();
        _yoloPausedForMiddleGates = true;
        _updateGate(CaptureGate.sideProfile, GateStatus.checking);
      } else {
        _updateGate(CaptureGate.framing, GateStatus.checking);
      }
      _setActiveGate(CaptureGate.framing);
      return;
    }

    // Gate 2: Side profile.
    if (_gateStatus(CaptureGate.sideProfile) != GateStatus.passed) {
      final sideOk = _isSideProfile();
      if (sideOk) {
        _updateGate(CaptureGate.sideProfile, GateStatus.passed);
        _updateGate(CaptureGate.roll, GateStatus.checking);
      } else {
        _updateGate(CaptureGate.sideProfile, GateStatus.checking);
        _setActiveGate(CaptureGate.sideProfile);
        return;
      }
    }

    // Gate 3: Roll.
    if (_gateStatus(CaptureGate.roll) != GateStatus.passed) {
      if (_accelerometer.isRollOk) {
        _updateGate(CaptureGate.roll, GateStatus.passed);
        _updateGate(CaptureGate.pitch, GateStatus.checking);
      } else {
        _updateGate(CaptureGate.roll, GateStatus.checking);
        _setActiveGate(CaptureGate.roll);
        return;
      }
    }

    // Gate 4: Pitch.
    if (_gateStatus(CaptureGate.pitch) != GateStatus.passed) {
      if (_accelerometer.isPitchOk) {
        _updateGate(CaptureGate.pitch, GateStatus.passed);
        _updateGate(CaptureGate.lighting, GateStatus.checking);
      } else {
        _updateGate(CaptureGate.pitch, GateStatus.checking);
        _setActiveGate(CaptureGate.pitch);
        return;
      }
    }

    // Gate 5: Lighting.
    if (_gateStatus(CaptureGate.lighting) != GateStatus.passed) {
      if (LuminanceAnalyzer.isAcceptable(_luminance)) {
        _updateGate(CaptureGate.lighting, GateStatus.passed);
        // Resume YOLO for final check.
        _mlDetector.resume();
        _yoloPausedForMiddleGates = false;
        _updateGate(CaptureGate.finalYolo, GateStatus.checking);
      } else {
        _updateGate(CaptureGate.lighting, GateStatus.checking);
        _setActiveGate(CaptureGate.lighting);
        return;
      }
    }

    // Gate 6: Final YOLO re-check (silent).
    if (_gateStatus(CaptureGate.finalYolo) != GateStatus.passed) {
      final yoloOk = _lastYolo?.bothDetected ?? false;
      if (yoloOk) {
        _updateGate(CaptureGate.finalYolo, GateStatus.passed);
        _updateGate(CaptureGate.stability, GateStatus.checking);
      } else {
        // Scene changed — worker/monitor no longer visible.
        // Reset ALL gates to force re-framing from Gate 1.
        // Otherwise gates 1-5 stay falsely green while user is stuck.
        _resetGatesToFraming();
        return;
      }
    }

    // Gate 7: Stability — handled by the timer above.
    _updateGate(CaptureGate.stability, GateStatus.checking);
    _setActiveGate(CaptureGate.stability);

    // Check if ALL are passed.
    final allPassed = CaptureGate.values
        .where((g) => g != CaptureGate.stability)
        .every((g) => _gateStatus(g) == GateStatus.passed);

    _readiness = _readiness.copyWith(
      allPassed: allPassed,
      clearActiveGate: allPassed,
    );
  }

  /// Check if pose shows side profile.
  ///
  /// Instead of relying on SideSelector (needs 5-frame warm-up in a
  /// fresh PoseDetector), check directly: if pose landmarks are detected
  /// with enough reliable points, the person is in a usable side view.
  /// Step 2 already verified proper side positioning before we got here.
  bool _isSideProfile() {
    if (_lastPose == null || !_lastPose!.poseDetected) return false;
    // If we can see 6+ reliable landmarks, it's a good side view.
    // The SideSelector may still be warming up (needs 5 frames), so
    // also accept a determined side.
    return _lastPose!.reliableLandmarkCount >= 6 ||
        _lastPose!.activeSide != BodyOrientation.unknown;
  }

  /// Trigger photo capture and ROSA scoring.
  Future<void> _triggerCapture(Emitter<CaptureBlocState> emit) async {
    _timeoutTimer?.cancel();

    // Mark all gates passed.
    for (final gate in CaptureGate.values) {
      _updateGate(gate, GateStatus.passed);
    }
    _readiness = _readiness.copyWith(allPassed: true, clearActiveGate: true);

    emit(CaptureProcessing(readiness: _readiness, progress: 0.0));

    try {
      // Stop YOLO — no longer needed.
      _mlDetector.pause();

      // Capture photo.
      emit(CaptureProcessing(readiness: _readiness, progress: 0.2));
      final imagePath = await _cameraService.capturePhoto();

      // Score.
      emit(CaptureProcessing(readiness: _readiness, progress: 0.5));
      final landmarks = _lastPose?.landmarks ?? [];
      final rosaScore = _scorer.score(
        landmarks,
        mouseCb: _questionnaire.mouseCb,
        durationModifier: _questionnaire.durationModifier,
      );

      // Face blur.
      emit(CaptureProcessing(readiness: _readiness, progress: 0.7));
      await FaceBlurrer.blurFace(imagePath: imagePath, landmarks: landmarks);

      // Apply storage policy (Option A/B/C + auto-delete toggle).
      // Returns null if image was deleted.
      emit(CaptureProcessing(readiness: _readiness, progress: 0.9));
      final keptImagePath = await _storage.applyToRawImage(imagePath);

      emit(CaptureProcessing(readiness: _readiness, progress: 1.0));

      // Brief delay so user sees progress bar complete.
      await Future.delayed(const Duration(milliseconds: 300));

      emit(
        CaptureComplete(
          rosaScore: rosaScore,
          // Pass empty string if image was deleted by storage policy.
          // Review screen handles missing image gracefully.
          imagePath: keptImagePath ?? '',
          poseResult: _lastPose ?? const PoseResult.empty(),
          questionnaire: _questionnaire,
        ),
      );
    } catch (e) {
      dev.log('Capture error: $e', name: 'CaptureBloc');
      emit(CaptureError('Failed to capture: $e'));
    }
  }

  Future<void> _onRetry(
    CaptureRetry event,
    Emitter<CaptureBlocState> emit,
  ) async {
    _stopped = false;
    _isProcessing = false;
    _allGreenSince = null;
    _lastYolo = null;
    _lastPose = null;
    _yoloPausedForMiddleGates = false;
    _readiness = CaptureReadiness.initial();
    _updateGate(CaptureGate.framing, GateStatus.checking);

    // Reinitialize services that were shut down on timeout.
    _mlDetector.resume();
    _accelerometer.start();
    await _poseDetector.initialize();

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(RosaConstants.conditionTimeout, () {
      if (!_stopped && state is CaptureGuiding) {
        add(const CaptureStopped());
      }
    });

    emit(
      CaptureGuiding(
        readiness: _readiness,
        guidanceText: CaptureGate.framing.guidanceText,
      ),
    );
  }

  Future<void> _onStopped(
    CaptureStopped event,
    Emitter<CaptureBlocState> emit,
  ) async {
    _stopped = true;
    _timeoutTimer?.cancel();
    // Don't shutdown pose detector or dispose accelerometer here —
    // user may Retry. Full cleanup happens in close().
    emit(const CaptureTimeout());
  }

  @override
  Future<void> close() async {
    _timeoutTimer?.cancel();
    _accelerometer.dispose();
    if (!_stopped) {
      await _poseDetector.shutdown();
    }
    return super.close();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  GateStatus _gateStatus(CaptureGate gate) =>
      _readiness.gates[gate] ?? GateStatus.pending;

  void _updateGate(CaptureGate gate, GateStatus status) {
    final gates = Map<CaptureGate, GateStatus>.from(_readiness.gates);
    gates[gate] = status;
    _readiness = _readiness.copyWith(gates: gates);
  }

  void _setActiveGate(CaptureGate gate) {
    _readiness = _readiness.copyWith(activeGate: gate);
  }

  /// Reset ALL gates back to the start (framing) and resume YOLO.
  ///
  /// Called when Gate 6 detects that the scene has changed — worker
  /// or monitor is no longer visible. User gets Gate 1 guidance again
  /// so they can reframe.
  void _resetGatesToFraming() {
    _allGreenSince = null;
    _lastYolo = null;
    _yoloPausedForMiddleGates = false;
    _mlDetector.resume();

    final gates = <CaptureGate, GateStatus>{
      for (final gate in CaptureGate.values) gate: GateStatus.pending,
    };
    gates[CaptureGate.framing] = GateStatus.checking;
    _readiness = _readiness.copyWith(
      gates: gates,
      activeGate: CaptureGate.framing,
      allPassed: false,
    );
  }
}
