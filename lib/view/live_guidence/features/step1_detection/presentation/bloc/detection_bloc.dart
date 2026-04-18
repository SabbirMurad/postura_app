import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/detection_state.dart';
import '../../data/ml_detector.dart';
import '../../domain/rolling_window.dart';
import 'detection_bloc_state.dart';
import 'detection_event.dart';

class DetectionBloc extends Bloc<DetectionEvent, DetectionBlocState> {
  DetectionBloc({required MlDetector detector})
    : _detector = detector,
      super(const DetectionLoading()) {
    on<DetectionStarted>(_onStarted);
    on<FrameCaptured>(_onFrameCaptured);
    on<DetectionStopped>(_onStopped);
    on<DetectionRestarted>(_onRestarted);
  }

  final MlDetector _detector;
  final RollingWindow _rollingWindow = RollingWindow();
  bool _isProcessing = false;
  bool _stopped = false;

  Future<void> _onStarted(
    DetectionStarted event,
    Emitter<DetectionBlocState> emit,
  ) async {
    try {
      emit(const DetectionLoading());
      await _detector.initialize();
      emit(const DetectionRunning(DetectionState.searching));
    } catch (e) {
      emit(DetectionError('Failed to initialize detector: $e'));
    }
  }

  Future<void> _onFrameCaptured(
    FrameCaptured event,
    Emitter<DetectionBlocState> emit,
  ) async {
    // Skip if already processing a frame or if permanently stopped.
    if (_isProcessing || _stopped) {
      return;
    }

    _isProcessing = true;

    try {
      final result = await _detector.processFrame(event.frame);

      _rollingWindow.add(result.bothDetected);

      if (_rollingWindow.isConfirmed) {
        emit(const DetectionConfirmed());
      } else if (result.isPartial || _rollingWindow.hasPartialActivity) {
        emit(DetectionRunning(DetectionState.partial, lastResult: result));
      } else {
        emit(DetectionRunning(DetectionState.searching, lastResult: result));
      }
    } catch (e, stack) {
      dev.log('Frame error: $e\n$stack', name: 'DetectionBloc');
      emit(DetectionError('Frame processing error: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onStopped(
    DetectionStopped event,
    Emitter<DetectionBlocState> emit,
  ) async {
    _stopped = true;
    await _detector.shutdown();
    _rollingWindow.reset();
    emit(const DetectionDisposed());
  }

  /// Restart without disposing model — just reset rolling window and state.
  void _onRestarted(
    DetectionRestarted event,
    Emitter<DetectionBlocState> emit,
  ) {
    _stopped = false;
    _isProcessing = false;
    _rollingWindow.reset();
    emit(const DetectionRunning(DetectionState.searching));
  }

  @override
  Future<void> close() async {
    // Do NOT shutdown the detector here — it's shared across steps.
    // App.dart owns the detector lifecycle. DetectionBloc only stops
    // processing frames. Shutting down here kills the isolate that
    // Step 3 Capture needs for YOLO re-check (Gate 1 & 6).
    _stopped = true;
    return super.close();
  }
}
