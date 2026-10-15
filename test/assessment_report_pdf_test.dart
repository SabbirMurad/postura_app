import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/models/profile/author_model.dart';
import 'package:posture_detector_app/utils/assessment_report_pdf.dart';

/// A `GET assessments/my-reports` payload in the current (v1.3) shape.
Map<String, dynamic> _v13Payload() => {
  'scan_id': 'scan-1',
  'created_at': '2026-10-14T09:30:00Z',
  'pain_units': [
    {'body_region': 'lower_back', 'intensity': 6, 'duration': '1-3 months'},
    {'body_region': 'neck', 'intensity': 3, 'duration': '< 2 weeks'},
  ],
  'pain_duration': '1-3 months',
  'chronicity_level': 'Elevated',
  'height_cm': 178.0,
  'supplemental_cpe_findings': {
    'phone_cradle': true,
    'hands_free_available': false,
    'flags': ['B_PHONE_CRADLE', 'B_PHONE_HANDSFREE'],
  },
  'symptoms': ['Stiffness', 'End of day fatigue'],
  'body_region_risks': {
    'elbows': 'low',
    'shoulder': 'medium',
    'wrist': 'low',
    'lower_back': 'high',
  },
  'corrections': [],
  'exercises': {
    'condition_type': 'subacute',
    'focus_regions': ['lower_back'],
    'average_pain_vas': 6,
    'exercise_status': 'OK',
    'readiness': 'GENTLE',
    'needs_cpe_review': true,
    'recommended_session': [
      {
        'id': 1,
        'title': 'Cat-cow',
        'body_region': 'Lower back mobility',
        'image': 'cat_cow.mp4',
        'description': 'Slow spinal flexion and extension on hands and knees.',
        'purpose': 'Move slowly between arching and rounding the back.',
        'muscles_addressed': 'Erector spinae, abdominals',
        'recommended_sets': 2,
        'recommended_duration': '60 s',
        'safety_note': 'Stop if pain increases or radiates into the leg.',
        'region_vas': 6,
      },
    ],
  },
  'equipment': [],
  'rosa_score': {
    'final_score': 6,
    'risk_level': 'Moderate',
    'chair_score': 4,
    'peripheral_score': 3,
    'seat_height_score': 2,
    'backrest_score': 3,
    'armrest_score': 1,
    'monitor_score': 3,
    'keyboard_score': 2,
    'mouse_score': 1,
  },
  'action_report_v1_3': {
    'header': {
      'tier_number': 2,
      'tier_name': 'Moderate',
      'rosa_score': 6,
      'main_risk_driver': 'Chair / Seating',
    },
    'executive_summary':
        'Your workstation shows moderate risk, mainly from the backrest.',
    'priority_findings_intro': 'These findings contributed most to your score.',
    'priority_findings': [
      {
        'finding_id': 'A_BACK',
        'section': 'A',
        'source_type': 'image',
        'rosa_scored': true,
        'employee_label': 'Backrest does not support the lower back',
        'action_now': 'Sit back fully so the backrest supports your lumbar curve.',
        'ergonomic_target': 'Lumbar support at belt height, ≥ 95° recline.',
        'iso_explanation': 'Backrest support contributed to the Chair score.',
        'driver_text': '',
        'equipment_handoff': true,
        'equipment_handoff_text': 'A lumbar cushion may help if the chair cannot.',
      },
    ],
    'supplemental_cpe_intro': 'Phone habits noted for your CPE.',
    'supplemental_cpe_findings': [
      {
        'finding_id': 'B_PHONE_CRADLE',
        'section': 'B',
        'source_type': 'questionnaire',
        'rosa_scored': false,
        'employee_label': 'Cradling the phone between ear and shoulder',
        'action_now': 'Use a headset or speakerphone for calls.',
        'ergonomic_target': '',
        'iso_explanation': '',
        'driver_text': '',
        'equipment_handoff': false,
      },
    ],
    'what_you_can_do_now': [
      'Adjust the backrest so it touches your lower back.',
      'Take a short movement break every 30–45 minutes.',
    ],
    'equipment_helps_text': 'Equipment helps when adjustments alone are not enough.',
    'equipment_cards': [
      {
        'equipment_id': 'EQ_LUMBAR',
        'card_title': 'Lumbar Support Cushion',
        'card_description': 'Adds lower-back support to an existing chair.',
        'priority_label': 'High Priority',
        'priority_text': 'Recommended for your current ROSA tier.',
        'related_findings': ['A_BACK'],
        'why_text': ['Your backrest does not support the lower back.'],
        'target_text': 'Supported lumbar curve',
        'required_features': ['adjustable height', 'firm foam'],
        'next_step_text': 'Request through your employer.',
        'related_action_label': 'View related action',
      },
    ],
    'general_workstation_habits': 'Alternate tasks and change posture often.',
    'professional_review_line':
        'Because your pain has lasted over a month, a CPE review is recommended.',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a PDF from a v1.3 my-reports payload', () async {
    final report = AnalysisReport.fromJson(_v13Payload());
    final bytes = await AssessmentReportPdf.build(
      report: report,
      profile: AuthorModel(
        id: 'u1',
        fullName: 'Zoë Ångström-Hassan',
        email: 'zoe@example.com',
        role: 'EMPLOYEE',
      ),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));

    // Set PDF_OUT=<path> to write the file for a visual check.
    final out = Platform.environment['PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });

  test('builds a PDF for a pre-v1.3 report without a profile', () async {
    final payload = _v13Payload()
      ..remove('action_report_v1_3')
      ..remove('created_at')
      ..['corrections'] = [
        {'title': 'Raise your monitor', 'description': 'Top edge at eye level.'},
      ];
    final bytes = await AssessmentReportPdf.build(
      report: AnalysisReport.fromJson(payload),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
