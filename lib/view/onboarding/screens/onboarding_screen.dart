import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';
import 'package:posture_detector_app/controller/onboarding_controller.dart';
import 'package:posture_detector_app/view/onboarding/widgets/onboarding_page.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController onboardingController =
      Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.onBoardingSurface,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            PageView(
              scrollDirection: Axis.horizontal,
              controller: onboardingController.pageController,
              onPageChanged: (index) {
                onboardingController.updatePageIndicator(index);
              },
              children: [
                OnboardingPage(
                  onboardingController: onboardingController,
                  image: Assets.images.onboarding.onboarding1,
                  // EN: "Improve Posture. Reduce Pain"
                  title: loc.onboardingTitle1,
                ),
                OnboardingPage(
                  onboardingController: onboardingController,
                  image: Assets.images.onboarding.onboarding2,
                  // EN: "Start Your ISO-Aligned Assessment"
                  title: loc.onboardingTitle2,
                ),
                OnboardingPage(
                  onboardingController: onboardingController,
                  image: Assets.images.onboarding.onboarding3,
                  // EN: "Science-Backed Posture Insights"
                  title: loc.onboardingTitle3,
                ),
              ],
            ),

            Positioned(
              left: 19.w,
              right: 19.w,
              bottom: 10.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      AppHelper.instance.setPhoneOnboard(true);
                      Get.offAllNamed(AppRoute.welcomeScreen);
                    },
                    child: Text(
                      // EN: "Skip"
                      loc.skip,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      AppHelper.instance.setPhoneOnboard(true);
                      onboardingController.isLastPage
                          ? Get.toNamed(AppRoute.welcomeScreen)
                          : onboardingController.nextPage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.h),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 24.h,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
