import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/provider/signup.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/provider/report.dart';

void showLogoutConfirmDialog(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (dialogContext) {
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
                      Get.back();
                    },
                    // EN: "Cancel"
                    text: loc.cancel,
                    backgroundColor: AppColors.greyDeemed,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    height: 46.h,
                    onTap: () {
                      final container = ProviderScope.containerOf(context);
                      container.read(signupNotifierProvider.notifier).reset();
                      container.read(assessmentNotifierProvider.notifier).reset();
                      container.read(reportNotifierProvider.notifier).clearData();
                      AppHelper.instance.clearAllPrefValue();
                      Get.offAllNamed(AppRoute.loginScreen);
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
    },
  );
}
