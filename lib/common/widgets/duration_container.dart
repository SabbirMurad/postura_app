import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/colors.dart';

class DurationContainer extends StatelessWidget {
  final IconData? icon;
  final String content;
  final Color? bgColor;
  final Color? textColor;

  const DurationContainer({
    super.key,
    this.icon,
    required this.content,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: bgColor ?? AppColors.greyDeemed,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 16.w),
          SizedBox(width: 4.w),
          Text(
            icon != null ? "$content " : content,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: textColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
