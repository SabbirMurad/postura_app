import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/capture_questionnaire.dart';

/// Multi-select chips for pain body regions.
class BodyRegionsScreen extends StatefulWidget {
  const BodyRegionsScreen({
    super.key,
    required this.questionnaire,
    required this.onNext,
  });

  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureQuestionnaire) onNext;

  @override
  State<BodyRegionsScreen> createState() => _BodyRegionsScreenState();
}

class _BodyRegionsScreenState extends State<BodyRegionsScreen> {
  late Set<BodyRegion> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.questionnaire.painRegions);
  }

  void _toggle(BodyRegion region) {
    setState(() {
      if (_selected.contains(region)) {
        _selected.remove(region);
      } else {
        _selected.add(region);
      }
    });
  }

  void _next() {
    widget.onNext(widget.questionnaire.copyWith(painRegions: _selected));
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
              _StepIndicator(current: 1, total: 5),
              SizedBox(height: 20.h),
              Text(
                'Pain Regions',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select any body regions where you experience discomfort.',
                style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: BodyRegion.values.map((region) {
                      final isSelected = _selected.contains(region);
                      return GestureDetector(
                        onTap: () => _toggle(region),
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
                            region.label,
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
                    _selected.isEmpty ? 'Skip' : 'Next',
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
