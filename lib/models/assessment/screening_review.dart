// Read-only view of an employee's health screening answers for the
// ergonomist's review screen. The backend sends these on the ergonomist
// assessment detail only — never to company admins.
//
// Question wording mirrors the employee screens
// (red_flag_screening_screen.dart and work_ability_recovery_outlook_screen.dart);
// keep the two in step.

import 'package:posture_detector_app/models/assessment/yellow_flag.dart';
import 'package:posture_detector_app/utils/l10n.dart';

class ScreeningAnswer {
  final String question;
  final String answer;

  /// Optional caption under the answer, e.g. what 0 and 10 mean.
  final String? scale;

  /// True when this answer counts towards the red flag or the Elevated
  /// recovery outlook (same thresholds as the backend).
  final bool flagged;

  const ScreeningAnswer({
    required this.question,
    required this.answer,
    this.scale,
    this.flagged = false,
  });
}

/// Question text per red-flag key. A getter so it follows the current
/// language; the keys are the backend's snake_case field names.
Map<String, String> get _redFlagQuestions => {
  'new_bladder_or_bowel_dysfunction': l10n.mdlRedFlagBladderBowel,
  'saddle_anaesthesia': l10n.mdlRedFlagSaddleNumbness,
  'progressive_motor_weakness': l10n.mdlRedFlagWeakness,
  'significant_recent_trauma': l10n.mdlRedFlagTrauma,
  'fever_or_infection_or_immunosuppression_with_back_pain':
      l10n.mdlRedFlagFeverInfection,
  'cancer_history_with_new_spinal_pain': l10n.mdlRedFlagCancerHistory,
  'severe_unremitting_or_night_pain': l10n.mdlRedFlagNightPain,
};

/// The 7 red-flag answers; empty when the scan has none recorded.
List<ScreeningAnswer> redFlagAnswersFromJson(Map<String, dynamic>? m) {
  if (m == null) return const [];
  return _redFlagQuestions.entries.map((q) {
    final yes = m[q.key] == true;
    return ScreeningAnswer(
      question: q.value,
      answer: yes ? l10n.yes : l10n.mdlNo,
      flagged: yes,
    );
  }).toList();
}

/// A 0-10 slider question. [flaggedWhen] matches the backend's
/// compute_chronicity_level thresholds.
class _Slider {
  final String key;
  final String question;
  final String low;
  final String high;
  final bool Function(int) flaggedWhen;
  const _Slider(this.key, this.question, this.low, this.high, this.flaggedWhen);
}

/// Getter (not a field) so the wording follows the current language.
List<_Slider> get _recoverySliders => [
  _Slider(
    'chronicity_risk',
    l10n.mdlRecoveryQChronicityRisk,
    l10n.mdlRecoveryScaleNoRisk,
    l10n.mdlRecoveryScaleVeryLargeRisk,
    (v) => v >= 7,
  ),
  _Slider(
    'rtw_expectancy',
    l10n.mdlRecoveryQRtwExpectancy,
    l10n.mdlRecoveryScaleNoChance,
    l10n.mdlRecoveryScaleVeryLargeChance,
    (v) => v <= 4,
  ),
  _Slider(
    'fear_avoidance',
    l10n.mdlRecoveryQFearAvoidance,
    l10n.mdlRecoveryScaleCompletelyDisagree,
    l10n.mdlRecoveryScaleCompletelyAgree,
    (v) => v >= 7,
  ),
  _Slider(
    'light_work_capacity',
    l10n.mdlRecoveryQLightWork,
    l10n.mdlRecoveryScaleCannotBecausePain,
    l10n.mdlRecoveryScaleCanWithoutPainProblem,
    (v) => v <= 4,
  ),
  _Slider(
    'sleep_interference',
    l10n.mdlRecoveryQSleep,
    l10n.mdlRecoveryScaleCannotBecausePain,
    l10n.mdlRecoveryScaleCanWithoutPainProblem,
    (v) => v <= 4,
  ),
  _Slider(
    'presenteeism',
    l10n.mdlRecoveryQPresenteeism,
    l10n.mdlRecoveryScaleNotAtAll,
    l10n.mdlRecoveryScaleExtremely,
    (v) => v >= 7,
  ),
];

_Slider get _workplaceSupport => _Slider(
  'workplace_support',
  l10n.mdlRecoveryQWorkplaceSupport,
  l10n.mdlRecoveryScaleStronglyDisagree,
  l10n.mdlRecoveryScaleStronglyAgree,
  _atMost3,
);

bool _atMost3(int v) => v <= 3;

/// Absence answers the backend counts towards an Elevated outlook. These are
/// the backend's wire values (compared with `previous_absence`), not labels.
const _flaggedAbsence = {'6-15 days', '16-30 days', 'More than 30 days'};

ScreeningAnswer _slider(_Slider s, Map<String, dynamic> m) {
  final v = (m[s.key] as num?)?.toInt();
  return ScreeningAnswer(
    question: s.question,
    answer: v == null ? '—' : '$v / 10',
    scale: '0 = ${s.low} · 10 = ${s.high}',
    flagged: v != null && s.flaggedWhen(v),
  );
}

/// The 8 Work Ability & Recovery Outlook answers, in on-screen order; empty
/// when the scan has none recorded.
List<ScreeningAnswer> recoveryAnswersFromJson(Map<String, dynamic>? m) {
  if (m == null) return const [];
  final absence = m['previous_absence'] as String?;
  return [
    ..._recoverySliders.map((s) => _slider(s, m)),
    ScreeningAnswer(
      question: l10n.mdlRecoveryQPreviousAbsence,
      answer: PreviousAbsence.fromApi(absence)?.label ?? absence ?? '—',
      flagged: _flaggedAbsence.contains(absence),
    ),
    _slider(_workplaceSupport, m),
  ];
}
