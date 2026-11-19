// Self-reported discomfort collected before the camera assessment.
//
// These feed the backend's `pain_units` / `symptoms` payload and give the
// ergonomist context. They are not inputs to ROSA scoring — the native
// PostureEngine scores from pose geometry plus the workstation checklist.
//
// Each enum carries a fixed English [apiValue] that is sent to the backend
// (never translate it) and a [label] getter for display, which follows the
// user's selected language.

import 'package:posture_detector_app/utils/l10n.dart';

/// Body regions for pain reporting.
enum BodyRegion {
  neck('Neck'),
  upperBack('Upper Back'),
  lowerBack('Lower Back'),
  leftShoulder('Left Shoulder'),
  rightShoulder('Right Shoulder'),
  leftWrist('Left Wrist'),
  rightWrist('Right Wrist'),
  leftElbow('Left Elbow'),
  rightElbow('Right Elbow'),
  leftHip('Left Hip'),
  rightHip('Right Hip'),
  leftKnee('Left Knee'),
  rightKnee('Right Knee');

  const BodyRegion(this.apiValue);

  /// Wire value sent as `body_region`. Do not translate.
  final String apiValue;

  /// Display name in the current language.
  String get label => switch (this) {
    BodyRegion.neck => l10n.neck,
    BodyRegion.upperBack => l10n.upperBack,
    BodyRegion.lowerBack => l10n.lowerBack,
    BodyRegion.leftShoulder => l10n.mdlRegionLeftShoulder,
    BodyRegion.rightShoulder => l10n.mdlRegionRightShoulder,
    BodyRegion.leftWrist => l10n.mdlRegionLeftWrist,
    BodyRegion.rightWrist => l10n.mdlRegionRightWrist,
    BodyRegion.leftElbow => l10n.mdlRegionLeftElbow,
    BodyRegion.rightElbow => l10n.mdlRegionRightElbow,
    BodyRegion.leftHip => l10n.mdlRegionLeftHip,
    BodyRegion.rightHip => l10n.mdlRegionRightHip,
    BodyRegion.leftKnee => l10n.mdlRegionLeftKnee,
    BodyRegion.rightKnee => l10n.mdlRegionRightKnee,
  };

  /// Display name for a `body_region` value read from the server; unknown
  /// values are returned unchanged.
  static String labelFor(String apiValue) {
    for (final r in BodyRegion.values) {
      if (r.apiValue == apiValue) return r.label;
    }
    return apiValue;
  }
}

/// How long pain has been present. Reported per [BodyRegion].
enum PainDuration {
  none('No pain'),
  lessThan1Week('Less than 1 week'),
  oneToFourWeeks('1-4 weeks'),
  // Subacute bucket: lets the exercise engine tell "6-12 weeks" apart from
  // true chronic (matches the backend's PainDurationEnum::SixToTwelveWeeks).
  sixToTwelveWeeks('6-12 weeks'),
  oneToThreeMonths('1-3 months'),
  threeToSixMonths('3-6 months'),
  moreThanSixMonths('More than 6 months');

  const PainDuration(this.apiValue);

  /// Wire value sent as the pain unit's `duration`. Do not translate.
  final String apiValue;

  /// Display text in the current language.
  String get label => switch (this) {
    PainDuration.none => l10n.mdlPainDurationNone,
    PainDuration.lessThan1Week => l10n.lessThanWeek,
    PainDuration.oneToFourWeeks => l10n.mdlPainDuration1To4Weeks,
    PainDuration.sixToTwelveWeeks => l10n.mdlPainDuration6To12Weeks,
    PainDuration.oneToThreeMonths => l10n.mdlPainDuration1To3Months,
    PainDuration.threeToSixMonths => l10n.mdlPainDuration3To6Months,
    PainDuration.moreThanSixMonths => l10n.mdlPainDurationMoreThan6Months,
  };

  /// Display text for a `duration` value read from the server; unknown
  /// values are returned unchanged.
  static String labelFor(String apiValue) {
    for (final d in PainDuration.values) {
      if (d.apiValue == apiValue) return d.label;
    }
    return apiValue;
  }
}

/// Optional symptoms (not used in scoring).
enum OptionalSymptom {
  numbness('Numbness or tingling'),
  stiffness('Stiffness'),
  swelling('Swelling'),
  reducedRange('Reduced range of motion'),
  headaches('Headaches'),
  eyeStrain('Eye strain'),
  fatigue('Fatigue');

  const OptionalSymptom(this.apiValue);

  /// Wire value sent in `symptoms`. Do not translate.
  final String apiValue;

  /// Display text in the current language.
  String get label => switch (this) {
    OptionalSymptom.numbness => l10n.mdlSymptomNumbness,
    OptionalSymptom.stiffness => l10n.stiffness,
    OptionalSymptom.swelling => l10n.mdlSymptomSwelling,
    OptionalSymptom.reducedRange => l10n.mdlSymptomReducedRange,
    OptionalSymptom.headaches => l10n.mdlSymptomHeadaches,
    OptionalSymptom.eyeStrain => l10n.mdlSymptomEyeStrain,
    OptionalSymptom.fatigue => l10n.fatigue,
  };

  /// Display text for a symptom value read from the server; unknown values
  /// are returned unchanged.
  static String labelFor(String apiValue) {
    for (final s in OptionalSymptom.values) {
      if (s.apiValue == apiValue) return s.label;
    }
    return apiValue;
  }
}
