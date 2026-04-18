/// Constants governing Step 1 frame validation behaviour.
abstract final class DetectionConstants {
  /// Minimum confidence score to count a detection (40%).
  /// Validated with YOLOv8n: 50/50 client images pass at 0.40.
  static const double confidenceThreshold = 0.40;

  /// Number of frames in the rolling confirmation window.
  /// Increased from 6 to 12 — gives more room for sporadic detections
  /// (especially monitor on iOS where detection is intermittent).
  static const int windowSize = 12;

  /// Minimum positive frames within [windowSize] to fire CONFIRMED.
  /// 4 out of 12 (33%) — works for both consistent Android detections
  /// and sporadic iOS monitor detections.
  static const int requiredPositives = 4;

  /// Target frames-per-second sent to the ML layer.
  static const int targetFps = 2;

  /// Interval between frames derived from [targetFps].
  static const Duration frameInterval = Duration(milliseconds: 500);

  /// Optional pause after GREEN so the user can see the indicator.
  static const Duration greenDisplayPause = Duration(milliseconds: 300);
}
