import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class AnalysisSectionContainer extends StatelessWidget {
  final String percentageText;
  final double percentage;
  final AIResult result;

  const AnalysisSectionContainer({
    super.key,
    required this.percentageText,
    required this.percentage,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        width: 335.w,
        height: 335.h,
        decoration: BoxDecoration(
          color: AppColors.onBoardingSurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EN: "ISO Ergonomic Analysis"
            Text(
              AppLocalizations.of(context)!.isoErgonomicAnalysis,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            SizedBox(height: 20.h),
            Center(
              child: CircularPercentIndicator(
                circularStrokeCap: CircularStrokeCap.round,
                animationDuration: 1500,
                animation: true,
                radius: 80.r,
                lineWidth: 14.r,
                progressColor: AppColors.text,
                backgroundColor: AppColors.text.withValues(alpha: 0.1),
                percent: percentage,
                center: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percentageText%',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // EN: "Compliance"
                        Text(
                          AppLocalizations.of(context)!.compliance,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            OverAllScore(aiResult: result),
          ],
        ),
      ),
    );
  }
}

class OverAllScore extends StatelessWidget {
  final AIResult aiResult;

  const OverAllScore({super.key, required this.aiResult});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EN: "Your overall score:"
            Text(
              AppLocalizations.of(context)!.yourOverallScore,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: aiResult.overallRisk == 'red'
                    ? AppColors.red.withValues(alpha: 0.6)
                    : aiResult.overallRisk == 'green'
                    ? AppColors.green.withValues(alpha: 0.6)
                    : AppColors.warning.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              aiResult.overallRisk,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: aiResult.overallRisk == 'red'
                    ? AppColors.red.withValues(alpha: 0.6)
                    : aiResult.overallRisk == 'green'
                    ? AppColors.green.withValues(alpha: 0.6)
                    : AppColors.warning.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        // EN: "Immediate correction required!"
        Text(
          AppLocalizations.of(context)!.immediateCorrectionRequired,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
