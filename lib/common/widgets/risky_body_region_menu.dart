import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

    // // Decide icon based on risk
    // Widget icon = high
    //     ? Assets.icons.status.wrongAlert.svg(width: 28.w, height: 28.h)
    //     : medium
    //     ? Assets.icons.status.alertLine.svg(width: 28.w, height: 28.h)
    //     : Assets.icons.status.rightGuard.svg(width: 28.w, height: 28.h);

    final statusColor = high
        ? const Color(0xFFE53935)
        : medium
        ? const Color(0xFFFB8C00)
        : const Color(0xFF43A047);

    return Container(
      width: (1.sw - 40.w - 12.w) / 2,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/region/${region.replaceAll(' ', '_').toLowerCase()}.svg',
              width: 28.w,
              height: 28.w,
            ),
            SizedBox(height: 6.w),
            Text(
              region,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            // icon,
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                risk.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Text(
            //   risk.toUpperCase(),
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w600,
            //     color: high
            //         ? AppColors.red
            //         : medium
            //         ? AppColors.warning
            //         : AppColors.green,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
