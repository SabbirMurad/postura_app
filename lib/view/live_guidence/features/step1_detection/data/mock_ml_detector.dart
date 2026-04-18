import '../../../services/camera_service.dart';
import '../domain/detection_result.dart';
import 'ml_detector.dart';

/// Mock implementation of [MlDetector] for testing and demo purposes.
///
/// Simulates detection by returning positive results after a configurable
/// number of frames, allowing the frontend to be developed and tested
/// independently of the real TFLite model.
class MockMlDetector implements MlDetector {
  MockMlDetector({this.framesBeforeDetection = 4});

  /// Number of frames to wait before simulating both-detected results.
  final int framesBeforeDetection;

  int _frameCount = 0;
  bool _isDisposed = false;

  @override
  Future<void> initialize() async {
    // Simulate model loading delay.
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<DetectionResult> processFrame(CopiedCameraFrame frame) async {
    assert(!_isDisposed, 'processFrame called after shutdown');
    if (_isPaused) {
      return const DetectionResult(
        personDetected: false,
        monitorDetected: false,
      );
    }

    // Simulate inference latency.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    _frameCount++;

    if (_frameCount <= 2) {
      // First couple of frames: nothing detected.
      return const DetectionResult(
        personDetected: false,
        monitorDetected: false,
      );
    }

    if (_frameCount <= framesBeforeDetection) {
      // Partial: only person detected.
      return const DetectionResult(
        personDetected: true,
        monitorDetected: false,
      );
    }

    // After threshold: both detected.
    return const DetectionResult(personDetected: true, monitorDetected: true);
  }

  @override
  Future<void> shutdown() async {
    _isDisposed = true;
  }

  bool _isPaused = false;

  @override
  bool get isPaused => _isPaused;

  @override
  void pause() => _isPaused = true;

  @override
  void resume() => _isPaused = false;
}
