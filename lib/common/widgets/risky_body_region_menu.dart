import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

import 'package:posture_detector_app/constants/app_colors.dart';

class RiskBodyRegionMenu extends StatelessWidget {
  final String risk;
  final String region;

  const RiskBodyRegionMenu({
    super.key,
    required this.risk,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final bool high = risk.toLowerCase() == 'high';
    final bool medium = risk.toLowerCase() == 'medium';

    // Decide icon based on risk
    Widget icon = high
        ? Assets.icons.status.wrongAlert.svg(width: 28.w, height: 28.h)
        : medium
        ? Assets.icons.status.alertLine.svg(width: 28.w, height: 28.h)
        : Assets.icons.status.rightGuard.svg(width: 28.w, height: 28.h);

    return Container(
      width: 162.w,
      height: 86.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.onBoardingSurface,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 16.h),
            Text(
              region,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
