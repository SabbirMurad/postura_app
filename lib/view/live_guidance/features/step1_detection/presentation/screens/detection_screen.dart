import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/detection_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/spine_orbit_loader.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../services/camera_service.dart';
import '../bloc/detection_bloc.dart';
import '../bloc/detection_bloc_state.dart';
import '../bloc/detection_event.dart';
import '../widgets/bounding_box_overlay.dart';
import '../widgets/detection_checklist.dart';
import '../widgets/detection_frame_overlay.dart';
import '../widgets/detection_status_bar.dart';
import '../widgets/detection_labels.dart';
import '../widgets/detection_toast.dart';
import '../widgets/setup_guide_overlay.dart';
import '../../../image_test/image_test_screen.dart';
import '../widgets/step_progress_bar.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({
    super.key,
    required this.cameraService,
    required this.onConfirmed,
  });

  final CameraService cameraService;
  final VoidCallback onConfirmed;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

enum _ScreenPhase { guide, detecting }

class _DetectionScreenState extends State<DetectionScreen> {
  StreamSubscription<CopiedCameraFrame>? _frameSub;
  _ScreenPhase _phase = _ScreenPhase.guide;

  // Track what has been detected for toasts (show once only).
  bool _personToastShown = false;
  bool _monitorToastShown = false;
  final GlobalKey<ToastManagerState> _toastKey = GlobalKey();

