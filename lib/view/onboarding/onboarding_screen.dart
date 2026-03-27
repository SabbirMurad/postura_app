import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/view/onboarding/widgets/onboarding_page.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 3;

  bool get _isLastPage => _currentPage == _totalPages - 1;

  void _nextPage() {
    if (_isLastPage) {
      AppHelper.instance.setPhoneOnboard(true);
      Get.toNamed(AppRoute.welcomeScreen);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                OnboardingPage(
                  pageController: _pageController,
                  currentPage: _currentPage,
                  image: Assets.images.onboarding.onboarding1,
                  // EN: "Improve Posture. Reduce Pain"
                  title: loc.onboardingTitle1,
                ),
                OnboardingPage(
                  pageController: _pageController,
                  currentPage: _currentPage,
                  image: Assets.images.onboarding.onboarding2,
                  // EN: "Start Your ISO-Aligned Assessment"
                  title: loc.onboardingTitle2,
                ),
                OnboardingPage(
                  pageController: _pageController,
                  currentPage: _currentPage,
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
                    onTap: _nextPage,
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
