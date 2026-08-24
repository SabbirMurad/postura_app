import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';

/// Equipment recommendation card for the deterministic Equipment Engine v1.3
/// (Postura_Equipment_Engine_v1.3_Enterprise_Copy_Complete.docx §3). Every
/// text field on the card is fixed copy from the backend — this widget just
/// lays it out, it never generates any of its own text.
class EquipmentRecommendationCardV13 extends StatelessWidget {
  final EquipmentCardV13 card;

  const EquipmentRecommendationCardV13({super.key, required this.card});

  Color get _priorityColor {
    switch (card.priorityLabel) {
      case 'Critical Priority':
        return const Color(0xFFA13544);
      case 'High Priority':
        return const Color(0xFFDA7101);
      case 'Recommended':
        return const Color(0xFFDAA101);
      default:
        return const Color(0xFF437A22); // Targeted Support
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryText.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.cardTitle,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: _priorityColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  card.priorityLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _priorityColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            card.priorityText,
            style: TextStyle(
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            card.cardDescription,
            style: TextStyle(fontSize: 13.sp, color: AppColors.text, height: 1.5),
          ),

          if (card.consolidationNote != null) ...[
            SizedBox(height: 8.h),
            Text(
              card.consolidationNote!,
              style: TextStyle(
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.secondaryText.withValues(alpha: 0.8),
              ),
            ),
          ],

          if (card.whyText.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Why this appears',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            SizedBox(height: 4.h),
            ...card.whyText.map(
              (w) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  '• $w',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText, height: 1.4),
                ),
              ),
            ),
          ],

          if (card.requiredFeatures.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Required features',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: card.requiredFeatures
                  .map(
                    (f) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryText.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          SizedBox(height: 10.h),
          Text(
            card.nextStepText,
            style: TextStyle(fontSize: 12.sp, color: AppColors.text, height: 1.4),
          ),
        ],
      ),
    );
  }
}
