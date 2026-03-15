import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/login_controller.dart';

class CpeAuth extends StatelessWidget {
  const CpeAuth({super.key, required this.loginController});

  final LoginControllerBusiness loginController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Form(
      key: loginController.cpeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ───────────────────────────────────
          Text(
            loc.email,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          CustomTextField(
            filled: true,
            controller: loginController.cpeEmailController,
            prefixIcon: Icon(
              Iconsax.sms,
              color: AppColors.primaryColor.withValues(alpha: 0.8),
              size: 25.h,
            ),
            hintText: loc.emailHint,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 28.h),

          // ── Password ─────────────────────────────────
          Text(
            loc.password,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            return CustomTextField(
              filled: true,
              controller: loginController.cpePasswordController,
              prefixIcon: Icon(
                Icons.lock,
                color: AppColors.primaryColor.withValues(alpha: 0.8),
                size: 25.h,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  loginController.isSeen.value = !loginController.isSeen.value;
                },
                child: loginController.isSeen.value
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
              isObscureText: loginController.isSeen.value,
            );
          }),
          SizedBox(height: 16.h),

          // ── Forget credential ────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoute.verifyEmail);
              },
              child: Text(
                loc.forgetCredential,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 235.h),

          // ── Bottom: Login button + sign up row ───────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return PrimaryButton(
                  loading: loginController.isLoadingCpe.value,
                  onTap: () async {
                    if (loginController.cpeFormKey.currentState!.validate()) {
                      final res = await loginController.cpeSignIn(
                        loginController.cpeEmailController.text.trim(),
                        loginController.cpePasswordController.text.trim(),
                      );

                      if (res) {
                        Get.offAllNamed(AppRoute.bottomNavCpe);
                      }
                    }
                  },
                  text: loc.login,
                  backgroundColor: AppColors.primaryColor,
                  textStyle: TextStyle(
                    color: AppColors.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
              SizedBox(height: 14.h),
            ],
          ),
        ],
      ),
    );
  }
}