  // Track rolling window progress for step indicator.
  int _confirmCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<DetectionBloc>().add(const DetectionStarted());
  }

  void _onGuideDismissed() {
    final bloc = context.read<DetectionBloc>();
    setState(() => _phase = _ScreenPhase.detecting);

    widget.cameraService.startFrameSampling();
    _frameSub = widget.cameraService.frameStream.listen((frame) {
      bloc.add(FrameCaptured(frame));
    });
  }

  void _onDetectionConfirmed() {
    // Cancel Step 1 frame subscription (Step 2 will create its own).
    _frameSub?.cancel();
    // Don't stop frame sampling — frames keep flowing for Step 2.
    // Defer navigation to next frame to avoid BlocConsumer rebuild conflict.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onConfirmed();
    });
  }

  @override
  void dispose() {
    _frameSub?.cancel();
    super.dispose();
  }

  Future<void> _onSwitchCamera() async {
    await widget.cameraService.switchCamera();
    setState(() {});
  }

  /// Check and show toasts for new detections.
  void _handleToasts(bool personDetected, bool monitorDetected) {
    final toastMgr = _toastKey.currentState;
    if (toastMgr == null) return;

    if (personDetected && !_personToastShown) {
      _personToastShown = true;
      toastMgr.showToast(
        'Person detected in frame',
        Icons.check_circle_rounded,
      );
    }
    if (monitorDetected && !_monitorToastShown) {
      _monitorToastShown = true;
      toastMgr.showToast(
        'Monitor detected in frame',
        Icons.check_circle_rounded,
      );
    }
  }

  /// Determine step statuses based on detection state.
  ({StepStatus camera, StepStatus detect, StepStatus confirm, StepStatus pose})
  _stepStatuses(DetectionBlocState state) {
    final personFound = _personToastShown;
    final monitorFound = _monitorToastShown;
    final bothFound = personFound && monitorFound;

    return (
      camera: StepStatus.completed, // Always done once we're detecting.
      detect: bothFound
          ? StepStatus.completed
          : (personFound || monitorFound)
          ? StepStatus.active
          : StepStatus.active,
      confirm: bothFound
          ? (_confirmCount >= DetectionConstants.requiredPositives
                ? StepStatus.completed
                : StepStatus.active)
          : StepStatus.pending,
      pose: state is DetectionConfirmed
          ? StepStatus.active
          : StepStatus.pending,
    );
  }

  /// Status bar text and color based on state.
  ({String text, Color color}) _statusBarInfo(DetectionBlocState state) {
    if (state is DetectionLoading) {
      return (text: 'Loading model...', color: Colors.grey.shade600);
    }
    if (state is DetectionRunning) {
      // Both ever detected → confirming (green dot).
      if (_personToastShown && _monitorToastShown) {
        return (text: 'Confirming position...', color: AppColors.successGreen);
      }
      // One detected → detecting (amber dot).
      if (_personToastShown || _monitorToastShown) {
        return (text: 'Detecting person + monitor', color: AppColors.amber);
      }
      // Nothing yet → searching (cyan dot).
      return (
        text: 'Searching for person + monitor',
        color: AppColors.lightTeal,
      );
    }
    return (text: 'Detecting person + monitor', color: AppColors.lightTeal);
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

          // Phase 1: Setup guide.
          if (_phase == _ScreenPhase.guide)
            SetupGuideOverlay(onDismiss: _onGuideDismissed),

          // Phase 2: Detection.
          if (_phase == _ScreenPhase.detecting)
            BlocConsumer<DetectionBloc, DetectionBlocState>(
              listener: (context, state) {
                if (state is DetectionConfirmed) {
                  _onDetectionConfirmed();
                }
                if (state is DetectionRunning && state.lastResult != null) {
                  final r = state.lastResult!;
                  _handleToasts(r.personDetected, r.monitorDetected);
                  if (r.bothDetected) {
                    setState(() => _confirmCount++);
                  }
                }
              },
              builder: (context, state) {
                final result = state is DetectionRunning
                    ? state.lastResult
                    : null;
                final steps = _stepStatuses(state);
                final statusInfo = _statusBarInfo(state);
                final bothEverDetected =
                    _personToastShown && _monitorToastShown;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Real-time bounding boxes for detected objects.
                    if (result != null)
                      BoundingBoxOverlay(
                        detectedObjects: result.detectedObjects,
                      ),

                    // Animated frame overlay.
                    DetectionFrameOverlay(detected: bothEverDetected),

                    // Top: Status bar + camera switch in one row.
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8.h,
                      left: 14.w,
                      right: 14.w,
                      child: Row(
                        children: [
                          Expanded(
                            child: DetectionStatusBar(
                              text: statusInfo.text,
                              color: statusInfo.color,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _ActionButton(
                            icon: Icons.image_search_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ImageTestScreen(),
                                ),
                              );
                            },
                          ),
                          if (widget.cameraService.canSwitchCamera) ...[
                            SizedBox(width: 8.w),
                            _ActionButton(
                              icon: Icons.cameraswitch_rounded,
                              onTap: _onSwitchCamera,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Top-right: Detection labels (person · 94%, monitor · 71%).
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 60.h,
                      right: 30.w,
                      child: DetectionLabels(result: result),
                    ),

                    // Middle: Toast notifications.
                    Positioned(
                      left: 20.w,
                      right: 20.w,
                      bottom: MediaQuery.of(context).padding.bottom + 190.h,
                      child: Center(child: ToastManager(key: _toastKey)),
                    ),

                    // Bottom: Checklist + Step progress.
                    Positioned(
                      left: 14.w,
                      right: 14.w,
                      bottom: MediaQuery.of(context).padding.bottom + 14.h,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Detection checklist.
                          DetectionChecklist(result: result),
                          SizedBox(height: 10.h),
                          // Step progress bar.
                          StepProgressBar(
                            cameraStatus: steps.camera,
                            detectStatus: steps.detect,
                            confirmStatus: steps.confirm,
                            poseStatus: steps.pose,
                            confirmCount: _confirmCount.clamp(
                              0,
                              DetectionConstants.requiredPositives,
                            ),
                            confirmTotal: DetectionConstants.requiredPositives,
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, color: context.colors.iconDefault, size: 22.sp),
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.controller});

  final CameraController? controller;

  static final _loader = Center(
    child: SpineOrbitLoader(label: 'LOADING CAMERA'),
  );

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null) return _loader;

    // Use ValueListenableBuilder with error boundary.
    return ValueListenableBuilder<CameraValue>(
      valueListenable: ctrl,
      builder: (context, value, _) {
        try {
          if (!value.isInitialized) return _loader;
          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: value.previewSize!.height,
              height: value.previewSize!.width,
              child: ctrl.buildPreview(),
            ),
          );
        } catch (_) {
          return _loader;
        }
      },
    );
  }
}
