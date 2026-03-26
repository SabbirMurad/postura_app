import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class ComplianceCardCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const ComplianceCardCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final label = controller.complianceLabel;
    final subtitle = controller.complianceSubtitle;
    final isRed = label == 'Red';
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Text(
            // EN: "ISO Ergonomic Analysis"
            loc.isoErgonomicAnalysis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF202020),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 150.w,
            height: 150.w,
            child: CircularPercentIndicator(
              circularStrokeCap: CircularStrokeCap.round,
              animationDuration: 1500,
              animation: true,
              radius: 80,
              lineWidth: 14,
              progressColor: AppColors.text,
              backgroundColor: AppColors.text.withValues(alpha: 0.1),
              percent: controller.compliancePercent,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${controller.compliance.value}%',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    // EN: "COMPLIANCE"
                    loc.complianceLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // EN: "Overall score:"
                loc.overallScore,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: isRed ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isRed ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A4A4A)),
          ),
        ],
      ),
    );
  }
}
