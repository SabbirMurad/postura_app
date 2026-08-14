import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/models/analysis/capture.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:posture_detector_app/view/assessment/analysis_result_screen.dart';

class CameraGuideScreen extends ConsumerStatefulWidget {
  const CameraGuideScreen({super.key});

  @override
  ConsumerState<CameraGuideScreen> createState() => _CameraGuideScreenState();
}

class _CameraGuideScreenState extends ConsumerState<CameraGuideScreen> {
  /// Bridge to the native PostureEngine (Android PoseDetectionActivity /
  /// iOS PoseDetectionViewController).
  static const _channel = MethodChannel('posture_detection');
  bool _detecting = false;

  Future<void> _handleCaptureCallBack(BuildContext context) async {
    if (_detecting) return;
    final assessment = ref.read(assessmentNotifierProvider);
    final notifier = ref.read(assessmentNotifierProvider.notifier);

    setState(() => _detecting = true);
    try {
      // Launches the native camera pipeline; blocks until it captures the
      // photos (or the user backs out, which returns null).
      final result = await _channel.invokeMethod<Map>(
        'startDetection',
        assessment.workstationAnswers.toMap(),
      );
      if (!mounted) return;
      if (result == null) return; // user cancelled

      final sideCaptures = (result['side_captures'] as List? ?? const [])
          .map(
            (e) => SideViewCapture.fromChannel(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      final frontMap = result['front_capture'] as Map?;
      final frontCapture = frontMap == null
          ? null
          : FrontViewCapture.fromChannel(Map<String, dynamic>.from(frontMap));

      if (sideCaptures.isEmpty) {
        showCustomToast(text: 'Capture did not complete. Please try again.');
        return;
      }

      notifier.setCaptures(sideCaptures, frontCapture);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AnalysisResultScreen()),
      );
    } on PlatformException catch (e) {
      printLine('Detection error: ${e.message}');
      if (mounted) showCustomToast(text: 'Posture detection failed.');
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                SizedBox(height: 6.h),
                // EN: "Photo Capture Guide"
                Text(
                  loc.photoCaptureGuide,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Assets.images.camera.cameraGuided.image(
                    width: 335.w,
                    height: 335.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  width: 333.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.secondaryText.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: "Person A (Subject)"
                      Text(
                        loc.personA,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // EN: "Sit in a natural posture"
                      GuidedItem(number: '1', title: loc.guideA1),
                      SizedBox(height: 12.h),
                      // EN: "Keep your feet flat on the floor"
                      GuidedItem(number: '2', title: loc.guideA2),
                      SizedBox(height: 12.h),
                      // EN: "Look at the screen naturally"
                      GuidedItem(number: '3', title: loc.guideA3),
                      SizedBox(height: 12.h),
                      // EN: "Wear fitted clothing"
                      GuidedItem(number: '4', title: loc.guideA4),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  width: 333.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.secondaryText.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: "Person B (Photographer)"
                      Text(
                        loc.personB,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // EN: "Stand 1.5 to 2 meters away"
                      GuidedItem(number: '1', title: loc.guideB1),
                      SizedBox(height: 12.h),
                      // EN: "Capture from the side (90 degrees)"
                      GuidedItem(number: '2', title: loc.guideB2),
                      SizedBox(height: 12.h),
                      // EN: "Make sure full body is visible"
                      GuidedItem(number: '3', title: loc.guideB3),
                      SizedBox(height: 12.h),
                      // EN: "Use good lighting"
                      GuidedItem(number: '4', title: loc.guideB4),
                    ],
                  ),
                ),
                SizedBox(height: 96.h),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () => _handleCaptureCallBack(context),
              // EN: "Continue"
              text: loc.continueButton,
              backgroundColor: AppColors.primaryColor,
              textStyle: TextStyle(
                color: AppColors.surface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }
}

class GuidedItem extends StatelessWidget {
  final String number;
  final String title;

  const GuidedItem({super.key, required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blackDeemed,
          ),
          child: Center(
            child: Text(number, style: TextStyle(color: AppColors.text)),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}
