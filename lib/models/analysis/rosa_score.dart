/// ROSA score for a single captured shot.
///
/// Mirrors the native `RosaScorer.Result.toMap()` contract emitted by the
/// PostureEngine over the `posture_detection` MethodChannel (Kotlin and Swift
/// produce identical snake_case keys).
///
/// Scores are 0–10; [invalidScore] (11) is the sentinel the native side uses
/// when angles couldn't be computed for a shot.
class RosaScore {
  const RosaScore({
    required this.finalScore,
    required this.riskLevel,
    required this.chairScore,
    required this.peripheralScore,
    required this.monitorAreaScore,
    required this.mouseKeyboardAreaScore,
    required this.seatHeightScore,
    required this.backrestScore,
    required this.armrestScore,
    required this.monitorScore,
    required this.keyboardScore,
    required this.mouseScore,
  });

  /// Sentinel for "not measurable" — valid ROSA scores are 0–10.
  static const int invalidScore = 11;

  /// Final ROSA score (1–10).
  final int finalScore;

  /// Risk band derived natively from [finalScore].
  final String riskLevel;

  /// Section A.
  final int chairScore;

  /// max(sectB, sectC).
  final int peripheralScore;

  /// Section B — monitor & telephone.
  final int monitorAreaScore;

  /// Section C — mouse & keyboard.
  final int mouseKeyboardAreaScore;

  /// Chair sub-components.
  final int seatHeightScore;
  final int backrestScore;
  final int armrestScore;

  /// Peripheral sub-components.
  final int monitorScore;
  final int keyboardScore;
  final int mouseScore;

  /// Whether this shot produced a usable measurement.
  bool get isValid => finalScore <= 10;

  /// Whether action is needed.
  bool get needsAction => finalScore >= 5;

  static int _i(Object? v) => v is num ? v.toInt() : invalidScore;

  factory RosaScore.fromJson(Map<String, dynamic> m) => RosaScore(
    finalScore: _i(m['final_score']),
    riskLevel: m['risk_level'] as String? ?? 'Unknown',
    chairScore: _i(m['chair_score']),
    peripheralScore: _i(m['peripheral_score']),
    monitorAreaScore: _i(m['monitor_area_score']),
    mouseKeyboardAreaScore: _i(m['mouse_keyboard_area_score']),
    seatHeightScore: _i(m['seat_height_score']),
    backrestScore: _i(m['backrest_score']),
    armrestScore: _i(m['armrest_score']),
    monitorScore: _i(m['monitor_score']),
    keyboardScore: _i(m['keyboard_score']),
    mouseScore: _i(m['mouse_score']),
  );

  /// The 9 sub-scores the backend's `RosaInput` consumes. The native-only
  /// extras (`risk_level`, `monitor_area_score`, `mouse_keyboard_area_score`)
  /// are kept on the model for the UI but not sent — the backend ignores them.
  Map<String, dynamic> toJson() => {
    'final_score': finalScore,
    'chair_score': chairScore,
    'peripheral_score': peripheralScore,
    'seat_height_score': seatHeightScore,
    'backrest_score': backrestScore,
    'armrest_score': armrestScore,
    'monitor_score': monitorScore,
    'keyboard_score': keyboardScore,
    'mouse_score': mouseScore,
  };

  /// Collapses the per-shot scores from one capture session into a single
  /// score. The engine captures multiple photos per session but the backend
  /// stores one score per scan.
  ///
  /// Invalid shots are excluded; each field is the rounded mean of the valid
  /// ones and [riskLevel] is re-derived from the averaged [finalScore] using
  /// the native thresholds. Returns an all-invalid score if nothing is valid.
  factory RosaScore.average(List<RosaScore> scores) {
    final valid = scores.where((s) => s.isValid).toList();
    if (valid.isEmpty) return RosaScore.fromJson(const {});

    int avg(int Function(RosaScore) field) =>
        (valid.map(field).reduce((a, b) => a + b) / valid.length).round();

    final finalScore = avg((s) => s.finalScore);
    return RosaScore(
      finalScore: finalScore,
      riskLevel: riskLevelFor(finalScore),
      chairScore: avg((s) => s.chairScore),
      peripheralScore: avg((s) => s.peripheralScore),
      monitorAreaScore: avg((s) => s.monitorAreaScore),
      mouseKeyboardAreaScore: avg((s) => s.mouseKeyboardAreaScore),
      seatHeightScore: avg((s) => s.seatHeightScore),
      backrestScore: avg((s) => s.backrestScore),
      armrestScore: avg((s) => s.armrestScore),
      monitorScore: avg((s) => s.monitorScore),
      keyboardScore: avg((s) => s.keyboardScore),
      mouseScore: avg((s) => s.mouseScore),
    );
  }

  /// Mirrors the native RosaScorer thresholds.
  static String riskLevelFor(int finalScore) {
    if (finalScore <= 2) return 'Low Risk';
    if (finalScore <= 4) return 'Medium Risk';
    if (finalScore <= 6) return 'High Risk';
    return 'Very High Risk';
  }
}
