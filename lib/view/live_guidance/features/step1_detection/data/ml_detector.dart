import '../../../services/camera_service.dart';
import '../domain/detection_result.dart';

/// Interface contract between the Flutter frontend and the ML backend.
///
/// The ML developer implements this class to integrate EfficientDet-Lite0.
/// The Flutter side codes against this abstraction only.
abstract class MlDetector {
  /// Process a single camera frame and return a per-frame detection result.
  ///
  /// Called by the BLoC at 2 fps. The implementation is responsible for:
  /// - Converting [frame] to the format required by the model
  /// - Running inference
  /// - Applying confidence filtering (≥ 0.5)
  /// - Returning which objects were detected
  Future<DetectionResult> processFrame(CopiedCameraFrame frame);

  /// Fully dispose the model interpreter and release all memory.
  ///
  /// After this call, [processFrame] must not be called again.
  Future<void> shutdown();

  /// Initialise the model. Called once before the first frame arrives.
  Future<void> initialize();

  /// Pause processing — model stays loaded, frames return empty result.
  ///
  /// Used in Step 3: YOLO pauses between conditions 1 and 6.
  void pause();

  /// Resume processing after a pause.
  void resume();

  /// Whether the detector is currently paused.
  bool get isPaused;
}
