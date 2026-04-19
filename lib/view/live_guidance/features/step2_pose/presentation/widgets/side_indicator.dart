import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/pose_result.dart';

/// Badge showing which body side (LEFT / RIGHT) is active.
/// Cross-fades on side switch (300ms).
class SideIndicator extends StatelessWidget {
  const SideIndicator({super.key, required this.side});
  final BodyOrientation side;

  @override
  Widget build(BuildContext context) {
    if (side == BodyOrientation.unknown) return const SizedBox.shrink();

    final label = side == BodyOrientation.left ? 'LEFT SIDE' : 'RIGHT SIDE';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(side),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: AppColors.lightTeal.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.lightTeal,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMMono',
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
