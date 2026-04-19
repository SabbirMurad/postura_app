import 'package:equatable/equatable.dart';

import '../../../../services/camera_service.dart';
import '../../../step1_detection/domain/detection_result.dart';
import '../../../step2_pose/domain/pose_result.dart';
import '../../domain/capture_questionnaire.dart';

sealed class CaptureEvent extends Equatable {
  const CaptureEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize all services and start condition evaluation.
class CaptureStarted extends CaptureEvent {
  const CaptureStarted(this.questionnaire);
  final CaptureQuestionnaire questionnaire;

  @override
  List<Object?> get props => [questionnaire];
}

/// A camera frame is available for condition evaluation.
class CaptureFrameReceived extends CaptureEvent {
  const CaptureFrameReceived(this.frame);
  final CopiedCameraFrame frame;

  @override
  List<Object?> get props => [frame];
}

/// YOLO detection result received (for conditions 1 and 6).
class CaptureYoloResult extends CaptureEvent {
  const CaptureYoloResult(this.result);
  final DetectionResult result;

  @override
  List<Object?> get props => [result.personDetected, result.monitorDetected];
}

/// Pose detection result received (for condition 2 — side profile).
class CapturePoseResult extends CaptureEvent {
  const CapturePoseResult(this.result);
  final PoseResult result;

  @override
  List<Object?> get props => [result.frameNumber];
}

/// Accelerometer update with roll/pitch.
class CaptureAccelerometerUpdate extends CaptureEvent {
  const CaptureAccelerometerUpdate({required this.roll, required this.pitch});
  final double roll;
  final double pitch;

  @override
  List<Object?> get props => [roll, pitch];
}

/// Luminance measured from camera frame.
class CaptureLuminanceUpdate extends CaptureEvent {
  const CaptureLuminanceUpdate(this.luminance);
  final double luminance;

  @override
  List<Object?> get props => [luminance];
}

/// Stability timer completed — all conditions held for 1.5s.
class CaptureStabilityComplete extends CaptureEvent {
  const CaptureStabilityComplete();
}

/// Photo captured successfully.
class CapturePhotoTaken extends CaptureEvent {
  const CapturePhotoTaken(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// User taps Retry after timeout.
class CaptureRetry extends CaptureEvent {
  const CaptureRetry();
}

/// Full cleanup.
class CaptureStopped extends CaptureEvent {
  const CaptureStopped();
}
