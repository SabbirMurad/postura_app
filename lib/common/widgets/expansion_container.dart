import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/constants/app_colors.dart';

class ExpansionContainer extends StatelessWidget {
  final String title;
  final String leading;
  final String content;

  const ExpansionContainer({
    super.key,
    required this.title,
    required this.leading,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16.r),
      child: ExpansionTile(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.greyDeemed, width: 0.1),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        // leading: IconContainer(path: leading),
        backgroundColor: AppColors.onBoardingSurface,
        collapsedShape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(width: 0.1, color: AppColors.greyDeemed),
        ),
        collapsedBackgroundColor: AppColors.onBoardingSurface,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 12.w,
              top: 6.h,
            ),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.greyDeemed,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              content,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
