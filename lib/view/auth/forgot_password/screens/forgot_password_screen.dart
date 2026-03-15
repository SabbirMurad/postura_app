import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/controller/forgot_password_controller.dart';

import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController forgotPasswordController =
      Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopSection(title: loc.changePassword, subtitle: ''),
              SizedBox(height: 24.h),
              Text(
                loc.changePassword,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              Obx(() {
                return CustomTextField(
                  controller: forgotPasswordController.passwordController,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      forgotPasswordController.isSeenPass.value =
                          !forgotPasswordController.isSeenPass.value;
                    },
                    child: forgotPasswordController.isSeenPass.value
                        ? Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20.w,
                            color: AppColors.text.withValues(alpha: 0.4),
                          )
                        : Assets.icons.auth.eyeOff.image(),
                  ),
                  hintText: loc.password,
                  keyboardType: TextInputType.text,
                  isPassword: true,
                  isObscureText: forgotPasswordController.isSeenPass.value,
                );
              }),
              SizedBox(height: 20.h),
              Text(
                loc.confirmPassword,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              Obx(() {
                return CustomTextField(
                  controller:
                      forgotPasswordController.confirmPasswordController,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      forgotPasswordController.isSeenPassConfirm.value =
                          !forgotPasswordController.isSeenPassConfirm.value;
                    },
                    child: forgotPasswordController.isSeenPassConfirm.value
                        ? Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20.w,
                            color: AppColors.text.withValues(alpha: 0.4),
                          )
                        : Assets.icons.auth.eyeOff.image(),
                  ),
                  hintText: loc.password,
                  keyboardType: TextInputType.text,
                  isPassword: true,
                  isObscureText:
                      forgotPasswordController.isSeenPassConfirm.value,
                );
              }),
            ],
          ),
        ),
      ),
      bottomSheet: Obx(() {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: PrimaryButton(
            loading: forgotPasswordController.isLoading.value,
            text: loc.confirmPassword,
            onTap: () async {
              if (forgotPasswordController.passwordController.text
                      .trim()
                      .toString() !=
                  forgotPasswordController.confirmPasswordController.text
                      .trim()
                      .toString()) {
                showCustomToast(text: loc.passwordNotMatched);
                return;
              }

              final res = await forgotPasswordController.resetPassword();
              if (res) {
                Get.toNamed(AppRoute.loginScreen);
              }
            },
            backgroundColor: AppColors.primaryColor,
            textStyle: TextStyle(
              color: AppColors.surface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }
}
