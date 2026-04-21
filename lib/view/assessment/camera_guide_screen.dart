import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:posture_detector_app/view/assessment/analysis_result_screen.dart';
import 'package:posture_detector_app/view/live_guidance/app.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/capture_questionnaire.dart';

class CameraGuideScreen extends ConsumerStatefulWidget {
  const CameraGuideScreen({super.key});

  @override
  ConsumerState<CameraGuideScreen> createState() => _CameraGuideScreenState();
}

class _CameraGuideScreenState extends ConsumerState<CameraGuideScreen> {
  void _handleCaptureCallBack(BuildContext context) {
    final assessment = ref.watch(assessmentNotifierProvider);

    final questionnaire = CaptureQuestionnaire(
      // hoursAtDesk: assessment.workPattern.hoursAtDeskPerDay,
      // breakIntervalHrs: assessment.workPattern.breakHabit,
      // deviceUsage: assessment.workPattern.deviceUsage,
      painRegions: assessment.selectedBodyRegions,
      painIntensity: assessment.painIntensity,
      painDuration: assessment.selectedPainDuration!,
      optionalSymptoms: assessment.selectedOptionalSymptoms,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LiveGuidance(
            questionnaire: questionnaire,
            onComplete:
                ({
                  required imagePath,
                  required poseResult,
                  required rosaScore,
                }) {
                  ref
                      .read(assessmentNotifierProvider.notifier)
                      .setRosaScore(rosaScore);

                  ref
                      .read(assessmentNotifierProvider.notifier)
                      .setCapturedImage(File(imagePath));

                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return const AnalysisResultScreen();
                      },
                    ),
                  );
                },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                SizedBox(height: 6.h),
                // EN: "Photo Capture Guide"
                Text(
                  loc.photoCaptureGuide,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Assets.images.camera.cameraGuided.image(
                    width: 335.w,
                    height: 335.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  width: 333.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.secondaryText.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: "Person A (Subject)"
                      Text(
                        loc.personA,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // EN: "Sit in a natural posture"
                      GuidedItem(number: '1', title: loc.guideA1),
                      SizedBox(height: 12.h),
                      // EN: "Keep your feet flat on the floor"
                      GuidedItem(number: '2', title: loc.guideA2),
                      SizedBox(height: 12.h),
                      // EN: "Look at the screen naturally"
                      GuidedItem(number: '3', title: loc.guideA3),
                      SizedBox(height: 12.h),
                      // EN: "Wear fitted clothing"
                      GuidedItem(number: '4', title: loc.guideA4),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  width: 333.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.secondaryText.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: "Person B (Photographer)"
                      Text(
                        loc.personB,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // EN: "Stand 1.5 to 2 meters away"
                      GuidedItem(number: '1', title: loc.guideB1),
                      SizedBox(height: 12.h),
                      // EN: "Capture from the side (90 degrees)"
                      GuidedItem(number: '2', title: loc.guideB2),
                      SizedBox(height: 12.h),
                      // EN: "Make sure full body is visible"
                      GuidedItem(number: '3', title: loc.guideB3),
                      SizedBox(height: 12.h),
                      // EN: "Use good lighting"
                      GuidedItem(number: '4', title: loc.guideB4),
                    ],
                  ),
                ),
                SizedBox(height: 96.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () => _handleCaptureCallBack(context),
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
      ),
    );
  }
}

class GuidedItem extends StatelessWidget {
  final String number;
  final String title;

  const GuidedItem({super.key, required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blackDeemed,
          ),
          child: Center(
            child: Text(number, style: TextStyle(color: AppColors.text)),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}
