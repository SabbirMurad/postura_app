import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/capture_questionnaire.dart';

/// Multi-select chips for optional symptoms. Skippable.
class OptionalSymptomsScreen extends StatefulWidget {
  const OptionalSymptomsScreen({
    super.key,
    required this.questionnaire,
    required this.onNext,
  });

  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureQuestionnaire) onNext;

  @override
  State<OptionalSymptomsScreen> createState() => _OptionalSymptomsScreenState();
}

class _OptionalSymptomsScreenState extends State<OptionalSymptomsScreen> {
  late Set<OptionalSymptom> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.questionnaire.optionalSymptoms);
  }

  void _toggle(OptionalSymptom symptom) {
    setState(() {
      if (_selected.contains(symptom)) {
        _selected.remove(symptom);
      } else {
        _selected.add(symptom);
      }
    });
  }

  void _next() {
    widget.onNext(widget.questionnaire.copyWith(optionalSymptoms: _selected));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              _StepIndicator(current: 5, total: 5),
              SizedBox(height: 20.h),
              Text(
                'Other Symptoms',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select any additional symptoms you experience. This step is optional.',
                style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: OptionalSymptom.values.map((symptom) {
                      final isSelected = _selected.contains(symptom);
                      return GestureDetector(
                        onTap: () => _toggle(symptom),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                : c.surfaceVariant,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : c.border,
                            ),
                          ),
                          child: Text(
                            symptom.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : c.textSecondary,
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Skip & Start Capture'
                        : 'Start Capture',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        return Expanded(
          child: Container(
            height: 3.h,
            margin: EdgeInsets.only(right: i < total - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGreen : c.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }
}
