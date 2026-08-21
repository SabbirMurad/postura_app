// Small per-scan fields that must NEVER affect ROSA scoring:
//  - employee height (context for chair/monitor recommendations, shown on the
//    CPE review screen)
//  - the two supplemental phone-ergonomics questions, shown only in the
//    Action Report's "Supplemental CPE Findings" section
//
// Sent to the backend as a fully separate payload from `workstation_answers`,
// so these values never reach the native ROSA scorer.

class ScanSupplemental {
  /// Employee height in centimeters. Null until the user enters it on the
  /// pre-scan screen.
  final double? heightCm;

  /// Q1 "Do you hold/cradle the phone between your ear and shoulder during
  /// calls?" — Yes (true) triggers the B_PHONE_CRADLE finding.
  final bool phoneCradle;

  /// Q2 "Do you have a hands-free option available for phone calls?" — No
  /// (false) triggers the B_PHONE_HANDSFREE finding.
  final bool handsFreeAvailable;

  const ScanSupplemental({
    this.heightCm,
    this.phoneCradle = false,
    this.handsFreeAvailable = true,
  });

  ScanSupplemental copyWith({
    double? heightCm,
    bool? phoneCradle,
    bool? handsFreeAvailable,
  }) {
    return ScanSupplemental(
      heightCm: heightCm ?? this.heightCm,
      phoneCradle: phoneCradle ?? this.phoneCradle,
      handsFreeAvailable: handsFreeAvailable ?? this.handsFreeAvailable,
    );
  }

  /// Contract: the backend's `ScanSupplementalInput` parses these exact
  /// snake_case keys.
  Map<String, dynamic> toMap() => {
    'height_cm': heightCm ?? 0,
    'phone_cradle': phoneCradle,
    'hands_free_available': handsFreeAvailable,
  };
}
