import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/controller/business_profile_controller.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/logout_confirm_dialog.dart';
import 'package:posture_detector_app/common/widgets/profile_info_container.dart';
import 'package:posture_detector_app/common/widgets/settings_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class SettingScreenCPE extends StatelessWidget {
  SettingScreenCPE({super.key});

  final BusinessProfileController _profileController =
      Get.find<BusinessProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // EN: "Settings"
                  loc.settings,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15.h),
                Obx(() {
                  return ProfileInfoContainer(
                    userName:
                        _profileController.profileInfo.value?.data.fullName ??
                        "username",
                    role:
                        _profileController.profileInfo.value?.data.role ??
                        "role",
                    image:
                        _profileController.profileInfo.value?.data.avatar ?? '',
                    businessController: _profileController,
                  );
                }),

                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.auth.person.path,
                  // EN: "Account Settings"
                  title: loc.accountSettings,
                  onTap: () {
                    Get.toNamed(AppRoute.businessAccountSettings);
                  },
                ),
                SizedBox(height: 12.h),

                SettingsContainer(
                  iconData: Assets.icons.general.language.path,
                  // EN: "Language"
                  title: loc.language,
                  onTap: () {
                    Get.toNamed(AppRoute.businessLanguageScreen);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.policy.path,
                  // EN: "Privacy & Policy"
                  title: loc.privacyPolicy,
                  onTap: () {
                    Get.toNamed(AppRoute.privacyPolicy);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.logout.path,
                  // EN: "Logout"
                  title: loc.logout,
                  onTap: () {
                    showLogoutConfirmDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
