import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/rosa_sub_score.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/utils/media.dart' as media;
import 'package:posture_detector_app/view/home/home_screen.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  // ── Risk helpers ─────────────────────────────────────────────────────────

  RosaRisk _subScoreRisk(int score) {
    if (score >= 3) return RosaRisk.red;
    if (score >= 2) return RosaRisk.orange;
    return RosaRisk.green;
  }

  RosaRisk _finalScoreRisk(int score) {
    if (score >= 7) return RosaRisk.red;
    if (score >= 4) return RosaRisk.orange;
    return RosaRisk.green;
  }

  String _subScoreLabel(int score) {
    if (score == 0) return 'Not assessed';
    if (score >= 3) return 'High risk';
    if (score >= 2) return 'Review needed';
    return 'Optimal';
  }

  String _finalLabel(int score) {
    if (score >= 7) return 'High risk — immediate action required';
    if (score >= 4) return 'Moderate risk — further investigation';
    return 'Low risk — no immediate action needed';
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Level 3 — Action required as soon as possible';
    if (score >= 4) return 'Level 2 — Further investigation needed';
    return 'Level 1 — No immediate action needed';
  }

  Color _riskColor(RosaRisk risk) {
    switch (risk) {
      case RosaRisk.red:
        return const Color(0xFFE53935);
      case RosaRisk.orange:
        return const Color(0xFFFB8C00);
      case RosaRisk.green:
        return const Color(0xFF43A047);
    }
  }

  // ── Sub-score items ───────────────────────────────────────────────────────

  List<RosaItem> _buildRosaItems(RosaScore score) => [
    RosaItem(
      category: 'Seat Height',
      score: '${score.seatHeightScore}',
      status: RosaStatus(
        _subScoreLabel(score.seatHeightScore),
        _subScoreRisk(score.seatHeightScore),
      ),
    ),
    RosaItem(
      category: 'Backrest',
      score: '${score.backrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.backrestScore),
        _subScoreRisk(score.backrestScore),
      ),
    ),
    RosaItem(
      category: 'Armrest',
      score: '${score.armrestScore}',
      status: RosaStatus(
        _subScoreLabel(score.armrestScore),
        _subScoreRisk(score.armrestScore),
      ),
    ),
    RosaItem(
      category: 'Chair',
      score: '${score.chairScore}',
      status: RosaStatus(
        _subScoreLabel(score.chairScore),
        _subScoreRisk(score.chairScore),
      ),
    ),
    RosaItem(
      category: 'Monitor',
      score: '${score.monitorScore}',
      status: RosaStatus(
        _subScoreLabel(score.monitorScore),
        _subScoreRisk(score.monitorScore),
      ),
    ),
    RosaItem(
      category: 'Keyboard',
      score: '${score.keyboardScore}',
      status: RosaStatus(
        _subScoreLabel(score.keyboardScore),
        _subScoreRisk(score.keyboardScore),
      ),
    ),
    RosaItem(
      category: 'Mouse',
      score: '${score.mouseScore}',
      status: RosaStatus(
        _subScoreLabel(score.mouseScore),
        _subScoreRisk(score.mouseScore),
      ),
    ),
    RosaItem(
      category: 'Peripheral',
      score: '${score.peripheralScore}',
      status: RosaStatus(
        _subScoreLabel(score.peripheralScore),
        _subScoreRisk(score.peripheralScore),
      ),
    ),
  ];

  Widget _rosaAssessmentSection(RosaScore score) {
    final items = _buildRosaItems(score);
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: items.map((item) => RosaSubScoreItem(item: item)).toList(),
    );
  }

  List<Widget> _mainRosaScores({
    required RosaScore score,
    required AppLocalizations loc,
  }) {
    final finalRisk = _finalScoreRisk(score.finalScore);
    final scoreColor = _riskColor(finalRisk);

    return [
      Text(
        loc.rosaErgonomicAnalysis,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF202020),
        ),
      ),
      SizedBox(height: 12.h),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/rosa/final_rosa.svg',
                  width: 40.w,
                  height: 40.w,
                ),
                SizedBox(height: 6.w),
                Text(
                  '${score.finalScore} / 10',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _finalLabel(score.finalScore),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _actionLevel(score.finalScore),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _retake() {
    // The capture guide sits directly beneath this preview; returning to it lets
    // the user run the native capture again (which overwrites the stored shots).
    Navigator.of(context).pop();
  }

  void _submitResult() async {
    setState(() {
      _submitting = true;
    });

    final ok = await ref
        .read(assessmentNotifierProvider.notifier)
        .submitAnalysis(ScanType.primaryScan);

    setState(() {
      _submitting = false;
    });

    if (!ok) return;
    AppRoute.push(AppRoute.correctionReportScreenBusiness);
  }

  bool _submitting = false;

  /// One card per captured shot: the photo plus its measured angles. Side shots
  /// come first (numbered), then the single front-view shot.
  List<Widget> _capturesSection(AssessmentState state) {
    // Flat list of every capture image (side shots, then front) so tapping any
    // one opens a swipeable full-screen gallery at that image.
    final gallery = <ImageProvider>[
      ...state.sideCaptures.map((c) => FileImage(c.image)),
      if (state.frontCapture != null) FileImage(state.frontCapture!.image),
    ];

    final cards = <Widget>[];
    var galleryIndex = 0;
    for (var i = 0; i < state.sideCaptures.length; i++) {
      final c = state.sideCaptures[i];
      final a = c.bodyAngles;
      cards.add(
        _captureCard(
          title: 'Side view ${i + 1}',
          image: c.image,
          gallery: gallery,
          galleryIndex: galleryIndex++,
          metrics: {
            'Knee': '${a.kneeAngle.toStringAsFixed(1)}°',
            'Trunk': '${a.trunkAngle.toStringAsFixed(1)}°',
            'Elbow': '${a.elbowAngle.toStringAsFixed(1)}°',
            'Neck': '${a.neckAngle.toStringAsFixed(1)}°',
            'Neck state': a.neckStateLabel,
            'Lower body confidence': a.lowerBodyConfidence,
          },
        ),
      );
    }
    final front = state.frontCapture;
    if (front != null) {
      cards.add(
        _captureCard(
          title: 'Front view',
          image: front.image,
          gallery: gallery,
          galleryIndex: galleryIndex++,
          metrics: {
            'Elbow abduction': '${front.abductionAngle.toStringAsFixed(1)}°',
            'Wrist deviation':
                '${front.wristDeviationAngle.toStringAsFixed(1)}°',
          },
        ),
      );
    }
    return cards;
  }

  Widget _captureCard({
    required String title,
    required File image,
    required List<ImageProvider> gallery,
    required int galleryIndex,
    required Map<String, String> metrics,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => media.open_image_viewer(
                  context: context,
                  images: gallery,
                  initial_index: galleryIndex,
                  show_counter: true,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    image,
                    width: 130.w,
                    height: 170.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: metrics.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => _metricChip(e.key, e.value))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE4E7EC)),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final rosaScore = ref.watch(
      assessmentNotifierProvider.select((s) => s.rosaScore),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              ..._mainRosaScores(score: rosaScore!, loc: loc),
              SizedBox(height: 20.h),
              Text(
                loc.rosaSubScores,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),
              SizedBox(height: 12.h),
              _rosaAssessmentSection(rosaScore),
              SizedBox(height: 20.h),
              ..._capturesSection(ref.watch(assessmentNotifierProvider)),
              SizedBox(height: 48.h),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Retake',
                      onTap: _retake,
                      backgroundColor: Colors.grey[300],
                      textStyle: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Submit Result',
                      loading: _submitting,
                      backgroundColor: AppColors.primaryColor,
                      textStyle: TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      onTap: _submitResult,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
