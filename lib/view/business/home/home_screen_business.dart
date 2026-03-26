import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/controller/report_controller.dart';
import 'package:posture_detector_app/controller/personal_home_controller.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';
import 'package:posture_detector_app/common/widgets/analysis_section_container.dart';
import 'package:posture_detector_app/common/widgets/details_analysis_list.dart';
import 'package:posture_detector_app/common/widgets/home_top_section.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class HomeScreenBusiness extends StatefulWidget {
  const HomeScreenBusiness({super.key});

  @override
  State<HomeScreenBusiness> createState() => _HomeScreenBusinessState();
}

class _HomeScreenBusinessState extends State<HomeScreenBusiness> {
  // ✅ Initialize controllers safely
  late final PersonalHomeController personalHomeController;
  late final PersonalProfileController profileController;
  late final ReportController reportController;

  @override
  void initState() {
    super.initState();
    personalHomeController = Get.find<PersonalHomeController>();
    profileController = Get.find<PersonalProfileController>();
    reportController = Get.find<ReportController>();

    // Defer fetch until after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reportController.fetchMyReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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

                /// ✅ Top Section with proper null handling
                Obx(() {
                  final analysisData = reportController.analysisData.value;
                  final profileData = profileController.profileInfo.value?.data;
                  final posture =
                      analysisData?.aiResult.detailedAnalysis.posture;

                  // ✅ Loading state
                  if (analysisData == null &&
                      reportController.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100.h),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  // ✅ Empty state
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
                              onTap: () => reportController.fetchMyReports(),
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

                  // ✅ Data loaded successfully
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Home header
                      HomeTopSection(
                        name: profileData?.fullName ?? 'User',
                        image: profileData?.avatar != null &&
                                profileData!.avatar!.isNotEmpty
                            ? CachedNetworkImageProvider(profileData.avatar!)
                            : null,
                      ),

                      SizedBox(height: 15.h),

                      /// Analysis section
                      AnalysisSectionContainer(
                        percentageText:
                            (analysisData.aiResult.complianceScore )
                                .toStringAsFixed(1),
                        percentage:
                            (analysisData.aiResult.complianceScore ) / 100,
                        result: analysisData.aiResult,
                      ),
                      SizedBox(height: 19.h),

                      /// Details analysis header
                      // EN: "Detailed Analysis"
                      Text(
                        loc.detailsAnalysis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      /// Details analysis containers
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

                /// Body region section
                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
                  // EN: "Risk by Body Region"
                  child: Text(
                    loc.riskByBodyRegion,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                Obx(() {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: personalHomeController.menuItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      mainAxisExtent: 120,
                    ),
                    itemBuilder: (context, index) {
                      final item = personalHomeController.menuItems[index];
                      return RiskBodyRegionMenu(
                        region: item.region,
                        risk: item.risk,
                      );
                    },
                  );
                }),
                SizedBox(height: 30.h),

                /// Export PDF button
                Obx(
                  () => PrimaryButton(
                    loading: reportController.isExportingPDF.value,
                    onTap: () {
                      reportController.exportReportPDF();
                    },
                    // EN: "Export ISO Report PDF"
                    text: AppLocalizations.of(context)!.exportIsoReportPdf,
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
