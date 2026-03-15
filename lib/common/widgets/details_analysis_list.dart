import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/details_analysis_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';

class DetailsAnalysisList extends StatelessWidget {
  final Posture posture;
  const DetailsAnalysisList({super.key, required this.posture});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final items = [
      _DetailItem(
        severity: posture.neckFlexion.severity,
        title: loc.neckFlexion,
        iso: posture.neckFlexion.iso,
        angle: posture.neckFlexion.angle,
      ),
      _DetailItem(
        severity: posture.shoulderElevation.severity,
        title: loc.shoulderElevation,
        iso: posture.shoulderElevation.iso,
        angle: posture.shoulderElevation.angle,
      ),
      _DetailItem(
        severity: posture.elbowAngle.severity,
        title: loc.elbowAngle,
        iso: posture.elbowAngle.iso,
        angle: posture.elbowAngle.deviation,
      ),
      _DetailItem(
        severity: posture.wristDeviation.severity,
        title: loc.wristDeviation,
        iso: posture.wristDeviation.iso,
        angle: posture.wristDeviation.deviation,
      ),
      _DetailItem(
        severity: posture.pelvicTilt.severity,
        title: loc.pelvicTilt,
        iso: posture.pelvicTilt.iso,
        angle: posture.pelvicTilt.deviation,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildContainer(items[i]),
          if (i < items.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildContainer(_DetailItem item) {
    final iconPath = item.severity == 'red'
        ? Assets.icons.status.wrongAlert.path
        : item.severity == 'green'
            ? Assets.icons.status.rightGuard.path
            : Assets.icons.status.alertLine.path;

    final bgColor = item.severity == 'red'
        ? AppColors.red
        : item.severity == 'green'
            ? AppColors.green
            : AppColors.warning;

    return DetailsAnalysisContainer(
      path: iconPath,
      iconBgColor: bgColor,
      title: item.title,
      subTitle: item.iso,
      comment: '${item.angle.toStringAsFixed(2)} deviation',
      commentColor: item.severity,
    );
  }
}

class _DetailItem {
  final String severity;
  final String title;
  final String iso;
  final double angle;

  _DetailItem({
    required this.severity,
    required this.title,
    required this.iso,
    required this.angle,
  });
}
