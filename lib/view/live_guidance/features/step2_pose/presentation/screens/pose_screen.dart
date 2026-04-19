import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/spine_orbit_loader.dart';
import '../../../../services/camera_service.dart';
import '../../../step1_detection/presentation/widgets/step_progress_bar.dart';
import '../bloc/pose_bloc.dart';
import '../bloc/pose_bloc_state.dart';
import '../bloc/pose_event.dart';
import '../widgets/landmark_overlay.dart';
import '../widgets/pose_status_bar.dart';
import '../widgets/side_indicator.dart';
import '../../domain/pose_result.dart';

class PoseScreen extends StatefulWidget {
  const PoseScreen({super.key, required this.cameraService, this.onStabilized});

  final CameraService cameraService;

  /// Called once when the pose stabilizes (all 8 landmarks locked).
  /// Used to trigger Step 3 navigation.
  final VoidCallback? onStabilized;

  @override
  State<PoseScreen> createState() => _PoseScreenState();
}

enum _PosePhase { initializing, tracking, stabilized }

class _PoseScreenState extends State<PoseScreen> {
  StreamSubscription<CopiedCameraFrame>? _frameSub;
  _PosePhase _phase = _PosePhase.initializing;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PoseBloc>();
    bloc.add(const PoseStarted());

    _frameSub = widget.cameraService.frameStream.listen((frame) {
      bloc.add(PoseFrameCaptured(frame));
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

          // BLoC consumer for all phases.
          BlocConsumer<PoseBloc, PoseBlocState>(
            listener: (context, state) {
              if (state is PoseRunning && _phase == _PosePhase.initializing) {
                setState(() => _phase = _PosePhase.tracking);
              }
              if (state is PoseStabilized && _phase != _PosePhase.stabilized) {
                setState(() => _phase = _PosePhase.stabilized);
                // Notify parent to advance to Step 3.
                widget.onStabilized?.call();
              }
            },
            builder: (context, state) {
              final result = _extractResult(state);
              final activeSide = result?.activeSide ?? BodyOrientation.unknown;
              final isStable = result?.isStable ?? false;
              final reliableCount = result?.reliableLandmarkCount ?? 0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Green border when stabilized.
                  if (_phase == _PosePhase.stabilized) _StabilizedBorder(),

                  // Landmark overlay.
                  if (result != null && result.landmarks.isNotEmpty)
                    LandmarkOverlay(
                      landmarks: result.landmarks,
                      isStable: isStable,
                    ),

                  // Top: Status bar + confidence badges.
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8.h,
                    left: 14.w,
                    right: 14.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PoseStatusBar(
                            text: _statusText(state),
                            color: _statusColor(state),
                            pulseDot: _phase != _PosePhase.stabilized,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Confidence badges.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Badge(
                              label: 'landmarks',
                              value: '$reliableCount/8',
                              color: reliableCount >= 8
                                  ? AppColors.successGreen
                                  : AppColors.lightTeal,
                            ),
                            SizedBox(height: 4.h),
                            _Badge(
                              label: activeSide.name,
                              value: isStable ? 'stable' : 'tracking',
                              color: isStable
                                  ? AppColors.successGreen
                                  : AppColors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Side indicator — left badge on left, right badge on right.
                  if (activeSide != BodyOrientation.unknown)
                    Positioned(
                      left: activeSide == BodyOrientation.left ? 14.w : null,
                      right: activeSide == BodyOrientation.right ? 14.w : null,
                      bottom: MediaQuery.of(context).padding.bottom + 200.h,
                      child: SideIndicator(side: activeSide),
                    ),

                  // "Pose stable — ready" pill (center-bottom, stabilized only).
                  if (_phase == _PosePhase.stabilized)
                    Positioned(
                      left: 40.w,
                      right: 40.w,
                      bottom: MediaQuery.of(context).padding.bottom + 240.h,
                      child: _StablePill(),
                    ),

                  // Manual continue button — ONLY when 8/8 landmarks
                  // are active AND pose is stable. Timer-based display
                  // was removed — we never allow capture with <8 landmarks.
                  if (reliableCount == 8 &&
                      isStable &&
                      _phase != _PosePhase.stabilized)
                    Positioned(
                      left: 40.w,
                      right: 40.w,
                      bottom: MediaQuery.of(context).padding.bottom + 240.h,
                      child: _ContinueButton(
                        onTap: () {
                          setState(() => _phase = _PosePhase.stabilized);
                          widget.onStabilized?.call();
                        },
                      ),
                    ),

                  // Bottom: Step progress + landmark info.
                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    bottom: MediaQuery.of(context).padding.bottom + 14.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BottomInfo(
                          reliableCount: reliableCount,
                          isStable: isStable,
                          isStabilized: _phase == _PosePhase.stabilized,
                        ),
                        SizedBox(height: 10.h),
                        StepProgressBar(
                          cameraStatus: StepStatus.completed,
                          detectStatus: StepStatus.completed,
                          confirmStatus: StepStatus.completed,
                          poseStatus: _phase == _PosePhase.stabilized
                              ? StepStatus.completed
                              : StepStatus.active,
                        ),
                      ],
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

  PoseResult? _extractResult(PoseBlocState state) {
    if (state is PoseRunning) return state.lastResult;
    if (state is PoseStabilized) return state.result;
    return null;
  }

  String _statusText(PoseBlocState state) {
    if (state is PoseLoading) return 'Initializing pose detection';
    if (state is PoseStabilized) return 'Pose stable';
    if (state is PoseRunning) return 'Tracking pose';
    if (state is PoseError) return 'Error: ${state.message}';
    return 'Initializing...';
  }

  Color _statusColor(PoseBlocState state) {
    if (state is PoseStabilized) return AppColors.successGreen;
    if (state is PoseRunning) return AppColors.lightTeal;
    if (state is PoseError) return AppColors.error;
    return Colors.grey;
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
    if (ctrl == null) {
      return Center(child: SpineOrbitLoader(label: 'LOADING CAMERA'));
    }
    return ValueListenableBuilder<CameraValue>(
      valueListenable: ctrl,
      builder: (context, value, _) {
        if (!value.isInitialized) {
          return Center(child: SpineOrbitLoader(label: 'INITIALIZING'));
        }
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: value.previewSize!.height,
            height: value.previewSize!.width,
            child: ctrl.buildPreview(),
          ),
        );
      },
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _ctrl.value * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.lightTeal.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _StabilizedBorder extends StatelessWidget {
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

class _StablePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.successGreen, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Pose stable — ready',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Continue to Capture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo({
    required this.reliableCount,
    required this.isStable,
    required this.isStabilized,
  });

  final int reliableCount;
  final bool isStable;
  final bool isStabilized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isStabilized
            ? AppColors.successGreen.withValues(alpha: 0.1)
            : context.colors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: isStabilized
            ? Border.all(color: AppColors.successGreen.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isStabilized
                      ? '$reliableCount/8 landmarks locked'
                      : '$reliableCount landmarks active',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: isStabilized
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (isStable)
                Text(
                  'stable',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (isStabilized) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successGreen,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                ),
              ],
            ],
          ),
          if (isStabilized) ...[
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ready for ROSA scoring',
                style: TextStyle(color: AppColors.lightTeal, fontSize: 11.sp),
              ),
            ),
          ],
          if (!isStabilized) ...[
            SizedBox(height: 6.h),
            Text(
              'SMOOTHING · ONE EURO FILTER',
              style: TextStyle(
                color: context.colors.textMuted,
                fontSize: 9.sp,
                fontFamily: 'DMMono',
                letterSpacing: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label · $value',
            style: TextStyle(
              color: color,
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
