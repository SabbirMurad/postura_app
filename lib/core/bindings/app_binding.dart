import 'package:get/get.dart';
import 'package:posture_detector_app/controller/forgot_password_controller.dart';
import 'package:posture_detector_app/controller/login_controller.dart';
import 'package:posture_detector_app/controller/camera_flow_controller.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/controller/business_home_controller.dart';
import 'package:posture_detector_app/controller/business_profile_controller.dart';
import 'package:posture_detector_app/controller/onboarding_controller.dart';
import 'package:posture_detector_app/controller/personal_home_controller.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController(), permanent: true);
    Get.put(SignupController(), permanent: true);
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut<LoginControllerBusiness>(() => LoginControllerBusiness(), fenix: true);
    Get.lazyPut<BusinessHomeController>(() => BusinessHomeController(), fenix: true);
    Get.lazyPut<BusinessProfileController>(() => BusinessProfileController(), fenix: true);
    Get.lazyPut<OnboardingController>(() => OnboardingController(), fenix: true);
    Get.lazyPut<PersonalHomeController>(() => PersonalHomeController(), fenix: true);
    Get.lazyPut<PersonalProfileController>(() => PersonalProfileController(), fenix: true);
    Get.lazyPut<CameraFlowController>(() => CameraFlowController(), fenix: true);
  }
}
