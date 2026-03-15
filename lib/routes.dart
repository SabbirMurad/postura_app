import 'package:get/get.dart';
import 'package:posture_detector_app/view/auth/login/screens/select_user_login_screen.dart';
import 'package:posture_detector_app/view/business/profile/screens/business_language_screen.dart';
import 'package:posture_detector_app/view/auth/forgot_password/screens/confirm_code_forgot_screen.dart';
import 'package:posture_detector_app/view/auth/forgot_password/screens/forgot_password_screen.dart';
import 'package:posture_detector_app/view/auth/forgot_password/screens/verify_email_screen.dart';
import 'package:posture_detector_app/view/auth/login/screens/login_screen.dart';
import 'package:posture_detector_app/view/camera_capture/screens/camera_guide_screen.dart';
import 'package:posture_detector_app/view/camera_capture/screens/correction_report_screen.dart';
import 'package:posture_detector_app/view/camera_capture/screens/image_capture_screen.dart';
import 'package:posture_detector_app/view/camera_capture/screens/image_preview_screen.dart';
import 'package:posture_detector_app/view/camera_capture/screens/output_screen.dart';
import 'package:posture_detector_app/view/auth/signup/business/company_credential_screen.dart';
import 'package:posture_detector_app/view/assessment/work_pattern/business_work_pattern_screen.dart';
import 'package:posture_detector_app/view/assessment/symptom/optional_symptom_screen.dart';
import 'package:posture_detector_app/view/assessment/pain/pain_duration_screen.dart';
import 'package:posture_detector_app/view/assessment/pain/pain_intensity_screen.dart';
import 'package:posture_detector_app/view/assessment/body_region/select_body_region_screen.dart';
import 'package:posture_detector_app/view/auth/signup/business/employee_credential_screen.dart';
import 'package:posture_detector_app/view/auth/signup/business/equipment_screen_business.dart';
import 'package:posture_detector_app/view/auth/signup/business/exercise_screen_business.dart';
import 'package:posture_detector_app/view/auth/signup/business/select_language_screen.dart';
import 'package:posture_detector_app/view/auth/signup/personal/confirm_code_screen.dart';
import 'package:posture_detector_app/view/auth/signup/personal/congratulations_screen.dart';
import 'package:posture_detector_app/view/auth/signup/personal/create_account_screen.dart';
import 'package:posture_detector_app/view/auth/signup/screens/select_user_screen.dart';
import 'package:posture_detector_app/view/auth/signup/screens/welcoming_screen.dart';
import 'package:posture_detector_app/view/business/navigation/bottom_nav_business.dart';
import 'package:posture_detector_app/view/business/exercises/screens/exercise_business_screen.dart';
import 'package:posture_detector_app/view/business/home/screens/home_screen_business.dart';
import 'package:posture_detector_app/view/business/profile/screens/business_profile_screen.dart';
import 'package:posture_detector_app/view/business/profile/screens/account_settings_business_screen.dart';
import 'package:posture_detector_app/view/business/scan/screens/scan_business_screen.dart';
import 'package:posture_detector_app/view/cpe/screens/assessment_screen_cpe.dart';
import 'package:posture_detector_app/view/cpe/screens/home_screen_cpe.dart';
import 'package:posture_detector_app/view/cpe/navigation/bottom_nav_cpe.dart';
import 'package:posture_detector_app/view/e_learning/screens/elearning_screen.dart';
import 'package:posture_detector_app/view/onboarding/screens/onboarding_screen.dart';
import 'package:posture_detector_app/view/onboarding/screens/splash_screen.dart';
import 'package:posture_detector_app/view/personal/navigation/bottom_nav_personal.dart';
import 'package:posture_detector_app/view/personal/exercises/screens/exercise_personal_screen.dart';
import 'package:posture_detector_app/view/personal/home/screens/home_screen_personal.dart';
import 'package:posture_detector_app/view/personal/profile/screens/personal_language_screen.dart';
import 'package:posture_detector_app/view/personal/profile/screens/profile_screen_personal.dart';
import 'package:posture_detector_app/view/personal/profile/screens/account_settings_personal_screen.dart';
import 'package:posture_detector_app/view/personal/scan/screens/scan_personal_screen.dart';

