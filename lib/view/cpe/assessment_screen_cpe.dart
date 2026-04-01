import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/compliance_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/patient_info_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/photo_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/approvals_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/decision_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/comment_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/signature_section_cpe.dart';

class CPEAssessmentScreen extends ConsumerWidget {
  const CPEAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final scanId = (args?['scan_id'] ?? 0) as int;
    final state = ref.watch(cpeAssessmentNotifierProvider(scanId));
    final notifier = ref.read(cpeAssessmentNotifierProvider(scanId).notifier);
    final loc = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
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
                    PatientInfoCardCPE(state: state),
                    SizedBox(height: 20.h),
                    ComplianceCardCPE(state: state),
                    SizedBox(height: 20.h),
                    DeskInfoSectionCPE(state: state),
                    SizedBox(height: 20.h),
                    PainSymptomsSectionCPE(state: state),
                    SizedBox(height: 20.h),
                    PhotoSectionCPE(state: state),
                    SizedBox(height: 20.h),
                    ApprovalsSectionCPE(state: state, notifier: notifier),
                    SizedBox(height: 20.h),
                    ReviewModeSectionCPE(state: state, notifier: notifier),
                    SizedBox(height: 20.h),
                    DecisionSectionCPE(state: state, notifier: notifier),
                    SizedBox(height: 20.h),
                    CommentSectionCPE(state: state, notifier: notifier),
                    SizedBox(height: 20.h),
                    SignatureSectionCPE(state: state, notifier: notifier),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            SubmitButtonCPE(state: state, notifier: notifier),
          ],
        ),
      ),
    );
  }
}
