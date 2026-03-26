import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/routes.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              // EN: "Change Password"
              AppTopSection(title: loc.changePassword, subtitle: ''),
              SizedBox(height: 24.h),
              // EN: "Change Password"
              Text(
                loc.changePassword,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _passwordController,
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppColors.primaryColor.withValues(alpha: 0.8),
                  size: 25.h,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _isPasswordObscured = !_isPasswordObscured,
                  ),
                  child: _isPasswordObscured
                      ? Icon(
                          Icons.remove_red_eye_outlined,
                          size: 20.w,
                          color: AppColors.text.withValues(alpha: 0.4),
                        )
                      : Assets.icons.auth.eyeOff.image(),
                ),
                // EN: "Password"
                hintText: loc.password,
                keyboardType: TextInputType.text,
                isPassword: true,
                isObscureText: _isPasswordObscured,
              ),
              SizedBox(height: 20.h),
              Text(
                // EN: "Confirm Password"
                loc.confirmPassword,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _confirmPasswordController,
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppColors.primaryColor.withValues(alpha: 0.8),
                  size: 25.h,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _isConfirmObscured = !_isConfirmObscured,
                  ),
                  child: _isConfirmObscured
                      ? Icon(
                          Icons.remove_red_eye_outlined,
                          size: 20.w,
                          color: AppColors.text.withValues(alpha: 0.4),
                        )
                      : Assets.icons.auth.eyeOff.image(),
                ),
                // EN: "Password"
                hintText: loc.password,
                keyboardType: TextInputType.text,
                isPassword: true,
                isObscureText: _isConfirmObscured,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: PrimaryButton(
          loading: _loading,
          // EN: "Confirm Password"
          text: loc.confirmPassword,
          onTap: () async {
            if (_passwordController.text.trim() !=
                _confirmPasswordController.text.trim()) {
              // EN: "Passwords do not match"
              showCustomToast(text: loc.passwordNotMatched);
              return;
            }
            setState(() => _loading = true);
            final res = await ref
                .read(authorNotifierProvider.notifier)
                .resetPassword(
                  _passwordController.text.trim(),
                  _confirmPasswordController.text.trim(),
                );
            setState(() => _loading = false);
            if (res) Get.toNamed(AppRoute.loginScreen);
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
