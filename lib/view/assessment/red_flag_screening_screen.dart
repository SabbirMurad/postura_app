import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

/// Medical red-flag safety screening — 7 yes/no questions collected once per
/// scan, right after Work Ability & Recovery Outlook and before the
/// Workstation checklist. A "Yes" on any item routes the backend exercise
/// engine to stop and recommend clinical assessment instead of generating a
/// session, independent of reported pain intensity (see RedFlagScreening).
class RedFlagScreeningScreen extends ConsumerStatefulWidget {
  const RedFlagScreeningScreen({super.key});

  @override
  ConsumerState<RedFlagScreeningScreen> createState() =>
      _RedFlagScreeningScreenState();
}

class _RedFlagScreeningScreenState
    extends ConsumerState<RedFlagScreeningScreen> {
  bool _newBladderOrBowelDysfunction = false;
  bool _saddleAnaesthesia = false;
  bool _progressiveMotorWeakness = false;
  bool _significantRecentTrauma = false;
  bool _feverOrInfectionOrImmunosuppression = false;
  bool _cancerHistoryWithNewSpinalPain = false;
  bool _severeUnremittingOrNightPain = false;

  void _continue() {
    ref.read(assessmentNotifierProvider.notifier).setRedFlagScreening(
      RedFlagScreening(
        newBladderOrBowelDysfunction: _newBladderOrBowelDysfunction,
        saddleAnaesthesia: _saddleAnaesthesia,
        progressiveMotorWeakness: _progressiveMotorWeakness,
        significantRecentTrauma: _significantRecentTrauma,
        feverOrInfectionOrImmunosuppressionWithBackPain:
            _feverOrInfectionOrImmunosuppression,
        cancerHistoryWithNewSpinalPain: _cancerHistoryWithNewSpinalPain,
        severeUnremittingOrNightPain: _severeUnremittingOrNightPain,
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
                title: 'A Few Safety Questions',
                subtitle:
                    'These help us make sure exercise is a safe option for '
                    'you right now. Answer honestly — a "Yes" just means we '
                    'point you to a healthcare professional instead.',
              ),
              SizedBox(height: 24.h),
              _BoolQuestion(
                'New loss of bladder or bowel control',
                _newBladderOrBowelDysfunction,
                (v) => setState(() => _newBladderOrBowelDysfunction = v),
              ),
              _BoolQuestion(
                'Numbness in the saddle area (inner thighs, groin, or genitals)',
                _saddleAnaesthesia,
                (v) => setState(() => _saddleAnaesthesia = v),
              ),
              _BoolQuestion(
                'New or worsening weakness in your legs or arms',
                _progressiveMotorWeakness,
                (v) => setState(() => _progressiveMotorWeakness = v),
              ),
              _BoolQuestion(
                'A significant recent trauma (e.g. a fall, accident, or blow '
                'to your back)',
                _significantRecentTrauma,
                (v) => setState(() => _significantRecentTrauma = v),
              ),
              _BoolQuestion(
                'Fever, a recent infection, or a weakened immune system '
                'along with back pain',
                _feverOrInfectionOrImmunosuppression,
                (v) => setState(() => _feverOrInfectionOrImmunosuppression = v),
              ),
              _BoolQuestion(
                'A history of cancer, with new or worsening back/spine pain',
                _cancerHistoryWithNewSpinalPain,
                (v) => setState(() => _cancerHistoryWithNewSpinalPain = v),
              ),
              _BoolQuestion(
                "Severe pain that doesn't ease up, especially at night",
                _severeUnremittingOrNightPain,
                (v) => setState(() => _severeUnremittingOrNightPain = v),
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

/// Explicit Yes/No question — mirrors the Workstation checklist's styling.
class _BoolQuestion extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolQuestion(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _YesNoOption(
                  text: 'Yes',
                  selected: value,
                  onTap: () => onChanged(true),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _YesNoOption(
                  text: 'No',
                  selected: !value,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YesNoOption extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _YesNoOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : AppColors.onBoardingSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.blackDeemed,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primaryColor : AppColors.text,
          ),
        ),
      ),
    );
  }
}
