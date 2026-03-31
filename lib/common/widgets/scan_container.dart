import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/app_colors.dart';
import 'icon_container.dart';

class ScanContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  const ScanContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 336.w,
          padding: EdgeInsets.only(bottom: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: AppColors.onBoardingSurface,
          ),
          child: Center(
            child: ListTile(
              leading: IconContainer(path: iconPath),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