import 'package:posture_detector_app/view/auth/signup/business/employee_work_detail_screen.dart';
import 'package:posture_detector_app/common/screens/privacy_policy_screen.dart';

class AppRoute {
  AppRoute._();

  static const bottomNavBusiness = '/bottom-nav-business';
  static const bottomNavPersonal = '/bottom-nav-personal';
  static const bottomNavCpe = '/bottom-nav-cpe';

  // ── Onboarding ──
  static const splashScreen = '/';
  static const onBoardingScreen = '/onboarding';
  static const welcomeScreen = '/welcome';

  // ── Auth - Signup ──
  static const selectUser = '/select-user';
  static const selectUserLogin = '/select-user-login';
  static const createAccountScreen = '/create-account';
  static const confirmCode = '/confirm-code';
  static const congratulationScreen = '/congratulations';
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
  static const businessHome = '/business-home';
  static const businessExercise = '/business-exercise';
  static const businessProfile = '/business-profile';
  static const businessAccountSettings = '/business-account-settings';
  static const scanBusinessScreen = '/business-scan';
  static const businessLanguageScreen = '/business-language';

  // ── Personal Dashboard ──
  static const personalHome = '/personal-home';
  static const personalExercise = '/personal-exercise';
  static const personalProfile = '/personal-profile';
  static const personalAccountSettings = '/personal-account-settings';
  static const personalScanScreen = '/personal-scan';
  static const personalLanguageScreen = '/personal-language';

  // ── E-Learning ──
  static const elearning = '/e-learning';

  // ── CPE ──
  static const cpeHome = '/cpe-home';
  static const cpeSetting = '/cpe-setting';
  static const cpeAssessment = '/cpe-assessment';

  // ── Shared ──
  static const privacyPolicy = '/privacy-policy';

