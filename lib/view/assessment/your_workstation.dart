import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

class YourWorkstationScreen extends ConsumerStatefulWidget {
  const YourWorkstationScreen({super.key});

  @override
  ConsumerState<YourWorkstationScreen> createState() =>
      _YourWorkstationScreenState();
}

class _YourWorkstationScreenState extends ConsumerState<YourWorkstationScreen> {
  Widget dropdown({
    required String title,
    required String? value,
    required void Function(String?) onChanged,
    required List<DropdownMenuItem<String>> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        hintText: title,
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
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
      borderRadius: BorderRadius.circular(10.r),
      dropdownColor: AppColors.surface,
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);
    final notifier = ref.read(assessmentNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopSection(
                  title: loc.yourWorkstation,
                  subtitle: loc.workstationSubtitle,
                ),
                SizedBox(height: 51.h),
                Text(
                  "Q1. ${loc.canAdjustChairHeight}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) => notifier.setCanAdjustChairHeight(value),
                  value: assessment.canAdjustChairHeight,
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q2. ${loc.enoughLegRoom}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) => notifier.setEnoughLegRoom(value),
                  value: assessment.enoughLegRoom,
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q3. ${loc.chairHasLumbarSupport}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) => notifier.setChairHasLumbarSupport(value),
                  value: assessment.chairHasLumbarSupport,
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q4. ${loc.monitorDistanceFromEyes}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                dropdown(
                  title: loc.monitorDistance,
                  value: assessment.monitorDistance.isEmpty
                      ? null
                      : assessment.monitorDistance,
                  onChanged: (value) =>
                      notifier.setMonitorDistance(value ?? ''),
                  items: [
                    DropdownMenuItem(
                      value: '<40cm',
                      child: Text(loc.monitorDistanceLessThan40cm),
                    ),
                    DropdownMenuItem(
                      value: '40-75cm',
                      child: Text(loc.monitorDistance40To70cm),
                    ),
                    DropdownMenuItem(
                      value: '>75cm',
                      child: Text(loc.monitorDistanceMoreThan70cm),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q5. ${loc.feetRestingFlat}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) => notifier.setFeetRestingFlat(value),
                  value: assessment.feetRestingFlat,
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q6. ${loc.monitorDirectlyInFront}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) =>
                      notifier.setMonitorDirectlyInFront(value),
                  value: assessment.monitorDirectlyInFront,
                ),
                SizedBox(height: 28.h),
                Text(
                  "Q7. ${loc.chairHasArmrests}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                YesAndNoSelect(
                  onChange: (value) => notifier.setChairHasArmrests(value),
                  value: assessment.chairHasArmrests,
                ),
                SizedBox(height: 36.h),
                PrimaryButton(
                  onTap: () {
                    if (assessment.canAdjustChairHeight == null ||
                        assessment.enoughLegRoom == null ||
                        assessment.chairHasLumbarSupport == null ||
                        assessment.monitorDistance.isEmpty ||
                        assessment.feetRestingFlat == null ||
                        assessment.monitorDirectlyInFront == null ||
                        assessment.chairHasArmrests == null) {
                      // EN: "Please fill all the fields"
                      showCustomToast(text: loc.pleaseFillAllFields);
                    } else {
                      context.push(AppRoute.employeeOptionalSymptom);
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
                SizedBox(height: 36.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YesAndNoSelect extends StatefulWidget {
  final bool? value;
  final void Function(bool)? onChange;

  const YesAndNoSelect({super.key, this.value, this.onChange});

  @override
  State<YesAndNoSelect> createState() => _YesAndNoSelectState();
}

class _YesAndNoSelectState extends State<YesAndNoSelect> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onChange != null) widget.onChange!(true);
          },
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: widget.value == true
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Yes",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 48.w),
        GestureDetector(
          onTap: () {
            if (widget.onChange != null) widget.onChange!(false);
          },
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: widget.value == false
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "No",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
