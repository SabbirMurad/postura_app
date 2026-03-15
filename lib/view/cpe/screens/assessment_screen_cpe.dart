import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/compliance_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/patient_info_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/photo_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/approvals_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/decision_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/comment_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/signature_section_cpe.dart';

// ─────────────────────────────────────────
// Binding
// ─────────────────────────────────────────
class CPEAssessmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CPEAssessmentController>(() => CPEAssessmentController());
  }
}

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────
class CPEAssessmentScreen extends StatelessWidget {
  const CPEAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CPEAssessmentController>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      AppBackButton(),
                      SizedBox(height: 12.h),

                      /// Title
                      Text(
                        loc.cpeAssessmentReview,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF202020),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        loc.cpeAssessmentSubtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),

                      SizedBox(height: 16.h),
                      PatientInfoCardCPE(controller: controller),
                      SizedBox(height: 20.h),
                      ComplianceCardCPE(controller: controller),
                      SizedBox(height: 20.h),
                      DeskInfoSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      PainSymptomsSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      PhotoSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      ApprovalsSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      ReviewModeSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      DecisionSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      CommentSectionCPE(controller: controller),
                      SizedBox(height: 20.h),
                      SignatureSectionCPE(controller: controller),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              SubmitButtonCPE(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}
