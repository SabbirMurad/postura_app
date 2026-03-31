import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/constants/app_text.dart';

import 'package:posture_detector_app/constants/app_colors.dart';
import 'back_button.dart';

class AppTopSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? isSkip;

  const AppTopSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSkip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.centerLeft, child: AppBackButton()),
            if (isSkip ?? false)
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoute.cameraGuideScreen);
                },
                child: Text(
                  AppText.skip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 17.h),
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
