import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/provider/signup.dart';
import 'package:posture_detector_app/routes.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class WaitingCompanyResponse extends ConsumerWidget {
  const WaitingCompanyResponse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200.h),
            Center(
              child: Assets.images.general.congrats.image(
                width: 172.w,
                height: 162.h,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              // EN: "Congratulations"
              loc.congrats,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              // EN: "Please wait for company admin approval, Contact your company admin."
              loc.waitForCompanyApproval,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.sp),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 58.h),
            PrimaryButton(
              // EN: "Go to Login"
              text: loc.goToLogin,
              backgroundColor: AppColors.primaryColor,
              textColor: AppColors.onBoardingSurface,
              onTap: () {
                ref.read(signupNotifierProvider.notifier).reset();
                Get.offAllNamed(AppRoute.loginScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
