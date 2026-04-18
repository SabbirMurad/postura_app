import 'dart:developer' as dev;

import 'package:flutter/services.dart';

import '../../../ml/inference_isolate.dart';
import '../../../ml/label_constants.dart';
import '../../../services/camera_service.dart';
import '../domain/detection_result.dart';
import 'ml_detector.dart';

/// Real ML detector — all preprocessing + inference runs in a persistent
/// background isolate. Main thread does zero ML work.
class RealMlDetector implements MlDetector {
  final InferenceIsolate _isolate = InferenceIsolate();
  bool _isShutdown = false;
  bool _isPaused = false;

  @override
  Future<void> initialize() async {
    // Load model bytes on main thread (rootBundle needs main isolate).
    final modelData = await rootBundle.load('assets/ml/yolov8n_float16.tflite');
    final modelBytes = modelData.buffer.asUint8List();
    await _isolate.start(modelBytes);
  }

  @override
  bool get isPaused => _isPaused;

  @override
  void pause() {
    _isPaused = true;
    dev.log('YOLO paused (model stays loaded)', name: 'RealMlDetector');
  }

  @override
  void resume() {
    _isPaused = false;
    dev.log('YOLO resumed', name: 'RealMlDetector');
  }

  @override
  Future<DetectionResult> processFrame(CopiedCameraFrame frame) async {
    if (_isShutdown || !_isolate.isRunning || _isPaused) {
      return const DetectionResult(
        personDetected: false,
        monitorDetected: false,
      );
    }

    // Everything runs in the persistent isolate — main thread stays free.
    final rawDetections = await _isolate.detect(frame);

    return _buildResult(rawDetections);
  }

  @override
  Future<void> shutdown() async {
    _isShutdown = true;
    _isolate.dispose();
  }

  /// Convert serialized maps from isolate back into DetectionResult.
  DetectionResult _buildResult(List<Map<String, dynamic>> raw) {
    bool hasPerson = false;
    bool hasMonitor = false;
    double? personConf;
    double? monitorConf;
    final objects = <DetectedObject>[];

    for (final d in raw) {
      final classId = d['classId'] as int;
      final confidence = d['confidence'] as double;
      final box = Rect.fromLTRB(
        d['left'] as double,
        d['top'] as double,
        d['right'] as double,
        d['bottom'] as double,
      );

      objects.add(
        DetectedObject(
          classId: classId,
          confidence: confidence,
          boundingBox: box,
        ),
      );

      if (classId == cocoPersonClassId) {
        hasPerson = true;
        if (personConf == null || confidence > personConf) {
          personConf = confidence;
        }
      }
      if (monitorClassIds.contains(classId)) {
        hasMonitor = true;
        if (monitorConf == null || confidence > monitorConf) {
          monitorConf = confidence;
        }
      }
    }

    dev.log(
      'Detections: ${raw.length} objects — '
      '${raw.map((d) => 'id:${d['classId']} conf:${(d['confidence'] as double).toStringAsFixed(2)}').join(', ')}',
      name: 'RealMlDetector',
    );
    dev.log('person=$hasPerson monitor=$hasMonitor', name: 'RealMlDetector');

    return DetectionResult(
      personDetected: hasPerson,
      monitorDetected: hasMonitor,
      personConfidence: personConf,
      monitorConfidence: monitorConf,
      detectedObjects: objects,
    );
  }
}
