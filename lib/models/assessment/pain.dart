// Self-reported discomfort collected before the camera assessment.
//
// These feed the backend's `pain_units` / `symptoms` payload and give the
// ergonomist context. They are not inputs to ROSA scoring — the native
// PostureEngine scores from pose geometry plus the workstation checklist.

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

/// How long pain has been present. Reported per [BodyRegion].
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
