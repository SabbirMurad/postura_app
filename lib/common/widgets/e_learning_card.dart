import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/constants/app_colors.dart';

class ELearningCard extends StatelessWidget {
  final QuizModule quizModule;
  final VoidCallback onTap;

  const ELearningCard({
    super.key,
    required this.quizModule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use the unlocked property from the module
    final bool isUnlocked = quizModule.unlocked;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.secondaryText.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // EN: moduleLabel = "Module"
                    '${AppLocalizations.of(context)!.moduleLabel} ${quizModule.id} .',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    quizModule.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Only show score if quiz has been attempted (highestScore > 0)
                  if (quizModule.unlocked)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h), // FIXED
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Assets.icons.general.trophy.svg(
                            width: 18.w,
                            height: 18.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${quizModule.highestScore}/5',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                          ),
                          SizedBox(width: 6.w),
                          quizModule.highestScore > 3
                              ? Assets.icons.status.check.svg(
                                  width: 18.w,
                                  height: 18.h,
                                  fit: BoxFit.contain,
                                )
                              : Icon(
                                  Icons.cancel_outlined,
                                  size: 18.h,
                                  color: AppColors.red,
                                ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Show forward arrow if unlocked, lock icon if locked
            isUnlocked
                ? Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18.w,
                    color: Colors.black,
                  )
                : Assets.icons.auth.lock.svg(width: 16.w, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
