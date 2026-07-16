import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class PhotoSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const PhotoSectionCPE({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final front = state.frontCapture;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context)!.photos),
        SizedBox(height: 10.h),

        // Side-view shots — one card each with its measured angles.
        for (var i = 0; i < state.sideCaptures.length; i++) ...[
          _CaptureCard(
            title: 'Side view ${i + 1}',
            imageUrl: state.sideCaptures[i].image,
            metrics: _sideMetrics(state.sideCaptures[i]),
          ),
          SizedBox(height: 12.h),
        ],

        // Front-view shot — image + abduction / wrist-deviation angles.
        if (front != null)
          _CaptureCard(
            title: 'Front view',
            imageUrl: front.image,
            metrics: {
              'Elbow abduction': '${front.abductionAngle.toStringAsFixed(1)}°',
              'Wrist deviation': '${front.wristDeviationAngle.toStringAsFixed(1)}°',
            },
          ),
      ],
    );
  }

  Map<String, String> _sideMetrics(SideCaptureView c) {
    final a = c.angles;
    return {
      'Knee': '${a.kneeAngle.toStringAsFixed(1)}°',
      'Trunk': '${a.trunkAngle.toStringAsFixed(1)}°',
      'Elbow': '${a.elbowAngle.toStringAsFixed(1)}°',
      'Neck': '${a.neckAngle.toStringAsFixed(1)}°',
      'Neck state': a.neckStateLabel,
      'Lower body': a.lowerBodyConfidence,
    };
  }
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
