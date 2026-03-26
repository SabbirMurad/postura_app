import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';
import 'package:posture_detector_app/controller/onboarding_controller.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late OnboardingController onboardingController;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    onboardingController = Get.find<OnboardingController>();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    _animController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      goTo();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void goTo() async {
    final token = await AppHelper.instance.getAccessToken();
    final userRole = await AppHelper.instance.getAuthRole();
    final phoneOnboard = await AppHelper.instance.getPhoneOnboard();
    final isonBoarding = await AppHelper.instance.getIsonBoarding();

    print('');
    print('token: $token');
    print('userRole: $userRole');
    print('phoneOnboard: $phoneOnboard');
    print('');

    if (token == null || userRole == null) {
      if (phoneOnboard == true) {
        Get.toNamed(AppRoute.welcomeScreen);
      } else {
        Get.offAllNamed(AppRoute.onBoardingScreen);
      }
    } else if (token.isNotEmpty && userRole.isNotEmpty) {
      if (userRole == Users.CPE.name) {
        Get.offAllNamed(AppRoute.bottomNavCpe);
      } else {
        if (isonBoarding == true) {
          Get.offAllNamed(AppRoute.bottomNavBusiness);
        } else {
          Get.offAllNamed(AppRoute.employeeSelectBodyRegion);
        }
      }
    } else {
      // EN: "Login first"
      showCustomToast(
        text: AppLocalizations.of(context)?.loginFirst ?? 'Login first',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0062CC),
              AppColors.primaryColor,
              Color(0xFF004A99),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// Spacer — push content to center
              const Spacer(flex: 3),

              /// Logo + Tagline
              FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// App logo
                      Assets.images.logos.posturaLogoFinal.image(width: 260.w),

                      SizedBox(height: 20.h),

                      /// Tagline
                      Text(
                        AppText.splashTitle,
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              /// Spacer
              const Spacer(flex: 4),

              /// Bottom description
              FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    AppText.splashSubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
