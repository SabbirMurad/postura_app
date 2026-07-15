import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/provider/signup.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

void showLogoutConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return LogoutModal();
    },
  );
}

class LogoutModal extends StatefulWidget {
  const LogoutModal({super.key});

  @override
  State<LogoutModal> createState() => _LogoutModalState();
}

class _LogoutModalState extends State<LogoutModal> {
  Future<void> _removeFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final response = await CustomHttp.delete(
        endpoint: 'notifications/fcm/unregister/',
        body: {'token': fcmToken},
        needAuth: true,
      );

      if (response.ok) {
        await AppHelper.instance.removeFcmToken();
      }
    } catch (e) {
      printLine('_removeFcmToken error: $e');
    }
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColors.onBoardingSurface,
      title: Text(
        // EN: "Are you sure?"
        loc.areYouSure,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // EN: "Do you really want to exit?"
            loc.areYouSureTitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  height: 46.h,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  // EN: "Cancel"
                  text: loc.cancel,
                  backgroundColor: AppColors.greyDeemed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryButton(
                  height: 46.h,
                  loading: _loading,
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () async {
                    setState(() => _loading = true);
                    await _removeFcmToken();
                    setState(() => _loading = false);
                    final container = ProviderScope.containerOf(context);
                    container.read(signupNotifierProvider.notifier).reset();
                    container.read(assessmentNotifierProvider.notifier).reset();
                    container.read(reportNotifierProvider.notifier).clearData();
                    AppHelper.instance.clearAllPrefValue();
                    AppRoute.go(AppRoute.loginScreen);
                  },
                  // EN: "Yes"
                  text: loc.yes,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.onBoardingSurface,
                ),
              ),
            ],
          ),
        ],
      ),
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }
}
