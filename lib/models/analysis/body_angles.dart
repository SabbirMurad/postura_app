/// Body angles measured by the native PostureEngine for a single side-view shot.
///
/// These are the raw ROSA geometry readings, returned alongside `rosa_scores`
/// on the `posture_detection` MethodChannel.
///
/// Note: the engine also computes `shrugGap`, `wristExtension` and `mouseReach`
/// internally, but treats them as private scoring inputs and does not surface
/// them here — see the native RosaAnglesCalculator on either platform.
class BodyAngles {
  const BodyAngles({
    required this.side,
    required this.kneeAngle,
    required this.trunkAngle,
    required this.elbowAngle,
    required this.neckAngle,
    required this.neckState,
    required this.lowerBodyConfidence,
  });

  /// "Left" / "Right" — which side's landmarks were used. Empty when this entry
  /// carries no measurement (e.g. a shot where pose landmarks were unavailable).
  final String side;

  /// Hip–knee–ankle angle (degrees).
  final double kneeAngle;

  /// Shoulder→hip line, degrees from vertical.
  final double trunkAngle;

  /// Shoulder→elbow→wrist angle (degrees).
  final double elbowAngle;

  /// Ear→shoulder line, degrees from vertical.
  final double neckAngle;

  /// Raw native enum name, e.g. FORWARD_HEAD.
  final String neckState;

  /// HIGH / LOW — LOW means the knee landmark was reconstructed, so
  /// [kneeAngle] (and the seat-height score) is a best-effort estimate.
  final String lowerBodyConfidence;

  /// True when this entry actually holds a measurement. Null/empty native
  /// entries deserialize with a blank [side] and NaN angles.
  bool get hasData => side.isNotEmpty && !kneeAngle.isNaN;

  static double _d(Object? v) => v is num ? v.toDouble() : double.nan;

  factory BodyAngles.fromJson(Map<String, dynamic> m) => BodyAngles(
    side: m['side'] as String? ?? '',
    kneeAngle: _d(m['knee_angle']),
    trunkAngle: _d(m['trunk_angle']),
    elbowAngle: _d(m['elbow_angle']),
    neckAngle: _d(m['neck_angle']),
    neckState: m['neck_state'] as String? ?? '',
    lowerBodyConfidence: m['lower_body_confidence'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'side': side,
    'knee_angle': kneeAngle,
    'trunk_angle': trunkAngle,
    'elbow_angle': elbowAngle,
    'neck_angle': neckAngle,
    'neck_state': neckState,
    'lower_body_confidence': lowerBodyConfidence,
  };

  /// Human-readable neck posture, mapping the native enum names to labels.
  String get neckStateLabel {
    switch (neckState) {
      case 'NEUTRAL':
        return 'Neutral';
      case 'FORWARD_HEAD':
        return 'Forward head';
      case 'MILD_FLEXION':
        return 'Mild flexion';
      case 'SEVERE_FLEXION':
        return 'Severe flexion';
      case 'HEAD_BACK':
        return 'Head back';
      default:
        return neckState;
    }
  }

  /// The first entry holding an actual measurement, or null if none do.
  static BodyAngles? firstWithData(List<BodyAngles> angles) {
    for (final a in angles) {
      if (a.hasData) return a;
    }
    return null;
  }
}
