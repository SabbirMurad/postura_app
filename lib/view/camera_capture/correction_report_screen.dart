import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/report.dart';

import 'package:posture_detector_app/common/widgets/bottom_button.dart';
import 'package:posture_detector_app/common/widgets/expansion_container.dart';

/// Renders the deterministic Action Report v1.3 (fixed-copy priority findings,
/// supplemental CPE findings, and equipment handoff) when the backend has
/// computed one. Falls back to the older AI-generated `corrections` list only
/// for scans that predate the v1.3 rollout (no action_report_v1_3 present).
class CorrectionReportScreenBusiness extends ConsumerWidget {
  const CorrectionReportScreenBusiness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportNotifierProvider);
    final loc = AppLocalizations.of(context)!;
    final report = reportState.analysisReport?.actionReportV13;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                AppTopSection(
                  title: 'ROSA Posture Guidance',
                  subtitle:
                      'Directional adjustments to improve your ergonomic setup',
                ),
                SizedBox(height: 14.h),
                if (report != null)
                  ..._buildActionReport(context, report)
                else
                  _LegacyCorrections(
                    corrections: reportState.analysisReport?.corrections,
                  ),
                SizedBox(height: 90.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
          child: BottomButton(
            title: loc.viewExercise,
            onTap: () {
              context.push(AppRoute.exerciseBusiness);
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionReport(BuildContext context, ActionReportV13 report) {
    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.onBoardingSurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tier ${report.tierNumber} - ${report.tierName} | ROSA ${report.rosaScore}/10',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Main risk driver: ${report.mainRiskDriver}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
            ),
            SizedBox(height: 10.h),
            Text(
              report.executiveSummary,
              style: TextStyle(fontSize: 13.sp, color: AppColors.text),
            ),
          ],
        ),
      ),
      SizedBox(height: 18.h),

      if (report.priorityFindings.isNotEmpty) ...[
        _SectionHeading('Priority Findings'),
        SizedBox(height: 4.h),
        Text(
          report.priorityFindingsIntro,
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
        ),
        SizedBox(height: 10.h),
        ...report.priorityFindings.map(
          (f) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ExpansionContainer(
              title: f.employeeLabel,
              leading: '',
              content: _findingContent(f),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],

      if (report.supplementalCpeFindings.isNotEmpty) ...[
        _SectionHeading('Supplemental CPE Findings'),
        if (report.supplementalCpeIntro != null) ...[
          SizedBox(height: 4.h),
          Text(
            report.supplementalCpeIntro!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
          ),
        ],
        SizedBox(height: 10.h),
        ...report.supplementalCpeFindings.map(
          (f) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ExpansionContainer(
              title: f.employeeLabel,
              leading: '',
              content: _findingContent(f),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],

      if (report.whatYouCanDoNow.isNotEmpty) ...[
        _SectionHeading('What You Can Do Right Now'),
        SizedBox(height: 8.h),
        ...report.whatYouCanDoNow.map(
          (a) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    a,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],

      if (report.equipmentHelpsText != null) ...[
        _SectionHeading('When Equipment Helps'),
        SizedBox(height: 6.h),
        Text(
          report.equipmentHelpsText!,
          style: TextStyle(fontSize: 13.sp, color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => context.push(AppRoute.equipmentScreenBusiness),
          child: Text(
            'View Equipment Recommendations',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],

      _SectionHeading('General Workstation Habits'),
      SizedBox(height: 6.h),
      Text(
        report.generalWorkstationHabits,
        style: TextStyle(fontSize: 13.sp, color: AppColors.text),
      ),

      if (report.professionalReviewLine != null) ...[
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: Text(
            report.professionalReviewLine!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.text),
          ),
        ),
      ],
    ];
  }

  String _findingContent(FindingV13 f) {
    final buffer = StringBuffer(f.actionNow);
    if (f.isoExplanation.isNotEmpty) {
      buffer.write('\n\n${f.isoExplanation}');
    }
    if (f.equipmentHandoff && f.equipmentHandoffText != null) {
      buffer.write('\n\n${f.equipmentHandoffText}');
    }
    return buffer.toString();
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _LegacyCorrections extends StatelessWidget {
  final List<Correction>? corrections;
  const _LegacyCorrections({required this.corrections});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(corrections?.length ?? 0, (index) {
        final correctReport = corrections?[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ExpansionContainer(
            title: correctReport?.title ?? 'title',
            leading: '',
            content: correctReport?.description ?? 'description',
          ),
        );
      }),
    );
  }
}
