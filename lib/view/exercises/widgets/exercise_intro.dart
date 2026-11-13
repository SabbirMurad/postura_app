import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/colors.dart';

/// Fixed copy shown once above the exercise list ("Postura Tier B: 25
/// employee exercise cards", content source tier-b-2026-11-10-r1). The shared
/// stop advice lives here; each card adds only its own specific advice.
class ExerciseIntro extends StatelessWidget {
  const ExerciseIntro({super.key});

  static const title = 'A comfortable movement break, one step at a time';

  static const paragraphs = <(String?, String)>[
    (
      null,
      'Use the exercises selected for you by the app—you do not need to '
          'complete this whole library. Start gently, breathe normally and '
          'choose a range that feels comfortable. A small, controlled movement '
          'is enough; there is no need to force a stretch.',
    ),
    (
      'Your exercise amount',
      'Follow the sets, repetitions or hold time shown in your programme. The '
          'descriptions below explain how to move, not a second amount to '
          'complete.',
    ),
    (
      'The highlighted body area',
      'The red area is an approximate guide, not a diagnosis or a promise '
          'that you will feel the movement in exactly that spot.',
    ),
    (
      'When to stop',
      'Stop for sharp pain, dizziness, numbness, tingling or symptoms that get '
          'worse. If symptoms continue after stopping, seek professional '
          'advice. Follow the specific safety advice for each exercise below.',
    ),
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
