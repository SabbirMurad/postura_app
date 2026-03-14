import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:posture_detector_app/common/widgets/custom_clipper.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  final AssetGenImage image;
  final String title;

  const OnboardingPage({
    super.key,
    required this.onboardingController,
    required this.image,
    required this.title,
  });

  final OnboardingController onboardingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: AppCustomClipper(),
          child: image.image(
            width: double.infinity,
            height: 570.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 22.h),
        SmoothPageIndicator(
          controller: onboardingController.pageController,
          count: 3,
          onDotClicked: (index) {
            onboardingController.dotNavigation(index);
          },
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            activeDotColor: AppColors.info,
            expansionFactor: 2.3,
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 19.w),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
