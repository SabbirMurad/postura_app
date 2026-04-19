/// Computed angles from pose landmarks for ROSA scoring.
class AngleResult {
  const AngleResult({
    required this.kneeAngle,
    required this.trunkAngle,
    required this.neckFlexion,
    required this.forwardHead,
    required this.wristExtension,
    required this.shoulderShrug,
    required this.mouseReach,
  });

  /// Hip-knee-ankle angle (degrees). ~90 = neutral seated.
  final double kneeAngle;

  /// Shoulder-hip deviation from vertical (degrees).
  final double trunkAngle;

  /// Ear_y - nose_y — positive = looking down.
  final double neckFlexion;

  /// Shoulder_x - ear_x — positive = head forward of shoulders.
  final double forwardHead;

  /// Elbow_y - wrist_y — positive = wrist extended upward.
  final double wristExtension;

  /// Ear_y - shoulder_y — negative = shrug.
  final double shoulderShrug;

  /// |Wrist_x - shoulder_x| — lateral mouse reach.
  final double mouseReach;
}
