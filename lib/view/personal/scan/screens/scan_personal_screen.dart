import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/primary_scan_alert_dialog.dart';
import 'package:posture_detector_app/common/widgets/scan_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/core/enums/scan_type.dart';

class ScanPersonalScreen extends StatefulWidget {
  const ScanPersonalScreen({super.key});

  @override
  State<ScanPersonalScreen> createState() => _ScanPersonalScreenState();
}

class _ScanPersonalScreenState extends State<ScanPersonalScreen> {
  bool _primaryScanShown = false;

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

                /// Header
                Text(
                  loc.scanYourPosture,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                  ),
                ),
                Text(
                  loc.scanYourPostureSubtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),

                SizedBox(height: 63.h),

                /// Scan Image
                Center(
                  child: Assets.images.general.scan.image(
                    height: 231.h,
                    width: 233.w,
                  ),
                ),

                SizedBox(height: 54.h),

                /// Instant Scan Button
                ScanContainer(
                  title: loc.instantScan,
                  subtitle: loc.instantScanInfo,
                  iconPath: Assets.icons.general.instantScan.path,
                  onTap: () {
                    Get.toNamed(
                      AppRoute.imageCaptureView,
                      arguments: {'type': ScanType.instantScan},
                    );
                  },
                ),

                SizedBox(height: 10.h),

                /// Primary Scan Button
                ScanContainer(
                  title: loc.primaryScan,
                  subtitle: loc.primaryScanInfo,
                  iconPath: Assets.icons.nav.cameraScan.path,
                  onTap: () {
                    if (_primaryScanShown) return;
                    _primaryScanShown = true;
                    showPrimaryScanAlert(
                      context,
                      onConfirm: () {
                        Get.back();
                        Get.toNamed(AppRoute.employeeSelectBodyRegion);
                      },
                      onCancel: () {
                        _primaryScanShown = false;
                      },
                    );
                  },
                ),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
