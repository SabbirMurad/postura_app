import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class BottomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BottomButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
      height: 60.h,
      decoration: BoxDecoration(color: AppColors.onBoardingSurface),
      child: PrimaryButton(
        onTap: onTap,
        text: title,
        backgroundColor: AppColors.primaryColor,
        textColor: AppColors.onBoardingSurface,
      ),
    );
  }
}
