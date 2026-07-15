import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:posture_detector_app/constants/colors.dart';

class IconContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final String path;
  final Color? color;
  final bool showBackground;

  const IconContainer({
    super.key,
    required this.path,
    this.color,
    this.width,
    this.height,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = SvgPicture.asset(path, width: 24.w, height: 24.h);

    if (!showBackground) {
      return SizedBox(
        width: width ?? 40.w,
        height: height ?? 40.w,
        child: Center(child: child),
      );
    }

    return Container(
      width: width ?? 40.w,
      height: height ?? 40.w,
      decoration: BoxDecoration(
        color:
            color?.withValues(alpha: 0.1) ??
            AppColors.greyDeemed.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(child: child),
    );
  }
}
