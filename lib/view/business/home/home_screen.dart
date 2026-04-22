import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/common/widgets/rosa_sub_score.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/common/widgets/home_top_section.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/rosa_score.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreenBusiness extends ConsumerStatefulWidget {
  const HomeScreenBusiness({super.key});

  @override
  ConsumerState<HomeScreenBusiness> createState() => _HomeScreenBusinessState();
}

enum RosaRisk { red, orange, green }

class RosaStatus {
  final String label;
  final RosaRisk risk;
  const RosaStatus(this.label, this.risk);
}

class RosaItem {
  final String category;
  final String score;
  final RosaStatus status;
  const RosaItem({
    required this.category,
    required this.score,
    required this.status,
  });
}

class _HomeScreenBusinessState extends ConsumerState<HomeScreenBusiness> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportNotifierProvider.notifier).fetchMyReports();
    });
  }

  // ── Risk helpers ────────────────────────────────────────────────────────

  RosaRisk _subScoreRisk(int score) {
    if (score >= 3) return RosaRisk.red;
    if (score >= 2) return RosaRisk.orange;
    return RosaRisk.green;
  }

  RosaRisk _finalScoreRisk(int score) {
    if (score >= 7) return RosaRisk.red;
    if (score >= 4) return RosaRisk.orange;
    return RosaRisk.green;
  }

  String _subScoreLabel(int score) {
    if (score == 0) return 'Not assessed';
    if (score >= 3) return 'High risk';
    if (score >= 2) return 'Review needed';
    return 'Optimal';
  }

  String _finalLabel(int score) {
    if (score >= 7) return 'High risk — immediate action required';
    if (score >= 4) return 'Moderate risk — further investigation';
    return 'Low risk — no immediate action needed';
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Level 3 — Action required as soon as possible';
    if (score >= 4) return 'Level 2 — Further investigation needed';
    return 'Level 1 — No immediate action needed';
  }

  Color _riskColor(RosaRisk risk) {
    switch (risk) {
      case RosaRisk.red:
        return const Color(0xFFE53935);
      case RosaRisk.orange:
        return const Color(0xFFFB8C00);
      case RosaRisk.green:
        return const Color(0xFF43A047);
    }
  }

  List<RosaItem> _buildRosaItems(RosaScore score) => [
    RosaItem(
      category: 'Seat Height',
      score: '${score.seatHeightScore}',
      status: RosaStatus(
        _subScoreLabel(score.seatHeightScore),
        _subScoreRisk(score.seatHeightScore),
      ),
    ),
    RosaItem(
      category: 'Backrest',
      score: '${score.backrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.backrestScore),
        _subScoreRisk(score.backrestScore),
      ),
    ),
    RosaItem(
      category: 'Armrest',
      score: '${score.armrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.armrestScore),
        _subScoreRisk(score.armrestScore),
      ),
    ),
    RosaItem(
      category: 'Chair',
      score: '${score.chairScore}',
      status: RosaStatus(
        _subScoreLabel(score.chairScore),
        _subScoreRisk(score.chairScore),
      ),
    ),
    RosaItem(
      category: 'Monitor',
      score: '${score.monitorScore}',
      status: RosaStatus(
        _subScoreLabel(score.monitorScore),
        _subScoreRisk(score.monitorScore),
      ),
    ),
    RosaItem(
      category: 'Keyboard',
      score: '${score.keyboardScore}',
      status: RosaStatus(
        _subScoreLabel(score.keyboardScore),
        _subScoreRisk(score.keyboardScore),
      ),
    ),
    RosaItem(
      category: 'Mouse',
      score: '${score.mouseScore}',
      status: RosaStatus(
        _subScoreLabel(score.mouseScore),
        _subScoreRisk(score.mouseScore),
      ),
    ),
    RosaItem(
      category: 'Peripheral',
      score: '${score.peripheralScore}',
      status: RosaStatus(
        _subScoreLabel(score.peripheralScore),
        _subScoreRisk(score.peripheralScore),
      ),
    ),
  ];

  Widget _rosaAssessmentSection(RosaScore score) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.w,
      children: _buildRosaItems(
        score,
      ).map((item) => RosaSubScoreItem(item: item)).toList(),
    );
  }

  Widget _rosaScoreCard(RosaScore score) {
    final risk = _finalScoreRisk(score.finalScore);
    final scoreColor = _riskColor(risk);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/rosa/final_rosa.svg',
                width: 40.w,
                height: 40.w,
              ),
              SizedBox(height: 6.w),
              Text(
                '${score.finalScore} / 10',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _finalLabel(score.finalScore),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _actionLevel(score.finalScore),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyRegionRiskSection(List<BodyRegionRiskModel> items) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.w,
      children: items.map((item) {
        return RiskBodyRegionMenu(region: item.region, risk: item.risk);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profileData = ref.watch(authorNotifierProvider).value?.data;
    final reportState = ref.watch(reportNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                Builder(
                  builder: (context) {
                    final analysisData = reportState.analysisReport;

                    if (analysisData == null && reportState.isLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 100.h),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }

                    if (analysisData == null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 100.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 64.sp,
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                // EN: "No analysis data available"
                                AppLocalizations.of(
                                  context,
                                )!.noAnalysisDataAvailable,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              PrimaryButton(
                                onTap: () => ref
                                    .read(reportNotifierProvider.notifier)
                                    .fetchMyReports(),
                                // EN: "Retry"
                                text: AppLocalizations.of(context)!.retry,
                                backgroundColor: AppColors.primaryColor,
                                textColor: AppColors.surface,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final risks = reportState.analysisReport!.bodyRegionRisks;
                    final bodyRegionRiskItems = [
                      BodyRegionRiskModel(region: 'Elbows', risk: risks.elbows),
                      BodyRegionRiskModel(
                        region: 'Shoulder',
                        risk: risks.shoulder,
                      ),
                      BodyRegionRiskModel(region: 'Wrist', risk: risks.wrist),
                      BodyRegionRiskModel(
                        region: 'Lower Back',
                        risk: risks.lowerBack,
                      ),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HomeTopSection(
                          name: profileData?.fullName ?? 'User',
                          image:
                              profileData?.avatar != null &&
                                  profileData!.avatar!.isNotEmpty
                              ? CachedNetworkImageProvider(profileData.avatar!)
                              : null,
                        ),

                        SizedBox(height: 24.h),
                        // EN: "ISO Ergonomic Analysis"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              loc.rosaErgonomicAnalysis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _rosaScoreCard(analysisData.rosaScore),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              // EN: "Detailed Analysis"
                              loc.detailsAnalysis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _rosaAssessmentSection(analysisData.rosaScore),
                        SizedBox(height: 24.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // EN: "Risk by Body Region"
                            loc.riskByBodyRegion,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _bodyRegionRiskSection(bodyRegionRiskItems),
                        SizedBox(height: 24.h),
                        PrimaryButton(
                          onTap: () {
                            final pdfUrl =
                                reportState.analysisReport?.pdfReportUrl;

                            if (pdfUrl == null || pdfUrl.isEmpty) {
                              // EN: "No PDF available"
                              showCustomToast(text: loc.noPdfAvailable);
                              return;
                            }

                            launchUrl(
                              mode: LaunchMode.externalApplication,
                              Uri.parse(pdfUrl),
                            );
                          },
                          // EN: "Export ISO Report PDF"
                          text: AppLocalizations.of(
                            context,
                          )!.exportRosaReportPdf,
                          backgroundColor: AppColors.primaryColor,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          prefixIcon: Icons.download,
                          prefixIconColor: AppColors.surface,
                          prefixIconSize: 22.sp,
                        ),

                        SizedBox(height: 20.h),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
