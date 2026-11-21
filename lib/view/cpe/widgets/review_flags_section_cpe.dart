import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/analysis/review_flag.dart';

const _amber = Color(0xFFFB8C00);

/// Where the server found the photos uncertain or in conflict with the
/// questionnaire. Flags that need a check come first, in amber; information
/// only flags follow in grey.
class ReviewFlagsSectionCPE extends StatelessWidget {
  final List<ReviewFlag> flags;
  const ReviewFlagsSectionCPE({super.key, required this.flags});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final sorted = [
      ...flags.where((f) => f.escalate),
      ...flags.where((f) => !f.escalate),
    ];
    final toCheck = flags.where((f) => f.escalate).length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: toCheck > 0 ? Border.all(color: _amber.withValues(alpha: 0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                toCheck > 0 ? Icons.flag_rounded : Icons.check_circle_outline,
                size: 18.sp,
                color: toCheck > 0 ? _amber : AppColors.secondaryText,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  loc.flagSectionTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (toCheck > 0) ReviewFlagBadge(count: toCheck),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            sorted.isEmpty ? loc.flagNone : loc.flagSectionSubtitle,
            style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
          ),
          for (var i = 0; i < sorted.length; i++) ...[
            if (i == 0) SizedBox(height: 6.h),
            if (i > 0) Divider(height: 1, color: const Color(0xFFEEF0F3)),
            _FlagRow(flag: sorted[i]),
          ],
        ],
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  final ReviewFlag flag;
  const _FlagRow({required this.flag});

  @override
  Widget build(BuildContext context) {
    final color = flag.escalate ? _amber : AppColors.secondaryText;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(
              flag.escalate ? Icons.warning_amber_rounded : Icons.info_outline,
              size: 16.sp,
              color: color,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flag.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: flag.escalate ? AppColors.text : AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  flag.explanation,
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

/// Small amber pill: "N to check".
class ReviewFlagBadge extends StatelessWidget {
  final int count;
  const ReviewFlagBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 12.sp, color: _amber),
          SizedBox(width: 3.w),
          Text(
            loc.flagToCheck(count),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _amber,
            ),
          ),
        ],
      ),
    );
  }
}
