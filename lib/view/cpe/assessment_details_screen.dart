import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/recovery_outlook_banner.dart';
import 'package:posture_detector_app/common/widgets/rosa_sub_score.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/home/home_screen.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';
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

  /// Employee height — context for chair/monitor recommendations. Never
  /// affects ROSA scoring; shown for the ergonomist's reference only.
  Widget _heightInfo(double? heightCm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Height'),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.height, size: 16.w, color: const Color(0xFF0078B5)),
            SizedBox(width: 4.w),
            Text(
              heightCm != null ? '${heightCm.round()} cm' : 'Not provided',
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

  // ── Score → RosaRisk ─────────────────────────────────────────────────────

  RosaRisk _subScoreRisk(int score) {
    if (score >= 3) return RosaRisk.red;
    if (score >= 2) return RosaRisk.orange;
    return RosaRisk.green;
  }

  RosaRisk _finalScoreRisk(int score) {
    if (score >= 7) return RosaRisk.red;
    if (score >= 4) return RosaRisk.orange;
    return RosaRisk.green;
  }

  // ── Score → label ─────────────────────────────────────────────────────────

  String _subScoreLabel(int score) {
    if (score == 0) return 'Not assessed';
    if (score >= 3) return 'High risk';
    if (score >= 2) return 'Review needed';
    return 'Optimal';
  }

  String _finalLabel(int score) {
    if (score >= 7) return 'High risk — immediate action required';
    if (score >= 4) return 'Moderate risk — further investigation';
    return 'Low risk — no immediate action needed';
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Level 3 — Action required as soon as possible';
    if (score >= 4) return 'Level 2 — Further investigation needed';
    return 'Level 1 — No immediate action needed';
  }

  Color _riskColor(RosaRisk risk) {
    switch (risk) {
      case RosaRisk.red:
        return const Color(0xFFE53935);
      case RosaRisk.orange:
        return const Color(0xFFFB8C00);
      case RosaRisk.green:
        return const Color(0xFF43A047);
    }
  }

  // ── Sub-score items ───────────────────────────────────────────────────────

  List<RosaItem> _buildRosaItems(RosaScore score) => [
    RosaItem(
      category: 'Seat Height',
      score: '${score.seatHeightScore}',
      status: RosaStatus(
        _subScoreLabel(score.seatHeightScore),
        _subScoreRisk(score.seatHeightScore),
      ),
    ),
    RosaItem(
      category: 'Backrest',
      score: '${score.backrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.backrestScore),
        _subScoreRisk(score.backrestScore),
      ),
    ),
    RosaItem(
      category: 'Armrest',
      score: '${score.armrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.armrestScore),
        _subScoreRisk(score.armrestScore),
      ),
    ),
    RosaItem(
      category: 'Chair',
      score: '${score.chairScore}',
      status: RosaStatus(
        _subScoreLabel(score.chairScore),
        _subScoreRisk(score.chairScore),
      ),
    ),
    RosaItem(
      category: 'Monitor',
      score: '${score.monitorScore}',
      status: RosaStatus(
        _subScoreLabel(score.monitorScore),
        _subScoreRisk(score.monitorScore),
      ),
    ),
    RosaItem(
      category: 'Keyboard',
      score: '${score.keyboardScore}',
      status: RosaStatus(
        _subScoreLabel(score.keyboardScore),
        _subScoreRisk(score.keyboardScore),
      ),
    ),
    RosaItem(
      category: 'Mouse',
      score: '${score.mouseScore}',
      status: RosaStatus(
        _subScoreLabel(score.mouseScore),
        _subScoreRisk(score.mouseScore),
      ),
    ),
    RosaItem(
      category: 'Peripheral',
      score: '${score.peripheralScore}',
      status: RosaStatus(
        _subScoreLabel(score.peripheralScore),
        _subScoreRisk(score.peripheralScore),
      ),
    ),
  ];

  Widget _rosaAssessmentSection(RosaScore score) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.w,
      children: _buildRosaItems(
        score,
      ).map((item) => RosaSubScoreItem(item: item)).toList(),
    );
  }

  List<Widget> _mainRosaScores({
    required CpeAssessmentState state,
    required AppLocalizations loc,
  }) {
    final finalRisk = _finalScoreRisk(state.rosaScore.finalScore);
    final scoreColor = _riskColor(finalRisk);

    return [
      Text(
        loc.rosaErgonomicAnalysis,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF202020),
        ),
      ),
      SizedBox(height: 12.h),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/rosa/final_rosa.svg',
                  width: 40.w,
                  height: 40.w,
                ),
                SizedBox(height: 6.w),
                Text(
                  '${state.rosaScore.finalScore} / 10',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _finalLabel(state.rosaScore.finalScore),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _actionLevel(state.rosaScore.finalScore),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final scanId = (args?['scan_id'] ?? 0) as int;
    final state = ref.watch(cpeAssessmentNotifierProvider(scanId));
    final notifier = ref.read(cpeAssessmentNotifierProvider(scanId).notifier);
    final loc = AppLocalizations.of(context)!;

    if (state == null || state.isLoading) {
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
                padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                    if (state.chronicityElevated) ...[
                      SizedBox(height: 12.h),
                      const RecoveryOutlookBanner(compact: true),
                    ],
                    SizedBox(height: 20.h),
                    ..._mainRosaScores(state: state, loc: loc),
                    SizedBox(height: 20.h),
                    _rosaAssessmentSection(state.rosaScore),
                    SizedBox(height: 20.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _deskInfo(
                            deskLocation: state.deskLocation,
                            loc: loc,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(child: _heightInfo(state.heightCm)),
                      ],
                    ),
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
