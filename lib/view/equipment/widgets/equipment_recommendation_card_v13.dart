import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';

/// Equipment recommendation card for the deterministic Equipment Engine v1.3
/// (Postura_Equipment_Engine_v1.3_Enterprise_Copy_Complete.docx §3). Every
/// text field on the card is fixed copy from the backend — this widget just
/// lays it out; only its own section headings are translated in the app.
class EquipmentRecommendationCardV13 extends StatelessWidget {
  final EquipmentCardV13 card;

  /// FINDING_ID -> employee-facing name, from the Action Report. Only used when
  /// the card itself carries no names (servers older than that field).
  final Map<String, String> findingLabels;

  const EquipmentRecommendationCardV13({
    super.key,
    required this.card,
    this.findingLabels = const {},
  });

  List<String> get _relatedLabels => card.relatedFindingLabels.isNotEmpty
      ? card.relatedFindingLabels
      : card.relatedFindings
            .map((id) => findingLabels[id])
            .whereType<String>()
            .toList();

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Text(
      '• $text',
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColors.secondaryText,
        height: 1.4,
      ),
    ),
  );

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
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.cardTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _priorityColor.withValues(alpha: 0.4),
                  ),
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
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.text,
              height: 1.5,
            ),
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

          if (_relatedLabels.isNotEmpty) ...[
            _sectionLabel(loc.rptRelatedFindings),
            ..._relatedLabels.map(_bullet),
          ],

          if (card.whyText.isNotEmpty) ...[
            _sectionLabel(loc.rptWhyThisAppears),
            ...card.whyText.map(_bullet),
          ],

          if (card.targetText.isNotEmpty) ...[
            _sectionLabel(loc.rptTarget),
            Text(
              card.targetText,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],

          if (card.requiredFeatures.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              loc.rptRequiredFeatures,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: card.requiredFeatures
                  .map(
                    (f) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryText.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          if (card.nextStepText.isNotEmpty) ...[
            _sectionLabel(loc.rptNextStep),
            Text(
              card.nextStepText,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
