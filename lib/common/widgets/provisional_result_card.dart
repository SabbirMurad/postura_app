import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

/// Shown above an employee's result while it is provisional: the server found
/// something in the photos the ergonomist should check, and no ergonomist has
/// reviewed the scan yet. The reasons stay with the ergonomist.
class ProvisionalResultCard extends StatelessWidget {
  const ProvisionalResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 22.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.provResultTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  loc.provResultBody,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
