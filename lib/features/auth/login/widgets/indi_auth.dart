import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/login_controller.dart';

class IndiAuth extends StatelessWidget {
  const IndiAuth({super.key, required this.loginController});

  final LoginControllerBusiness loginController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Form(
      key: loginController.privateFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.email,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          CustomTextField(
            filled: true,
            controller: loginController.emailControllerIndi,
            prefixIcon: Icon(
              Iconsax.sms,
              color: AppColors.primaryColor.withValues(alpha: 0.8),
              size: 25.h,
            ),
            hintText: loc.emailHint,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 28.h),
          Text(
            loc.password,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            return CustomTextField(
              filled: true,
              controller: loginController.passwordController,
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

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return PrimaryButton(
                  loading: loginController.isLoading2.value,
                  onTap: () async {
                    if (loginController.privateFormKey.currentState!
                        .validate()) {
                      if (loginController.userRole.value == Users.PRIVATE) {
                        final response = await loginController.privateSignIn(
                          Users.PRIVATE.name,
                          loginController.emailControllerIndi.text
                              .trim()
                              .toString(),
                          loginController.passwordController.text
                              .trim()
                              .toString(),
                        );

                        if (response) {
                          Get.offAllNamed(AppRoute.bottomNavPersonal);
                        } else {
                          Get.offAllNamed(AppRoute.employeeSelectBodyRegion);
                        }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.donHaveAnAccount,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.selectUser);
                    },
                    child: Text(
                      loc.signUp,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ],
      ),
    );
  }
}
