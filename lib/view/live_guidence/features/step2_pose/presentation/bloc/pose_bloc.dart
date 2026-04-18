import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pose_detector.dart';
import 'pose_bloc_state.dart';
import 'pose_event.dart';

class PoseBloc extends Bloc<PoseEvent, PoseBlocState> {
  PoseBloc({required PoseDetector detector})
    : _detector = detector,
      super(const PoseLoading()) {
    on<PoseStarted>(_onStarted);
    on<PoseFrameCaptured>(_onFrameCaptured);
    on<PoseStopped>(_onStopped);
    on<PoseRestarted>(_onRestarted);
  }

  final PoseDetector _detector;
  bool _isProcessing = false;
  bool _stopped = false;

  Future<void> _onStarted(
    PoseStarted event,
    Emitter<PoseBlocState> emit,
  ) async {
    try {
      emit(const PoseLoading());
      await _detector.initialize();
      emit(const PoseRunning());
    } catch (e) {
      emit(PoseError('Failed to initialize pose detector: $e'));
    }
  }

  Future<void> _onFrameCaptured(
    PoseFrameCaptured event,
    Emitter<PoseBlocState> emit,
  ) async {
    if (_isProcessing || _stopped) return;

    _isProcessing = true;

    try {
      final result = await _detector.processFrame(event.frame);

      // Allow stabilization with 6/8 landmarks — ankle/knee often
      // occluded in seated desk side-view.
      if (result.isStable && result.reliableLandmarkCount >= 6) {
        emit(PoseStabilized(result));
      } else {
        emit(PoseRunning(lastResult: result));
      }
    } catch (e, stack) {
      dev.log('Pose frame error: $e\n$stack', name: 'PoseBloc');
      emit(PoseError('Pose processing error: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onStopped(
    PoseStopped event,
    Emitter<PoseBlocState> emit,
  ) async {
    _stopped = true;
    await _detector.shutdown();
    emit(const PoseDisposed());
  }

  void _onRestarted(PoseRestarted event, Emitter<PoseBlocState> emit) {
    _stopped = false;
    _isProcessing = false;
    emit(const PoseRunning());
  }

  @override
  Future<void> close() async {
    if (!_stopped) {
      await _detector.shutdown();
    }
    return super.close();
  }
}
