import 'package:posture_detector_app/utils/l10n.dart';

/// One reason the server marked a scan for the ergonomist's attention: the
/// photos are uncertain, or disagree with the questionnaire. Sent on the
/// ergonomist list rows and detail (`review_flags`).
class ReviewFlag {
  /// Server code, e.g. `LOWER_BODY_HIDDEN`.
  final String code;

  /// True when the ergonomist should check the scan; false for information.
  final bool escalate;

  /// The server's one-sentence explanation, in English. Shown only for codes
  /// this app version doesn't know.
  final String detail;

  const ReviewFlag({required this.code, required this.escalate, required this.detail});

  factory ReviewFlag.fromJson(Map<String, dynamic> json) => ReviewFlag(
        code: '${json['code'] ?? ''}',
        escalate: json['escalate'] == true,
        detail: '${json['detail'] ?? ''}',
      );

  /// Null-safe parse of a `review_flags` array; anything malformed is skipped.
  static List<ReviewFlag> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ReviewFlag.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Localized short title; the raw code for unknown codes.
  String get title => switch (code) {
        'LOWER_BODY_HIDDEN' => l10n.flagLowerBodyHiddenTitle,
        'FEET_ANSWER_OVERRIDES_KNEE' => l10n.flagFeetAnswerTitle,
        'FRONT_PHOTO_MISSING' => l10n.flagFrontPhotoMissingTitle,
        'FRONT_UNMEASURED' => l10n.flagFrontUnmeasuredTitle,
        'MONITOR_HEIGHT_MISMATCH' => l10n.flagMonitorHeightMismatchTitle,
        'MONITOR_NOT_DETECTED' => l10n.flagMonitorNotDetectedTitle,
        'MOUSE_REACH_MISMATCH' => l10n.flagMouseReachMismatchTitle,
        'SHOT_DISAGREEMENT' => l10n.flagShotDisagreementTitle,
        'NEAR_CUTOFF' => l10n.flagNearCutoffTitle,
        _ => code,
      };

  /// Localized one-line explanation; the server's English [detail] for
  /// unknown codes.
  String get explanation => switch (code) {
        'LOWER_BODY_HIDDEN' => l10n.flagLowerBodyHiddenText,
        'FEET_ANSWER_OVERRIDES_KNEE' => l10n.flagFeetAnswerText,
        'FRONT_PHOTO_MISSING' => l10n.flagFrontPhotoMissingText,
        'FRONT_UNMEASURED' => l10n.flagFrontUnmeasuredText,
        'MONITOR_HEIGHT_MISMATCH' => l10n.flagMonitorHeightMismatchText,
        'MONITOR_NOT_DETECTED' => l10n.flagMonitorNotDetectedText,
        'MOUSE_REACH_MISMATCH' => l10n.flagMouseReachMismatchText,
        'SHOT_DISAGREEMENT' => l10n.flagShotDisagreementText,
        'NEAR_CUTOFF' => l10n.flagNearCutoffText,
        _ => detail,
      };
}
