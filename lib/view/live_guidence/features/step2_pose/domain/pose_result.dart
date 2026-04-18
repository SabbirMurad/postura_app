import 'pose_landmark.dart';

/// Which side of the body is facing the camera.
enum BodyOrientation { left, right, unknown }

/// Per-frame pose detection result.
class PoseResult {
  /// The 8 tracked landmarks (one per BodyPart).
  final List<PoseLandmark> landmarks;

  /// Which side is currently active (left or right profile).
  final BodyOrientation activeSide;

  /// Whether the pose is stable (low stddev across recent frames).
  final bool isStable;

  /// Sequential frame number for tracking.
  final int frameNumber;

  const PoseResult({
    required this.landmarks,
    required this.activeSide,
    required this.isStable,
    required this.frameNumber,
  });

  /// Empty result when no pose is detected.
  const PoseResult.empty()
    : landmarks = const [],
      activeSide = BodyOrientation.unknown,
      isStable = false,
      frameNumber = 0;

  /// Whether a pose was detected at all.
  bool get poseDetected => landmarks.isNotEmpty;

  /// Number of reliable landmarks (above confidence threshold).
  int get reliableLandmarkCount => landmarks.where((l) => l.isReliable).length;

  /// Whether all 8 landmarks are reliable.
  bool get allLandmarksReliable => reliableLandmarkCount == 8;
}
