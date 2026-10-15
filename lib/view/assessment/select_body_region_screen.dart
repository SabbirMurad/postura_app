import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/common/widgets/height_input_field.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/selection_chip.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';

class SelectBodyRegionScreen extends ConsumerStatefulWidget {
  const SelectBodyRegionScreen({super.key});

  @override
  ConsumerState<SelectBodyRegionScreen> createState() =>
      _SelectBodyRegionScreenState();
}

class _SelectBodyRegionScreenState
    extends ConsumerState<SelectBodyRegionScreen> {
  /// True when no height is known yet — the first scan after sign-up (or after
  /// an app restart) lands here directly, skipping the Scan tab that normally
  /// asks for it. Coming from the Scan tab, height is already set (and reset()
  /// below carries it over), so it isn't asked twice.
  late final bool _askHeight;
  double? _heightCm;

  @override
  void initState() {
    super.initState();
    _heightCm = ref.read(assessmentNotifierProvider).scanSupplemental.heightCm;
    _askHeight = _heightCm == null || _heightCm! <= 0;
    // First screen of a new scan: clear anything left from a previous
    // assessment. The notifier is keepAlive, so without this the old pain
    // selections and captured photos persist and the review screen shows the
    // earlier scan's images. Deferred to post-frame — a provider can't be
    // mutated while the widget tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assessmentNotifierProvider.notifier).reset();
    });
  }

  void _onContinue() {
    final loc = AppLocalizations.of(context)!;
    if (_askHeight) {
      final h = _heightCm;
      if (h == null || h <= 0) {
        showCustomToast(text: 'Please enter your height');
        return;
      }
      if (h < 50 || h > 250) {
        showCustomToast(text: 'Height must be between 50 and 250 cm');
        return;
      }
    }
    if (ref.read(assessmentNotifierProvider).selectedBodyRegions.isEmpty) {
      // EN: "Please select a body region"
      showCustomToast(text: loc.pleaseSelectBodyRegion);
      return;
    }
    if (_askHeight) {
      ref.read(assessmentNotifierProvider.notifier).setHeightCm(_heightCm!);
    }
    context.push(AppRoute.employeePainIntensityScreen);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final assessment = ref.watch(assessmentNotifierProvider);

    final allBodyRegions = AssessmentState.allPainRegions;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // Scrollable so the keyboard (height field) can't overflow the page;
      // IntrinsicHeight keeps the Spacer pinning the button to the bottom.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // EN: "Body Region"
                    AppTopSection(
                      title: loc.bodyRegionTitle,
                      subtitle: AppText.bodyRegionSubtitle,
                    ),
                    if (_askHeight) ...[
                      SizedBox(height: 32.h),
                      HeightInputField(
                        initialHeightCm: _heightCm,
                        onChanged: (cm) => _heightCm = cm,
                      ),
                      SizedBox(height: 32.h),
                    ] else
                      SizedBox(height: 52.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: allBodyRegions.toList().map((region) {
                        final isSelected = assessment.selectedBodyRegions
                            .contains(region);
                        return GestureDetector(
                          onTap: () => ref
                              .read(assessmentNotifierProvider.notifier)
                              .toggleRegion(region),
                          child: SelectionChip(
                            title: region.label,
                            selected: isSelected,
                          ),
                        );
                      }).toList(),
                    ),
                    Spacer(),
                    SizedBox(height: 24.h),
                    SafeArea(
                      top: false,
                      child: PrimaryButton(
                        margin: EdgeInsets.only(bottom: 20.h),
                        onTap: _onContinue,
                        // EN: "Continue"
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
