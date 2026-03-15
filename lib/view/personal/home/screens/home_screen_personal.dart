import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';
import 'package:posture_detector_app/controller/report_controller.dart';
import 'package:posture_detector_app/common/widgets/analysis_section_container.dart';
import 'package:posture_detector_app/common/widgets/details_analysis_list.dart';
import 'package:posture_detector_app/common/widgets/home_top_section.dart';
import 'package:posture_detector_app/common/widgets/risky_body_region_menu.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/personal_home_controller.dart';

class HomeScreenPersonal extends StatefulWidget {
  HomeScreenPersonal({super.key});

  @override
  State<HomeScreenPersonal> createState() => _HomeScreenPersonalState();
}

class _HomeScreenPersonalState extends State<HomeScreenPersonal> {
  final PersonalHomeController personalHomeController = Get.find<PersonalHomeController>();

  final PersonalProfileController _profileController =
      Get.find<PersonalProfileController>();

  final ReportController _reportController = Get.find<ReportController>();

  @override
  void initState() {
    super.initState();
    // Defer fetch until after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportController.fetchMyReports();
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

                /// ------------------------- Top Section ---------------------------------- ///
                Obx(() {
                  final analysisData = _reportController.analysisData.value;
                  final profileData =
                      _profileController.profileInfo.value?.data;
                  final posture =
                      analysisData?.aiResult.detailedAnalysis.posture;

                  // Show loading while fetching
                  if (analysisData == null &&
                      _reportController.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100.h),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  // Show error message if no data
                  if (analysisData == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100.h),
                        child: Text(
                          loc.noAnalysisDataAvailable,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
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

                      /// ------------------------- Analysis Section ---------------------------- ///
                      AnalysisSectionContainer(
                        percentageText:
                            (analysisData.aiResult.complianceScore ?? 0)
                                .toStringAsFixed(1),
                        percentage:
                            (analysisData.aiResult.complianceScore ?? 0) / 100,
                        result: analysisData.aiResult,
                      ),
                      SizedBox(height: 19.h),

                      /// ------------------------------- Details Analysis Section -------------------------- ///
                      Text(
                        loc.detailsAnalysis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      if (posture != null)
                        DetailsAnalysisList(posture: posture),
                    ],
                  );
                }),

                /// ------------------------------- Body Region Section -------------------------- ///
                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
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
                    physics: NeverScrollableScrollPhysics(),
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

                /// ------------------------------- Export ISO Report Button Section -------------------------- ///
                Obx(
                  () => PrimaryButton(
                    loading: _reportController.isExportingPDF.value,
                    onTap: () {
                      _reportController.exportReportPDF();
                    },
                    text: loc.exportIsoReportPdf,
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
