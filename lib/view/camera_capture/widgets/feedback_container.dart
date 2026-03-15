import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class FeedBackContainer extends StatelessWidget {
  final String title;
  final IconData iconData;

  const FeedBackContainer({
    super.key,
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      width: 235.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: title == 'Perfect posture'
            ? AppColors.greenish
            : AppColors.red.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(92.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
