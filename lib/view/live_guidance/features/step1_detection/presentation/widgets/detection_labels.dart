import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/detection_result.dart';

/// Top-right corner detection labels — always visible, shows 0% when not detected.
class DetectionLabels extends StatelessWidget {
  const DetectionLabels({super.key, required this.result});

  final DetectionResult? result;

  @override
  Widget build(BuildContext context) {
    final personDetected = result?.personDetected ?? false;
    final monitorDetected = result?.monitorDetected ?? false;
    final personConf = personDetected ? (result?.personConfidence ?? 0) : 0.0;
    final monitorConf = monitorDetected
        ? (result?.monitorConfidence ?? 0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Label(
          label: 'person',
          confidence: personConf,
          detected: personDetected,
          color: AppColors.lightTeal,
        ),
        SizedBox(height: 4.h),
        _Label(
          label: 'monitor',
          confidence: monitorConf,
          detected: monitorDetected,
          color: AppColors.amber,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
    required this.confidence,
    required this.detected,
    required this.color,
  });

  final String label;
  final double confidence;
  final bool detected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final displayColor = detected ? color : color.withValues(alpha: 0.4);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: displayColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: displayColor,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label · ${(confidence * 100).toInt()}%',
            style: TextStyle(
              color: displayColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'DMMono',
            ),
          ),
        ],
      ),
    );
  }
}
