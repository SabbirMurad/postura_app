import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/models/user_type.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

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

  Future<void> _saveFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final savedToken = await AppHelper.instance.getFcmToken();
      if (savedToken == fcmToken) return;

      final response = await CustomHttp.post(
        endpoint: 'notifications/fcm/register/',
        body: {'token': fcmToken},
      );

      if (response.ok) {
        await AppHelper.instance.setFcmToken(fcmToken);
      }
    } catch (e) {
      printLine('SplashScreen _saveFcmToken error: $e');
    }
  }

  /// Fetches the authoritative `has_onboarded` flag from the server and mirrors
  /// it into local storage. Returns null when the request fails so the caller can
  /// fall back to the last-known local flag.
  Future<bool?> _serverOnboarded() async {
    try {
      final response = await CustomHttp.get(
        endpoint: 'settings/personal-info/me',
        needAuth: true,
        showFloatingError: false,
      );
      if (!response.ok) return null;
      final value = response.data['has_onboarded'];
      if (value is bool) {
        await AppHelper.instance.setIsonBoarding(value);
        return value;
      }
      return null;
    } catch (e) {
      printLine('SplashScreen _serverOnboarded error: $e');
      return null;
    }
  }

  void goTo() async {
    final token = await AppHelper.instance.getAccessToken();
    final userRole = await AppHelper.instance.getAuthRole();
    final phoneOnboard = await AppHelper.instance.getPhoneOnboard();
    final isonBoarding = await AppHelper.instance.getIsonBoarding();

    if (token == null || userRole == null) {
      if (phoneOnboard == true) {
        if (mounted) context.push(AppRoute.welcomeScreen);
      } else {
        if (mounted) context.go(AppRoute.onBoardingScreen);
      }
    } else if (token.isNotEmpty && userRole.isNotEmpty) {
      await _saveFcmToken();
      if (userRole == UserType.ERGONOMIST.name) {
        if (mounted) context.go(AppRoute.bottomNavCpe);
      } else {
        // Re-sync the onboarding flag from the server before routing. A stored
        // local flag can be stale (assessment completed on another device, or a
        // cleared cache), so the server's `has_onboarded` is the source of truth;
        // fall back to the local flag only when the server is unreachable.
        final onboarded = await _serverOnboarded() ?? isonBoarding;
        if (onboarded == true) {
          if (mounted) context.go(AppRoute.bottomNavBusiness);
        } else {
          if (mounted) context.go(AppRoute.employeeSelectBodyRegion);
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
