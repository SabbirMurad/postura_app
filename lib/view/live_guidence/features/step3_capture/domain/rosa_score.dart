/// Result of ROSA scoring with final score and breakdown.
class RosaScore {
  const RosaScore({
    required this.finalScore,
    required this.chairScore,
    required this.monitorScore,
    required this.keyboardScore,
    required this.mouseScore,
    required this.peripheralScore,
    required this.seatHeightScore,
    required this.backrestScore,
    required this.armrestScore,
    required this.kneeAngle,
    required this.trunkAngle,
    required this.neckFlexion,
    required this.forwardHead,
    required this.wristExtension,
  });

  /// Final ROSA score (1–10).
  final int finalScore;

  /// Section A: Chair combined score.
  final int chairScore;

  /// Monitor subscore (1–3).
  final int monitorScore;

  /// Keyboard subscore (1–3).
  final int keyboardScore;

  /// Mouse subscore (1–3).
  final int mouseScore;

  /// Peripheral combined score (from TABLE D).
  final int peripheralScore;

  /// Chair sub-components.
  final int seatHeightScore;
  final int backrestScore;
  final int armrestScore;

  /// Raw computed angles for debug / display.
  final double kneeAngle;
  final double trunkAngle;
  final double neckFlexion;
  final double forwardHead;
  final double wristExtension;

  /// Risk level label based on final score.
  String get riskLevel {
    if (finalScore <= 2) return 'Low Risk';
    if (finalScore <= 4) return 'Medium Risk';
    if (finalScore <= 6) return 'High Risk';
    return 'Very High Risk';
  }

  /// Whether action is needed.
  bool get needsAction => finalScore >= 5;
}
