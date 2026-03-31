import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/models/user_type.dart';

import 'package:posture_detector_app/constants/app_colors.dart';

class UserTypeCard extends StatelessWidget {
  final SvgPicture image;
  final String title;
  final String subtitle;
  final String selectedRole;
  final UserType userType;

  const UserTypeCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.selectedRole,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRole == userType.name;

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 100.h,
        width: 335.w,
        decoration: BoxDecoration(
          color: AppColors.onBoardingSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.onBoardingSurface,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Center(
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: AppColors.blackDeemed,
              ),
              child: image,
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            trailing: isSelected
                ? Container(
                    width: 25.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    child: Icon(Icons.check, color: AppColors.surface),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
