import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:share_plus/share_plus.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/duration_container.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class EquipmentScreenBusiness extends StatefulWidget {
  const EquipmentScreenBusiness({super.key});

  @override
  State<EquipmentScreenBusiness> createState() =>
      _EquipmentScreenBusinessState();
}

class _EquipmentScreenBusinessState extends State<EquipmentScreenBusiness> {
  final SignupController signupController = Get.find<SignupController>();
  final ReportController reportController = Get.find<ReportController>();

  /// Reactive user role using enum
  Rx<String> userRole = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializeRole();
  }

  /// Initialize user role async
  Future<void> _initializeRole() async {
    try {
      final role = await AppHelper.instance.getAuthRole();
      debugPrint("Fetched user role: $role ${Users.EMPLOYEE}");
      userRole.value = role ?? '';
    } catch (e) {
      debugPrint('Error getting auth role: $e');
    }
  }

  Future<void> _sendCompanyData() async {
    try {
      await CustomHttp.post(
        endpoint: 'companies/share-data',
        body: {},
        showFloatingError: true,
        needAuth: true,
      );
      showCustomToast(
        text: AppLocalizations.of(Get.context!)!.recommendationsSentToHr,
        toastType: ToastTypesInfo(ToastTypes.success),
      );
    } catch (e) {
      debugPrint('Error sending data to company: $e');
    }
  }

  /// Download & share PDF
  ///
  Future<void> _exportReportPDF() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final pdfUrl =
          reportController.analysisData.value?.aiResult.equipmentPdfUrl;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        showCustomToast(text: loc.noPdfAvailable);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = pdfUrl.split('/').last.split('?').first;
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(pdfUrl, filePath);

      await Share.shareXFiles([XFile(filePath)], text: AppLocalizations.of(Get.context!)!.yourReportPdf);

      // showCustomToast(text: "PDF downloadeded completely");
    } catch (e) {
      debugPrint('$e');
      showCustomToast(text: loc.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: AppTopSection(
                title: loc.equipmentRecommendations,
                subtitle: loc.equipmentRecommendationsSubtitle,
              ),
            ),

            SizedBox(height: 14.h),

            // Content Area (Scrollable)
            Expanded(
              child: Obx(() {
                final equipmentList =
                    reportController.analysisData.value?.aiResult.equipment ??
                    [];

                if (equipmentList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64.sp,
                          color: AppColors.secondaryText.withValues(alpha: 0.5),
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
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: equipmentList.length,
                  itemBuilder: (context, index) {
                    final equipment = equipmentList[index];

                    final isHigh = equipment.priority == 'high';
                    final isMedium = equipment.priority == 'medium';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: RecommendationContainer(
                        title: equipment.name,
                        subtitle: equipment.description,
                        priority: isHigh
                            ? "High Priority"
                            : isMedium
                            ? "Medium"
                            : "Low",
                        improvement: equipment.improvementPercentage,
                        source: equipment.source ?? 'Unknown',
                        chipColor: isHigh
                            ? AppColors.red
                            : isMedium
                            ? AppColors.warning
                            : AppColors.greenish,
                        chipTextColor: isHigh || isMedium
                            ? AppColors.surface
                            : AppColors.green,
                      ),
                    );
                  },
                );
              }),
            ),

            // Bottom Buttons Section
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Obx(() {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Download Button
                      PrimaryButton(
                        onTap: _exportReportPDF,
                        leading: Icon(
                          Icons.file_download_sharp,
                          color: AppColors.primaryColor,
                        ),
                        height: 45.h,
                        text: loc.downloadList,
                        backgroundColor: AppColors.greyDeemed,
                        textColor: AppColors.primaryColor,
                      ),

                      SizedBox(height: 8.h),

                      // Send to Company (Only Employees)
                      if (userRole.value == "EMPLOYEE")
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: PrimaryButton(
                            onTap: () {
                              _sendCompanyData();
                            },
                            text: loc.sendDataToCompany,
                            leading: Assets.icons.auth.message.svg(
                              width: 18.w,
                              height: 18.h,
                            ),
                            height: 45.h,
                            backgroundColor: AppColors.warning,
                            textColor: AppColors.onBoardingSurface,
                          ),
                        ),

                      // Open Dashboard Button
                      PrimaryButton(
                        onTap: () {
                          if (userRole.value == "EMPLOYEE") {
                            Get.offAllNamed(AppRoute.bottomNavBusiness);
                          } else {
                            Get.offAllNamed(AppRoute.bottomNavPersonal);
                          }
                        },
                        height: 45.h,
                        text: loc.openDashboard,
                        backgroundColor: AppColors.primaryColor,
                        textColor: AppColors.onBoardingSurface,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Recommendation Card
class RecommendationContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priority;
  final String improvement;
  final Color chipColor;
  final Color chipTextColor;
  final String source;

  const RecommendationContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.improvement,
    required this.chipColor,
    required this.chipTextColor,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.onBoardingSurface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  'Source:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    source,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(166, 166, 166, 1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                DurationContainer(
                  content: priority,
                  bgColor: chipColor,
                  textColor: chipTextColor,
                ),
                SizedBox(width: 8.w),
                DurationContainer(
                  icon: Icons.timeline_rounded,
                  content: improvement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 FlutterDownloader Top-Level Callback
@pragma('vm:entry-point')
void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  if (status == DownloadTaskStatus.complete) {
    // TODO: Open the downloaded file here if you have path mapping
    debugPrint("Download completed for task $id");
  }
}
