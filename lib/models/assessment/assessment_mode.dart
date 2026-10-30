/// Who answers the workstation (ROSA) checklist for a scan.
///
/// [employee]: the employee answers it before the photos, and the scan is
/// scored as soon as it's submitted. [ergonomist]: the employee only takes the
/// photos; the scan waits until the ergonomist answers the checklist in their
/// review, which scores it and releases the result to the employee.
enum AssessmentMode {
  employee('employee'),
  ergonomist('ergonomist');

  final String apiValue;
  const AssessmentMode(this.apiValue);

  static AssessmentMode fromApi(String? value) => AssessmentMode.values
      .firstWhere((m) => m.apiValue == value, orElse: () => employee);
}

/// Backend `status` of a scan: `awaiting_ergonomist` until a photos-only scan
/// has been answered and scored by the ergonomist, otherwise `completed`.
const String scanStatusAwaitingErgonomist = 'awaiting_ergonomist';
