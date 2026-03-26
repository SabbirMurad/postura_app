import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/login_controller.dart';
import 'package:posture_detector_app/view/auth/login/widgets/business_auth.dart';
import 'package:posture_detector_app/view/auth/login/widgets/cpe_auth.dart';
import 'package:posture_detector_app/view/auth/login/widgets/indi_auth.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginControllerBusiness loginController =
      Get.find<LoginControllerBusiness>();

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

                // ── User type dropdown ──────────────────
                _UserTypeDropdown(loginController: loginController, loc: loc),
                SizedBox(height: 29.h),

                // ── Form — switches by selected role ────
                Obx(() {
                  final role = loginController.userRole.value;
                  if (role == Users.EMPLOYEE) {
                    return BusinessAuth(loginController: loginController);
                  }
                  if (role == Users.CPE) {
                    return CpeAuth(loginController: loginController);
                  }
                  return IndiAuth(loginController: loginController);
                }),
              ],
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
  final LoginControllerBusiness loginController;
  final AppLocalizations loc;

  const _UserTypeDropdown({required this.loginController, required this.loc});

  @override
  Widget build(BuildContext context) {
    final options = [
      // _UserOption(
      //   user: Users.PRIVATE,
      //   // EN: "Individual User"
      //   label: loc.individualUser,
      //   icon: Icons.person_outline_rounded,
      // ),
      _UserOption(
        user: Users.EMPLOYEE,
        // EN: "Company User"
        label: loc.companyUser,
        icon: Icons.business_center_outlined,
      ),
      _UserOption(
        user: Users.CPE,
        label: 'CPE',
        icon: Icons.medical_services_outlined,
      ),
    ];

    return Obx(() {
      final current = options.firstWhere(
        (o) => o.user == loginController.userRole.value,
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
    });
  }

  void _showSheet(BuildContext context, List<_UserOption> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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
            ...options.map(
              (option) => Obx(() {
                final isSelected =
                    loginController.userRole.value == option.user;
                return GestureDetector(
                  onTap: () {
                    loginController.userRole.value = option.user;
                    Get.back();
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
                                : AppColors.primaryColor.withValues(alpha: 0.10),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Model
// ─────────────────────────────────────────
class _UserOption {
  final Users user;
  final String label;
  final IconData icon;
  const _UserOption({
    required this.user,
    required this.label,
    required this.icon,
  });
}
