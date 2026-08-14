import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:posture_detector_app/common/widgets/custom_clipper.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/colors.dart';

class OnboardingPage extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final AssetGenImage image;
  final String title;

  const OnboardingPage({
    super.key,
    required this.pageController,
    required this.currentPage,
    required this.image,
    required this.title,
  });

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
          controller: pageController,
          count: 3,
          onDotClicked: (index) {
            pageController.jumpToPage(index);
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
