import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/capture_questionnaire.dart';

/// Single-select radio for pain duration.
class PainDurationScreen extends StatefulWidget {
  const PainDurationScreen({
    super.key,
    required this.questionnaire,
    required this.onNext,
  });

  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureQuestionnaire) onNext;

  @override
  State<PainDurationScreen> createState() => _PainDurationScreenState();
}

class _PainDurationScreenState extends State<PainDurationScreen> {
  late PainDuration _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.questionnaire.painDuration;
  }

  void _next() {
    widget.onNext(widget.questionnaire.copyWith(painDuration: _selected));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // If no pain regions, skip this screen.
    if (widget.questionnaire.painRegions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _next());
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              _StepIndicator(current: 3, total: 5),
              SizedBox(height: 20.h),
              Text(
                'Pain Duration',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'How long have you been experiencing this discomfort?',
                style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.separated(
                  itemCount: PainDuration.values.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final duration = PainDuration.values[i];
                    final isSelected = _selected == duration;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = duration),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withValues(alpha: 0.1)
                              : c.surfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : c.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : c.iconMuted,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              duration.label,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                    'Next',
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
