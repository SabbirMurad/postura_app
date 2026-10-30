import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/analysis/rosa_revision.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';

/// The employee's original ROSA score next to the ergonomist's updated one,
/// for an assessment whose workstation answers the ergonomist updated during
/// the review. The original is kept and shown muted; the updated one is the
/// score the recommendations follow.
class RosaScoreComparison extends StatelessWidget {
  const RosaScoreComparison({
    super.key,
    required this.original,
    required this.revision,
  });

  final RosaScore original;
  final RosaRevision revision;

  static Color _color(int score) {
    if (score >= 7) return const Color(0xFFE53935);
    if (score >= 4) return const Color(0xFFFB8C00);
    return const Color(0xFF43A047);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final updatedBy = revision.revisedBy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _tile(
                  title: loc.originalRosaScore,
                  subtitle: loc.fromEmployeesAnswers,
                  score: original,
                  highlighted: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.sp,
                  color: AppColors.secondaryText,
                ),
              ),
              Expanded(
                child: _tile(
                  title: loc.updatedRosaScore,
                  subtitle: updatedBy == null || updatedBy.isEmpty
                      ? loc.updatedByErgonomist
                      : '${loc.updatedByErgonomist} · $updatedBy',
                  score: revision.rosaScore,
                  highlighted: true,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          loc.rosaUpdatedNote,
          style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required RosaScore score,
    required bool highlighted,
  }) {
    final color = highlighted
        ? _color(score.finalScore)
        : AppColors.secondaryText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.06)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.35)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            score.isValid ? '${score.finalScore} / 10' : 'N/A',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
