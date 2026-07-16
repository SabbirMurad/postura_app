import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/assessment/workstation_answers.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

/// Pre-camera ROSA checklist covering the items the camera can't see
/// (adjustability, glare, phone use, duration). Writes a [WorkstationAnswers]
/// to the assessment provider, then continues to the optional-symptom step.
///
/// Positive phrasing in the UI ("Chair height is adjustable") is inverted into
/// the ROSA-style negative modifier stored on [WorkstationAnswers].
class WorkstationQuestionnaireScreen extends ConsumerStatefulWidget {
  const WorkstationQuestionnaireScreen({super.key});

  @override
  ConsumerState<WorkstationQuestionnaireScreen> createState() =>
      _WorkstationQuestionnaireScreenState();
}

class _WorkstationQuestionnaireScreenState
    extends ConsumerState<WorkstationQuestionnaireScreen> {
  // Section A — Chair
  bool _chairHeightAdjustable = true;
  bool _enoughUnderDeskSpace = true;
  SeatDepthFit _seatDepthFit = SeatDepthFit.ok;
  bool _seatPanAdjustable = true;
  bool _armrestAdjustable = true;
  bool _armrestHardDamaged = false;
  bool _backrestAdjustable = true;
  bool _workSurfaceTooHigh = false;

  // Section B — Monitor & Telephone
  bool _monitorAdjustable = true;
  bool _neckTwistOver30 = false;
  bool _monitorTooFar = false;
  bool _screenGlare = false;
  bool _hasDocumentHolder = true;
  PhoneUsage _phoneUsage = PhoneUsage.none;
  bool _phoneCradleNeckShoulder = false;
  bool _hasHandsFreeOption = true;

  // Section C — Mouse & Keyboard
  bool _mouseKeyboardDifferentSurfaces = false;
  bool _mousePinchGrip = false;
  bool _mousePalmrest = false;
  bool _mouseAdjustable = true;
  bool _keyboardTooHigh = false;
  bool _reachingOverhead = false;
  bool _keyboardPlatformAdjustable = true;

  // Duration
  DeskDuration _deskDuration = DeskDuration.medium;

  void _continue() {
    ref.read(assessmentNotifierProvider.notifier).setWorkstationAnswers(
      WorkstationAnswers(
        chairHeightNonAdjustable: !_chairHeightAdjustable,
        insufficientUnderDeskSpace: !_enoughUnderDeskSpace,
        seatDepthFit: _seatDepthFit,
        seatPanNonAdjustable: !_seatPanAdjustable,
        armrestNonAdjustable: !_armrestAdjustable,
        armrestHardDamaged: _armrestHardDamaged,
        backrestNonAdjustable: !_backrestAdjustable,
        workSurfaceTooHigh: _workSurfaceTooHigh,
        monitorNonAdjustable: !_monitorAdjustable,
        neckTwistOver30: _neckTwistOver30,
        monitorTooFar: _monitorTooFar,
        screenGlare: _screenGlare,
        noDocumentHolder: !_hasDocumentHolder,
        phoneUsage: _phoneUsage,
        phoneCradleNeckShoulder: _phoneCradleNeckShoulder,
        noHandsFreeOption: !_hasHandsFreeOption,
        mouseKeyboardDifferentSurfaces: _mouseKeyboardDifferentSurfaces,
        mousePinchGrip: _mousePinchGrip,
        mousePalmrest: _mousePalmrest,
        mouseNonAdjustable: !_mouseAdjustable,
        keyboardTooHigh: _keyboardTooHigh,
        reachingOverhead: _reachingOverhead,
        keyboardPlatformNonAdjustable: !_keyboardPlatformAdjustable,
        deskDuration: _deskDuration,
      ),
    );
    context.push(AppRoute.employeeOptionalSymptom);
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
                title: loc.yourWorkstation,
                subtitle: loc.workstationSubtitle,
              ),
              SizedBox(height: 24.h),

              _SectionHeader('Chair'),
              _BoolQuestion(
                'Chair height is adjustable',
                _chairHeightAdjustable,
                (v) => setState(() => _chairHeightAdjustable = v),
              ),
              _BoolQuestion(
                'Enough room under the desk to cross your legs',
                _enoughUnderDeskSpace,
                (v) => setState(() => _enoughUnderDeskSpace = v),
              ),
              _SegmentLabel('Seat pan depth (space behind your knees)'),
              _Segments<SeatDepthFit>(
                segments: const {
                  SeatDepthFit.ok: '~3 in (OK)',
                  SeatDepthFit.tooLong: 'Too long',
                  SeatDepthFit.tooShort: 'Too short',
                },
                selected: _seatDepthFit,
                onChanged: (v) => setState(() => _seatDepthFit = v),
              ),
              _BoolQuestion(
                'Seat pan depth is adjustable',
                _seatPanAdjustable,
                (v) => setState(() => _seatPanAdjustable = v),
              ),
              _BoolQuestion(
                'Armrests are adjustable',
                _armrestAdjustable,
                (v) => setState(() => _armrestAdjustable = v),
              ),
              _BoolQuestion(
                'Armrest surface is hard or damaged',
                _armrestHardDamaged,
                (v) => setState(() => _armrestHardDamaged = v),
              ),
              _BoolQuestion(
                'Backrest is adjustable',
                _backrestAdjustable,
                (v) => setState(() => _backrestAdjustable = v),
              ),
              _BoolQuestion(
                'Desk/work surface is too high (shoulders shrug)',
                _workSurfaceTooHigh,
                (v) => setState(() => _workSurfaceTooHigh = v),
              ),

              _SectionHeader('Monitor & Telephone'),
              _BoolQuestion(
                'Monitor position is adjustable',
                _monitorAdjustable,
                (v) => setState(() => _monitorAdjustable = v),
              ),
              _BoolQuestion(
                'You twist your neck more than 30° to view the monitor',
                _neckTwistOver30,
                (v) => setState(() => _neckTwistOver30 = v),
              ),
              _BoolQuestion(
                'Monitor is farther than arm\'s length away (>75cm)',
                _monitorTooFar,
                (v) => setState(() => _monitorTooFar = v),
              ),
              _BoolQuestion(
                'There is glare on the screen',
                _screenGlare,
                (v) => setState(() => _screenGlare = v),
              ),
              _BoolQuestion(
                'You have a document holder for paper references',
                _hasDocumentHolder,
                (v) => setState(() => _hasDocumentHolder = v),
              ),
              _SegmentLabel('Desk phone usage'),
              _Segments<PhoneUsage>(
                segments: const {
                  PhoneUsage.none: 'Don\'t use',
                  PhoneUsage.headsetOrOneHand: 'Headset/1-hand',
                  PhoneUsage.reachFar: 'Reach far',
                },
                selected: _phoneUsage,
                onChanged: (v) => setState(() => _phoneUsage = v),
              ),
              if (_phoneUsage != PhoneUsage.none) ...[
                _BoolQuestion(
                  'You cradle the phone between ear and shoulder',
                  _phoneCradleNeckShoulder,
                  (v) => setState(() => _phoneCradleNeckShoulder = v),
                ),
                _BoolQuestion(
                  'You have a hands-free option (headset/speakerphone)',
                  _hasHandsFreeOption,
                  (v) => setState(() => _hasHandsFreeOption = v),
                ),
              ],

              _SectionHeader('Mouse & Keyboard'),
              _BoolQuestion(
                'Mouse and keyboard are on different surfaces/heights',
                _mouseKeyboardDifferentSurfaces,
                (v) => setState(() => _mouseKeyboardDifferentSurfaces = v),
              ),
              _BoolQuestion(
                'You use a pinch grip on the mouse',
                _mousePinchGrip,
                (v) => setState(() => _mousePinchGrip = v),
              ),
              _BoolQuestion(
                'There is a palm rest in front of the mouse',
                _mousePalmrest,
                (v) => setState(() => _mousePalmrest = v),
              ),
              _BoolQuestion(
                'Mouse position is adjustable',
                _mouseAdjustable,
                (v) => setState(() => _mouseAdjustable = v),
              ),
              _BoolQuestion(
                'Keyboard is too high (shoulders shrug)',
                _keyboardTooHigh,
                (v) => setState(() => _keyboardTooHigh = v),
              ),
              _BoolQuestion(
                'You frequently reach overhead for items',
                _reachingOverhead,
                (v) => setState(() => _reachingOverhead = v),
              ),
              _BoolQuestion(
                'Keyboard platform/tray is adjustable',
                _keyboardPlatformAdjustable,
                (v) => setState(() => _keyboardPlatformAdjustable = v),
              ),

              _SectionHeader('Daily Duration'),
              _SegmentLabel(
                'How long do you typically work continuously at this desk?',
              ),
              _Segments<DeskDuration>(
                segments: const {
                  DeskDuration.short: '< 30 min',
                  DeskDuration.medium: '30-60 min',
                  DeskDuration.long: '> 1 hour',
                },
                selected: _deskDuration,
                onChanged: (v) => setState(() => _deskDuration = v),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  final String text;
  const _SegmentLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _BoolQuestion extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolQuestion(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeThumbColor: AppColors.primaryColor,
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: AppColors.text),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Segments<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  const _Segments({
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: segments.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.12)
                  : AppColors.onBoardingSurface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.blackDeemed,
                width: 2,
              ),
            ),
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? AppColors.primaryColor : AppColors.text,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
