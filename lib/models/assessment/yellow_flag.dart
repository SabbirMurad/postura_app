// Yellow-flag / chronicity risk screen ("Work Ability & Recovery Outlook").
//
// 8 questions collected once per scan, right after Pain Intensity + Pain
// Duration and before the Workstation checklist. The backend computes the
// Chronicity Level (Low / Elevated) from these answers — see
// `Postura_Yellow_Flag_Chronicity_Implementation.pdf` for the exact rule.

import 'package:posture_detector_app/utils/l10n.dart';

/// Previous work-day absence in the last 12 months (Question 7).
enum PreviousAbsence {
  zero('0 days'),
  oneToFive('1-5 days'),
  sixToFifteen('6-15 days'),
  sixteenToThirty('16-30 days'),
  moreThanThirty('More than 30 days');

  const PreviousAbsence(this.apiValue);

  /// Wire value sent as `previous_absence`. Do not translate.
  final String apiValue;

  /// Display text in the current language.
  String get label => switch (this) {
    PreviousAbsence.zero => l10n.mdlAbsenceZeroDays,
    PreviousAbsence.oneToFive => l10n.mdlAbsence1To5Days,
    PreviousAbsence.sixToFifteen => l10n.mdlAbsence6To15Days,
    PreviousAbsence.sixteenToThirty => l10n.mdlAbsence16To30Days,
    PreviousAbsence.moreThanThirty => l10n.mdlAbsenceMoreThan30Days,
  };

  /// The option for a `previous_absence` value read from the server, or null.
  static PreviousAbsence? fromApi(String? value) {
    for (final a in PreviousAbsence.values) {
      if (a.apiValue == value) return a;
    }
    return null;
  }
}

/// The 8 slider/chip answers for the Work Ability & Recovery Outlook screen.
/// Questions 2, 4, 5 and 8 are reverse-scored (higher answer = lower risk);
/// that scoring happens server-side, this model just carries the raw 0-10
/// (or chip) values the user picked.
class YellowFlagAnswers {
  final int chronicityRisk; // Q1, 0-10
  final int rtwExpectancy; // Q2, 0-10 (reverse)
  final int fearAvoidance; // Q3, 0-10
  final int lightWorkCapacity; // Q4, 0-10 (reverse)
  final int sleepInterference; // Q5, 0-10 (reverse)
  final int presenteeism; // Q6, 0-10
  final PreviousAbsence previousAbsence; // Q7
  final int workplaceSupport; // Q8, 0-10 (reverse)

  const YellowFlagAnswers({
    this.chronicityRisk = 0,
    this.rtwExpectancy = 0,
    this.fearAvoidance = 0,
    this.lightWorkCapacity = 0,
    this.sleepInterference = 0,
    this.presenteeism = 0,
    this.previousAbsence = PreviousAbsence.zero,
    this.workplaceSupport = 0,
  });

  YellowFlagAnswers copyWith({
    int? chronicityRisk,
    int? rtwExpectancy,
    int? fearAvoidance,
    int? lightWorkCapacity,
    int? sleepInterference,
    int? presenteeism,
    PreviousAbsence? previousAbsence,
    int? workplaceSupport,
  }) {
    return YellowFlagAnswers(
      chronicityRisk: chronicityRisk ?? this.chronicityRisk,
      rtwExpectancy: rtwExpectancy ?? this.rtwExpectancy,
      fearAvoidance: fearAvoidance ?? this.fearAvoidance,
      lightWorkCapacity: lightWorkCapacity ?? this.lightWorkCapacity,
      sleepInterference: sleepInterference ?? this.sleepInterference,
      presenteeism: presenteeism ?? this.presenteeism,
      previousAbsence: previousAbsence ?? this.previousAbsence,
      workplaceSupport: workplaceSupport ?? this.workplaceSupport,
    );
  }

  /// Contract: the backend's `YellowFlagAnswersInput` parses these exact
  /// snake_case keys.
  Map<String, dynamic> toMap() => {
    'chronicity_risk': chronicityRisk,
    'rtw_expectancy': rtwExpectancy,
    'fear_avoidance': fearAvoidance,
    'light_work_capacity': lightWorkCapacity,
    'sleep_interference': sleepInterference,
    'presenteeism': presenteeism,
    'previous_absence': previousAbsence.apiValue,
    'workplace_support': workplaceSupport,
  };
}
