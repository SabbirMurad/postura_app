import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class CameraBottomBar extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleFlash;
  final bool isFlashOn;

  const CameraBottomBar({
    super.key,
    required this.onCapture,
    required this.onToggleFlash,
    required this.isFlashOn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 123.h,
      color: AppColors.text.withValues(alpha: 0.4),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBackButton(
                backgroundColor: AppColors.blackDeemed.withValues(alpha: 0.3),
                iconColor: AppColors.surface,
              ),
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 72.w,
                  height: 70.h,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Assets.icons.general.cameraTap.svg(
                    width: 30.w,
                    height: 30.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleFlash,
                icon: Icon(
                  isFlashOn ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
