import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'icon_container.dart';

class DetailsAnalysisContainer extends StatelessWidget {
  final String path;
  final Color iconBgColor;
  final String title;
  final String subTitle;
  final String comment;
  final String commentColor;

  const DetailsAnalysisContainer({
    super.key,
    required this.path,
    required this.iconBgColor,
    required this.title,
    required this.subTitle,
    required this.comment,
    required this.commentColor,
  });

  /// Get display comment based on color status
  String _getDisplayComment() {
    if (commentColor.toLowerCase() == 'green') {
      return '✓ Optimal';
    }
    return comment;
  }

  /// Get color based on severity
  Color _getCommentColor() {
    final severity = commentColor.toLowerCase();

    switch (severity) {
      case 'red':
        return AppColors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Color.fromRGBO(234, 154, 0, 1);
      default:
        return AppColors.secondaryText; // ✅ Default fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 2.h, bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.onBoardingSurface,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
        title: Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
        leading: IconContainer(color: iconBgColor, path: path),
        subtitle: Text(
          subTitle,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _getDisplayComment(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _getCommentColor(),
          ),
        ),
      ),
    );
  }
}
