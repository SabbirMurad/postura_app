import 'dart:io';

import 'package:posture_detector_app/models/analysis/body_angles.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';

/// One side-view shot from the native PostureEngine: the captured image plus the
/// ROSA score and raw body angles measured from it.
class SideViewCapture {
  const SideViewCapture({
    required this.image,
    required this.rosaScore,
    required this.bodyAngles,
  });

  final File image;
  final RosaScore rosaScore;
  final BodyAngles bodyAngles;

  factory SideViewCapture.fromChannel(Map<String, dynamic> m) =>
      SideViewCapture(
        image: File(m['image_path'] as String? ?? ''),
        rosaScore: RosaScore.fromJson(
          Map<String, dynamic>.from(m['rosa_score'] as Map? ?? const {}),
        ),
        bodyAngles: BodyAngles.fromJson(
          Map<String, dynamic>.from(m['body_angles'] as Map? ?? const {}),
        ),
      );

  /// Backend payload for this capture (the SideViewCaptureInput contract): the
  /// uploaded asset id plus the measured angles, flat. The per-scan rosa_score is
  /// sent once at the top level of the request, not per capture.
  Map<String, dynamic> toJson(String imageId) => {
    'image_id': imageId,
    ...bodyAngles.toJson(),
  };
}

/// The single front-view shot: the captured image plus the two raw front-view
/// angles (elbow abduction and wrist deviation, in degrees).
class FrontViewCapture {
  const FrontViewCapture({
    required this.image,
    required this.abductionAngle,
    required this.wristDeviationAngle,
  });

  final File image;

  /// Max elbow abduction across both arms (degrees) — "armrests too wide".
  final double abductionAngle;

  /// Max wrist deviation from straight across both hands (degrees) —
  /// "wrists deviate while typing".
  final double wristDeviationAngle;

  factory FrontViewCapture.fromChannel(Map<String, dynamic> m) =>
      FrontViewCapture(
        image: File(m['image_path'] as String? ?? ''),
        abductionAngle: (m['abduction_angle'] as num?)?.toDouble() ?? 0,
        wristDeviationAngle:
            (m['wrist_deviation_angle'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson(String imageId) => {
    'image_id': imageId,
    'abduction_angle': abductionAngle,
    'wrist_deviation_angle': wristDeviationAngle,
  };
}
