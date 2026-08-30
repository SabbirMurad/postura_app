// Medical red-flag safety screening — 7 yes/no questions collected once per
// scan, right after Work Ability & Recovery Outlook and before the
// Workstation checklist. A "Yes" on any item means the backend routes the
// exercise engine to STOP_AND_SEEK_CLINICAL_ASSESSMENT instead of generating
// a session, independent of reported pain intensity.

class RedFlagScreening {
  final bool newBladderOrBowelDysfunction;
  final bool saddleAnaesthesia;
  final bool progressiveMotorWeakness;
  final bool significantRecentTrauma;
  final bool feverOrInfectionOrImmunosuppressionWithBackPain;
  final bool cancerHistoryWithNewSpinalPain;
  final bool severeUnremittingOrNightPain;

  const RedFlagScreening({
    this.newBladderOrBowelDysfunction = false,
    this.saddleAnaesthesia = false,
    this.progressiveMotorWeakness = false,
    this.significantRecentTrauma = false,
    this.feverOrInfectionOrImmunosuppressionWithBackPain = false,
    this.cancerHistoryWithNewSpinalPain = false,
    this.severeUnremittingOrNightPain = false,
  });

  RedFlagScreening copyWith({
    bool? newBladderOrBowelDysfunction,
    bool? saddleAnaesthesia,
    bool? progressiveMotorWeakness,
    bool? significantRecentTrauma,
    bool? feverOrInfectionOrImmunosuppressionWithBackPain,
    bool? cancerHistoryWithNewSpinalPain,
    bool? severeUnremittingOrNightPain,
  }) {
    return RedFlagScreening(
      newBladderOrBowelDysfunction:
          newBladderOrBowelDysfunction ?? this.newBladderOrBowelDysfunction,
      saddleAnaesthesia: saddleAnaesthesia ?? this.saddleAnaesthesia,
      progressiveMotorWeakness:
          progressiveMotorWeakness ?? this.progressiveMotorWeakness,
      significantRecentTrauma:
          significantRecentTrauma ?? this.significantRecentTrauma,
      feverOrInfectionOrImmunosuppressionWithBackPain:
          feverOrInfectionOrImmunosuppressionWithBackPain ??
          this.feverOrInfectionOrImmunosuppressionWithBackPain,
      cancerHistoryWithNewSpinalPain:
          cancerHistoryWithNewSpinalPain ?? this.cancerHistoryWithNewSpinalPain,
      severeUnremittingOrNightPain:
          severeUnremittingOrNightPain ?? this.severeUnremittingOrNightPain,
    );
  }

  /// Contract: the backend's `RedFlagScreeningInput` parses these exact
  /// snake_case keys.
  Map<String, dynamic> toMap() => {
    'new_bladder_or_bowel_dysfunction': newBladderOrBowelDysfunction,
    'saddle_anaesthesia': saddleAnaesthesia,
    'progressive_motor_weakness': progressiveMotorWeakness,
    'significant_recent_trauma': significantRecentTrauma,
    'fever_or_infection_or_immunosuppression_with_back_pain':
        feverOrInfectionOrImmunosuppressionWithBackPain,
    'cancer_history_with_new_spinal_pain': cancerHistoryWithNewSpinalPain,
    'severe_unremitting_or_night_pain': severeUnremittingOrNightPain,
  };
}
