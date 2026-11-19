import 'package:posture_detector_app/utils/l10n.dart';

/// Body angles measured by the native PostureEngine for a single side-view shot.
///
/// These are the raw ROSA geometry readings, returned alongside `rosa_scores`
/// on the `posture_detection` MethodChannel.
///
/// The engine also surfaces its raw scoring offsets ([shrugGap],
/// [wristExtension], [mouseReach]). They aren't shown; they're sent to the
/// backend, which scores a photos-only scan once the ergonomist answers the
/// workstation checklist.
class BodyAngles {
  const BodyAngles({
    required this.side,
    required this.kneeAngle,
    required this.trunkAngle,
    required this.elbowAngle,
    required this.neckAngle,
    required this.neckState,
    required this.lowerBodyConfidence,
    this.shrugGap,
    this.wristExtension,
    this.mouseReach,
    this.trunkRecline,
    this.thighSlope,
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

  /// Raw normalized offsets (ear.y − shoulder.y, elbow.y − wrist.y,
  /// |wrist.x − shoulder.x|). Null on captures from before they were surfaced.
  final double? shrugGap;
  final double? wristExtension;
  final double? mouseReach;

  /// [trunkAngle] signed: positive leaning back, negative leaning forward.
  /// Null on older captures, or when the photo didn't show which way the
  /// person faces. The backend uses it for the backrest-angle recommendation.
  final double? trunkRecline;

  /// Degrees the knee sits below the hip along the thigh (negative = knee
  /// above hip). The backend uses it to tell tucked feet from a low chair.
  /// Null on older captures or when the knee was hidden.
  final double? thighSlope;

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
    shrugGap: (m['shrug_gap'] as num?)?.toDouble(),
    wristExtension: (m['wrist_extension'] as num?)?.toDouble(),
    mouseReach: (m['mouse_reach'] as num?)?.toDouble(),
    trunkRecline: (m['trunk_recline'] as num?)?.toDouble(),
    thighSlope: (m['thigh_slope'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'side': side,
    'knee_angle': kneeAngle,
    'trunk_angle': trunkAngle,
    'elbow_angle': elbowAngle,
    'neck_angle': neckAngle,
    'neck_state': neckState,
    'lower_body_confidence': lowerBodyConfidence,
    if (shrugGap != null) 'shrug_gap': shrugGap,
    if (wristExtension != null) 'wrist_extension': wristExtension,
    if (mouseReach != null) 'mouse_reach': mouseReach,
    if (trunkRecline != null) 'trunk_recline': trunkRecline,
    if (thighSlope != null) 'thigh_slope': thighSlope,
  };

  /// Human-readable neck posture, mapping the native enum names to labels.
  String get neckStateLabel {
    switch (neckState) {
      case 'NEUTRAL':
        return l10n.mdlNeckNeutral;
      case 'FORWARD_HEAD':
        return l10n.mdlNeckForwardHead;
      case 'MILD_FLEXION':
        return l10n.mdlNeckMildFlexion;
      case 'SEVERE_FLEXION':
        return l10n.mdlNeckSevereFlexion;
      case 'HEAD_BACK':
        return l10n.mdlNeckHeadBack;
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
