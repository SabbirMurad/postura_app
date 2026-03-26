import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/services/api/profile_service.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';

class BusinessChangePasswordController extends GetxController {
  final ProfileService _profileService = ProfileService();

  RxBool isLoading = RxBool(false);
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  Future<void> changePassword() async {
    isLoading.value = true;
    final token = await AppHelper.instance.getAccessToken();

    if (token == null) {
      isLoading.value = false;
      return;
    }
    final response = await _profileService.changePassword(
      token,
      currentPassController.text.trim().toString(),
      newPassController.text.trim().toString(),
      confirmPassController.text.trim().toString(),
    );

    if (response.success) {
      clearAll();
      isLoading.value = false;
      final loc = AppLocalizations.of(Get.context!)!;
      showCustomToast(
        // EN: "Password changed successfully"
        text: loc.passwordChangedSuccessfully,
        toastType: ToastTypesInfo(ToastTypes.success),
      );
      Get.back();
    } else {
      isLoading.value = false;
      final loc = AppLocalizations.of(Get.context!)!;
      // EN: "Something went wrong"
      showCustomToast(text: response.error ?? loc.somethingWentWrong);
    }
  }

  void clearAll() {
    currentPassController.clear();
    newPassController.clear();
    confirmPassController.clear();
  }

  @override
  void onClose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.onClose();
  }
}
