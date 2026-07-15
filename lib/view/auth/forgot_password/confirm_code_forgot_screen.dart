import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/routes.dart';

class ConfirmCodeForgotScreen extends ConsumerStatefulWidget {
  const ConfirmCodeForgotScreen({super.key});

  @override
  ConsumerState<ConfirmCodeForgotScreen> createState() =>
      _ConfirmCodeForgotScreenState();
}

class _ConfirmCodeForgotScreenState
    extends ConsumerState<ConfirmCodeForgotScreen> {
  String _otp = '';
  bool _loading = false;

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
                  // EN: confirmEmail = "Confirm Email", weSend6digitCode = "We send a 4 digit verification code to your email."
                  title: loc.confirmEmail,
                  subtitle: loc.weSend6digitCode,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Enter OTP"
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
                    _otp = verificationCode;
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // EN: "Didn't get the code?"
                      loc.donGetCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(authorNotifierProvider.notifier).resendOtp(),
                      child: Text(
                        // EN: "Resend code"
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
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: PrimaryButton(
          loading: _loading,
          // EN: "Confirm Code"
          text: loc.confirmCode,
          onTap: () async {
            setState(() => _loading = true);
            final res = await ref
                .read(authorNotifierProvider.notifier)
                .verifyOtp(_otp);
            setState(() => _loading = false);
            if (res) context.push(AppRoute.forgotPasswordScreen);
          },
          backgroundColor: AppColors.primaryColor,
          textStyle: TextStyle(
            color: AppColors.surface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
