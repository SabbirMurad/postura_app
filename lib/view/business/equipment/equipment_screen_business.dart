import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:share_plus/share_plus.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/duration_container.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/models/user_type.dart';
import 'package:posture_detector_app/main.dart';
import 'package:posture_detector_app/provider/report.dart';

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
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _initializeRole();
    Future(() => ref.read(reportNotifierProvider.notifier).fetchMyReports());
  }

  /// Initialize user role async
  Future<void> _initializeRole() async {
    try {
      final role = await AppHelper.instance.getAuthRole();
      debugPrint("Fetched user role: $role ${UserType.EMPLOYEE}");
      setState(() => _userRole = role ?? '');
    } catch (e) {
      debugPrint('Error getting auth role: $e');
    }
  }

  Future<void> _sendCompanyData() async {
    try {
      await CustomHttp.post(
        endpoint: 'companies/share-data',
        showFloatingError: true,
        needAuth: true,
      );
      showCustomToast(
        // EN: "Recommendations sent to HR"
        text: AppLocalizations.of(
          scaffoldMessengerKey.currentContext!,
        )!.recommendationsSentToHr,
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
      final pdfUrl = ref
          .read(reportNotifierProvider)
          .analysisData
          ?.aiResult
          .equipmentExcelUrl;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        // EN: "No PDF available"
        showCustomToast(text: loc.noPdfAvailable);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = pdfUrl.split('/').last.split('?').first;
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(pdfUrl, filePath);

      // EN: "Your report PDF"
      await Share.shareXFiles([XFile(filePath)], text: loc.yourReportPdf);
    } catch (e) {
      debugPrint('$e');
      // EN: "Something went wrong"
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
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      final reportState = ref.watch(reportNotifierProvider);
                      final equipmentList =
                          reportState.analysisData?.aiResult.equipment ?? [];

                      return Column(
                        children: [
                          // Header Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            child: AppTopSection(
                              // EN: equipmentRecommendations = "Equipment Recommendations", equipmentRecommendationsSubtitle = "Based on your posture analysis, the following equipment is recommended to improve your ergonomic setup"
                              hasBackButton: widget.backButton,
                              title: loc.equipmentRecommendations,
                              subtitle: loc.equipmentRecommendationsSubtitle,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          if (equipmentList.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 72.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                    // EN: "No data found"
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
                          if (equipmentList.isNotEmpty)
                            ...equipmentList.map((equipment) {
                              final isHigh = equipment.priority == 'high';
                              final isMedium = equipment.priority == 'medium';

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: 12.h,
                                  left: 20.w,
                                  right: 20.w,
                                ),
                                child: RecommendationContainer(
                                  title: equipment.name,
                                  subtitle: equipment.description,
                                  status: equipment.status,
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
                            }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Buttons Section
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
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
                      // EN: "Download List"
                      text: loc.downloadList,
                      backgroundColor: AppColors.greyDeemed,
                      textColor: AppColors.primaryColor,
                    ),

                    SizedBox(height: 8.h),

                    // Send to Company (Only Employees)
                    if (_userRole == "EMPLOYEE" && widget.canSendListToCompany)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: PrimaryButton(
                          onTap: () {
                            _sendCompanyData();
                          },
                          // EN: "Send data to Company"
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
                    if (widget.dashboardButton)
                      // Open Dashboard Button
                      PrimaryButton(
                        onTap: () {
                          context.go(AppRoute.bottomNavBusiness);
                        },
                        height: 45.h,
                        // EN: "Open Dashboard"
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

/// 🔹 Recommendation Card
class RecommendationContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priority;
  final String improvement;
  final Color chipColor;
  final Color chipTextColor;
  final String source;
  final String status;

  const RecommendationContainer({
    super.key,
    required this.title,
    required this.status,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
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
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: status == 'ACTIONED'
                        ? AppColors.green
                        : status == 'PENDING'
                        ? AppColors.warning
                        : AppColors.red,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
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
