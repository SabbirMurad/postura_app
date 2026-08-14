import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class ReviewModeSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  final CpeAssessmentNotifier notifier;
  const ReviewModeSectionCPE({super.key, required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.howDidYouReview),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              _ModeButton(
                icon: Icons.home_outlined,
                label: loc.remote,
                isSelected: state.reviewMode == ReviewMode.remote,
                onTap: state.initialReviewStatus == 'PENDING'
                    ? () => notifier.setReviewMode(ReviewMode.remote)
                    : () {},
              ),
              _ModeButton(
                icon: Icons.wifi_tethering_rounded,
                label: loc.live,
                isSelected: state.reviewMode == ReviewMode.live,
                onTap: state.initialReviewStatus == 'PENDING'
                    ? () => notifier.setReviewMode(ReviewMode.live)
                    : () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
