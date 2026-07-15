import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/primary_scan_alert_dialog.dart';
import 'package:posture_detector_app/view/business/scan/widgets/scan_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/routes.dart';

class ScanBusinessScreen extends StatefulWidget {
  const ScanBusinessScreen({super.key});

  @override
  State<ScanBusinessScreen> createState() => _ScanBusinessScreenState();
}

class _ScanBusinessScreenState extends State<ScanBusinessScreen> {
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
                  // EN: "Scan your posture!"
                  loc.scanYourPosture,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                  ),
                ),
                Text(
                  // EN: "Scan and get personalized posture"
                  loc.scanYourPostureSubtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),

                SizedBox(height: 36.h),
                /// Scan Image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/scan_center_icon.svg',
                      width: 184.w,
                      height: 184.w,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                SizedBox(height: 36.h),
                /// Instant Scan Button
                ScanContainer(
                  // EN: instantScan = "Instant Scan", instantScanInfo = "If you perform an instant scan, you will get a new set of suggestions and score and your previous scores and suggestions will be replaced by the new."
                  title: loc.instantScan,
                  subtitle: loc.instantScanInfo,
                  iconPath: Assets.icons.general.instantScan.path,
                  onTap: () {},
                ),

                SizedBox(height: 12.h),

                /// Primary Scan Button
                ScanContainer(
                  // EN: primaryScan = "Primary Scan", primaryScanInfo = "If you perform a primary scan, you will get a new set of suggestions and score and your previous scores and suggestions will be replaced by the new OR You can perform an Instant scan!"
                  title: loc.primaryScan,
                  subtitle: loc.primaryScanInfo,
                  iconPath: Assets.icons.nav.cameraScan.path,
                  onTap: () {
                    if (_primaryScanShown) return;
                    _primaryScanShown = true;
                    showPrimaryScanAlert(
                      context,
                      onConfirm: () {
                        context.pop();
                        context.push(AppRoute.employeeSelectBodyRegion);
                      },
                      onCancel: () {
                        _primaryScanShown = false;
                      },
                    );
                  },
                ),

                // SizedBox(height: 44.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
