import 'package:flutter/material.dart';
import 'package:posture_detector_app/view/exercises/widgets/exercise_intro.dart';
import 'package:posture_detector_app/common/widgets/awaiting_ergonomist_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/view/exercises/widgets/exercise_showcase_container.dart';
import 'package:posture_detector_app/provider/report.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/utils/l10n.dart';

class ExerciseBusinessScreen extends ConsumerWidget {
  const ExerciseBusinessScreen({super.key});

  /// Dose label from the backend's `readiness` — pain/duration-driven, and
  /// deliberately never escalates to a higher-intensity label just because
  /// reported pain is higher (that inverted vas>=7 => "Active" mapping was
  /// the exact bug the client's audit flagged; GENTLE/GENTLE_MAINTENANCE
  /// both read as "Gentle" here, MODERATE as "Moderate" — there is no
  /// "Active"/higher-intensity tier).
  ///
  /// Returns the translated label (also used by the PDF report, so it reads
  /// the global l10n); [tierMessage], [frequency] and the tier colour compare
  /// against the same translated label.
  static String sensitivityLabel(String readiness) {
    return readiness == 'MODERATE' ? l10n.genTierModerate : l10n.genTierGentle;
  }

  static bool _isModerate(String label) => label == l10n.genTierModerate;

  Color _tierColor(String label) {
    return _isModerate(label)
        ? const Color(0xFFDA7101)
        : const Color(0xFF437A22);
  }

  static String tierMessage(String label) {
    return _isModerate(label)
        ? l10n.genTierModerateMessage
        : l10n.genTierGentleMessage;
  }

  static String frequency(String label) {
    return _isModerate(label)
        ? l10n.genTierFrequency(12)
        : l10n.genTierFrequency(10);
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
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
            ),

            /// Content
            Expanded(
              child: Builder(
                builder: (context) {
                  if (reportState.analysisReport?.isAwaitingErgonomist ??
                      false) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: AwaitingErgonomistCard(),
                      ),
                    );
                  }
                  final exercisesData = reportState.analysisReport?.exercises;
                  final exercises = exercisesData?.recommendedSession;
                  final needsCpeReview = exercisesData?.needsCpeReview ?? false;
                  final stopped =
                      exercisesData?.exerciseStatus ==
                      'STOP_AND_SEEK_CLINICAL_ASSESSMENT';

                  // Filter out exercises that duplicate clinical projection
                  final filteredExercises = exercises?.where((e) {
                    final cp = exercisesData?.clinicalProjection;
                    if (cp?.text != null && cp!.text.isNotEmpty) {
                      if (e.bodyRegion.toLowerCase().contains(
                        'clinical projection',
                      )) {
                        return false;
                      }
                      if (e.description.trim() == cp.text.trim()) return false;
                    }
                    return true;
                  }).toList();

                  if (filteredExercises == null || filteredExercises.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              stopped
                                  ? Icons.health_and_safety_rounded
                                  : Icons.fitness_center_rounded,
                              size: 80.sp,
                              color: AppColors.secondaryText.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              stopped
                                  ? loc.genCheckInWithProfessional
                                  : loc.noExercisesYet,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              stopped
                                  ? (exercisesData?.message ??
                                        loc.genConsultBeforeExercises)
                                  : loc.pleaseCompleteAssessmentFirst,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final readiness =
                      exercisesData?.readiness ?? 'GENTLE_MAINTENANCE';
                  final tierLabel = sensitivityLabel(readiness);
                  final tierColor = _tierColor(tierLabel);

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
                                tierMessage(tierLabel),
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
                                    frequency(tierLabel),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              /// CPE-review banner (backend-driven — never a
                              /// diagnosis claim, just "worth a second look").
                              if (needsCpeReview) ...[
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
                                      color: const Color(
                                        0xFFDAA101,
                                      ).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFF856404),
                                        size: 18,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          loc.genKeepExercisesGentleCpe,
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

                              SizedBox(height: 12.h),
                              const ExerciseIntro(),
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
                          title: exercise.title,
                          subtitle: exercise.cardBodyArea,
                          duration: exercise.recommendedDuration,
                          sensitivityLabel: tierLabel,
                          purpose: exercise.howToDoIt,
                          musclesAddressed: exercise.musclesAddressed,
                          regionVas: exercise.regionVas,
                          recommendedSets: exercise.recommendedSets,
                          safetyNote: exercise.safetyNote,
                          musclesText: exercise.musclesText,
                          whyThisHelps: exercise.whyThisHelps,
                          whenToStop: exercise.contraindications ?? '',
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
