import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/bottom_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/view/business/exercises/widgets/exercise_showcase_container.dart';

class ExerciseScreenBusiness extends ConsumerWidget {
  const ExerciseScreenBusiness({super.key});

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
            /// ✅ AppBar Section
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
                  // EN: "The following exercise are recommended based on your posture analysis:"
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

            /// ✅ Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),

            /// ✅ Content Area with Fixed Clinical Projection Footer
            Expanded(
              child: Builder(
                builder: (context) {
                  final exercises =
                      reportState.analysisReport?.exercises.recommendedSession;

                  final clinicalProjection =
                      reportState.analysisReport?.exercises.clinicalProjection;

                  // Filter out exercises that duplicate clinical projection
                  final filteredExercises = exercises?.where((e) {
                    if (clinicalProjection?.text != null &&
                        clinicalProjection!.text.isNotEmpty) {
                      if (e.bodyRegion.toLowerCase().contains(
                        'clinical projection',
                      )) {
                        return false;
                      }
                      if (e.description.trim() ==
                          clinicalProjection.text.trim()) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  /// ✅ Empty State
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

                  /// ✅ Check if clinical projection exists
                  final hasClinicalProjection =
                      clinicalProjection?.text != null &&
                      clinicalProjection!.text.isNotEmpty;

                  // Calculate dynamic footer height based on content
                  final clinicalFooterHeight = hasClinicalProjection
                      ? 120.h
                      : 0.0;

                  /// ✅ Stack: Scrollable List + Fixed Footer
                  return Stack(
                    children: [
                      /// Scrollable Exercise List
                      ListView.builder(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 16.h,
                          bottom: clinicalFooterHeight + 16.h + 80.h,
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
                              sensitivityLabel: 'Gentle',
                              purpose: exercise.purpose,
                              musclesAddressed: exercise.musclesAddressed,
                              regionVas: exercise.regionVas,
                              recommendedSets: exercise.recommendedSets,
                              safetyNote: exercise.safetyNote,
                            ),
                          );
                        },
                      ),

                      /// ✅ FIXED Clinical Projection Footer (above navbar, doesn't scroll)
                      if (hasClinicalProjection)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(230, 245, 240, 0.95),
                                  Color.fromRGBO(220, 240, 235, 1),
                                ],
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 2,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: Offset(0, -4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Optional: Show expanded details in bottom sheet
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 14.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /// Header Row with Badge
                                      Row(
                                        children: [
                                          /// Animated Icon with Background
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              Icons.insights_rounded,
                                              size: 20.sp,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),

                                          /// Title
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Clinical Projection',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Evidence-based prediction',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// Tap to expand indicator
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: AppColors.primaryColor
                                                    .withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Details',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 10.sp,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 12.h),

                                      /// Projection Message with Background Card
                                      Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Quote icon
                                            Icon(
                                              Icons.format_quote_rounded,
                                              size: 16.sp,
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.4),
                                            ),
                                            SizedBox(width: 8.w),

                                            /// Message text
                                            Expanded(
                                              child: Text(
                                                clinicalProjection.text,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                  height: 1.5,
                                                  letterSpacing: 0.2,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// Source Citation (if exists)
                                      if (clinicalProjection
                                          .source
                                          .isNotEmpty) ...[
                                        SizedBox(height: 10.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified_rounded,
                                                size: 12.sp,
                                                color: Colors.green[700],
                                              ),
                                              SizedBox(width: 6.w),
                                              Expanded(
                                                child: Text(
                                                  clinicalProjection.source,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ✅ Bottom Navigation Bar (above clinical footer)
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        child: BottomButton(
          // EN: "Equipment Recommendations"
          title: loc.equipmentRecommendations,
          onTap: () => context.push(AppRoute.equipmentScreenBusiness),
        ),
      ),
    );
  }
}
