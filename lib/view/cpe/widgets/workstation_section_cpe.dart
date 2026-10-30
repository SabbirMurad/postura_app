import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/assessment/workstation_answers.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/assessment/workstation_questionnaire_screen.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

/// The workstation checklist on the ergonomist's review.
///
/// Photos-only scan: the employee left it to the ergonomist. Opens the same
/// checklist the employee would have answered; the answers are sent with the
/// review, which scores the scan and releases the result to the employee.
///
/// Employee-answered scan: the ergonomist may update the answers once. The
/// checklist opens pre-filled with the employee's answers; submitting the
/// review re-scores the scan and the original score is kept next to it.
class WorkstationSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  final CpeAssessmentNotifier notifier;
  const WorkstationSectionCPE({
    super.key,
    required this.state,
    required this.notifier,
  });

  Future<void> _open(BuildContext context) async {
    final result = await Navigator.of(context).push<ChecklistAnswers>(
      MaterialPageRoute(
        builder: (_) => WorkstationQuestionnaireScreen(
          // Armrest width / wrist deviation are only asked when there's no
          // front photo to measure them from.
          reviewFrontPhotoAvailable: state.frontCapture != null,
          initialAnswers: state.checklistAnswers ?? state.employeeAnswers,
        ),
      ),
    );
    if (result != null) notifier.setChecklistAnswers(result);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final answered = state.checklistAnswers != null;
    final photosOnly = state.awaitingErgonomist;
    final revised = state.rosaRevision != null;

    final String status;
    final String hint;
    if (photosOnly) {
      status = answered ? loc.workstationAnswered : loc.workstationNotAnswered;
      hint = loc.workstationErgonomistHint;
    } else if (revised) {
      status =
          loc.updatedByErgonomist +
          (state.rosaRevision!.revisedBy?.isNotEmpty == true
              ? ' · ${state.rosaRevision!.revisedBy}'
              : '');
      hint = loc.workstationAlreadyRevised;
    } else {
      status = answered
          ? loc.workstationRevisionPending
          : loc.workstationAnsweredByEmployee;
      hint = loc.workstationReviseHint;
    }
    final done = answered || revised;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.workstationQuestions),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.assignment_outlined,
                    size: 20.sp,
                    color: done
                        ? const Color(0xFF43A047)
                        : AppColors.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                ),
              ),
              if (!revised) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _open(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      answered
                          ? loc.editAnswers
                          : photosOnly
                          ? loc.answerWorkstationQuestions
                          : loc.updateAnswersOnce,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // An unsent update of the employee's answers can be dropped.
                if (answered && !photosOnly)
                  Center(
                    child: TextButton(
                      onPressed: notifier.clearChecklistAnswers,
                      child: Text(
                        loc.discardChanges,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
