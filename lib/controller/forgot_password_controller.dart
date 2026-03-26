import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/data/services/api/auth_service.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();

  AppLocalizations get _loc => AppLocalizations.of(Get.context!)!;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool isSeenPass = RxBool(false);
  RxBool isSeenPassConfirm = RxBool(false);
  RxBool isLoading = RxBool(false);
  String otp = '';

  Future<bool> verifyEmail() async {
    isLoading.value = true;

    final response = await _authService.forgetPassEmailVerify(
      emailController.text.toString(),
    );

    if (response.success) {
      isLoading.value = false;
      return true;
    } else {
      isLoading.value = false;
      // EN: "Please enter a valid email"
      showCustomToast(text: response.error ?? _loc.pleaseEnterValidEmail);
    }
    return false;
  }

  Future<bool> verifyOtp() async {
    isLoading.value = true;

    final userId = await AppHelper.instance.getUserId();

    if (userId == null) {
      isLoading.value = false;
      return false;
    }

    final response = await _authService.resetPassOtpVerify(userId, otp);

    if (response.success) {
      isLoading.value = false;
      return true;
    } else {
      isLoading.value = false;
      // EN: "Please enter a valid OTP"
      showCustomToast(text: response.error ?? _loc.pleaseEnterValidOtp);
    }
    return false;
  }

  Future<bool> resetPassword() async {
    
    isLoading.value = true;

    final userId = await AppHelper.instance.getUserId();
    final secretkey = await AppHelper.instance.getSecretKey();

    if (userId == null || secretkey == null) {
      isLoading.value = false;
      return false;
    }
    final response = await _authService.resetPass(
      userId,
      secretkey,
      passwordController.text.trim().toString(),
      confirmPasswordController.text.trim().toString(),
    );

    if (response.success) {
      isLoading.value = false;
      showCustomToast(
        // EN: "Password changed successfully"
        text: _loc.passwordChangedSuccessfully,
        toastType: ToastTypesInfo(ToastTypes.success),
      );
      return true;
    } else {
      isLoading.value = false;
      // EN: "Something went wrong"
      showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
    return false;
  }

  Future<void> resendOtp() async {
    isLoading.value = true;
    final userId = await AppHelper.instance.getUserId();

    if (userId == null) {
      isLoading.value = false;
      return;
    }
    final response = await _authService.resendOtp(userId);

    if (response.success) {
      isLoading.value = false;
      showCustomToast(
        // EN: "OTP sent to your email"
        text: _loc.otpSentToEmail,
        toastType: ToastTypesInfo(ToastTypes.success),
      );
    } else {
      isLoading.value = false;
      // EN: "Something went wrong"
      showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
