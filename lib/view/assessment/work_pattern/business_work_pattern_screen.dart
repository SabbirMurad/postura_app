import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';

class BusinessWorkPatternScreen extends StatelessWidget {
  BusinessWorkPatternScreen({super.key});

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
                title: loc.workPattern,
                subtitle: loc.workPatternSubtitle,
              ),
              SizedBox(height: 51.h),
              Text(
                loc.hoursAtDeskPerDay,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: loc.hoursAtDeskPerDay,
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
                items: [
                  DropdownMenuItem(
                    value: '0-4',
                    child: Text(loc.zeroToFourHours),
                  ),
                  DropdownMenuItem(
                    value: '4-6',
                    child: Text(loc.fourToSixHours),
                  ),
                  DropdownMenuItem(
                    value: '6-8',
                    child: Text(loc.sixToEightHours),
                  ),
                  DropdownMenuItem(
                    value: '8+',
                    child: Text(loc.eightPlusHours),
                  ),
                ],
                onChanged: (value) {
                  signupController.hourDeskPerDay.value = value ?? '';
                },
              ),

              SizedBox(height: 28.h),
              Text(
                loc.breakHabits,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: loc.breakHabits,
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
                items: [
                  DropdownMenuItem(value: '1H', child: Text(loc.everyOneHour)),
                  DropdownMenuItem(value: '2H', child: Text(loc.everyTwoHours)),
                  DropdownMenuItem(
                    value: '3H',
                    child: Text(loc.everyThreeHours),
                  ),
                  DropdownMenuItem(value: 'RARE', child: Text(loc.rarely)),
                ],
                onChanged: (value) {
                  signupController.breakHabit.value = value ?? '';
                },
              ),

              SizedBox(height: 28.h),
              Text(
                AppText.workPatternRole,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: loc.selectDeviceUsage,
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
                items: [
                  DropdownMenuItem(value: 'LAPTOP', child: Text(loc.laptop)),
                  DropdownMenuItem(
                    value: 'SINGLE',
                    child: Text(loc.singleScreen),
                  ),
                  DropdownMenuItem(value: 'DUAL', child: Text(loc.dualScreen)),
                ],
                onChanged: (value) {
                  signupController.workPatternRole.value = value ?? '';
                },
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () {
                if (signupController.hourDeskPerDay.value.isEmpty ||
                    signupController.breakHabit.value.isEmpty ||
                    signupController.workPatternRole.value.isEmpty) {
                  showCustomToast(text: loc.pleaseFillAllFields);
                } else {
                  Get.toNamed(AppRoute.employeeOptionalSymptom);
                }
              },
              text: AppText.continueButton,
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
