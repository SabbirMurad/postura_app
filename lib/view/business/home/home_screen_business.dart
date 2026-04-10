import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class HomeScreenBusiness extends ConsumerStatefulWidget {
  const HomeScreenBusiness({super.key});

  @override
  ConsumerState<HomeScreenBusiness> createState() => _HomeScreenBusinessState();
}

class _HomeScreenBusinessState extends ConsumerState<HomeScreenBusiness> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportNotifierProvider.notifier).fetchMyReports();
    });
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

                Builder(builder: (context) {
                  final analysisData = reportState.analysisData;
                  final posture =
                      analysisData?.aiResult.detailedAnalysis.posture;

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
                              color: AppColors.secondaryText.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              // EN: "No analysis data available"
                              AppLocalizations.of(context)!.noAnalysisDataAvailable,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            PrimaryButton(
                              onTap: () => ref.read(reportNotifierProvider.notifier).fetchMyReports(),
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      HomeTopSection(
                        name: profileData?.fullName ?? 'User',
                        image: profileData?.avatar != null &&
                                profileData!.avatar!.isNotEmpty
                            ? CachedNetworkImageProvider(profileData.avatar!)
                            : null,
                      ),

                      SizedBox(height: 15.h),

                      AnalysisSectionContainer(
                        percentageText:
                            (analysisData.aiResult.complianceScore)
                                .toStringAsFixed(1),
                        percentage:
                            (analysisData.aiResult.complianceScore) / 100,
                        result: analysisData.aiResult,
                      ),
                      SizedBox(height: 19.h),

                      Text(
                        // EN: "Detailed Analysis"
                        loc.detailsAnalysis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      if (posture != null)
                        DetailsAnalysisList(posture: posture)
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            // EN: "No posture data available"
                            child: Text(loc.noPostureDataAvailable),
                          ),
                        ),
                    ],
                  );
                }),

                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // EN: "Risk by Body Region"
                    loc.riskByBodyRegion,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                Builder(builder: (context) {
                  final risks = reportState.analysisData?.aiResult.bodyRegionRisks;
                  final menuItems = risks == null
                      ? <BodyRegionRiskModel>[]
                      : [
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
                }),
                SizedBox(height: 30.h),

                PrimaryButton(
                    loading: reportState.isExportingPDF,
                    onTap: () {
                      ref.read(reportNotifierProvider.notifier).exportReportPDF();
                    },
                    // EN: "Export ISO Report PDF"
                    text: AppLocalizations.of(context)!.exportRosaReportPdf,
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
            ),
          ),
        ),
      ),
    );
  }
}
