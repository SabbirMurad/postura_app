import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class BusinessWorkPatternScreen extends ConsumerWidget {
  const BusinessWorkPatternScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);
    final notifier = ref.read(assessmentNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopSection(
                // EN: workPattern = "Work Pattern", workPatternSubtitle = "Select your work pattern from here"
                title: loc.workPattern,
                subtitle: loc.workPatternSubtitle,
              ),
              SizedBox(height: 51.h),
              Text(
                // EN: "Hours at desk per day"
                loc.hoursAtDeskPerDay,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              DropdownButtonFormField<String>(
                value: assessment.hourDeskPerDay.isEmpty ? null : assessment.hourDeskPerDay,
                decoration: InputDecoration(
                  hintText: loc.hoursAtDeskPerDay,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.text),
                borderRadius: BorderRadius.circular(10.r),
                dropdownColor: AppColors.surface,
                items: [
                  DropdownMenuItem(value: '0-4', child: Text(loc.zeroToFourHours)),
                  DropdownMenuItem(value: '4-6', child: Text(loc.fourToSixHours)),
                  DropdownMenuItem(value: '6-8', child: Text(loc.sixToEightHours)),
                  DropdownMenuItem(value: '8+', child: Text(loc.eightPlusHours)),
                ],
                onChanged: (value) => notifier.setHourDeskPerDay(value ?? ''),
              ),

              SizedBox(height: 28.h),
              Text(
                // EN: "Break habits"
                loc.breakHabits,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              DropdownButtonFormField<String>(
                value: assessment.breakHabit.isEmpty ? null : assessment.breakHabit,
                decoration: InputDecoration(
                  hintText: loc.breakHabits,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.text),
                borderRadius: BorderRadius.circular(10.r),
                dropdownColor: AppColors.surface,
                items: [
                  DropdownMenuItem(value: '1H', child: Text(loc.everyOneHour)),
                  DropdownMenuItem(value: '2H', child: Text(loc.everyTwoHours)),
                  DropdownMenuItem(value: '3H', child: Text(loc.everyThreeHours)),
                  DropdownMenuItem(value: 'RARE', child: Text(loc.rarely)),
                ],
                onChanged: (value) => notifier.setBreakHabit(value ?? ''),
              ),

              SizedBox(height: 28.h),
              Text(
                AppText.workPatternRole,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: assessment.workPatternRole.isEmpty ? null : assessment.workPatternRole,
                decoration: InputDecoration(
                  hintText: loc.selectDeviceUsage,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.blackDeemed, width: 1.5),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.text),
                borderRadius: BorderRadius.circular(10.r),
                dropdownColor: AppColors.surface,
                items: [
                  DropdownMenuItem(value: 'LAPTOP', child: Text(loc.laptop)),
                  DropdownMenuItem(value: 'SINGLE', child: Text(loc.singleScreen)),
                  DropdownMenuItem(value: 'DUAL', child: Text(loc.dualScreen)),
                ],
                onChanged: (value) => notifier.setWorkPatternRole(value ?? ''),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: PrimaryButton(
            onTap: () {
              if (assessment.hourDeskPerDay.isEmpty ||
                  assessment.breakHabit.isEmpty ||
                  assessment.workPatternRole.isEmpty) {
                // EN: "Please fill all the fields"
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
    );
  }
}
