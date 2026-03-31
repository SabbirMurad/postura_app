import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:posture_detector_app/constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;

  const AppBackButton({super.key, this.backgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }
        Get.back();
      },
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? AppColors.greyDeemed,
        ),
        child: Icon(
          Icons.arrow_back,
          size: 20.w,
          color: iconColor ?? AppColors.text,
        ),
      ),
    );
  }
}
