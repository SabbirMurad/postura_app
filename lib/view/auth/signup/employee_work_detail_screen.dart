import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/view/auth/signup/waiting_company_response.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/provider/author.dart';

class EmployeeWorkDetailScreen extends ConsumerStatefulWidget {
  const EmployeeWorkDetailScreen({super.key});

  @override
  ConsumerState<EmployeeWorkDetailScreen> createState() =>
      _EmployeeWorkDetailScreenState();
}

class _EmployeeWorkDetailScreenState
    extends ConsumerState<EmployeeWorkDetailScreen> {
  final SignupController signupController = Get.find<SignupController>();
  bool _loading = false;

  void _signUp(AppLocalizations loc) async {
    if (signupController.deskIdController.text.isEmpty ||
        signupController.departmentController.text.isEmpty ||
        signupController.workRole.value.isEmpty) {
      // EN: "Please fill all the requirements"
      showCustomToast(text: loc.pleaseFillAllRequirements);
      return;
    }

    setState(() => _loading = true);

    final id = int.tryParse(signupController.employeeIdController.text.trim());

    final res = await ref
        .read(authorNotifierProvider.notifier)
        .signUp(
          language: signupController.selectedLanguage.value,
          name: signupController.userNameController.text.trim(),
          email: signupController.companyEmailController.text.trim(),
          password: signupController.companyPasswordController.text.trim(),
          companyCode: signupController.companyCodeController.text.trim(),
          employeeId: id!,
          deskLocation: signupController.deskIdController.text.trim(),
          department: signupController.departmentController.text.trim(),
          deskRole: signupController.workRole.value,
        );

    setState(() => _loading = false);

    if (res == true) {
      Get.offAll(WaitingCompanyResponse());
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                AppTopSection(
                  title: loc.userDeskWorkZone,
                  subtitle: loc.userDeskWorkZoneSubtitle,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Desk ID or Location (Recommended)"
                  loc.deskId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: signupController.deskIdController,
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "e.g. Floor 3, Desk 42"
                  hintText: loc.deskIdHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Department"
                  loc.department,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextField(
                  filled: true,
                  controller: signupController.departmentController,
                  prefixIcon: Icon(
                    Icons.perm_contact_cal_outlined,
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    size: 25.h,
                  ),
                  // EN: "e.g. Marketing"
                  hintText: loc.departmentHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 28.h),
                Text(
                  // EN: "Role"
                  loc.role,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      // EN: "Select your role"
                      hintText: loc.roleHint,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.blackDeemed,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.blackDeemed,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    dropdownColor: AppColors.surface,
                    value: signupController.workRole.value.isEmpty
                        ? null
                        : signupController.workRole.value,
                    items: [
                      DropdownMenuItem(value: 'DESK', child: Text(loc.desk)),
                      DropdownMenuItem(
                        value: 'STANDING',
                        child: Text(loc.standingDesk),
                      ),
                      DropdownMenuItem(
                        value: 'HYBRID',
                        child: Text(loc.hybrid),
                      ),
                      DropdownMenuItem(value: 'OTHER', child: Text(loc.other)),
                    ],
                    onChanged: (value) {
                      signupController.workRole.value = value ?? '';
                    },
                  ),
                ),
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ),

      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: PrimaryButton(
            loading: _loading,
            onTap: () => _signUp(loc),
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
    );
  }
}
