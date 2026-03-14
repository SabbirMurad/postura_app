import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/core/constants/app_colors.dart';

class ProfileInfo extends StatelessWidget {
  final String title;
  final String value;
  final String? tailingText;
  final IconData? iconData;
  final VoidCallback onTap;

  const ProfileInfo({
    super.key,
    required this.title,
    required this.value,
    this.tailingText,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Icon(iconData, size: 20.h),
                SizedBox(width: 3.w),
                Text(
                  tailingText ?? '',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
