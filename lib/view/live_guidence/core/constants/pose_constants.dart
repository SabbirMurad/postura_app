import 'dart:math';

/// Constants governing Step 2 pose landmark detection.
abstract final class PoseConstants {
  /// Frame rate during pose detection (faster than Step 1's 2fps).
  static const int targetFps = 10;
  static const Duration frameInterval = Duration(milliseconds: 100);

  /// Confidence threshold — landmarks below this are unreliable.
  static const double minLikelihood = 0.5;

  /// Side detection: must see new side win for N consecutive frames before switching.
  static const int sideSwitchWindow = 5;

  /// One Euro filter parameters.
  /// min_cutoff: lower = more smoothing when still.
  /// beta: higher = more responsive during movement.
  /// dCutoff: derivative low-pass cutoff.
  static const double oneEuroMinCutoff = 1.0;
  static const double oneEuroBeta = 0.7;
  static const double oneEuroDCutoff = 1.0;

  /// Stability: stddev threshold (normalized units) below which pose is "stable".
  /// 0.018 = allows ~13px movement at 720p. Accounts for natural breathing
  /// and micro-shifts of a seated person. 0.01 was too strict — a person
  /// holding still would never reach stable=true due to involuntary motion.
  static const double stabilityStdDevThreshold = 0.018;

  /// Number of frames to compute stddev over for stability check.
  static const int stabilityWindow = 10;

  /// Number of required landmarks for pose to be considered complete.
  static const int requiredLandmarks = 8;

  /// Pre-computed 2*pi for One Euro filter.
  static const double twoPi = 2 * pi;
}
