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
                1,
                'New loss of bladder or bowel control',
                _newBladderOrBowelDysfunction,
                (v) => setState(() => _newBladderOrBowelDysfunction = v),
              ),
              _BoolQuestion(
                2,
                'Numbness in the saddle area (inner thighs, groin, or genitals)',
                _saddleAnaesthesia,
                (v) => setState(() => _saddleAnaesthesia = v),
              ),
              _BoolQuestion(
                3,
                'New or worsening weakness in your legs or arms',
                _progressiveMotorWeakness,
                (v) => setState(() => _progressiveMotorWeakness = v),
              ),
              _BoolQuestion(
                4,
                'A significant recent trauma (e.g. a fall, accident, or blow '
                'to your back)',
                _significantRecentTrauma,
                (v) => setState(() => _significantRecentTrauma = v),
              ),
              _BoolQuestion(
                5,
                'Fever, a recent infection, or a weakened immune system '
                'along with back pain',
                _feverOrInfectionOrImmunosuppression,
                (v) => setState(() => _feverOrInfectionOrImmunosuppression = v),
              ),
              _BoolQuestion(
                6,
                'A history of cancer, with new or worsening back/spine pain',
                _cancerHistoryWithNewSpinalPain,
                (v) => setState(() => _cancerHistoryWithNewSpinalPain = v),
              ),
              _BoolQuestion(
                7,
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

/// Numbered yes/no question — the two answers are pill chips, matching the
/// chip pickers used elsewhere in the assessment flow.
class _BoolQuestion extends StatelessWidget {
  final int number;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolQuestion(this.number, this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22.w,
                child: Text(
                  '$number.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.text),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 22.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: [
                GestureDetector(
                  onTap: () => onChanged(true),
                  child: SelectionChip(title: 'Yes', selected: value),
                ),
                GestureDetector(
                  onTap: () => onChanged(false),
                  child: SelectionChip(title: 'No', selected: !value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
