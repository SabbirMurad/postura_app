import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/core/constants/app_colors.dart';

class SelectionalContainer extends StatelessWidget {
  final String title;
  final bool selected;

  const SelectionalContainer({
    super.key,
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      width: 335.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.onBoardingSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: selected ? AppColors.primaryColor : AppColors.blackDeemed,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryColor : AppColors.text.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
