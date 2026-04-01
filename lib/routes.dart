import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/view/auth/forgot_password/confirm_code_forgot_screen.dart';
import 'package:posture_detector_app/view/auth/forgot_password/forgot_password_screen.dart';
import 'package:posture_detector_app/view/auth/forgot_password/verify_email_screen.dart';
import 'package:posture_detector_app/view/auth/login/login_screen.dart';
import 'package:posture_detector_app/view/camera_capture/camera_guide_screen.dart';
import 'package:posture_detector_app/view/camera_capture/correction_report_screen.dart';
import 'package:posture_detector_app/view/camera_capture/image_capture_screen.dart';
import 'package:posture_detector_app/view/camera_capture/image_preview_screen.dart';
import 'package:posture_detector_app/view/camera_capture/output_screen.dart';
import 'package:posture_detector_app/view/auth/signup/company_credential_screen.dart';
import 'package:posture_detector_app/view/assessment/work_pattern/business_work_pattern_screen.dart';
import 'package:posture_detector_app/view/assessment/symptom/optional_symptom_screen.dart';
import 'package:posture_detector_app/view/assessment/pain/pain_duration_screen.dart';
import 'package:posture_detector_app/view/assessment/pain/pain_intensity_screen.dart';
import 'package:posture_detector_app/view/assessment/body_region/select_body_region_screen.dart';
import 'package:posture_detector_app/view/auth/signup/employee_credential_screen.dart';
import 'package:posture_detector_app/view/auth/signup/equipment_screen_business.dart';
import 'package:posture_detector_app/view/auth/signup/exercise_screen_business.dart';
import 'package:posture_detector_app/view/auth/signup/select_language_screen.dart';
import 'package:posture_detector_app/view/onboarding/welcoming_screen.dart';
import 'package:posture_detector_app/view/business/navigation/bottom_nav_business.dart';
import 'package:posture_detector_app/view/business/profile/account_settings_business_screen.dart';
import 'package:posture_detector_app/view/cpe/assessment_screen_cpe.dart';
import 'package:posture_detector_app/view/cpe/navigation/bottom_nav_cpe.dart';
import 'package:posture_detector_app/view/e_learning/elearning_screen.dart';
import 'package:posture_detector_app/view/onboarding/onboarding_screen.dart';
import 'package:posture_detector_app/view/onboarding/splash_screen.dart';

