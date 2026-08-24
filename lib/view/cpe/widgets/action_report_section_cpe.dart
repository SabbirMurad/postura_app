import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/expansion_container.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/equipment/widgets/equipment_recommendation_card_v13.dart';

/// CPE-reviewer view of the deterministic Action Report v1.3: the same fixed
/// priority findings, supplemental CPE findings, and equipment cards the
/// employee sees, so the reviewer can judge them before checking off
/// "Recommendations are professionally appropriate" (see ApprovalsSectionCPE).
/// Renders nothing for scans that predate the v1.3 rollout.
class ActionReportSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const ActionReportSectionCPE({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final report = state.actionReportV13;
    if (report == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action Report v1.3',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Tier ${report.tierNumber} - ${report.tierName} | ROSA ${report.rosaScore}/10 | Main risk driver: ${report.mainRiskDriver}',
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
        ),
        SizedBox(height: 12.h),

        if (report.priorityFindings.isNotEmpty) ...[
          Text(
            'Priority Findings',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          ...report.priorityFindings.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ExpansionContainer(
                title: f.employeeLabel,
                leading: '',
                content: _findingContent(f),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],

        if (report.supplementalCpeFindings.isNotEmpty) ...[
          Text(
            'Supplemental CPE Findings',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          ...report.supplementalCpeFindings.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ExpansionContainer(
                title: f.employeeLabel,
                leading: '',
                content: _findingContent(f),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],

        if (report.equipmentCards.isNotEmpty) ...[
          Text(
            'Equipment Recommendations',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          ...report.equipmentCards.map(
            (card) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: EquipmentRecommendationCardV13(card: card),
            ),
          ),
        ],
      ],
    );
  }

  String _findingContent(FindingV13 f) {
    final buffer = StringBuffer(f.actionNow);
    if (f.isoExplanation.isNotEmpty) {
      buffer.write('\n\n${f.isoExplanation}');
    }
    if (f.equipmentHandoff && f.equipmentHandoffText != null) {
      buffer.write('\n\n${f.equipmentHandoffText}');
    }
    return buffer.toString();
  }
}
