import 'package:equatable/equatable.dart';

import '../../domain/pose_result.dart';

sealed class PoseBlocState extends Equatable {
  const PoseBlocState();

  @override
  List<Object?> get props => [];
}

/// Pose detector is loading / initializing.
class PoseLoading extends PoseBlocState {
  const PoseLoading();
}

/// Pose detection is actively running.
class PoseRunning extends PoseBlocState {
  const PoseRunning({this.lastResult});
  final PoseResult? lastResult;

  @override
  List<Object?> get props => [lastResult?.frameNumber, lastResult?.isStable];
}

/// Pose is stable and all landmarks locked.
class PoseStabilized extends PoseBlocState {
  const PoseStabilized(this.result);
  final PoseResult result;

  @override
  List<Object?> get props => [result.frameNumber];
}

/// Error during pose detection.
class PoseError extends PoseBlocState {
  const PoseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Pose detector fully disposed.
class PoseDisposed extends PoseBlocState {
  const PoseDisposed();
}
