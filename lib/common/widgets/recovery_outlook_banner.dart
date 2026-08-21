import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';

/// Yellow-flag / chronicity risk banner — shown only when the Chronicity
/// Level is "Elevated" (see Postura_Yellow_Flag_Chronicity_Implementation.pdf).
/// Re-uses the same rounded/tinted-container style as the existing ROSA
/// risk-tier banner so the two read as one family.
class RecoveryOutlookBanner extends StatelessWidget {
  /// Compact one-line version for tight spaces (e.g. the CPE summary strip).
  final bool compact;

  const RecoveryOutlookBanner({super.key, this.compact = false});

  static const _color = AppColors.warning;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: _color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 16.sp, color: _color),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Recovery Outlook: Elevated — early support recommended',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up_rounded, size: 22.sp, color: _color),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery Outlook: Elevated',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your answers indicate a higher risk that the current pain '
                  'could become longer-term. Early targeted support is '
                  'recommended in addition to the workstation adjustments below.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
