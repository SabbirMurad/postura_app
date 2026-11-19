import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/utils/l10n.dart';

/// Fixed copy shown once above the exercise list ("Postura Tier B: 25
/// employee exercise cards", content source tier-b-2026-11-10-r1). The shared
/// stop advice lives here; each card adds only its own specific advice.
class ExerciseIntro extends StatelessWidget {
  const ExerciseIntro({super.key});

  static String get title => l10n.genExerciseIntroTitle;

  // Getters, not constants, so the text follows the selected language. Also
  // read by the PDF report, which has no BuildContext, hence the global l10n.
  static List<(String?, String)> get paragraphs => <(String?, String)>[
    (null, l10n.genExerciseIntroBody),
    (l10n.genExerciseIntroAmountTitle, l10n.genExerciseIntroAmountBody),
    (l10n.genExerciseIntroAreaTitle, l10n.genExerciseIntroAreaBody),
    (l10n.genExerciseIntroStopTitle, l10n.genExerciseIntroStopBody),
  ];

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(
      fontSize: 12.5.sp,
      color: const Color(0xFF4A4A4A),
      height: 1.5,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
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
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          for (final (lead, text) in paragraphs) ...[
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  if (lead != null)
                    TextSpan(
                      text: '$lead: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  TextSpan(text: text),
                ],
              ),
              style: body,
            ),
          ],
        ],
      ),
    );
  }
}
