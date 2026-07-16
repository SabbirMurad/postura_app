import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/colors.dart';

/// Pill-shaped selectable chip shared by the body-region and pain-duration
/// pickers so the two inputs stay visually identical.
class SelectionChip extends StatelessWidget {
  final String title;
  final bool selected;

  const SelectionChip({super.key, required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: AppColors.onBoardingSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: selected ? AppColors.primaryColor : AppColors.blackDeemed,
          width: 2,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          color: selected ? AppColors.primaryColor : AppColors.text,
        ),
      ),
    );
  }
}
