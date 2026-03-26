import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class ApprovalsSectionCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const ApprovalsSectionCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EN: "Approvals"
        SectionTitle(AppLocalizations.of(context)!.approvals),
        SizedBox(height: 12.h),
        Obx(
          () => Column(
            children: controller.approvalItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: controller.initialReviewStatus.value == 'PENDING'
                      ? () => controller.toggleApproval(index)
                      : null,
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: item.isChecked
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: item.isChecked
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                        child: item.isChecked
                            ? Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF202020),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