  static final routes = [
    /// -------------------------------------- Auth ------------------------------ ///
    GetPage(name: AppRoute.splashScreen, page: () => SplashScreen()),
    GetPage(name: AppRoute.onBoardingScreen, page: () => OnboardingScreen()),
    GetPage(name: AppRoute.welcomeScreen, page: () => WelcomingScreen()),
    GetPage(
      name: AppRoute.createAccountScreen,
      page: () => CreateAccountScreen(),
    ),
    GetPage(name: AppRoute.confirmCode, page: () => ConfirmCodeScreen()),
    GetPage(
      name: AppRoute.congratulationScreen,
      page: () => CongratulationsScreen(),
    ),
    GetPage(name: AppRoute.loginScreen, page: () => LoginScreen()),

    /// -------------------------------- forgot password ------------------------------ ///
    GetPage(name: AppRoute.verifyEmail, page: () => VerifyEmailScreen()),
    GetPage(
      name: AppRoute.confirmCodeForgot,
      page: () => ConfirmCodeForgotScreen(),
    ),
    GetPage(
      name: AppRoute.forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
    ),

    /// ------------------------------------------------------------------------------- ///
    GetPage(name: AppRoute.selectUser, page: () => SelectUserScreen()),
    GetPage(
      name: AppRoute.selectUserLogin,
      page: () => SelectUserLoginScreen(),
    ),
    GetPage(name: AppRoute.selectLanguage, page: () => SelectLanguageScreen()),
    GetPage(
      name: AppRoute.companyCredential,
      page: () => CompanyCredentialScreen(),
    ),
    GetPage(
      name: AppRoute.employeeCredential,
      page: () => EmployeeCredentialScreen(),
    ),
    GetPage(
      name: AppRoute.employeeWorkDetail,
      page: () => EmployeeWorkDetailScreen(),
    ),
    GetPage(
      name: AppRoute.employeeSelectBodyRegion,
      page: () => SelectBodyRegionScreen(),
    ),
    GetPage(
      name: AppRoute.employeePainIntensityScreen,
      page: () => BusinessPainIntensityScreen(),
    ),
    GetPage(
      name: AppRoute.employeePainDurationScreen,
      page: () => BusinessPainDurationScreen(),
    ),
    GetPage(
      name: AppRoute.employeeWorkPatternScreen,
      page: () => BusinessWorkPatternScreen(),
    ),
    GetPage(
      name: AppRoute.employeeOptionalSymptom,
      page: () => BusinessOptionalSymptomScreen(),
    ),
    GetPage(name: AppRoute.cameraGuideScreen, page: () => CameraGuideScreen()),
    GetPage(
      name: AppRoute.imageCaptureView,
      page: () => ImageCaptureScreen(type: Get.arguments['type']),
    ),
    GetPage(name: AppRoute.imagePreview, page: () => ImagePreviewScreen()),
    GetPage(
      name: AppRoute.outputScreenBusiness,
      page: () => OutputScreenBusiness(),
    ),
    GetPage(
      name: AppRoute.correctionReportScreenBusiness,
      page: () => CorrectionReportScreenBusiness(),
    ),
    GetPage(
      name: AppRoute.exerciseBusiness,
      page: () => ExerciseScreenBusiness(),
    ),
    GetPage(
      name: AppRoute.equipmentScreenBusiness,
      page: () => EquipmentScreenBusiness(),
    ),

    /// ------------------------- Business Dashboard ---------------------------------- ///
    GetPage(name: AppRoute.businessHome, page: () => HomeScreenBusiness()),
    GetPage(
      name: AppRoute.businessExercise,
      page: () => ExerciseBusinessScreen(),
    ),
    GetPage(
      name: AppRoute.businessProfile,
      page: () => BusinessProfileScreen(),
    ),
    GetPage(
      name: AppRoute.businessAccountSettings,
      page: () => AccountSettingsBusinessScreen(),
    ),
    GetPage(
      name: AppRoute.scanBusinessScreen,
      page: () => ScanBusinessScreen(),
    ),

    /// ---------------------------- Bottom Nav business ----------------------------------- ///
    GetPage(name: AppRoute.bottomNavBusiness, page: () => BottomNavBusiness()),

    /// ---------------------------- Bottom Nav personal ----------------------------------- ///
    GetPage(name: AppRoute.bottomNavPersonal, page: () => BottomNavPersonal()),

    /// ---------------------------- Bottom Nav CPE ----------------------------------- ///
    GetPage(name: AppRoute.bottomNavCpe, page: () => BottomNavCPE()),

    /// ---------------------------- Personal Dashboard ------------------------------------ ///
    GetPage(name: AppRoute.personalHome, page: () => HomeScreenPersonal()),
    GetPage(
      name: AppRoute.personalExercise,
      page: () => ExercisePersonalScreen(),
    ),
    GetPage(
      name: AppRoute.personalScanScreen,
      page: () => ScanPersonalScreen(),
    ),
    GetPage(
      name: AppRoute.personalProfile,
      page: () => ProfileScreenPersonal(),
    ),
    GetPage(
      name: AppRoute.personalAccountSettings,
      page: () => AccountSettingsPersonalScreen(),
    ),

    GetPage(
      name: AppRoute.businessLanguageScreen,
      page: () => BusinessLanguageScreen(),
    ),
    GetPage(
      name: AppRoute.personalLanguageScreen,
      page: () => PersonalLanguageScreen(),
    ),

    /// -------------------------  e-learning ----------------------------------- ///
    GetPage(name: AppRoute.elearning, page: () => ELearningScreen()),

    /// -------------------------  cpe ----------------------------------- ///
    GetPage(name: AppRoute.cpeHome, page: () => HomeScreenCPE()),
    // GetPage(name: AppRoute.cpeSetting, page: () => CPESettingScreen()),
    GetPage(
      name: AppRoute.cpeAssessment,
      page: () => const CPEAssessmentScreen(),
      binding: CPEAssessmentBinding(),
    ),

    /// -------------------------  Shared ----------------------------------- ///
    GetPage(
      name: AppRoute.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
    ),
  ];
}
