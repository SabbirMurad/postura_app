import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/capture_questionnaire.dart';

/// Slider 0-10 for each selected pain region.
class PainIntensityScreen extends StatefulWidget {
  const PainIntensityScreen({
    super.key,
    required this.questionnaire,
    required this.onNext,
  });

  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureQuestionnaire) onNext;

  @override
  State<PainIntensityScreen> createState() => _PainIntensityScreenState();
}

class _PainIntensityScreenState extends State<PainIntensityScreen> {
  late Map<BodyRegion, int> _intensity;

  @override
  void initState() {
    super.initState();
    _intensity = {
      for (final region in widget.questionnaire.painRegions)
        region: widget.questionnaire.painIntensity[region] ?? 3,
    };
  }

  void _next() {
    widget.onNext(widget.questionnaire.copyWith(painIntensity: _intensity));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final regions = widget.questionnaire.painRegions.toList();

    // If no regions selected, skip automatically.
    if (regions.isEmpty) {
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
              _StepIndicator(current: 2, total: 5),
              SizedBox(height: 20.h),
              Text(
                'Pain Intensity',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Rate the pain intensity for each region (0 = none, 10 = worst).',
                style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.separated(
                  itemCount: regions.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, i) {
                    final region = regions[i];
                    final value = _intensity[region] ?? 3;
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: c.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                region.label,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$value / 10',
                                style: TextStyle(
                                  color: _intensityColor(value),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DMMono',
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: value.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            activeColor: _intensityColor(value),
                            inactiveColor: c.border,
                            onChanged: (v) {
                              setState(() {
                                _intensity[region] = v.round();
                              });
                            },
                          ),
                        ],
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

  Color _intensityColor(int value) {
    if (value <= 3) return AppColors.successGreen;
    if (value <= 6) return AppColors.amber;
    return AppColors.error;
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
