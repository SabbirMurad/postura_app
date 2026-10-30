import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class DecisionSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  final CpeAssessmentNotifier notifier;
  const DecisionSectionCPE({super.key, required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.decisionLabel),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: state.initialReviewStatus == 'PENDING'
              ? () => _showDecisionPicker(context)
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: cardDecoration(),
            child: Row(
              children: [
                decisionSvgIcon(state.decision, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    state.decisionLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ),
                if (state.initialReviewStatus == 'PENDING')
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: const Color(0xFF4A4A4A),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDecisionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReviewDecision.values.map((d) {
            return ListTile(
              title: Text(d.label),
              onTap: () {
                notifier.setDecision(d);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
