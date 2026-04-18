import '../core/constants/pose_constants.dart';
import '../features/step1_detection/data/ml_detector.dart';
import 'camera_service.dart';

/// Orchestrates the sequential handoff from Step 1 → Step 2.
///
/// Ensures Step 1 is fully disposed before Step 2 initializes.
class PipelineController {
  PipelineController({required this.cameraService, required this.mlDetector});

  final CameraService cameraService;
  final MlDetector mlDetector;

  /// Execute the Step 1 → Step 2 handoff.
  ///q
  /// 1. Stop frame sampling
  /// 2. Shut down the Step 1 ML model (free isolate + GPU resources)
  /// 3. Brief pause so user sees GREEN indicator
  /// 4. Switch camera to higher fps for pose detection
  /// 5. Restart frame sampling at new fps
  /// 6. Invoke [onStep2Ready] callback
  Future<void> handoffToStep2({required void Function() onStep2Ready}) async {
    // 1. Stop the 2fps frame loop.
    await cameraService.stopFrameSampling();

    // 2. Dispose Step 1 model (fire-and-forget — don't block navigation).
    mlDetector.shutdown();

    // 3. Switch camera to 10fps for pose detection.
    cameraService.setFrameRate(PoseConstants.targetFps);

    // 4. Restart frame sampling at new fps.
    cameraService.startFrameSampling();

    // 5. Signal that Step 2 can begin.
    onStep2Ready();
  }

  /// Restore Step 1 frame rate (e.g., when returning from Step 2).
  void restoreStep1FrameRate() {
    cameraService.setFrameRate(2); // Step 1 default: 2fps
  }

  /// Full cleanup — call when exiting the pipeline entirely.
  Future<void> dispose() async {
    await cameraService.dispose();
  }
}
