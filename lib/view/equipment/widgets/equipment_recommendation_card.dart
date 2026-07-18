import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';

/// Equipment recommendation card — driven by EquipmentEngine output
class EquipmentRecommendationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String source;
  final String urgencyLabel;    // 'Urgent' | 'Recommended' | 'Preventive'
  final int urgencyLevel;       // 3 | 2 | 1
  final String riskBadgeText;   // e.g. 'Monitor risk: 3'
  final String? cardNote;
  final bool chronicityFlag;
  final String? status; // 'ACTIONED' | 'PENDING' | 'REJECTED' | null

  const EquipmentRecommendationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.urgencyLabel,
    required this.urgencyLevel,
    required this.riskBadgeText,
    this.cardNote,
    this.chronicityFlag = false,
    this.status,
  });

  Color get _urgencyColor {
    switch (urgencyLevel) {
      case 3:
        return const Color(0xFFA13544); // red — Urgent
      case 2:
        return const Color(0xFFDA7101); // orange — Recommended
      default:
        return const Color(0xFF437A22); // green — Preventive
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Chronicity banner (amber, shown when long-term condition flag set)
          if (chronicityFlag)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFDAA101).withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: Color(0xFF856404),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Long-term condition — consistent use recommended',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),

          /// Main card content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + riskBadge row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (riskBadgeText.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryText.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          riskBadgeText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),

                /// Description
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),

                /// Card note (modifier note — italic)
                if (cardNote != null && cardNote!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    cardNote!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                /// Source line
                Text(
                  'Source: $source',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFFA6A6A6),
                  ),
                ),
                SizedBox(height: 10.h),

                /// Urgency badge + status chip row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _urgencyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _urgencyColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        urgencyLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _urgencyColor,
                        ),
                      ),
                    ),
                    if (status != null && status!.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'ACTIONED'
                              ? AppColors.green
                              : status == 'PENDING'
                              ? AppColors.warning
                              : AppColors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          status!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
