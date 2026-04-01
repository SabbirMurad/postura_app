import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/routes.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
                // EN: "Verify Your Email"
                AppTopSection(title: loc.verifyEmail, subtitle: ''),
                // EN: "Email"
                Text(
                  loc.email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  controller: _emailController,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "Enter your email"
                  hintText: loc.emailHint,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.toString().isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
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
          // EN: "Confirm Email"
          text: loc.confirmEmail,
          onTap: () async {
            setState(() => _loading = true);
            final res = await ref
                .read(authorNotifierProvider.notifier)
                .verifyEmail(_emailController.text.trim());
            setState(() => _loading = false);
            if (res) context.push(AppRoute.confirmCodeForgot);
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
