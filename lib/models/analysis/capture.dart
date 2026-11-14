import 'dart:io';

import 'package:posture_detector_app/models/analysis/body_angles.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';

Map<String, dynamic>? _rawPoseFrom(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

/// One side-view shot from the native PostureEngine: the captured image plus the
/// ROSA score and raw body angles measured from it.
class SideViewCapture {
  const SideViewCapture({
    required this.image,
    required this.rosaScore,
    required this.bodyAngles,
    this.monitorDetected,
    this.rawPose,
  });

  final File image;
  final RosaScore rosaScore;
  final BodyAngles bodyAngles;

  /// Whether the monitor detector found a monitor in this photo (checked once
  /// all photos are taken). Null if the check couldn't run.
  final bool? monitorDetected;

  /// The pose model's raw landmarks for this photo (`landmarks`: x, y, z,
  /// visibility per point; `image_width`, `image_height`, `source`). Not shown;
  /// stored by the backend so scoring cutoffs can be re-fitted from real scans.
  final Map<String, dynamic>? rawPose;

  factory SideViewCapture.fromChannel(Map<String, dynamic> m) =>
      SideViewCapture(
        image: File(m['image_path'] as String? ?? ''),
        rosaScore: RosaScore.fromJson(
          Map<String, dynamic>.from(m['rosa_score'] as Map? ?? const {}),
        ),
        bodyAngles: BodyAngles.fromJson(
          Map<String, dynamic>.from(m['body_angles'] as Map? ?? const {}),
        ),
        monitorDetected: m['monitor_detected'] as bool?,
        rawPose: _rawPoseFrom(m['raw_pose']),
      );

  /// Backend payload for this capture (the SideViewCaptureInput contract): the
  /// uploaded asset id plus the measured angles, flat. The per-scan rosa_score is
  /// sent once at the top level of the request, not per capture.
  Map<String, dynamic> toJson(String imageId) => {
    'image_id': imageId,
    ...bodyAngles.toJson(),
    if (monitorDetected != null) 'monitor_detected': monitorDetected,
    if (rawPose != null) 'raw_pose': rawPose,
  };
}

/// The single front-view shot: the captured image plus the two raw front-view
/// angles (elbow abduction and wrist deviation, in degrees), plus the two
/// side-view-derived findings that used to be internal-only (C_WRIST_EXT /
/// A_SURFACE_HIGH source, Action Report v1.3).
class FrontViewCapture {
  const FrontViewCapture({
    required this.image,
    this.abductionAngle,
    this.wristDeviationAngle,
    this.wristExtension = false,
    this.shrugGap = 0,
    this.rawPose,
  });

  final File image;

  /// Max elbow abduction across both arms (degrees) — "armrests too wide".
  /// Null when the native engine couldn't measure it on the front photo.
  final double? abductionAngle;

  /// Max wrist deviation from straight across both hands (degrees) —
  /// "wrists deviate while typing". Null when it couldn't be measured (no
  /// hand found in the front photo), which is not the same as 0°.
  final double? wristDeviationAngle;

  /// C_WRIST_EXT source: native wristExtension >= 0.03 (RosaScorer's own
  /// "elevated risk" cutoff). Previously computed but never surfaced.
  final bool wristExtension;

  /// A_SURFACE_HIGH support signal: raw shrugGap (ear.y - shoulder.y),
  /// surfaced for diagnostics/logging alongside the boolean gate the backend
  /// applies (RosaScorer's own armrestScore cutoff, shrugGap > -0.06).
  final double shrugGap;

  /// Raw pose landmarks for this photo; see [SideViewCapture.rawPose].
  final Map<String, dynamic>? rawPose;

  factory FrontViewCapture.fromChannel(Map<String, dynamic> m) =>
      FrontViewCapture(
        image: File(m['image_path'] as String? ?? ''),
        abductionAngle: (m['abduction_angle'] as num?)?.toDouble(),
        wristDeviationAngle: (m['wrist_deviation_angle'] as num?)?.toDouble(),
        wristExtension: m['wrist_extension'] as bool? ?? false,
        shrugGap: (m['shrug_gap'] as num?)?.toDouble() ?? 0,
        rawPose: _rawPoseFrom(m['raw_pose']),
      );

  /// An angle the engine couldn't measure is left out; the backend then keeps
  /// the questionnaire answer instead of scoring it as 0°.
  Map<String, dynamic> toJson(String imageId) => {
    'image_id': imageId,
    if (abductionAngle != null) 'abduction_angle': abductionAngle,
    if (wristDeviationAngle != null)
      'wrist_deviation_angle': wristDeviationAngle,
    'wrist_extension': wristExtension,
    'shrug_gap': shrugGap,
    if (rawPose != null) 'raw_pose': rawPose,
  };
}
