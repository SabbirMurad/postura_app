import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class BusinessOptionalSymptomScreen extends ConsumerWidget {
  const BusinessOptionalSymptomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: optionalSymptom = "Optional Symptom", optionalSymptomSubtitle = "Select your optional symptoms"
              AppTopSection(
                title: loc.optionalSymptom,
                subtitle: loc.optionalSymptomSubtitle,
                isSkip: true,
              ),
              SizedBox(height: 51.h),
              Wrap(
                children: AssessmentState.symptoms.map((symptom) {
                  final isSelected = assessment.selectedSymptoms.contains(symptom);
                  return GestureDetector(
                    onTap: () => ref
                        .read(assessmentNotifierProvider.notifier)
                        .toggleSymptom(symptom),
                    child: SelectionalContainer(
                      title: symptom,
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
            onTap: () => context.push(AppRoute.cameraGuideScreen),
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
