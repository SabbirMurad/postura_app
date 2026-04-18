import 'package:equatable/equatable.dart';

import '../../domain/capture_questionnaire.dart';
import '../../domain/capture_readiness.dart';
import '../../domain/gate_state.dart';
import '../../domain/rosa_score.dart';
import '../../../step2_pose/domain/pose_result.dart';

sealed class CaptureBlocState extends Equatable {
  const CaptureBlocState();

  @override
  List<Object?> get props => [];
}

/// Initializing services (ML Kit, accelerometer, YOLO).
class CaptureLoading extends CaptureBlocState {
  const CaptureLoading();
}

/// Live guidance mode — evaluating conditions in order.
class CaptureGuiding extends CaptureBlocState {
  const CaptureGuiding({
    required this.readiness,
    required this.guidanceText,
    this.lastPoseResult,
    this.luminance,
  });

  final CaptureReadiness readiness;
  final String guidanceText;
  final PoseResult? lastPoseResult;
  final double? luminance;

  /// Which gate is currently being checked.
  CaptureGate? get activeGate => readiness.activeGate;

  @override
  List<Object?> get props => [
    readiness.activeGate,
    readiness.gates.values.toList(),
    guidanceText,
    lastPoseResult?.frameNumber,
  ];
}

/// All conditions met — counting down the 1.5s stability buffer.
class CaptureStabilizing extends CaptureBlocState {
  const CaptureStabilizing({
    required this.readiness,
    required this.elapsedMs,
    this.lastPoseResult,
  });

  final CaptureReadiness readiness;
  final int elapsedMs;
  final PoseResult? lastPoseResult;

  @override
  List<Object?> get props => [elapsedMs];
}

/// Processing: capturing photo, extracting landmarks, scoring.
class CaptureProcessing extends CaptureBlocState {
  const CaptureProcessing({required this.readiness, this.progress = 0.0});

  final CaptureReadiness readiness;
  final double progress; // 0.0 – 1.0 for progress bar.

  @override
  List<Object?> get props => [progress];
}

/// Done — ROSA score computed, image saved.
class CaptureComplete extends CaptureBlocState {
  const CaptureComplete({
    required this.rosaScore,
    required this.imagePath,
    required this.poseResult,
    required this.questionnaire,
  });

  final RosaScore rosaScore;
  final String imagePath;
  final PoseResult poseResult;
  final CaptureQuestionnaire questionnaire;

  @override
  List<Object?> get props => [rosaScore.finalScore, imagePath];
}

/// Timeout — conditions not met in time.
class CaptureTimeout extends CaptureBlocState {
  const CaptureTimeout();
}

/// Error during capture process.
class CaptureError extends CaptureBlocState {
  const CaptureError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
