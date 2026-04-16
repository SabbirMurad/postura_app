import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/view/business/home/home_screen.dart';

class RosaSubScoreItem extends StatelessWidget {
  final RosaItem item;

  RosaSubScoreItem({super.key, required this.item});

  late final statusColor = switch (item.status.risk) {
    RosaRisk.red => const Color(0xFFE53935),
    RosaRisk.orange => const Color(0xFFFB8C00),
    RosaRisk.green => const Color(0xFF43A047),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      width: (1.sw - 40.w - 12.w) / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/rosa/${item.category.replaceAll(' ', '_').toLowerCase()}.svg',
            width: 28.w,
            height: 28.w,
          ),
          SizedBox(height: 6.w),
          Text(
            item.category,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            item.score,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              item.status.label,
              style: TextStyle(
                fontSize: 11.sp,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
