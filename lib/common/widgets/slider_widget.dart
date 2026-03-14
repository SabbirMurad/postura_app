import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'package:posture_detector_app/core/constants/app_colors.dart';

class AppSliderWidget extends StatelessWidget {
  final String title;
  final RxDouble sliderValue;

  const AppSliderWidget({
    super.key,
    required this.title,
    required this.sliderValue,
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
                child: Obx(() {
                  return Text(
                    sliderValue.round().toString(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Obx(() {
          return Slider(
            padding: EdgeInsets.zero,
            value: sliderValue.value,
            onChanged: (value) {
              sliderValue.value = value;
            },
            thumbColor: AppColors.surface,
            activeColor: AppColors.primaryColor,
            inactiveColor: AppColors.text.withValues(alpha: 0.2),
            min: 1,
            max: 10,
          );
        }),
      ],
    );
  }
}
