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
import 'package:posture_detector_app/common/widgets/analysis_section_container.dart';
import 'package:posture_detector_app/common/widgets/details_analysis_list.dart';
import 'package:posture_detector_app/common/widgets/home_top_section.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/provider/author.dart';
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

  static const _rosaItems = [
    RosaItem(
      category: 'Chair',
      score: '3 / 3',
      status: RosaStatus('Too high', RosaRisk.red),
    ),
    RosaItem(
      category: 'Monitor',
      score: '2 / 3',
      status: RosaStatus('Looking up', RosaRisk.red),
    ),
    RosaItem(
      category: 'Keyboard',
      score: '1 / 3',
      status: RosaStatus('Wrists extended', RosaRisk.orange),
    ),
    RosaItem(
      category: 'Mouse',
      score: '2 / 3',
      status: RosaStatus('Optimal', RosaRisk.green),
    ),
    RosaItem(
      category: 'Final ROSA',
      score: '7 / 10',
      status: RosaStatus('High risk', RosaRisk.red),
    ),
  ];

  Widget _rosaAssessmentSection() {
    return Wrap(
      spacing: 12.w,
      children: _rosaItems.map((item) {
        return RosaSubScoreItem(item: item);
      }).toList(),
    );
  }

  Widget _rosaScoreCard() {
    const score = '7 / 10';
    const label = 'High risk - immediate action required';
    const actionLevel = 'Level 3 - Action required as soon as possible';
    const scoreColor = Color(0xFFE53935);

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
          Text(
            score,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: scoreColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  actionLevel,
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
                    final analysisData = reportState.analysisData;

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

                    final risks =
                        reportState.analysisData!.aiResult.bodyRegionRisks;
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
                        _rosaScoreCard(),
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
                        _rosaAssessmentSection(),

                        // if (posture != null)
                        //   DetailsAnalysisList(posture: posture)
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
                          loading: reportState.isExportingPDF,
                          onTap: () {
                            final pdfUrl =
                                reportState.analysisData?.aiResult.pdfReportUrl;

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
                            fontSize: 16.sp,
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
