import 'package:equatable/equatable.dart';

import '../../../../services/camera_service.dart';

sealed class DetectionEvent extends Equatable {
  const DetectionEvent();

  @override
  List<Object?> get props => [];
}

/// Start the detection pipeline (initialize model + begin processing).
class DetectionStarted extends DetectionEvent {
  const DetectionStarted();
}

/// A new camera frame is available for processing.
class FrameCaptured extends DetectionEvent {
  const FrameCaptured(this.frame);

  final CopiedCameraFrame frame;

  @override
  List<Object?> get props => [identityHashCode(frame)];
}

/// Stop detection and dispose the ML model.
class DetectionStopped extends DetectionEvent {
  const DetectionStopped();
}

/// Restart detection without disposing the model — just resets rolling window.
class DetectionRestarted extends DetectionEvent {
  const DetectionRestarted();
}
