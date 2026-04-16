import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'icon_container.dart';

class SettingsContainer extends StatelessWidget {
  final String? iconData;
  final IconData? icon;
  final String title;
  final VoidCallback onTap;

  const SettingsContainer({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.secondaryText.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: ListTile(
            leading: icon != null
                ? Icon(icon)
                : IconContainer(path: iconData ?? ''),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.sp),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_outlined,
              size: 16.w,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
