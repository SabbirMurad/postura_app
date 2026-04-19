/// Pre-capture questionnaire data collected before ROSA assessment.
///
/// Scoring fields ([hoursAtDesk], [breakIntervalHrs], [deviceUsage]) feed
/// into [durationModifier] and [mouseCb] which are passed to the ROSA
/// scorer. All other fields are for ergonomist context only.
class CaptureQuestionnaire {
  const CaptureQuestionnaire({
    this.hoursAtDesk = 4,
    this.breakIntervalHrs = 2,
    this.deviceUsage = DeviceUsage.singleScreen,
    this.painRegions = const {},
    this.painIntensity = const {},
    this.painDuration = PainDuration.none,
    this.optionalSymptoms = const {},
  });

  /// Hours at desk per day: 0, 2, 4, 6, 8+.
  final int hoursAtDesk;

  /// Hours between breaks: 1, 2, 3, 4+.
  final int breakIntervalHrs;

  /// Primary input device setup.
  final DeviceUsage deviceUsage;

  /// Body regions where user reports pain (ergonomist context only).
  final Set<BodyRegion> painRegions;

  /// Pain intensity 0-10 per region (ergonomist context only).
  final Map<BodyRegion, int> painIntensity;

  /// How long pain has been present (ergonomist context only).
  final PainDuration painDuration;

  /// Optional symptoms (ergonomist context only).
  final Set<OptionalSymptom> optionalSymptoms;

  /// Cornell ROSA duration rule:
  ///  +1 if >4 hrs/day OR break interval > 1 hr
  ///  -1 if <1 hr/day
  ///   0 otherwise
  int get durationModifier {
    if (hoursAtDesk > 4 || breakIntervalHrs > 1) return 1;
    if (hoursAtDesk < 1) return -1;
    return 0;
  }

  /// Mouse callback modifier for ROSA scorer:
  ///  0 = laptop trackpad (no mouse)
  ///  1 = normal desktop mouse
  ///  2 = dual screen (more reaching)
  int get mouseCb {
    switch (deviceUsage) {
      case DeviceUsage.laptop:
        return 0;
      case DeviceUsage.singleScreen:
        return 1;
      case DeviceUsage.dualScreen:
        return 2;
    }
  }

  CaptureQuestionnaire copyWith({
    int? hoursAtDesk,
    int? breakIntervalHrs,
    DeviceUsage? deviceUsage,
    Set<BodyRegion>? painRegions,
    Map<BodyRegion, int>? painIntensity,
    PainDuration? painDuration,
    Set<OptionalSymptom>? optionalSymptoms,
  }) {
    return CaptureQuestionnaire(
      hoursAtDesk: hoursAtDesk ?? this.hoursAtDesk,
      breakIntervalHrs: breakIntervalHrs ?? this.breakIntervalHrs,
      deviceUsage: deviceUsage ?? this.deviceUsage,
      painRegions: painRegions ?? this.painRegions,
      painIntensity: painIntensity ?? this.painIntensity,
      painDuration: painDuration ?? this.painDuration,
      optionalSymptoms: optionalSymptoms ?? this.optionalSymptoms,
    );
  }
}

/// Input device setup — determines mouseCb parameter.
enum DeviceUsage {
  laptop('Laptop (trackpad)'),
  singleScreen('Desktop (single monitor)'),
  dualScreen('Desktop (dual monitor)');

  const DeviceUsage(this.label);
  final String label;
}

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

  const BodyRegion(this.label);
  final String label;
}

/// Duration of pain symptoms.
enum PainDuration {
  none('No pain'),
  lessThan1Week('Less than 1 week'),
  oneToFourWeeks('1-4 weeks'),
  oneToThreeMonths('1-3 months'),
  threeToSixMonths('3-6 months'),
  moreThanSixMonths('More than 6 months');

  const PainDuration(this.label);
  final String label;
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

  const OptionalSymptom(this.label);
  final String label;
}
