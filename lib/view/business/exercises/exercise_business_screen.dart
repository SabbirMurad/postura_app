import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/clinical_projection_card.dart';
import 'package:posture_detector_app/common/widgets/exercise_showcase_container.dart';
import 'package:posture_detector_app/provider/report.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/app_colors.dart';

class ExerciseBusinessScreen extends ConsumerWidget {
  const ExerciseBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final reportState = ref.watch(reportNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// AppBar Section
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN: "Personalized Exercise Program"
                    Text(
                      loc.personalizedExerciseProgram,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Content
            Expanded(
              child: Builder(
                builder: (context) {
                  final exercises = reportState
                      .analysisData
                      ?.aiResult
                      .exercises
                      .recommendedSession;

                  final clinicalProjection = reportState
                      .analysisData
                      ?.aiResult
                      .exercises
                      .clinicalProjection;

                  // Filter out exercises that duplicate clinical projection
                  final filteredExercises = exercises?.where((e) {
                    if (clinicalProjection?.text != null &&
                        clinicalProjection!.text.isNotEmpty) {
                      if (e.bodyRegion.toLowerCase().contains(
                        'clinical projection',
                      ))
                        return false;
                      if (e.description.trim() ==
                          clinicalProjection.text.trim())
                        return false;
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
                            color: AppColors.secondaryText.withValues(
                              alpha: 0.5,
                            ),
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
                              color: AppColors.secondaryText.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final hasClinicalProjection =
                      clinicalProjection?.text != null &&
                      clinicalProjection!.text.isNotEmpty;

                  return ListView.builder(
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
                          percentage: '${exercise.improvementPercentage ?? 0}%',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
