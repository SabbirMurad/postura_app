import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/data/services/api/auth_service.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class LoginControllerBusiness extends GetxController {
  Rx<Users> userRole = Rx<Users>(Users.EMPLOYEE);

  final privateFormKey = GlobalKey<FormState>();
  final businessFormKey = GlobalKey<FormState>();
  final cpeFormKey = GlobalKey<FormState>(); // ← NEW

  RxBool isSeen = RxBool(true);
  RxBool isLoading = RxBool(false);
  RxBool isLoading2 = RxBool(false);
  RxBool isLoadingCpe = RxBool(false); // ← NEW

  // Business / Employee controllers
  TextEditingController empPasswordController = TextEditingController();
  TextEditingController empEmailController = TextEditingController();

  // Private / Individual controllers
  TextEditingController emailControllerIndi = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // CPE controllers                                 // ← NEW
  TextEditingController cpeEmailController = TextEditingController();
  TextEditingController cpePasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  AppLocalizations get _loc => AppLocalizations.of(Get.context!)!;

  // ── Private sign in ──────────────────────────────────────────────────
  Future<bool> privateSignIn(String mode, String email, String password) async {
    isLoading2.value = true;

    final response = await _authService.privateSignIn(mode, email, password);
    final isOnboarding = await AppHelper.instance.getIsonBoarding();

    if (response.data != null) {
      isLoading2.value = false;
      // Pre-fetch reports so data is ready when home screen loads
      _prefetchReports();
      if (isOnboarding == true) {
        return true;
      } else {
        return false;
      }
    } else {
      isLoading2.value = false;
      showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
    return false;
  }

  // ── Business sign in ─────────────────────────────────────────────────
  Future<bool> businessSignIn(
    String mode,
    String email,
    String password,
  ) async {
    isLoading.value = true;

    final response = await _authService.businessSignIn(mode, email, password);
    final isOnboarding = await AppHelper.instance.getIsonBoarding();

    if (response.data != null) {
      isLoading.value = false;
      // Pre-fetch reports so data is ready when home screen loads
      _prefetchReports();
      if (isOnboarding == true) {
        return true;
      } else {
        return false;
      }
    } else {
      isLoading.value = false;
      showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
    return false;
  }

  // ── CPE sign in ──────────────────────────────────────────────────────
  Future<bool> cpeSignIn(String email, String password) async {
    // ← NEW
    if (!cpeFormKey.currentState!.validate()) return false;

    isLoadingCpe.value = true;

    final response = await _authService.cpeSignIn(
      "ERGONOMIST",
      email,
      password,
    );

    if (response.data != null) {
      isLoadingCpe.value = false;
      return true;
    } else {
      isLoadingCpe.value = false;
      showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
    return false;
  }

  // ── Pre-fetch reports after login ────────────────────────────────────
  void _prefetchReports() {
    if (Get.isRegistered<ReportController>()) {
      Get.find<ReportController>().fetchMyReports();
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────
  @override
  void onClose() {
    empPasswordController.dispose();
    empEmailController.dispose();
    emailControllerIndi.dispose();
    passwordController.dispose();
    cpeEmailController.dispose();
    cpePasswordController.dispose();
    super.onClose();
  }
}
