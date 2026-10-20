import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/models/assessment/screening_review.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';

const _red = Color(0xFFE53935);
const _amber = Color(0xFFFB8C00);

/// The employee's red-flag safety screening and Work Ability & Recovery
/// Outlook answers, for the ergonomist only (the company-admin dashboard
/// never receives them). Renders nothing for scans recorded without them.
class ScreeningSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const ScreeningSectionCPE({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.redFlagAnswers.isEmpty && state.recoveryAnswers.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Screening',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Visible to ergonomists only. Not shared with the company.',
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
        ),
        if (state.redFlagAnswers.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _Group(
            title: 'Safety Questions (Red Flags)',
            status: state.redFlagPositive
                ? 'Positive: exercises withheld, refer to a healthcare professional'
                : 'Negative',
            statusColor: state.redFlagPositive ? _red : AppColors.secondaryText,
            answers: state.redFlagAnswers,
            flagColor: _red,
          ),
        ],
        if (state.recoveryAnswers.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _Group(
            title: 'Work Ability & Recovery Outlook',
            status: 'Recovery outlook: ${state.chronicityLevel}',
            statusColor:
                state.chronicityElevated ? _amber : AppColors.secondaryText,
            answers: state.recoveryAnswers,
            flagColor: _amber,
          ),
        ],
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final List<ScreeningAnswer> answers;
  final Color flagColor;

  const _Group({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.answers,
    required this.flagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            status,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          SizedBox(height: 6.h),
          for (var i = 0; i < answers.length; i++) ...[
            if (i > 0) Divider(height: 1, color: const Color(0xFFEEF0F3)),
            _AnswerRow(answer: answers[i], flagColor: flagColor),
          ],
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final ScreeningAnswer answer;
  final Color flagColor;
  const _AnswerRow({required this.answer, required this.flagColor});

  @override
  Widget build(BuildContext context) {
    final color = answer.flagged ? flagColor : AppColors.text;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answer.question,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.text),
                ),
                if (answer.scale != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    answer.scale!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: answer.flagged
                  ? flagColor.withValues(alpha: 0.12)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              answer.answer,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
