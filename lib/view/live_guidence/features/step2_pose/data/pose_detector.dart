import '../../../services/camera_service.dart';
import '../domain/pose_result.dart';

/// Abstract interface for pose landmark detection.
/// Mirrors the MlDetector pattern from Step 1.
abstract class PoseDetector {
  /// Initialize the pose detection model.
  Future<void> initialize();

  /// Process a single camera frame and return pose landmarks.
  Future<PoseResult> processFrame(CopiedCameraFrame frame);

  /// Shut down the detector and release resources.
  Future<void> shutdown();
}
