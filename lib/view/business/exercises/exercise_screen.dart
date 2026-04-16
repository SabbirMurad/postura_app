import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/view/business/exercises/widgets/exercise_showcase_container.dart';
import 'package:posture_detector_app/provider/report.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/app_colors.dart';

class ExerciseBusinessScreen extends ConsumerWidget {
  const ExerciseBusinessScreen({super.key});

  /// Derive sensitivity level from average VAS score
  String _sensitivityLabel(int vas) {
    if (vas >= 7) return 'Active';
    if (vas >= 4) return 'Moderate';
    return 'Gentle';
  }

  Color _tierColor(String label) {
    switch (label) {
      case 'Active':
        return const Color(0xFFA13544);
      case 'Moderate':
        return const Color(0xFFDA7101);
      default:
        return const Color(0xFF437A22);
    }
  }

  String _tierMessage(String label) {
    switch (label) {
      case 'Active':
        return 'Higher-intensity programme for significant pain relief.';
      case 'Moderate':
        return 'Balanced programme to reduce discomfort and improve mobility.';
      default:
        return 'Gentle programme to relieve tension and build resilience.';
    }
  }

  String _frequency(String label) {
    switch (label) {
      case 'Active':
        return '4× per week · 15 min sessions';
      case 'Moderate':
        return '3× per week · 12 min sessions';
      default:
        return '3× per week · 10 min sessions';
    }
  }

  /// Detect acute flag: pain or tingling
  String? _acuteFlag(List<String> symptoms, int vas) {
    final lower = symptoms.map((s) => s.toLowerCase()).toList();
    if (lower.any((s) => s.contains('tingling') || s.contains('numbness'))) {
      return 'tingling';
    }
    if (vas >= 7) return 'pain';
    return null;
  }

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
            /// AppBar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.w),
              child: Text(
                loc.personalizedExerciseProgram,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            /// Content
            Expanded(
              child: Builder(
                builder: (context) {
                  final exercisesData = reportState.analysisData?.aiResult.exercises;
                  final exercises = exercisesData?.recommendedSession;
                  final vas = exercisesData?.averagePainVas ?? 0;
                  final symptoms = reportState.analysisData?.assessment?.symptoms ?? [];

                  // Filter out exercises that duplicate clinical projection
                  final filteredExercises = exercises?.where((e) {
                    final cp = exercisesData?.clinicalProjection;
                    if (cp?.text != null && cp!.text.isNotEmpty) {
                      if (e.bodyRegion.toLowerCase().contains('clinical projection')) {
                        return false;
                      }
                      if (e.description.trim() == cp.text.trim()) return false;
                    }
                    return true;
                  }).toList();

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
                              color: AppColors.secondaryText.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final tierLabel = _sensitivityLabel(vas);
                  final tierColor = _tierColor(tierLabel);
                  final acuteFlag = _acuteFlag(symptoms, vas);

                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      top: 8.h,
                      bottom: 16.h,
                    ),
                    itemCount: filteredExercises.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      // Header block
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Tier badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: tierColor.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  tierLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: tierColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),

                              /// Tier message
                              Text(
                                _tierMessage(tierLabel),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 4.h),

                              /// Frequency line
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14.sp,
                                    color: AppColors.secondaryText,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _frequency(tierLabel),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              /// AcuteFlag warning banner
                              if (acuteFlag != null) ...[
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: const Color(0xFFDAA101).withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFF856404),
                                        size: 18,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          acuteFlag == 'tingling'
                                              ? 'Tingling or numbness detected — all exercises set to Gentle. Stop immediately if symptoms worsen.'
                                              : 'High pain level detected — start slowly and stop if any exercise increases your pain.',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(0xFF856404),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: 8.h),
                            ],
                          ),
                        );
                      }

                      final exercise = filteredExercises[index - 1];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: ExerciseShowCaseContainer(
                          videoUrl: exercise.video,
                          title: exercise.bodyRegion,
                          subtitle: exercise.description,
                          duration: exercise.recommendedDuration,
                          sensitivityLabel: tierLabel,
                          purpose: exercise.purpose,
                          musclesAddressed: exercise.musclesAddressed,
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
