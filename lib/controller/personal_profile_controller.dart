import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

import 'package:posture_detector_app/common/widgets/custom_toast.dart' as utils;
import 'package:posture_detector_app/data/helpers/app_helper.dart';
import 'package:posture_detector_app/models/profile/profile_model.dart';
import 'package:posture_detector_app/data/services/api/profile_service.dart';

class PersonalProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final ProfileService _profileService = ProfileService();

  AppLocalizations get _loc => AppLocalizations.of(Get.context!)!;

  RxString selectedLanguage = RxString('en');
  Rx<File?> selectedImage = Rx<File?>(null);

  RxBool isLoading = RxBool(false);
  Rxn<ProfileModel> profileInfo = Rxn(null);

  Future<void> fetchProfileData() async {
    isLoading.value = true;

    final response = await _profileService.fetchUserInfo();

    if (response.data != null) {
      isLoading.value = false;
      profileInfo.value = response.data;
    } else {
      isLoading.value = false;
      utils.showCustomToast(text: _loc.fetchingDataNotFound);
    }
  }

  Future<void> updateName() async {
    final newName = nameController.text.trim();

    final currentProfile = profileInfo.value;
    if (currentProfile != null) {
      profileInfo.value = currentProfile.copyWith(
        data: currentProfile.data.copyWith(
          fullName: newName,
        ),
      );
    }

    isLoading.value = true;

    final response = await _profileService.updateName(newName);

    isLoading.value = false;

    if (response.data == true) {
      utils.showCustomToast(
        text: _loc.userNameChangedSuccessfully,
        toastType: utils.ToastTypesInfo(utils.ToastTypes.success),
      );
    } else {
      await fetchProfileData();
      utils.showCustomToast(text: _loc.somethingWentWrong);
    }
  }

  Future<void> updateImage() async {
    if (selectedImage.value == null) return;
    final response = await _profileService.updateProfilePic(
      selectedImage.value!,
    );

    if (response.data != null) {
      utils.showCustomToast(
        text: _loc.uploadImageSuccessfully,
        toastType: utils.ToastTypesInfo(utils.ToastTypes.success),
      );

      fetchProfileData();
      profileInfo.refresh();
    } else {
      utils.showCustomToast(text: response.error ?? _loc.somethingWentWrong);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
    fetchProfileData();
  }

  Future<void> _loadSavedLanguage() async {
    final saved = await AppHelper.instance.getLanguage();
    if (saved != null) {
      selectedLanguage.value = saved;
    }
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
  }
}
