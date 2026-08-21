import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/selection_chip.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

/// "Work Ability & Recovery Outlook" — yellow-flag / chronicity risk screen.
/// Sits after Pain Intensity + Pain Duration, before the Workstation checklist.
/// The 8 answers here let the backend compute a simple Chronicity Level
/// (Low / Elevated); see Postura_Yellow_Flag_Chronicity_Implementation.pdf.
class WorkAbilityRecoveryOutlookScreen extends ConsumerStatefulWidget {
  const WorkAbilityRecoveryOutlookScreen({super.key});

  @override
  ConsumerState<WorkAbilityRecoveryOutlookScreen> createState() =>
      _WorkAbilityRecoveryOutlookScreenState();
}

class _WorkAbilityRecoveryOutlookScreenState
    extends ConsumerState<WorkAbilityRecoveryOutlookScreen> {
  int _chronicityRisk = 0;
  int _rtwExpectancy = 0;
  int _fearAvoidance = 0;
  int _lightWorkCapacity = 0;
  int _sleepInterference = 0;
  int _presenteeism = 0;
  PreviousAbsence _previousAbsence = PreviousAbsence.zero;
  int _workplaceSupport = 0;

  void _continue() {
    ref.read(assessmentNotifierProvider.notifier).setYellowFlagAnswers(
      YellowFlagAnswers(
        chronicityRisk: _chronicityRisk,
        rtwExpectancy: _rtwExpectancy,
        fearAvoidance: _fearAvoidance,
        lightWorkCapacity: _lightWorkCapacity,
        sleepInterference: _sleepInterference,
        presenteeism: _presenteeism,
        previousAbsence: _previousAbsence,
        workplaceSupport: _workplaceSupport,
      ),
    );
    context.push(AppRoute.workstationQuestionnaire);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ListView(
            padding: EdgeInsets.only(top: 12.h, bottom: 96.h),
            children: [
              AppTopSection(
                title: loc.workAbilityRecoveryOutlook,
                subtitle: loc.workAbilityRecoveryOutlookSubtitle,
              ),
              SizedBox(height: 24.h),

              _SliderQuestion(
                label:
                    'How large is the risk that your current pain may become '
                    'persistent or long-term?',
                lowLabel: 'No risk',
                highLabel: 'Very large risk',
                value: _chronicityRisk,
                onChanged: (v) => setState(() => _chronicityRisk = v),
              ),
              _SliderQuestion(
                label:
                    'What are the chances you will be working your normal '
                    'duties in 3 months?',
                lowLabel: 'No chance',
                highLabel: 'Very large chance',
                value: _rtwExpectancy,
                onChanged: (v) => setState(() => _rtwExpectancy = v),
              ),
              _SliderQuestion(
                label:
                    'An increase in pain is an indication that I should stop '
                    'what I am doing until the pain decreases.',
                lowLabel: 'Completely disagree',
                highLabel: 'Completely agree',
                value: _fearAvoidance,
                onChanged: (v) => setState(() => _fearAvoidance = v),
              ),
              _SliderQuestion(
                label: 'I can do light work (or normal light duties) for an hour.',
                lowLabel: 'Cannot do it because of the pain',
                highLabel: 'Can do it without the pain being a problem',
                value: _lightWorkCapacity,
                onChanged: (v) => setState(() => _lightWorkCapacity = v),
              ),
              _SliderQuestion(
                label: 'I can sleep at night.',
                lowLabel: 'Cannot do it because of the pain',
                highLabel: 'Can do it without the pain being a problem',
                value: _sleepInterference,
                onChanged: (v) => setState(() => _sleepInterference = v),
              ),
              _SliderQuestion(
                label:
                    'How much has your pain reduced your productivity or '
                    'ability to work at full capacity in the past week?',
                lowLabel: 'Not at all',
                highLabel: 'Extremely (unable to work normally)',
                value: _presenteeism,
                onChanged: (v) => setState(() => _presenteeism = v),
              ),

              SizedBox(height: 4.h),
              Text(
                'In the last 12 months, how many work days have you missed '
                'because of similar pain or musculoskeletal problems?',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.w,
                children: PreviousAbsence.values.map((option) {
                  return GestureDetector(
                    onTap: () => setState(() => _previousAbsence = option),
                    child: SelectionChip(
                      title: option.label,
                      selected: _previousAbsence == option,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 22.h),

              _SliderQuestion(
                label:
                    'I feel I can get support or make reasonable adjustments '
                    'at work if needed because of this pain.',
                lowLabel: 'Strongly disagree',
                highLabel: 'Strongly agree',
                value: _workplaceSupport,
                onChanged: (v) => setState(() => _workplaceSupport = v),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: PrimaryButton(
            onTap: _continue,
            text: loc.continueButton,
            backgroundColor: AppColors.primaryColor,
            textStyle: TextStyle(
              color: AppColors.surface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

/// One 0-10 slider question: label, low/high end captions, and a live value
/// badge — mirrors the Pain Intensity screen's slider styling.
class _SliderQuestion extends StatelessWidget {
  final String label;
  final String lowLabel;
  final String highLabel;
  final int value;
  final ValueChanged<int> onChanged;

  const _SliderQuestion({
    required this.label,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$value / 10',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.primaryColor,
            inactiveColor: AppColors.border,
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lowLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                highLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
