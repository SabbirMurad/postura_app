import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class SelectBodyRegionScreen extends ConsumerWidget {
  const SelectBodyRegionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);

    final allBodyRegions = AssessmentState.allPainRegions;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
                spacing: 8.w,
                runSpacing: 8.w,
                children: allBodyRegions.toList().map((region) {
                  final isSelected = assessment.selectedBodyRegions.contains(
                    region,
                  );
                  return GestureDetector(
                    onTap: () => ref
                        .read(assessmentNotifierProvider.notifier)
                        .toggleRegion(region),
                    child: BodyRegionContainer(
                      title: region.label,
                      selected: isSelected,
                    ),
                  );
                }).toList(),
              ),
              Spacer(),
              SafeArea(
                top: false,
                child: PrimaryButton(
                  margin: EdgeInsets.only(bottom: 20.h),
                  onTap: () {
                    if (assessment.selectedBodyRegions.isEmpty) {
                      // EN: "Please select a body region"
                      showCustomToast(text: loc.pleaseSelectBodyRegion);
                    } else {
                      context.push(AppRoute.employeePainIntensityScreen);
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
            ],
          ),
        ),
      ),
    );
  }
}

class BodyRegionContainer extends StatelessWidget {
  final String title;
  final bool selected;

  const BodyRegionContainer({
    super.key,
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: AppColors.onBoardingSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: selected ? AppColors.primaryColor : AppColors.blackDeemed,
          width: 2,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          color: selected ? AppColors.primaryColor : AppColors.text,
        ),
      ),
    );
  }
}
