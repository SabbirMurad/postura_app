import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/slider_widget.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class BusinessPainIntensityScreen extends ConsumerWidget {
  const BusinessPainIntensityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);
    final notifier = ref.read(assessmentNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // EN: painIntensity = "Pain Intensity", painIntensitySubtitle = "Rate the pain intensity for each region"
                AppTopSection(
                  title: loc.painIntensity,
                  subtitle: loc.painIntensitySubtitle,
                ),
                SizedBox(height: 51.h),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => SizedBox(height: 22.h),
                  itemCount: assessment.selectedRegions.length,
                  itemBuilder: (context, index) {
                    final region = assessment.selectedRegions[index];
                    return AppSliderWidget(
                      title: region,
                      value: assessment.painIntensity[region] ?? 1.0,
                      onChanged: (value) => notifier.setPainForRegion(region, value),
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
            onTap: () => context.push(AppRoute.employeePainDurationScreen),
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
