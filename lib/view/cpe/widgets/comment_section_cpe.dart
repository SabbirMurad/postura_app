import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class CommentSectionCPE extends StatefulWidget {
  final CpeAssessmentState state;
  final CpeAssessmentNotifier notifier;
  const CommentSectionCPE({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  State<CommentSectionCPE> createState() => _CommentSectionCPEState();
}

class _CommentSectionCPEState extends State<CommentSectionCPE> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.state.comment,
    )..selection = TextSelection.collapsed(offset: widget.state.comment.length);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isEditable = widget.state.initialReviewStatus == 'PENDING';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.commentLabel),
        SizedBox(height: 8.h),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              TextField(
                maxLines: 5,
                readOnly: !isEditable,
                controller: _textController,
                onChanged: isEditable
                    ? (value) {
                        widget.notifier.setComment(value);
                        setState(() {});
                      }
                    : null,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF202020),
                ),
                decoration: InputDecoration(
                  hintText: loc.commentHint,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFFBDBDBD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_textController.text.length}/${widget.state.maxCommentLength}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SubmitButtonCPE extends StatelessWidget {
  final CpeAssessmentState state;
  final CpeAssessmentNotifier notifier;
  const SubmitButtonCPE({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (state.initialReviewStatus != 'PENDING') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () async {
                  final result = await notifier.submitReview();
                  if (result) {
                    Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            disabledBackgroundColor: const Color(
              0xFF2563EB,
            ).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: state.isSubmitting
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  loc.submitReview,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
