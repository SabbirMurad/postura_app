import 'package:equatable/equatable.dart';

import '../../../../services/camera_service.dart';

sealed class PoseEvent extends Equatable {
  const PoseEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the pose detector.
class PoseStarted extends PoseEvent {
  const PoseStarted();
}

/// Process a single camera frame for pose landmarks.
class PoseFrameCaptured extends PoseEvent {
  const PoseFrameCaptured(this.frame);
  final CopiedCameraFrame frame;

  @override
  List<Object?> get props => [frame];
}

/// Fully shut down the pose detector.
class PoseStopped extends PoseEvent {
  const PoseStopped();
}

/// Reset smoother and side selector without re-initializing the model.
class PoseRestarted extends PoseEvent {
  const PoseRestarted();
}
