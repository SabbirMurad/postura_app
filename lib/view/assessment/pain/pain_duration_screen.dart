import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class BusinessPainDurationScreen extends ConsumerWidget {
  const BusinessPainDurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: painDuration = "Pain Duration", painDurationSubtitle = "Select the duration of your pain"
              AppTopSection(
                title: loc.painDuration,
                subtitle: loc.painDurationSubtitle,
              ),
              SizedBox(height: 51.h),
              Wrap(
                children: AssessmentState.painDurations.map((duration) {
                  final isSelected = assessment.selectedPainDuration == duration;
                  return GestureDetector(
                    onTap: () => ref
                        .read(assessmentNotifierProvider.notifier)
                        .setPainDuration(duration),
                    child: SelectionalContainer(
                      title: duration,
                      selected: isSelected,
                    ),
                  );
                }).toList(),
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
              if (assessment.selectedPainDuration.isEmpty) {
                // EN: "Please fill all the fields"
                showCustomToast(text: loc.pleaseFillAllFields);
                return;
              }
              Get.toNamed(AppRoute.employeeWorkPatternScreen);
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
    );
  }
}
