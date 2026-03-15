import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/logout_confirm_dialog.dart';
import 'package:posture_detector_app/common/widgets/profile_info_container.dart';
import 'package:posture_detector_app/common/widgets/settings_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';

class ProfileScreenPersonal extends StatelessWidget {
  ProfileScreenPersonal({super.key});

  final PersonalProfileController personalProfileController =
      Get.find<PersonalProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                        personalProfileController
                            .profileInfo
                            .value
                            ?.data
                            .fullName ??
                        'username',
                    role:
                        personalProfileController
                            .profileInfo
                            .value
                            ?.data
                            .role ??
                        'role',
                    image:
                        personalProfileController
                            .profileInfo
                            .value
                            ?.data
                            .avatar ??
                        '',
                    controller: personalProfileController,
                  );
                }),

                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.auth.person.path,
                  title: loc.accountSettings,
                  onTap: () {
                    Get.toNamed(AppRoute.personalAccountSettings);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.notification.path,
                  title: loc.notifications,
                  onTap: () {},
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.language.path,
                  title: loc.language,
                  onTap: () {
                    Get.toNamed(AppRoute.personalLanguageScreen);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.policy.path,
                  title: loc.privacyPolicy,
                  onTap: () {
                    Get.toNamed(AppRoute.privacyPolicy);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.logout.path,
                  title: loc.logout,
                  onTap: () {
                    showLogoutConfirmDialog(context);
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
