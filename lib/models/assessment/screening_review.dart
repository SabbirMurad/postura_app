// Read-only view of an employee's health screening answers for the
// ergonomist's review screen. The backend sends these on the ergonomist
// assessment detail only — never to company admins.
//
// Question wording mirrors the employee screens
// (red_flag_screening_screen.dart and work_ability_recovery_outlook_screen.dart);
// keep the two in step.

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

const _redFlagQuestions = <String, String>{
  'new_bladder_or_bowel_dysfunction': 'New loss of bladder or bowel control',
  'saddle_anaesthesia':
      'Numbness in the saddle area (inner thighs, groin, or genitals)',
  'progressive_motor_weakness': 'New or worsening weakness in your legs or arms',
  'significant_recent_trauma':
      'A significant recent trauma (e.g. a fall, accident, or blow to your back)',
  'fever_or_infection_or_immunosuppression_with_back_pain':
      'Fever, a recent infection, or a weakened immune system along with back pain',
  'cancer_history_with_new_spinal_pain':
      'A history of cancer, with new or worsening back/spine pain',
  'severe_unremitting_or_night_pain':
      "Severe pain that doesn't ease up, especially at night",
};

/// The 7 red-flag answers; empty when the scan has none recorded.
List<ScreeningAnswer> redFlagAnswersFromJson(Map<String, dynamic>? m) {
  if (m == null) return const [];
  return _redFlagQuestions.entries.map((q) {
    final yes = m[q.key] == true;
    return ScreeningAnswer(
      question: q.value,
      answer: yes ? 'Yes' : 'No',
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

final _recoverySliders = <_Slider>[
  _Slider(
    'chronicity_risk',
    'How large is the risk that your current pain may become persistent or long-term?',
    'No risk',
    'Very large risk',
    (v) => v >= 7,
  ),
  _Slider(
    'rtw_expectancy',
    'What are the chances you will be working your normal duties in 3 months?',
    'No chance',
    'Very large chance',
    (v) => v <= 4,
  ),
  _Slider(
    'fear_avoidance',
    'An increase in pain is an indication that I should stop what I am doing until the pain decreases.',
    'Completely disagree',
    'Completely agree',
    (v) => v >= 7,
  ),
  _Slider(
    'light_work_capacity',
    'I can do light work (or normal light duties) for an hour.',
    'Cannot do it because of the pain',
    'Can do it without the pain being a problem',
    (v) => v <= 4,
  ),
  _Slider(
    'sleep_interference',
    'I can sleep at night.',
    'Cannot do it because of the pain',
    'Can do it without the pain being a problem',
    (v) => v <= 4,
  ),
  _Slider(
    'presenteeism',
    'How much has your pain reduced your productivity or ability to work at full capacity in the past week?',
    'Not at all',
    'Extremely (unable to work normally)',
    (v) => v >= 7,
  ),
];

const _workplaceSupport = _Slider(
  'workplace_support',
  'I feel I can get support or make reasonable adjustments at work if needed because of this pain.',
  'Strongly disagree',
  'Strongly agree',
  _atMost3,
);

bool _atMost3(int v) => v <= 3;

/// Absence answers the backend counts towards an Elevated outlook.
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
      question:
          'In the last 12 months, how many work days have you missed because of similar pain or musculoskeletal problems?',
      answer: absence ?? '—',
      flagged: _flaggedAbsence.contains(absence),
    ),
    _slider(_workplaceSupport, m),
  ];
}
