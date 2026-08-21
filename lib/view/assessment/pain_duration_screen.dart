import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/selection_chip.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class PainDurationScreen extends ConsumerWidget {
  const PainDurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);
    final notifier = ref.read(assessmentNotifierProvider.notifier);

    final regions = assessment.selectedBodyRegions.toList();
    final durations = AssessmentState.allPainDurations.toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EN: painDuration = "Pain Duration", painDurationSubtitle = "Select the duration of your pain"
                AppTopSection(
                  title: loc.painDuration,
                  subtitle: loc.painDurationSubtitle,
                ),
                SizedBox(height: 51.h),
                // One duration picker per selected region — durations are
                // reported independently, the same way intensity is.
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: regions.length,
                  separatorBuilder: (_, __) => SizedBox(height: 24.h),
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final selectedDuration = assessment.painDuration[region];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          region.label,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.w,
                          children: durations.map((duration) {
                            return GestureDetector(
                              onTap: () => notifier.setPainDurationForRegion(
                                region,
                                duration,
                              ),
                              child: SelectionChip(
                                title: duration.label,
                                selected: selectedDuration == duration,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: PrimaryButton(
            onTap: () {
              if (!notifier.allRegionsHaveDuration) {
                // EN: "Please fill all the fields"
                showCustomToast(text: loc.pleaseFillAllFields);
                return;
              }
              context.push(AppRoute.workAbilityRecoveryOutlook);
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
