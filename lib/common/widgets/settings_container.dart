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
    required this.onTap, this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: AppColors.onBoardingSurface,
          ),
          child: Center(
            child: ListTile(
              leading: icon != null ? Icon(icon) : IconContainer(path: iconData ?? ''),
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
      ),
    );
  }
}
