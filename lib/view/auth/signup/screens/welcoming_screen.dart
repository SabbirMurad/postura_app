import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/custom_clipper.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class WelcomingScreen extends StatelessWidget {
  const WelcomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.onBoardingSurface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ClipPath(
              clipper: AppCustomClipper(),
              child: Assets.images.onboarding.onboarding1.image(
                width: double.infinity,
                fit: BoxFit.cover,
                height: 400.h,
              ),
            ),
            SizedBox(height: 24.h),
            Assets.images.logos.appLogoBlack.image(width: 158.w, height: 55.h),
            SizedBox(height: 7.h),
            Text(
              // EN: "Welcome to Posture care"
              loc.welcomeTitle,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                // EN: "PostureCare helps users assess their posture, get ISO-aligned corrections, follow personalized exercises!"
                loc.welcomeSubtitle,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  PrimaryButton(
                    // EN: "Create new account"
                    text: loc.createNewAccount,
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Get.toNamed(AppRoute.companyCredential);
                    },
                  ),
                  SizedBox(height: 12.h),
                  PrimaryButton(
                    // EN: "Login"
                    text: loc.login,
                    backgroundColor: AppColors.greyDeemed,
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Get.toNamed(AppRoute.loginScreen);
                    },
                  ),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
