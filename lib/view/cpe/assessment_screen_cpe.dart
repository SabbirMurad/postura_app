import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';
import 'package:posture_detector_app/view/cpe/widgets/compliance_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/patient_info_card_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/photo_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/approvals_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/decision_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/comment_section_cpe.dart';
import 'package:posture_detector_app/view/cpe/widgets/signature_section_cpe.dart';

class CPEAssessmentScreen extends ConsumerWidget {
  const CPEAssessmentScreen({super.key});

  Widget _deskInfo({
    required String deskLocation,
    required AppLocalizations loc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.deskIdLocation),
        SizedBox(height: 8.h),
        Row(
          children: [
            Assets.icons.workplace.desk.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0078B5),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              deskLocation,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _infoRow(String label, String value) {
    return [
      Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }

  Widget _yesNoRow(String label, bool? value, AppLocalizations loc) {
    final isYes = value == true;
    final isAnswered = value != null;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.text),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: !isAnswered
                  ? const Color(0xFFEDEDED)
                  : isYes
                  ? const Color(0xFFF6FFF0)
                  : const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              !isAnswered
                  ? '-'
                  : isYes
                  ? loc.yes
                  : 'No',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: !isAnswered
                    ? const Color(0xFF9E9E9E)
                    : isYes
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordPatternSection({
    required WorkPattern workPattern,
    required AppLocalizations loc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.workPattern),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: cardDecoration(),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._infoRow(loc.hoursAtDeskPerDay, workPattern.hoursAtDesk),
              SizedBox(height: 10.h),
              ..._infoRow(loc.breakHabits, workPattern.breakHabit),
              SizedBox(height: 10.h),
              ..._infoRow(loc.selectDeviceUsage, workPattern.deviceUsage),
              SizedBox(height: 10.h),
              ..._infoRow(loc.mouseType, workPattern.mouseType),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workstation({
    required Workstation workstation,
    required AppLocalizations loc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.workstation),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _yesNoRow(
                loc.canAdjustChairHeight,
                workstation.canAdjustChairHeight,
                loc,
              ),
              _yesNoRow(loc.enoughLegRoom, workstation.enoughLegRoom, loc),
              _yesNoRow(
                loc.chairHasLumbarSupport,
                workstation.chairHasLumbarSupport,
                loc,
              ),
              SizedBox(height: 10.h),
              ..._infoRow(
                loc.monitorDistance,
                workstation.monitorDistance.isEmpty
                    ? '-'
                    : workstation.monitorDistance,
              ),
              SizedBox(height: 10.h),
              _yesNoRow(loc.feetRestingFlat, workstation.feetRestingFlat, loc),
              _yesNoRow(
                loc.monitorDirectlyInFront,
                workstation.monitorDirectlyInFront,
                loc,
              ),
              _yesNoRow(
                loc.chairHasArmrests,
                workstation.chairHasArmrests,
                loc,
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      loc.cpeAssessmentSubtitle,
                      style: TextStyle(fontSize: 13.sp, color: AppColors.text),
                    ),

                    SizedBox(height: 16.h),
                    PatientInfoCardCPE(state: state),
                    SizedBox(height: 20.h),
                    ComplianceCardCPE(state: state),
                    SizedBox(height: 20.h),
                    _deskInfo(deskLocation: state.deskLocation, loc: loc),
                    SizedBox(height: 20.h),
                    PainSymptomsSectionCPE(state: state),
                    SizedBox(height: 20.h),
                    PhotoSectionCPE(state: state),
                    SizedBox(height: 20.h),
                    if (state.workPattern != null)
                      _wordPatternSection(
                        workPattern: state.workPattern!,
                        loc: loc,
                      ),
                    if (state.workPattern != null) SizedBox(height: 20.h),
                    if (state.workstation != null)
                      _workstation(workstation: state.workstation!, loc: loc),
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
