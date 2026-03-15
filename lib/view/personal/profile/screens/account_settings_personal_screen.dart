import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/view/personal/profile/screens/personal_change_password_screen.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';
import 'package:posture_detector_app/common/dialogs/edit_name_dialog.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/profile_info.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class AccountSettingsPersonalScreen extends StatelessWidget {
  AccountSettingsPersonalScreen({super.key});

  final PersonalProfileController personalProfileController =
      Get.find<PersonalProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.onBoardingSurface,
        title: Text(loc.accountSettings),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w, top: 7.h),
          child: AppBackButton(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Obx(() {
                return ProfileInfo(
                  title: AppText.name,
                  value:
                      personalProfileController
                          .profileInfo
                          .value
                          ?.data
                          .fullName ??
                      'username',
                  tailingText: AppText.edit,
                  iconData: Iconsax.edit,
                  onTap: () {
                    showEditNameDialog(
                      context,
                      nameController: personalProfileController.nameController,
                      isLoading: personalProfileController.isLoading,
                      onSave: () {
                        personalProfileController.updateName();
                      },
                    );
                  },
                );
              }),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
              SizedBox(height: 24.h),
              ProfileInfo(
                title: loc.email,
                value:
                    personalProfileController.profileInfo.value?.data.email ??
                    'email',
                onTap: () {
                },
              ),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
              SizedBox(height: 24.h),
              ProfileInfo(
                title: loc.password,
                value: '••••••••••••',
                tailingText: loc.change,
                iconData: Iconsax.edit,
                onTap: () {
                  Get.to(PersonalChangePasswordScreen());
                },
              ),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
