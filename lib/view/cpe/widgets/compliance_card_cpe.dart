import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';
import 'package:posture_detector_app/common/widgets/rosa_sub_score.dart';
import 'package:posture_detector_app/view/business/home/home_screen.dart';

class ComplianceCardCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const ComplianceCardCPE({super.key, required this.state});

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section title

        ],
      ),
    );
  }
}
