import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/login_controller.dart';

class BusinessAuth extends StatelessWidget {
  const BusinessAuth({super.key, required this.loginController});

  final LoginControllerBusiness loginController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Form(
      key: loginController.businessFormKey,
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
            controller: loginController.empEmailController,
            prefixIcon: Icon(
              Iconsax.sms,
              color: AppColors.primaryColor.withValues(alpha: 0.8),
              size: 25.h,
            ),
            hintText: loc.emailHint,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Employee email is required';
              }
              return null;
            },
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
              controller: loginController.empPasswordController,
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            );
          }),
          SizedBox(height: 255.h),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return PrimaryButton(
                  loading: loginController.isLoading.value,
                  onTap: () async {
                    if (loginController.businessFormKey.currentState!
                        .validate()) {
                      if (loginController.userRole.value == Users.EMPLOYEE) {
                        final res = await loginController.businessSignIn(
                          Users.EMPLOYEE.name,
                          loginController.empEmailController.text
                              .trim()
                              .toString(),
                          loginController.empPasswordController.text
                              .trim()
                              .toString(),
                        );
                        if (res) {
                          Get.offAllNamed(AppRoute.bottomNavBusiness);
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
