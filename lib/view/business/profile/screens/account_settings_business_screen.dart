import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/common/dialogs/edit_name_dialog.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/view/business/profile/screens/business_change_password_screen.dart';
import 'package:posture_detector_app/controller/business_profile_controller.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/profile_info.dart';

class AccountSettingsBusinessScreen extends StatelessWidget {
  AccountSettingsBusinessScreen({super.key});

  final BusinessProfileController controller =
      Get.find<BusinessProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
                  title: loc.name,
                  value:
                      controller.profileInfo.value?.data.fullName ?? 'username',
                  tailingText: loc.edit,
                  iconData: Iconsax.edit,
                  onTap: () {
                    showEditNameDialog(
                      context,
                      nameController: controller.nameController,
                      isLoading: controller.isLoading,
                      initialValue:
                          controller.profileInfo.value?.data.fullName ?? '',
                      onSave: () {
                        controller.updateName();
                        controller.nameController.clear();
                        Get.back();
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
                    controller.profileInfo.value?.data.email ??
                    'example@gmail.com',
                onTap: () {},
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
                  Get.to(BusinessChangePasswordScreen());
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
