import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/clinical_projection_card.dart';
import 'package:posture_detector_app/common/widgets/exercise_showcase_container.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class ExerciseBusinessScreen extends StatelessWidget {
  const ExerciseBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final ReportController reportController = Get.find<ReportController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// AppBar Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  // EN: "Personalized Exercise Program"
                  Text(
                    loc.personalizedExerciseProgram,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // EN: "Follow these exercises tailored to your posture analysis"
                  Text(
                    loc.personalizedExerciseProgramSubtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),

            /// Content
            Expanded(
              child: Obx(() {
                final exercises = reportController
                    .analysisData
                    .value
                    ?.aiResult
                    .exercises
                    .recommendedSession;

                final clinicalProjection = reportController
                    .analysisData
                    .value
                    ?.aiResult
                    .exercises
                    .clinicalProjection;

                // Filter out exercises that duplicate clinical projection
                final filteredExercises = exercises?.where((e) {
                  if (clinicalProjection?.text != null &&
                      clinicalProjection!.text!.isNotEmpty) {
                    if (e.bodyRegion.toLowerCase().contains('clinical projection')) return false;
                    if (e.description.trim() == clinicalProjection.text!.trim()) return false;
                  }
                  return true;
                }).toList();

                /// Empty State
                if (filteredExercises == null || filteredExercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 80.sp,
                          color: AppColors.secondaryText.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'No Exercises Yet',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please complete your assessment first',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final hasClinicalProjection =
                    clinicalProjection?.text != null &&
                    clinicalProjection!.text!.isNotEmpty;

                return Stack(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        top: 16.h,
                        bottom: hasClinicalProjection ? 150.h : 16.h,
                      ),
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ExerciseShowCaseContainer(
                            videoUrl: exercise.video,
                            title: exercise.bodyRegion,
                            subtitle: exercise.description,
                            duration: exercise.recommendedDuration,
                            percentage:
                                '${exercise.improvementPercentage ?? 0}%',
                            badge: exercise.badge ?? '',
                            purpose: exercise.purpose,
                            musclesAddressed: exercise.musclesAddressed,
                            contraindications: exercise.contraindications,
                            regionVas: exercise.regionVas,
                            recommendedSets: exercise.recommendedSets,
                            safetyNote: exercise.safetyNote,
                          ),
                        );
                      },
                    ),

                    /// Clinical Projection Card — sticky at bottom
                    if (hasClinicalProjection)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.surface.withValues(alpha: 0),
                                AppColors.surface,
                              ],
                              stops: [0.0, 0.15],
                            ),
                          ),
                          child: ClinicalProjectionCard(
                            text: clinicalProjection!.text!,
                            source: clinicalProjection.source,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
