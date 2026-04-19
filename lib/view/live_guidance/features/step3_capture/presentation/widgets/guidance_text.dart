import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Amber guidance text overlay shown in camera view.
///
/// Cross-fades between different guidance messages (200ms).
/// Hidden when text is empty (condition passed or silent).
class GuidanceText extends StatelessWidget {
  const GuidanceText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: text.isEmpty
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(text),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.amber,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
    );
  }
}
