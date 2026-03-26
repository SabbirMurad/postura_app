import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class CommentSectionCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const CommentSectionCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EN: "Comment"
        SectionTitle(loc.commentLabel),
        SizedBox(height: 8.h),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              TextField(
                maxLines: 5,
                readOnly: controller.initialReviewStatus.value != 'PENDING',
                onChanged: controller.initialReviewStatus.value == 'PENDING'
                    ? controller.setComment
                    : null,
                controller:
                    TextEditingController(text: controller.comment.value)
                      ..selection = TextSelection.collapsed(
                        offset: controller.comment.value.length,
                      ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF202020),
                ),
                decoration: InputDecoration(
                  // EN: "e.g. this looks good I guess."
                  hintText: loc.commentHint,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFFBDBDBD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${controller.comment.value.length}/${controller.maxCommentLength}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF4A4A4A),
                      ),
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
  final CPEAssessmentController controller;
  const SubmitButtonCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Obx(() {
      if (controller.initialReviewStatus.value != 'PENDING') {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              disabledBackgroundColor:
                  const Color(0xFF2563EB).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: controller.isSubmitting.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    // EN: "Submit Review"
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
    });
  }
}
