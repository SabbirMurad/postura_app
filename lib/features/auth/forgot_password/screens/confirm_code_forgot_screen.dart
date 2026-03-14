import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/forgot_password_controller.dart';

class ConfirmCodeForgotScreen extends StatelessWidget {
  ConfirmCodeForgotScreen({super.key});

  final ForgotPasswordController forgotPasswordController =
      Get.find<ForgotPasswordController>();

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
                AppTopSection(
                  title: loc.confirmEmail,
                  subtitle: loc.weSend6digitCode,
                ),
                SizedBox(height: 28.h),
                Text(
                  loc.enterOTP,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                OtpTextField(
                  numberOfFields: 6,
                  cursorColor: AppColors.text,
                  fillColor: AppColors.surface,
                  filled: true,
                  focusedBorderColor: AppColors.primaryColor,
                  enabledBorderColor: AppColors.border,
                  showFieldAsBox: true,
                  borderRadius: BorderRadius.circular(12.r),
                  fieldWidth: 62.w,
                  borderWidth: 1.5,
                  fieldHeight: 60.w,
                  textStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  onCodeChanged: (String code) {},
                  onSubmit: (String verificationCode) {
                    forgotPasswordController.otp = verificationCode;
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.donGetCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        forgotPasswordController.resendOtp();
                      },
                      child: Text(
                        loc.resendCode,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Obx(() {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: PrimaryButton(
            loading: forgotPasswordController.isLoading.value,
            text: loc.confirmCode,
            onTap: () async {
              final res = await forgotPasswordController.verifyOtp();
              if (res) {
                Get.toNamed(AppRoute.forgotPasswordScreen);
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