import 'package:posture_detector_app/view/auth/signup/employee_work_detail_screen.dart';
import 'package:posture_detector_app/common/screens/privacy_policy_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  AppRoute._();

  static const bottomNavBusiness = '/bottom-nav-business';
  static const bottomNavCpe = '/bottom-nav-cpe';

  // ── Onboarding ──
  static const splashScreen = '/';
  static const onBoardingScreen = '/onboarding';
  static const welcomeScreen = '/welcome';

  // ── Auth - Signup ──
  static const createAccountScreen = '/create-account';
  static const selectLanguage = '/select-language';

  // ── Auth - Login ──
  static const loginScreen = '/login';

  // ── Auth - Forgot Password ──
  static const verifyEmail = '/verify-email';
  static const confirmCodeForgot = '/confirm-code-forgot-password';
  static const forgotPasswordScreen = '/forgot-password';

  // ── Signup - Business Credentials ──
  static const companyCredential = '/company-credential';
  static const employeeCredential = '/employee-credential';
  static const employeeWorkDetail = '/employee-work-detail';

  // ── Assessment Flow ──
  static const employeeSelectBodyRegion = '/select-body-region';
  static const employeePainIntensityScreen = '/pain-intensity';
  static const employeePainDurationScreen = '/pain-duration';
  static const employeeWorkPatternScreen = '/work-pattern';
  static const employeeOptionalSymptom = '/optional-symptom';

  // ── Camera Capture Flow ──
  static const cameraGuideScreen = '/camera-guide';
  static const imageCaptureView = '/image-capture';
  static const imagePreview = '/image-preview';
  static const outputScreenBusiness = '/output';
  static const correctionReportScreenBusiness = '/correction-report';

  // ── Signup - Business Extras ──
  static const exerciseBusiness = '/exercise-selection-business';
  static const equipmentScreenBusiness = '/equipment-selection-business';

  // ── Business Dashboard ──
  static const businessAccountSettings = '/business-account-settings';
  static const businessLanguageScreen = '/business-language';

  // ── E-Learning ──
  static const elearning = '/e-learning';

  // ── CPE ──
  static const cpeAssessment = '/cpe-assessment';

  // ── Shared ──
  static const privacyPolicy = '/privacy-policy';

  static void push(String route) => allRoutes.push(route);
  static void go(String route) => allRoutes.go(route);
  static void pop() {
    if (allRoutes.canPop()) {
      allRoutes.pop();
    } else {
      allRoutes.go(splashScreen);
    }
  }

  static final allRoutes = GoRouter(
    routes: [
      /// ------------------------ Auth ------------------------------ ///
      GoRoute(
        path: AppRoute.splashScreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onBoardingScreen,
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.welcomeScreen,
        builder: (context, state) => WelcomingScreen(),
      ),
      GoRoute(
        path: AppRoute.loginScreen,
        builder: (context, state) => LoginScreen(),
      ),

      /// ---------------------- forgot password ------------------------ ///
      GoRoute(
        path: AppRoute.verifyEmail,
        builder: (context, state) => VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoute.confirmCodeForgot,
        builder: (context, state) => ConfirmCodeForgotScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPasswordScreen,
        builder: (context, state) => ForgotPasswordScreen(),
      ),

      /// ---------------------------------------------------------------- ///
      GoRoute(
        path: AppRoute.selectLanguage,
        builder: (context, state) => SelectLanguageScreen(),
      ),
      GoRoute(
        path: AppRoute.companyCredential,
        builder: (context, state) => CompanyCredentialScreen(),
      ),
      GoRoute(
        path: AppRoute.employeeCredential,
        builder: (context, state) => EmployeeCredentialScreen(),
      ),
      GoRoute(
        path: AppRoute.employeeWorkDetail,
        builder: (context, state) => EmployeeWorkDetailScreen(),
      ),
      GoRoute(
        path: AppRoute.employeeSelectBodyRegion,
        builder: (context, state) => SelectBodyRegionScreen(),
      ),
      GoRoute(
        path: AppRoute.employeePainIntensityScreen,
        builder: (context, state) => PainIntensityScreen(),
      ),
      GoRoute(
        path: AppRoute.employeePainDurationScreen,
        builder: (context, state) => PainDurationScreen(),
      ),
      GoRoute(
        path: AppRoute.employeeWorkPatternScreen,
        builder: (context, state) => WorkPatternScreen(),
      ),
      GoRoute(
        path: AppRoute.employeeOptionalSymptom,
        builder: (context, state) => OptionalSymptomScreen(),
      ),
      GoRoute(
        path: AppRoute.cameraGuideScreen,
        builder: (context, state) => CameraGuideScreen(),
      ),
      GoRoute(
        path: AppRoute.imageCaptureView,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final type = query['type']!;

          return ImageCaptureScreen(
            type: type == 'primary'
                ? ScanType.primaryScan
                : ScanType.captureImage,
          );
        },
      ),
      GoRoute(
        path: AppRoute.imagePreview,
        builder: (context, state) => ImagePreviewScreen(),
      ),
      GoRoute(
        path: AppRoute.outputScreenBusiness,
        builder: (context, state) => OutputScreenBusiness(),
      ),
      GoRoute(
        path: AppRoute.correctionReportScreenBusiness,
        builder: (context, state) => CorrectionReportScreenBusiness(),
      ),
      GoRoute(
        path: AppRoute.exerciseBusiness,
        builder: (context, state) => ExerciseScreenBusiness(),
      ),
      GoRoute(
        path: AppRoute.equipmentScreenBusiness,
        builder: (context, state) =>
            EquipmentScreenBusiness(canSendListToCompany: true),
      ),

      /// ------------------------- Business Dashboard ---------------------------------- ///
      GoRoute(
        path: AppRoute.businessAccountSettings,
        builder: (context, state) => AccountSettingsBusinessScreen(),
      ),

      /// ---------------------------- Bottom Nav business ----------------------------------- ///
      GoRoute(
        path: AppRoute.bottomNavBusiness,
        builder: (context, state) => BottomNavBusiness(),
      ),

      /// ---------------------------- Bottom Nav CPE ----------------------------------- ///
      GoRoute(
        path: AppRoute.bottomNavCpe,
        builder: (context, state) => BottomNavCPE(),
      ),

      /// -------------------------  e-learning ----------------------------------- ///
      GoRoute(
        path: AppRoute.elearning,
        builder: (context, state) => ELearningScreen(),
      ),

      /// -------------------------  cpe ----------------------------------- ///
      GoRoute(
        path: AppRoute.cpeAssessment,
        builder: (context, state) => const CPEAssessmentScreen(),
      ),

      /// -------------------------  Shared ----------------------------------- ///
      GoRoute(
        path: AppRoute.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
