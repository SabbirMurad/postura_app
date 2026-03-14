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
}
