import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

enum StepStatus { pending, active, completed }

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.cameraStatus,
    required this.detectStatus,
    required this.confirmStatus,
    required this.poseStatus,
    this.confirmCount,
    this.confirmTotal,
  });
  final StepStatus cameraStatus, detectStatus, confirmStatus, poseStatus;
  final int? confirmCount, confirmTotal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: c.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          _StepItem(
            icon: Icons.videocam_rounded,
            label: 'Camera',
            status: cameraStatus,
            c: c,
          ),
          _Line(active: detectStatus != StepStatus.pending, c: c),
          _StepItem(
            icon: Icons.search_rounded,
            label: 'Detect',
            status: detectStatus,
            c: c,
          ),
          _Line(active: confirmStatus != StepStatus.pending, c: c),
          _StepItem(
            icon: Icons.verified_rounded,
            label: 'Confirm',
            status: confirmStatus,
            c: c,
            badge: confirmStatus == StepStatus.active && confirmCount != null
                ? '$confirmCount'
                : null,
          ),
          _Line(active: poseStatus != StepStatus.pending, c: c),
          _StepItem(
            icon: Icons.accessibility_new_rounded,
            label: 'Pose',
            status: poseStatus,
            c: c,
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.label,
    required this.status,
    required this.c,
    this.badge,
  });
  final IconData icon;
  final String label;
  final StepStatus status;
  final AppColorSet c;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDone = status == StepStatus.completed;
    final isActive = status == StepStatus.active;
    final color = isDone
        ? AppColors.successGreen
        : isActive
        ? AppColors.lightTeal
        : c.iconMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.confirmGreen
                    : isActive
                    ? AppColors.primaryGreen.withValues(alpha: 0.3)
                    : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child: isDone
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                  : Icon(icon, color: color, size: 16.sp),
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightTeal,
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            color: isDone || isActive ? c.textSecondary : c.textMuted,
            fontSize: 9.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.active, required this.c});
  final bool active;
  final AppColorSet c;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Container(
          height: 2,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: active
                ? AppColors.lightTeal.withValues(alpha: 0.5)
                : c.border,
          ),
        ),
      ),
    );
  }
}
