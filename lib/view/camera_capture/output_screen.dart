import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/details_analysis_container.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class OutputScreenBusiness extends ConsumerWidget {
  const OutputScreenBusiness({super.key});

  /// ✅ Helper method to get color based on severity
  Color _getColorBySeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return AppColors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return AppColors.warning;
      default:
        return AppColors.secondaryText;
    }
  }

  /// ✅ Helper method to get icon based on severity
  String _getIconBySeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return Assets.icons.status.wrongAlert.path;
      case 'green':
        return Assets.icons.status.rightGuard.path;
      case 'yellow':
        return Assets.icons.status.alertLine.path;
      default:
        return Assets.icons.status.alertLine.path;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final reportState = ref.watch(reportNotifierProvider);
    final analysisData = reportState.analysisData;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Builder(
        builder: (context) {
          if (analysisData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  // EN: "Loading analysis data..."
                  Text(loc.loadingAnalysisData),
                ],
              ),
            );
          }

          final complianceScore = analysisData.aiResult.complianceScore;
          final detailedAnalysis = analysisData.aiResult.detailedAnalysis;
          final posture = detailedAnalysis.posture;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  Center(
                    // EN: "ISO Ergonomic Analysis"
                    child: Text(
                      loc.rosaErgonomicAnalysis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Center(
                    // EN: "Based on ISO 9241"
                    child: Text(
                      loc.basedOnIso9241,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 70.h),

                  /// Pie chart
                  CircularPercentIndicator(
                    circularStrokeCap: CircularStrokeCap.round,
                    animationDuration: 1500,
                    animation: true,
                    radius: 86.w,
                    lineWidth: 14.w,
                    progressColor: AppColors.text,
                    backgroundColor: AppColors.text.withValues(alpha: 0.1),
                    percent: complianceScore / 100,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${complianceScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Compliance',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 50.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppText.yourOverallScore,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                      ),
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 9.h),

                  /// Overall score bar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 165.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          gradient: AppColors.redGradient,
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                      ),
                      Positioned(
                        left: 120,
                        bottom: -2.5,
                        child: Container(
                          width: 12.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),
                  // EN: "Immediate correction required"
                  Text(
                    loc.immediateCorrection,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),

                  SizedBox(height: 30.h),
                  if (analysisData.aiResult.annotatedImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: analysisData.aiResult.annotatedImageUrl,
                        // height: 400.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 30.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    // EN: "Detailed Analysis"
                    child: Text(
                      loc.detailsAnalysis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// ✅ Neck Flexion
                  DetailsAnalysisContainer(
                    path: _getIconBySeverity(posture.neckFlexion.severity),
                    iconBgColor: _getColorBySeverity(
                      posture.neckFlexion.severity,
                    ),
                    // EN: "Neck Flexion"
                    title: AppLocalizations.of(context)!.neckFlexion,
                    subTitle: posture.neckFlexion.iso,
                    comment:
                        '${posture.neckFlexion.deviation.toStringAsFixed(1)}° deviation',
                    commentColor: posture.neckFlexion.severity,
                  ),

                  SizedBox(height: 12.h),

                  /// ✅ Shoulder Elevation
                  DetailsAnalysisContainer(
                    path: _getIconBySeverity(
                      posture.shoulderElevation.severity,
                    ),
                    iconBgColor: _getColorBySeverity(
                      posture.shoulderElevation.severity,
                    ),
                    // EN: "Shoulder Elevation"
                    title: AppLocalizations.of(context)!.shoulderElevation,
                    subTitle: posture.shoulderElevation.iso,
                    comment:
                        '${posture.shoulderElevation.angle.toStringAsFixed(1)}°',
                    commentColor: posture.shoulderElevation.severity,
                  ),

                  SizedBox(height: 12.h),

                  /// ✅ Elbow Angle
                  DetailsAnalysisContainer(
                    path: _getIconBySeverity(posture.elbowAngle.severity),
                    iconBgColor: _getColorBySeverity(
                      posture.elbowAngle.severity,
                    ),
                    // EN: "Elbow Angle"
                    title: AppLocalizations.of(context)!.elbowAngle,
                    subTitle: posture.elbowAngle.iso,
                    comment:
                        '${posture.elbowAngle.deviation.toStringAsFixed(1)}° deviation',
                    commentColor: posture.elbowAngle.severity,
                  ),

                  SizedBox(height: 12.h),

                  /// ✅ Wrist Deviation
                  DetailsAnalysisContainer(
                    path: _getIconBySeverity(posture.wristDeviation.severity),
                    iconBgColor: _getColorBySeverity(
                      posture.wristDeviation.severity,
                    ),
                    // EN: "Wrist Deviation"
                    title: AppLocalizations.of(context)!.wristDeviation,
                    subTitle: posture.wristDeviation.iso,
                    comment:
                        '${posture.wristDeviation.deviation.toStringAsFixed(1)}° deviation',
                    commentColor: posture.wristDeviation.severity,
                  ),

                  SizedBox(height: 12.h),

                  /// ✅ Pelvic Tilt
                  DetailsAnalysisContainer(
                    path: _getIconBySeverity(posture.pelvicTilt.severity),
                    iconBgColor: _getColorBySeverity(
                      posture.pelvicTilt.severity,
                    ),
                    // EN: "Pelvic Tilt"
                    title: AppLocalizations.of(context)!.pelvicTilt,
                    subTitle: posture.pelvicTilt.iso,
                    comment:
                        '${posture.pelvicTilt.deviation.toStringAsFixed(1)}° deviation',
                    commentColor: posture.pelvicTilt.severity,
                  ),

                  SizedBox(height: 30.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppText.riskByBodyRegion,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),
                  Builder(
                    builder: (context) {
                      final risks = analysisData?.aiResult.bodyRegionRisks;
                      final menuItems = risks == null
                          ? <BodyRegionRiskModel>[]
                          : [
                              BodyRegionRiskModel(
                                region: 'Elbows',
                                risk: risks.elbows,
                              ),
                              BodyRegionRiskModel(
                                region: 'Shoulder',
                                risk: risks.shoulder,
                              ),
                              BodyRegionRiskModel(
                                region: 'Wrist',
                                risk: risks.wrist,
                              ),
                              BodyRegionRiskModel(
                                region: 'Lower Back',
                                risk: risks.lowerBack,
                              ),
                            ];
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: menuItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.h,
                          crossAxisSpacing: 12.w,
                          mainAxisExtent: 120,
                        ),
                        itemBuilder: (context, index) {
                          final item = menuItems[index];
                          return RiskBodyRegionMenu(
                            region: item.region,
                            risk: item.risk,
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 120.h), // Add padding for bottom sheet
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: Container(
        height: 120.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(color: AppColors.onBoardingSurface),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                // EN: "Back"
                text: loc.backButton,
                onTap: () {
                  context.go(AppRoute.bottomNavBusiness);
                },
                backgroundColor: AppColors.greyDeemed,
                textColor: AppColors.text,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                onTap: () {
                  context.push(AppRoute.correctionReportScreenBusiness);
                },
                // EN: "View Correction"
                text: loc.viewCorrection,
                backgroundColor: AppColors.primaryColor,
                textColor: AppColors.onBoardingSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
