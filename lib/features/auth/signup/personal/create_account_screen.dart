import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class CreateAccountScreen extends StatelessWidget {
  CreateAccountScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopSection(title: loc.createNewAccountWith, subtitle: ''),

                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      CustomTextField(
                        filled: true,
                        controller: signupController.personalNameController,
                        prefixIcon: Icon(
                          Iconsax.user,
                          color: AppColors.primaryColor.withValues(alpha: 0.8),
                          size: 25.h,
                        ),
                        hintText: loc.nameHint,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        loc.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      CustomTextField(
                        filled: true,
                        controller: signupController.personalEmailController,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryColor.withValues(alpha: 0.8),
                          size: 25.h,
                        ),
                        hintText: loc.emailHint,
                        keyboardType: TextInputType.text,
                      ),

                      SizedBox(height: 28.h),
                      Text(
                        loc.password,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Obx(() {
                        return CustomTextField(
                          filled: true,
                          controller:
                              signupController.personalPasswordController,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.8,
                            ),
                            size: 25.h,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              signupController.isSeen.value =
                                  !signupController.isSeen.value;
                            },
                            child: signupController.isSeen.value
                                ? Assets.icons.auth.eyeOff.image()
                                : Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 20.w,
                                    color: AppColors.text.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                          ),
                          hintText: loc.password,
                          keyboardType: TextInputType.text,
                          isPassword: true,
                          isObscureText: signupController.isSeen.value,
                        );
                      }),
                      SizedBox(height: 32.h),
                      Obx(() {
                        return PrimaryButton(
                          loading: signupController.isLoading.value,
                          onTap: () async {
                            if (signupController
                                    .personalNameController
                                    .text
                                    .isEmpty ||
                                signupController
                                    .personalEmailController
                                    .text
                                    .isEmpty ||
                                signupController
                                    .personalPasswordController
                                    .text
                                    .isEmpty) {
                              showCustomToast(
                                text: AppLocalizations.of(
                                  context,
                                )!.pleaseFillAllFields,
                              );
                              return; // Add return statement
                            } else {
                              final res = await signupController
                                  .privateSignup();

                              if (res) {
                                Get.toNamed(AppRoute.confirmCode);
                              }
                            }
                          },
                          text: loc.createAccount,
                          backgroundColor: AppColors.primaryColor,
                          textColor: AppColors.onBoardingSurface,
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: loc.byCreatingAccount,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.text,
                        ),
                      ),
                      TextSpan(
                        text: loc.termsOfService,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: loc.and,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.text,
                        ),
                      ),
                      TextSpan(
                        text: loc.privacyPolicy,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
