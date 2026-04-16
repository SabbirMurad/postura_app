import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';

class OutputScreenBusiness extends ConsumerWidget {
  const OutputScreenBusiness({super.key});

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'green':
        return const Color(0xFF437A22);
      case 'orange':
        return const Color(0xFFDA7101);
      case 'red':
        return const Color(0xFFA13544);
      case 'yellow':
        return const Color(0xFFDAA101);
      default:
        return AppColors.secondaryText;
    }
  }

  String _tierMessage(String tier) {
    switch (tier.toLowerCase()) {
      case 'green':
        return 'Your workspace posture is within safe ergonomic limits.';
      case 'orange':
        return 'Some ergonomic adjustments are recommended.';
      case 'red':
        return 'Immediate ergonomic corrections are needed.';
      case 'yellow':
        return 'Mild ergonomic risk detected — monitor and adjust.';
      default:
        return 'Complete your assessment to see your risk tier.';
    }
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Action Level 3 — Investigate and change soon';
    if (score >= 4) return 'Action Level 2 — Further investigation needed';
    return 'Action Level 1 — No immediate action needed';
  }

  Color _subScoreColor(int score) {
    if (score >= 5) return const Color(0xFFA13544);
    if (score >= 3) return const Color(0xFFDA7101);
    return const Color(0xFF437A22);
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
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(loc.loadingAnalysisData),
                ],
              ),
            );
          }

          final aiResult = analysisData.aiResult;
          final tier = aiResult.overallRisk;
          final tierColor = _tierColor(tier);
          final rosaFinal = aiResult.rosaFinal ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),

                  /// Screen title
                  Center(
                    child: Text(
                      loc.rosaErgonomicAnalysis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      loc.basedOnIso9241,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  /// Risk Tier Badge
                  if (tier.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: tierColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tier.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: tierColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _tierMessage(tier),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    /// ROSA Final Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ROSA Score: ',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                ),
                              ),
                              TextSpan(
                                text: '$rosaFinal',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: tierColor,
                                ),
                              ),
                              TextSpan(
                                text: ' / 10',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _actionLevel(rosaFinal),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],

                  /// Annotated image
                  if (aiResult.annotatedImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: aiResult.annotatedImageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 30.h),

                  /// ROSA Sub-score Analysis
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ROSA Sub-scores',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildRosaRow(
                    context,
                    label: 'Chair',
                    score: aiResult.rosaChair ?? 0,
                    icon: Icons.chair_rounded,
                  ),
                  SizedBox(height: 10.h),
                  _buildRosaRow(
                    context,
                    label: 'Monitor / Screen',
                    score: aiResult.rosaMonitor ?? 0,
                    icon: Icons.monitor_rounded,
                  ),
                  SizedBox(height: 10.h),
                  _buildRosaRow(
                    context,
                    label: 'Keyboard',
                    score: aiResult.rosaKeyboard ?? 0,
                    icon: Icons.keyboard_rounded,
                  ),
                  SizedBox(height: 10.h),
                  _buildRosaRow(
                    context,
                    label: 'Mouse / Peripherals',
                    score: aiResult.rosaMouse ?? 0,
                    icon: Icons.mouse_rounded,
                  ),
                  SizedBox(height: 10.h),
                  _buildRosaRow(
                    context,
                    label: 'Final ROSA Score',
                    score: rosaFinal,
                    icon: Icons.assessment_rounded,
                    isFinal: true,
                  ),

                  SizedBox(height: 30.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Risk by Body Region',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Builder(
                    builder: (context) {
                      final risks = aiResult.bodyRegionRisks;
                      final menuItems = [
                        BodyRegionRiskModel(region: 'Elbows', risk: risks.elbows),
                        BodyRegionRiskModel(region: 'Shoulder', risk: risks.shoulder),
                        BodyRegionRiskModel(region: 'Wrist', risk: risks.wrist),
                        BodyRegionRiskModel(region: 'Lower Back', risk: risks.lowerBack),
                      ];
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                  SizedBox(height: 120.h),
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
                text: loc.backButton,
                onTap: () => context.go(AppRoute.bottomNavBusiness),
                backgroundColor: AppColors.greyDeemed,
                textColor: AppColors.text,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                onTap: () => context.push(AppRoute.correctionReportScreenBusiness),
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

  Widget _buildRosaRow(
    BuildContext context, {
    required String label,
    required int score,
    required IconData icon,
    bool isFinal = false,
  }) {
    final color = _subScoreColor(score);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isFinal
              ? color.withValues(alpha: 0.4)
              : AppColors.secondaryText.withValues(alpha: 0.15),
          width: isFinal ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isFinal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
