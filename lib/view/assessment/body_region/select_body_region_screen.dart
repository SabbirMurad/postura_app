import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class SelectBodyRegionScreen extends ConsumerWidget {
  const SelectBodyRegionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // EN: "Body Region"
                AppTopSection(
                  title: loc.bodyRegionTitle,
                  subtitle: AppText.bodyRegionSubtitle,
                ),
                SizedBox(height: 52.h),
                Wrap(
                  children: AssessmentState.bodyRegions.map((region) {
                    final isSelected = assessment.selectedRegions.contains(region);
                    return GestureDetector(
                      onTap: () => ref
                          .read(assessmentNotifierProvider.notifier)
                          .toggleRegion(region),
                      child: SelectionalContainer(
                        title: region,
                        selected: isSelected,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.h),
          child: PrimaryButton(
            onTap: () {
              if (assessment.selectedRegions.isEmpty) {
                // EN: "Please select a body region"
                showCustomToast(text: loc.pleaseSelectBodyRegion);
              } else {
                Get.toNamed(AppRoute.employeePainIntensityScreen);
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
    );
  }
}
