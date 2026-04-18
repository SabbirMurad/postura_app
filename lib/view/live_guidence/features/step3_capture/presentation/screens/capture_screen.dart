import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/spine_orbit_loader.dart';
import '../../../../services/camera_service.dart';
import '../../../step2_pose/presentation/widgets/landmark_overlay.dart';
import '../../../step2_pose/presentation/widgets/pose_status_bar.dart';
import '../../domain/capture_questionnaire.dart';
import '../../domain/gate_state.dart';
import '../bloc/capture_bloc.dart';
import '../bloc/capture_bloc_state.dart';
import '../bloc/capture_event.dart';
import '../widgets/corner_brackets.dart';
import '../widgets/gate_checklist.dart';
import '../widgets/guidance_text.dart';

/// Live camera screen with 7-condition autocapture.
///
/// Shows camera preview, skeleton overlay, scan line, corner brackets,
/// gate checklist, guidance text, and status pill. Handles all capture
/// states: loading → guiding → stabilizing → processing → complete/timeout.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.cameraService,
    required this.questionnaire,
    required this.onComplete,
    required this.onCancel,
  });

  final CameraService cameraService;
  final CaptureQuestionnaire questionnaire;
  final void Function(CaptureBlocState) onComplete;
  final VoidCallback onCancel;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  StreamSubscription<CopiedCameraFrame>? _frameSub;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CaptureBloc>();
    bloc.add(CaptureStarted(widget.questionnaire));

    // Feed frames to bloc after short delay for initialization.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _frameSub = widget.cameraService.frameStream.listen((frame) {
        bloc.add(CaptureFrameReceived(frame));
      });
    });
  }

  @override
  void dispose() {
    _frameSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview.
          _CameraPreview(controller: widget.cameraService.controller),

          // BLoC consumer.
          BlocConsumer<CaptureBloc, CaptureBlocState>(
            listener: (context, state) {
              if (state is CaptureComplete) {
                _frameSub?.cancel();
                widget.onComplete(state);
              }
            },
            builder: (context, state) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Scan line removed — was causing green overlay tint.

                  // Corner brackets.
                  if (state is! CaptureLoading) const CornerBrackets(),

                  // Green border when stabilizing or processing.
                  if (state is CaptureStabilizing || state is CaptureProcessing)
                    _GreenBorder(),

                  // Landmark overlay.
                  if (_poseResult(state) != null &&
                      _poseResult(state)!.landmarks.isNotEmpty)
                    LandmarkOverlay(
                      landmarks: _poseResult(state)!.landmarks,
                      isStable:
                          state is CaptureStabilizing ||
                          state is CaptureProcessing,
                    ),

                  // Top-left: Status pill.
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8.h,
                    left: 14.w,
                    right: 14.w,
                    child: _buildStatusPill(state),
                  ),

                  // Guidance text (center).
                  if (state is CaptureGuiding && state.guidanceText.isNotEmpty)
                    Positioned(
                      left: 30.w,
                      right: 30.w,
                      top: MediaQuery.of(context).size.height * 0.35,
                      child: GuidanceText(text: state.guidanceText),
                    ),

                  // Gate checklist (bottom).
                  if (state is CaptureGuiding || state is CaptureStabilizing)
                    Positioned(
                      left: 14.w,
                      right: 14.w,
                      bottom: MediaQuery.of(context).padding.bottom + 14.h,
                      child: GateChecklist(gates: _gates(state)),
                    ),

                  // Processing overlay.
                  if (state is CaptureProcessing)
                    _ProcessingOverlay(
                      progress: state.progress,
                      gates: state.readiness.gates,
                    ),

                  // Loading.
                  if (state is CaptureLoading)
                    Center(
                      child: SpineOrbitLoader(label: 'INITIALIZING CAPTURE'),
                    ),

                  // Timeout.
                  if (state is CaptureTimeout)
                    _TimeoutOverlay(
                      onRetry: () =>
                          context.read<CaptureBloc>().add(const CaptureRetry()),
                      onCancel: widget.onCancel,
                    ),

                  // Error.
                  if (state is CaptureError)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(CaptureBlocState state) {
    if (state is CaptureGuiding) {
      return PoseStatusBar(
        text: 'Checking conditions',
        color: AppColors.amber,
        pulseDot: true,
      );
    }
    if (state is CaptureStabilizing) {
      return PoseStatusBar(
        text: 'Hold steady...',
        color: AppColors.lightTeal,
        pulseDot: true,
      );
    }
    if (state is CaptureProcessing) {
      return PoseStatusBar(
        text: 'All conditions met',
        color: AppColors.successGreen,
        pulseDot: false,
      );
    }
    return const SizedBox.shrink();
  }

  dynamic _poseResult(CaptureBlocState state) {
    if (state is CaptureGuiding) return state.lastPoseResult;
    if (state is CaptureStabilizing) return state.lastPoseResult;
    return null;
  }

  Map<CaptureGate, GateStatus> _gates(CaptureBlocState state) {
    if (state is CaptureGuiding) return state.readiness.gates;
    if (state is CaptureStabilizing) return state.readiness.gates;
    return {};
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.controller});
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: ctrl.value.previewSize!.height,
        height: ctrl.value.previewSize!.width,
        child: ctrl.buildPreview(),
      ),
    );
  }
}

class _GreenBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.successGreen, width: 2.5),
      ),
      child: Container(color: AppColors.successGreen.withValues(alpha: 0.05)),
    );
  }
}

class _ProcessingOverlay extends StatefulWidget {
  const _ProcessingOverlay({required this.progress, required this.gates});
  final double progress;
  final Map<CaptureGate, GateStatus> gates;

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Mini gate panel (top-left, slide down).
        Positioned(
          top: MediaQuery.of(context).padding.top + 50.h,
          left: 14.w,
          right: 14.w,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -20.0, end: 0.0),
            duration: const Duration(milliseconds: 400),
            builder: (_, offset, child) => Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: (1 + offset / 20).clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: GateChecklist(gates: widget.gates),
          ),
        ),

        // Center pill.
        Positioned(
          left: 40.w,
          right: 40.w,
          bottom: MediaQuery.of(context).padding.bottom + 120.h,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.successGreen, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _spinCtrl,
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Analysing posture geometry...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Progress bar.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.successGreen,
                      ),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeoutOverlay extends StatelessWidget {
  const _TimeoutOverlay({required this.onRetry, required this.onCancel});
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.amber,
                size: 40.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'Unable to capture',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Please reposition the phone and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textSecondary, fontSize: 13.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: c.surfaceVariant,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onRetry,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
