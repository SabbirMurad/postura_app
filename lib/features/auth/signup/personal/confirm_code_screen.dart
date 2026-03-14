import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';

class ConfirmCodeScreen extends StatelessWidget {
  ConfirmCodeScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

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
              AppTopSection(
                title: loc.confirmEmail,
                subtitle: loc.weSend6digitCode,
              ),
              SizedBox(height: 28.h),
              Text(
                loc.enterOTP,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              OtpTextField(
                numberOfFields: 6,
                cursorColor: AppColors.text,
                fillColor: AppColors.onBoardingSurface,
                filled: true,
                focusedBorderColor: AppColors.primaryColor,
                enabledBorderColor: AppColors.border,
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(12.r),
                fieldWidth: 48.w,
                borderWidth: 1.5,
                fieldHeight: 48.w,
                contentPadding: EdgeInsets.all(0),
                textStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {
                  signupController.verifyUserOtp = verificationCode;
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
                      signupController.resendOtp();
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
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Obx(() {
          return PrimaryButton(
            loading: signupController.isLoading.value,
            text: loc.confirmCode,
            onTap: () async {
              final res = await signupController.verifyUser();
              if (res) {
                Get.offAllNamed(AppRoute.congratulationScreen);
              }
            },
            backgroundColor: AppColors.primaryColor,
            textColor: AppColors.onBoardingSurface,
          );
        }),
      ),
    );
  }
}
