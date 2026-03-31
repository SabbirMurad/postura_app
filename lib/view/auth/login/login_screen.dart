import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/user_type.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserType _userType = UserType.EMPLOYEE;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _isPasswordObscured = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final res = await ref
        .read(authorNotifierProvider.notifier)
        .signIn(
          user_type: _userType,
          email_address: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    setState(() => _loading = false);

    if (_userType == UserType.EMPLOYEE) {
      if (res == true) {
        setState(() => _loading = true);
        await Future.wait([
          ref.read(reportNotifierProvider.notifier).fetchMyReports(),
          ref.read(authorNotifierProvider.notifier).refreshProfile(),
        ]);
        setState(() => _loading = false);
        Get.offAllNamed(AppRoute.bottomNavBusiness);
      } else if (res == false) {
        Get.offAllNamed(AppRoute.employeeSelectBodyRegion);
      }
    } else {
      if (res == true) {
        ref.read(authorNotifierProvider.notifier).refreshProfile();
        Get.offAllNamed(AppRoute.bottomNavCpe);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  AppBackButton(),
                  SizedBox(height: 17.h),
                  Center(
                    child: Text(
                      // EN: "Welcome back"
                      loc.welcomeBackWithName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 17.h),

                  _UserTypeDropdown(
                    userType: _userType,
                    loc: loc,
                    onChange: (type) => setState(() => _userType = type),
                  ),
                  SizedBox(height: 29.h),

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
                    filled: true,
                    controller: _emailController,
                    prefixIcon: Icon(
                      Iconsax.sms,
                      color: AppColors.primaryColor.withValues(alpha: 0.8),
                      size: 25.h,
                    ),
                    // EN: "Enter your email"
                    hintText: loc.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 28.h),

                  // EN: "Password"
                  Text(
                    loc.password,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  CustomTextField(
                    filled: true,
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoute.verifyEmail),
                      // EN: "Forget Credential"
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
                  SizedBox(height: 224.h),
                  PrimaryButton(
                    loading: _loading,
                    onTap: _submit,
                    // EN: "Login"
                    text: loc.login,
                    backgroundColor: AppColors.primaryColor,
                    textStyle: TextStyle(
                      color: AppColors.surface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (_userType == UserType.EMPLOYEE)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // EN: "Don't have an account?"
                          Text(
                            loc.donHaveAnAccount,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () =>
                                Get.toNamed(AppRoute.companyCredential),
                            // EN: "Sign up"
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
                    ),
                  SafeArea(top: false, child: SizedBox(height: 18.h)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// User Type Dropdown
// ─────────────────────────────────────────
class _UserTypeDropdown extends StatelessWidget {
  final UserType userType;
  final AppLocalizations loc;
  final void Function(UserType)? onChange;

  _UserTypeDropdown({required this.userType, required this.loc, this.onChange});

  late final options = [
    _UserOption(
      user: UserType.EMPLOYEE,
      // EN: "Company User"
      label: loc.companyUser,
      icon: Icons.business_center_outlined,
    ),
    _UserOption(
      user: UserType.ERGONOMIST,
      label: 'CPE',
      icon: Icons.medical_services_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere(
      (o) => o.user == userType,
      orElse: () => options.first,
    );

    return GestureDetector(
      onTap: () => _showSheet(context, options),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.blackDeemed,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                current.icon,
                size: 18.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login as',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.text.withValues(alpha: 0.45),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    current.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: AppColors.text.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, List<_UserOption> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Account Type',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              ...options.map((option) {
                final isSelected = userType == option.user;
                return GestureDetector(
                  onTap: () {
                    onChange?.call(option.user);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.08)
                          : AppColors.blackDeemed,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withValues(
                                    alpha: 0.10,
                                  ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            option.icon,
                            size: 20.sp,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserOption {
  final UserType user;
  final String label;
  final IconData icon;
  const _UserOption({
    required this.user,
    required this.label,
    required this.icon,
  });
}
