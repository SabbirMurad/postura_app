import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/capture_questionnaire.dart';

/// Three dropdowns: hours at desk, break interval, device usage.
class WorkPatternScreen extends StatefulWidget {
  const WorkPatternScreen({
    super.key,
    required this.questionnaire,
    required this.onNext,
  });

  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureQuestionnaire) onNext;

  @override
  State<WorkPatternScreen> createState() => _WorkPatternScreenState();
}

class _WorkPatternScreenState extends State<WorkPatternScreen> {
  late int _hours;
  late int _breakInterval;
  late DeviceUsage _device;

  @override
  void initState() {
    super.initState();
    _hours = widget.questionnaire.hoursAtDesk;
    _breakInterval = widget.questionnaire.breakIntervalHrs;
    _device = widget.questionnaire.deviceUsage;
  }

  void _next() {
    widget.onNext(
      widget.questionnaire.copyWith(
        hoursAtDesk: _hours,
        breakIntervalHrs: _breakInterval,
        deviceUsage: _device,
      ),
    );
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
              _StepIndicator(current: 4, total: 5),
              SizedBox(height: 20.h),
              Text(
                'Work Pattern',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'These affect your ROSA risk score calculation.',
                style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DropdownField<int>(
                        label: 'Hours at desk per day',
                        value: _hours,
                        items: const [0, 2, 4, 6, 8],
                        labelBuilder: (v) => v == 8 ? '8+ hours' : '$v hours',
                        onChanged: (v) => setState(() => _hours = v),
                        colors: c,
                      ),
                      SizedBox(height: 20.h),
                      _DropdownField<int>(
                        label: 'Break interval',
                        value: _breakInterval,
                        items: const [1, 2, 3, 4],
                        labelBuilder: (v) => v == 4
                            ? '4+ hours'
                            : 'Every $v hour${v > 1 ? 's' : ''}',
                        onChanged: (v) => setState(() => _breakInterval = v),
                        colors: c,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Device setup',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...DeviceUsage.values.map((device) {
                        final isSelected = _device == device;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: GestureDetector(
                            onTap: () => setState(() => _device = device),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withValues(
                                        alpha: 0.1,
                                      )
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
                                    device.label,
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
                          ),
                        );
                      }),
                    ],
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

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.colors,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surface,
              style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
              icon: Icon(Icons.keyboard_arrow_down, color: colors.iconMuted),
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(labelBuilder(item)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
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
