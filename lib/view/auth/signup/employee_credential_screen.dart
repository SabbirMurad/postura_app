import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/provider/signup.dart';
import 'package:posture_detector_app/routes.dart';

class EmployeeCredentialScreen extends ConsumerStatefulWidget {
  const EmployeeCredentialScreen({super.key});

  @override
  ConsumerState<EmployeeCredentialScreen> createState() => _EmployeeCredentialScreenState();
}

class _EmployeeCredentialScreenState extends ConsumerState<EmployeeCredentialScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                AppTopSection(
                  // EN: "User Identification"
                  title: loc.userIdentification,
                  subtitle: AppText.userIdentificationSubtitle,
                ),

                SizedBox(height: 28.h),
                Text(
                  // EN: "Email"
                  loc.email,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: _emailController,
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "Enter your email"
                  hintText: loc.emailHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Name"
                  loc.name,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: _nameController,
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "Enter your name"
                  hintText: loc.nameHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Employee ID"
                  loc.employId,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: _employeeIdController,
                  prefixIcon: Icon(
                    Icons.perm_contact_cal_outlined,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "Your employee ID"
                  hintText: loc.employIdHint,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Password"
                  loc.password,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: _passwordController,
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "Password"
                  hintText: loc.password,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 125.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () {
                if (_emailController.text.isEmpty ||
                    _nameController.text.isEmpty ||
                    _employeeIdController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  // EN: "All fields must be filled"
                  showCustomToast(text: loc.allFieldsMustBeFilled);
                } else {
                  ref.read(signupNotifierProvider.notifier).setCredentials(
                    email: _emailController.text.trim(),
                    name: _nameController.text.trim(),
                    password: _passwordController.text.trim(),
                    employeeId: _employeeIdController.text.trim(),
                  );
                  Get.toNamed(AppRoute.employeeWorkDetail);
                }
              },
              // EN: "Continue"
              text: loc.continueButton,
              backgroundColor: AppColors.primaryColor,
              textStyle: TextStyle(
                color: AppColors.surface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }
}
