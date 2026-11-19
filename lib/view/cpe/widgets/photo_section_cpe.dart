import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class PhotoSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const PhotoSectionCPE({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final front = state.frontCapture;
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.photos),
        SizedBox(height: 10.h),

        // Side-view shots — one card each with its measured angles.
        for (var i = 0; i < state.sideCaptures.length; i++) ...[
          _CaptureCard(
            title: loc.rvwSideViewNumber(i + 1),
            imageUrl: state.sideCaptures[i].image,
            metrics: _sideMetrics(state.sideCaptures[i], loc),
          ),
          SizedBox(height: 12.h),
        ],

        // Front-view shot — image + abduction / wrist-deviation angles.
        if (front != null)
          _CaptureCard(
            title: loc.rvwFrontView,
            imageUrl: front.image,
            metrics: {
              loc.rvwElbowAbduction: front.abductionAngle == null
                  ? loc.rvwNotMeasured
                  : '${front.abductionAngle!.toStringAsFixed(1)}°',
              loc.wristDeviation: front.wristDeviationAngle == null
                  ? loc.rvwNotMeasured
                  : '${front.wristDeviationAngle!.toStringAsFixed(1)}°',
            },
          ),
      ],
    );
  }

  // The labels are only shown (map keys of the chip list, never sent).
  Map<String, String> _sideMetrics(SideCaptureView c, AppLocalizations loc) {
    final a = c.angles;
    return {
      loc.rvwMetricKnee: '${a.kneeAngle.toStringAsFixed(1)}°',
      loc.rvwMetricTrunk: '${a.trunkAngle.toStringAsFixed(1)}°',
      loc.rvwMetricElbow: '${a.elbowAngle.toStringAsFixed(1)}°',
      loc.neck: '${a.neckAngle.toStringAsFixed(1)}°',
      loc.rvwMetricNeckState: a.neckStateLabel,
      loc.rvwMetricLowerBody: a.lowerBodyConfidence,
      loc.rvwMetricMonitorDetected: _yesNo(c.monitorDetected, loc),
      loc.rvwMetricMonitorTopVsEyeLevel:
          _monitorHeight(c.monitorHeightFromPhoto, loc),
    };
  }

  // Older scans were recorded before the check existed.
  String _yesNo(bool? v, AppLocalizations loc) =>
      v == null ? '—' : (v ? loc.yes : loc.rvwNo);

  // Same wording as the questionnaire's answers; the 'below' / 'at' /
  // 'above' values themselves stay as they are.
  String _monitorHeight(String? v, AppLocalizations loc) => switch (v) {
    'below' => loc.rvwMonitorBelow,
    'at' => loc.rvwMonitorAtEyeLevel,
    'above' => loc.rvwMonitorAbove,
    _ => '—',
  };
}

class _CaptureCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Map<String, String> metrics;

  const _CaptureCard({
    required this.title,
    required this.imageUrl,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            // Scan captures are served token-gated (used_at = Capture); send the
            // bearer token or the request 404s and only the errorWidget shows.
            httpHeaders: AppHelper.authHeaders,
            width: double.infinity,
            height: 350.h,
            fit: BoxFit.cover,
            placeholder: (_, __) => SizedBox(
              height: 350.h,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 350.h,
              color: const Color(0xFFEEEEEE),
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 28.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: metrics.entries
              .where((e) => e.value.isNotEmpty)
              .map((e) => _MetricChip(label: e.key, value: e.value))
              .toList(),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF475467)),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
