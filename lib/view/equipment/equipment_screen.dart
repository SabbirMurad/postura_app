import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/view/equipment/widgets/equipment_recommendation_card.dart';
import 'package:posture_detector_app/view/equipment/widgets/equipment_recommendation_card_v13.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/services/equipment_engine.dart';
import 'package:posture_detector_app/models/equipment/equipment_output.dart';

class EquipmentScreenBusiness extends ConsumerStatefulWidget {
  final bool canSendListToCompany;
  final bool dashboardButton;
  final bool backButton;

  const EquipmentScreenBusiness({
    super.key,
    required this.canSendListToCompany,
    required this.dashboardButton,
    required this.backButton,
  });

  @override
  ConsumerState<EquipmentScreenBusiness> createState() =>
      _EquipmentScreenBusinessState();
}

class _EquipmentScreenBusinessState
    extends ConsumerState<EquipmentScreenBusiness> {
  @override
  void initState() {
    super.initState();
    Future(() => ref.read(reportNotifierProvider.notifier).fetchMyReports());
  }

  /// Build engine input from report state, returns null if required data missing
  EquipmentOutput? _buildEngineOutput(ReportState reportState) {
    final data = reportState.analysisReport;
    if (data == null) return null;

    final painIntensities = data.painIntensities;

    double? vasFor(List<String> regions) {
      for (final pi in painIntensities) {
        if (regions.any(
          (r) => pi.bodyRegion.toLowerCase().contains(r.toLowerCase()),
        )) {
          return pi.intensity.toDouble();
        }
      }
      return null;
    }

    final symptoms = data.symptoms;

    final input = EquipmentEngineInput(
      rosaScore: data.rosaScore,
      workZoneType: 'desk',
      hoursAtDesk: data.workPattern.hoursAtDesk,
      breakHabit: data.workPattern.breakHabit,
      deviceSetup: data.workPattern.deviceUsage,
      mouseType: data.workPattern.mouseType,
      painDuration: data.painDuration,
      vasNeck: vasFor(['neck']),
      vasUpperBack: vasFor(['upper back', 'upper_back']),
      vasLowerBack: vasFor(['lower back', 'lower_back']),
      vasShoulder: vasFor(['shoulder']),
      vasWrist: vasFor(['wrist']),
      vasElbow: vasFor(['elbow']),
      vasKnee: vasFor(['knee']),
      vasFeet: vasFor(['feet', 'foot', 'ankle']),
      vasHip: vasFor(['hip']),
      symTingling: symptoms.any((s) => s.toLowerCase().contains('tingling')),
      symFatigue: symptoms.any((s) => s.toLowerCase().contains('fatigue')),
      symEndOfDay: symptoms.any((s) => s.toLowerCase().contains('end')),
      symStiffness: symptoms.any((s) => s.toLowerCase().contains('stiff')),
      symMorningPain: symptoms.any((s) => s.toLowerCase().contains('morning')),
    );

    return EquipmentEngine.run(input);
  }

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final reportState = ref.watch(reportNotifierProvider);
    // Equipment Engine v1.3 — deterministic, fixed-copy cards from the
    // backend, shared FINDING_IDs with the Action Report. Preferred whenever
    // present; the local ROSA/VAS-based EquipmentEngine and the AI-generated
    // list only cover scans that predate the v1.3 rollout.
    final v13Report = reportState.analysisReport?.actionReportV13;
    final v13Cards = v13Report?.equipmentCards ?? const [];
    final engineOutput = v13Report == null ? _buildEngineOutput(reportState) : null;
    final fallbackList = reportState.analysisReport?.equipment ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: AppTopSection(
                        hasBackButton: widget.backButton,
                        title: loc.equipmentRecommendations,
                        subtitle: loc.basedOnPostureAnalysisIso,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Tier banner — v1.3 report preferred, legacy engine as fallback.
                    if (v13Report != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            'Tier ${v13Report.tierNumber} - ${v13Report.tierName} | ROSA ${v13Report.rosaScore}/10',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ] else if (engineOutput != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: _tierColor(
                              engineOutput.tier,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _tierColor(
                                engineOutput.tier,
                              ).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _tierColor(
                                    engineOutput.tier,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Text(
                                  engineOutput.tier,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _tierColor(engineOutput.tier),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                engineOutput.tierMessage,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Equipment cards — v1.3 report preferred over the legacy engine.
                    if (v13Report != null && v13Cards.isNotEmpty)
                      ...v13Cards.map(
                        (card) => Padding(
                          padding: EdgeInsets.only(
                            bottom: 12.h,
                            left: 20.w,
                            right: 20.w,
                          ),
                          child: EquipmentRecommendationCardV13(card: card),
                        ),
                      )
                    else if (v13Report != null && v13Cards.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 72.w),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64.sp,
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                loc.noDataFound,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (engineOutput != null &&
                        engineOutput.equipmentCards.isNotEmpty)
                      ...engineOutput.equipmentCards.map((card) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 12.h,
                            left: 20.w,
                            right: 20.w,
                          ),
                          child: EquipmentRecommendationCard(
                            title: card.title,
                            subtitle: card.description,
                            source: card.sourceLine,
                            urgencyLabel: card.urgencyLabel,
                            urgencyLevel: card.urgencyLevel,
                            riskBadgeText: card.riskBadgeText,
                            cardNote: card.cardNote,
                            chronicityFlag: card.chronicityFlag,
                          ),
                        );
                      })
                    else if (engineOutput == null && fallbackList.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 72.w),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64.sp,
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                loc.noDataFound,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Fallback: API equipment list with legacy card style
                    else if (engineOutput == null && fallbackList.isNotEmpty)
                      ...fallbackList.map((equipment) {
                        final isHigh = equipment.priority == 'high';
                        final isMedium = equipment.priority == 'medium';
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 12.h,
                            left: 20.w,
                            right: 20.w,
                          ),
                          child: EquipmentRecommendationCard(
                            title: equipment.name,
                            subtitle: equipment.description,
                            source: equipment.source ?? 'Unknown',
                            urgencyLabel: isHigh
                                ? 'Urgent'
                                : isMedium
                                ? 'Recommended'
                                : 'Preventive',
                            urgencyLevel: isHigh
                                ? 3
                                : isMedium
                                ? 2
                                : 1,
                            riskBadgeText: equipment.improvementPercentage,
                            chronicityFlag: false,
                            status: equipment.status.isNotEmpty
                                ? equipment.status
                                : null,
                          ),
                        );
                      }),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.dashboardButton)
                      PrimaryButton(
                        onTap: () => context.go(AppRoute.bottomNavBusiness),
                        height: 45.h,
                        text: loc.openDashboard,
                        backgroundColor: AppColors.primaryColor,
                        textColor: AppColors.onBoardingSurface,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
