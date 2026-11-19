import 'package:flutter/material.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/start_scan_alert_dialog.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/common/widgets/height_input_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class ScanBusinessScreen extends ConsumerStatefulWidget {
  const ScanBusinessScreen({super.key});

  @override
  ConsumerState<ScanBusinessScreen> createState() => _ScanBusinessScreenState();
}

class _ScanBusinessScreenState extends ConsumerState<ScanBusinessScreen> {
  bool _startScanShown = false;
  double? _heightCm;

  @override
  void initState() {
    super.initState();
    // Height never changes between scans — prefill from whatever was entered
    // last time so a returning user only has to confirm it.
    // The height saved on this device by an earlier scan, if any. Read from
    // the device, not the in-memory scan state, which can still hold the
    // previous user's value right after a sign-out.
    _heightCm = AppHelper.savedHeightCm;
  }

  void _onStartScan() {
    if (_startScanShown) return;

    // Close the keyboard before leaving the page. Otherwise the height field
    // keeps focus, and when the assessment flow returns here Flutter restores
    // that focus and the keyboard pops up on its own.
    FocusManager.instance.primaryFocus?.unfocus();

    if (_heightCm == null || _heightCm! <= 0) {
      showCustomToast(text: AppLocalizations.of(context)!.mdlPleaseEnterHeight);
      return;
    }
    if (_heightCm! < 50 || _heightCm! > 250) {
      showCustomToast(text: AppLocalizations.of(context)!.mdlHeightOutOfRange);
      return;
    }

    _startScanShown = true;
    ref.read(assessmentNotifierProvider.notifier).setHeightCm(_heightCm!);
    showStartScanAlert(
      context,
      onConfirm: () {
        // The flag only guards against opening the dialog twice. It has to be
        // cleared here too: this page stays alive under the assessment flow,
        // and a flag left set made "Start Scan" do nothing on return until the
        // page was rebuilt by switching tabs.
        _startScanShown = false;
        context.pop();
        context.push(AppRoute.employeeSelectBodyRegion);
      },
      onCancel: () {
        _startScanShown = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // The keyboard shrinks the body when the height field is focused, so the
      // page scrolls instead of overflowing; IntrinsicHeight keeps the Expanded
      // spacer working (button pinned to the bottom) while there is room.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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

                    SizedBox(height: 20.h),
                    HeightInputField(
                      initialHeightCm: _heightCm,
                      onChanged: (cm) => _heightCm = cm,
                    ),

                    /// Scan Image + Info
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/scan_center_icon.svg',
                              width: 200.w,
                              height: 200.w,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: 28.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                // EN: "You'll get a new set of suggestions and score, and your previous results will be replaced by the new ones."
                                loc.startScanInfo,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13.sp,
                                  height: 1.5,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Start Scan Button
                    PrimaryButton(
                      // EN: "Start Scan"
                      text: loc.startScan,
                      onTap: _onStartScan,
                      backgroundColor: AppColors.primaryColor,
                      textColor: AppColors.surface,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
