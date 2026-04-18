import 'package:equatable/equatable.dart';

import '../../../../core/enums/detection_state.dart';
import '../../domain/detection_result.dart';

sealed class DetectionBlocState extends Equatable {
  const DetectionBlocState();

  @override
  List<Object?> get props => [];
}

/// ML model is loading / initializing.
class DetectionLoading extends DetectionBlocState {
  const DetectionLoading();
}

/// Detection is actively running. Carries the current [DetectionState]
/// and the latest frame's detection details for UI feedback.
class DetectionRunning extends DetectionBlocState {
  const DetectionRunning(this.detectionState, {this.lastResult});

  final DetectionState detectionState;

  /// Latest per-frame detection result (for bounding boxes, checklist, etc).
  final DetectionResult? lastResult;

  @override
  List<Object?> get props => [
    detectionState,
    lastResult?.personDetected,
    lastResult?.monitorDetected,
    lastResult?.detectedObjects.length,
  ];
}

/// Detection confirmed — both objects verified across rolling window.
class DetectionConfirmed extends DetectionBlocState {
  const DetectionConfirmed();
}

/// Detection pipeline has been shut down.
class DetectionDisposed extends DetectionBlocState {
  const DetectionDisposed();
}

/// An error occurred during detection.
class DetectionError extends DetectionBlocState {
  const DetectionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
