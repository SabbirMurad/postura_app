import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/detection_result.dart';

class DetectionChecklist extends StatelessWidget {
  const DetectionChecklist({super.key, required this.result});
  final DetectionResult? result;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CheckItem(
            icon: Icons.person_rounded,
            label: 'Person',
            detected: result?.personDetected ?? false,
            confidence: result?.personConfidence,
            c: c,
          ),
          Container(width: 1, height: 26.h, color: c.divider),
          _CheckItem(
            icon: Icons.desktop_mac_rounded,
            label: 'Monitor',
            detected: result?.monitorDetected ?? false,
            confidence: result?.monitorConfidence,
            c: c,
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.icon,
    required this.label,
    required this.detected,
    this.confidence,
    required this.c,
  });
  final IconData icon;
  final String label;
  final bool detected;
  final double? confidence;
  final AppColorSet c;

  @override
  Widget build(BuildContext context) {
    final color = detected ? AppColors.lightTeal : c.iconMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: detected
              ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey('on'),
                  color: color,
                  size: 18.sp,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  key: const ValueKey('off'),
                  color: color,
                  size: 18.sp,
                ),
        ),
        SizedBox(width: 5.w),
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            color: detected ? c.textPrimary : c.textTertiary,
            fontSize: 12.sp,
            fontWeight: detected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (detected && confidence != null) ...[
          SizedBox(width: 5.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.lightTeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              '${(confidence! * 100).toInt()}%',
              style: TextStyle(
                color: AppColors.lightTeal,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
