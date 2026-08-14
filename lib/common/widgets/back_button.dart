import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:posture_detector_app/constants/colors.dart';

class AppBackButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;

  const AppBackButton({super.key, this.backgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    // Nothing to pop (e.g. this screen was reached via context.go, which
    // replaces the stack) — don't show a back button that leads nowhere.
    if (!context.canPop()) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        context.pop();
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
