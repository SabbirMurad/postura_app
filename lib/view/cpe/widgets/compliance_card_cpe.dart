import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class ComplianceCardCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const ComplianceCardCPE({super.key, required this.state});

  Color _tierColor(int score) {
    if (score >= 7) return const Color(0xFFA13544);
    if (score >= 4) return const Color(0xFFDA7101);
    return const Color(0xFF437A22);
  }

  String _tierLabel(int score) {
    if (score >= 7) return 'HIGH RISK';
    if (score >= 4) return 'MODERATE RISK';
    return 'LOW RISK';
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Investigate and change soon';
    if (score >= 4) return 'Further investigation needed';
    return 'No immediate action needed';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final rosaFinal = state.rosaFinal;
    final tierColor = _tierColor(rosaFinal);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              loc.rosaErgonomicAnalysis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF202020),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          /// ROSA Final Score display
          Center(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$rosaFinal',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w700,
                          color: tierColor,
                        ),
                      ),
                      TextSpan(
                        text: ' / 10',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _tierLabel(rosaFinal),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: tierColor,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _actionLevel(rosaFinal),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          Divider(color: AppColors.secondaryText.withValues(alpha: 0.15)),
          SizedBox(height: 12.h),

          /// ROSA Sub-score rows
          _buildSubScoreRow('Chair', state.rosaChair),
          SizedBox(height: 8.h),
          _buildSubScoreRow('Monitor / Screen', state.rosaMonitor),
          SizedBox(height: 8.h),
          _buildSubScoreRow('Keyboard', state.rosaKeyboard),
          SizedBox(height: 8.h),
          _buildSubScoreRow('Mouse / Peripherals', state.rosaMouse),
        ],
      ),
    );
  }

  Widget _buildSubScoreRow(String label, int score) {
    final color = score >= 3
        ? (score >= 5 ? const Color(0xFFA13544) : const Color(0xFFDA7101))
        : const Color(0xFF437A22);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4A4A4A)),
        ),
        Container(
          width: 30.w,
          height: 30.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
