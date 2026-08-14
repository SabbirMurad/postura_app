import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';

class AppSliderWidget extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;

  const AppSliderWidget({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            Container(
              width: 41.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  value.round().toString(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Slider(
          padding: EdgeInsets.zero,
          value: value,
          onChanged: onChanged,
          thumbColor: AppColors.surface,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.text.withValues(alpha: 0.2),
          min: 1,
          max: 10,
        ),
      ],
    );
  }
}
