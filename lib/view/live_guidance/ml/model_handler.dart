import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:tflite_flutter/tflite_flutter.dart';

import 'label_constants.dart';

/// A single object detection result from YOLOv8n.
class Detection {
  /// COCO class index (0-indexed).
  final int classId;

  /// Detection confidence score (0.0 – 1.0).
  final double confidence;

  /// Bounding box in normalized coordinates (0.0 – 1.0).
  /// Format: left, top, right, bottom.
  final Rect boundingBox;

  const Detection({
    required this.classId,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() =>
      'Detection(classId: $classId, confidence: ${confidence.toStringAsFixed(2)}, '
      'box: $boundingBox)';
}

/// Manages the TFLite YOLOv8n interpreter lifecycle.
///
/// Handles model loading, inference execution, output parsing with NMS,
/// and disposal. After [dispose] is called, all further [runInference]
/// calls return empty.
class ModelHandler {
  static const String _modelAssetPath = 'assets/ml/yolov8n_float16.tflite';

  /// Model input dimensions (320×320 to match export).
  static const int _inputSize = 320;

  /// Number of COCO classes in YOLOv8n output.
  static const int _numClasses = 80;

  /// Number of values per detection: 4 bbox + 80 class scores.
  static const int _numValues = 4 + _numClasses;

  /// Number of candidate detections at 320×320 input.
  static const int _numCandidates = 2100;

  /// IoU threshold for Non-Maximum Suppression.
  static const double _nmsIouThreshold = 0.45;

  Interpreter? _interpreter;
  bool _isDisposed = false;

  /// Whether the model has been loaded and is ready for inference.
  bool get isReady => _interpreter != null && !_isDisposed;

  /// Load the YOLOv8n model from Flutter assets.
  ///
  /// Must be called before [runInference]. Allocates tensors and optionally
  /// logs input/output shapes for verification.
  Future<void> loadModel({bool logShapes = false}) async {
    if (_isDisposed) {
      throw StateError('Cannot load model after disposal.');
    }

    final options = InterpreterOptions()..threads = 2;
    _tryAddGpuDelegate(options);

    _interpreter = await Interpreter.fromAsset(
      _modelAssetPath,
      options: options,
    );

    _interpreter!.allocateTensors();

    if (logShapes) {
      _logTensorShapes();
    }
  }

  /// Run inference on a preprocessed RGB buffer.
  ///
  /// [rgbBuffer] must be a flat `Uint8List` of length 320 * 320 * 3.
  /// Returns detections filtered by [confidenceThreshold] and NMS.
  ///
  /// Returns empty list if model is disposed or not loaded.
  List<Detection> runInference(Uint8List rgbBuffer) {
    if (_isDisposed || _interpreter == null) return [];

    assert(
      rgbBuffer.length == _inputSize * _inputSize * 3,
      'Expected ${_inputSize * _inputSize * 3} bytes, got ${rgbBuffer.length}',
    );

    // Convert uint8 [0-255] to float32 [0.0-1.0] for YOLOv8n.
    final float32Input = Float32List(rgbBuffer.length);
    for (int i = 0; i < rgbBuffer.length; i++) {
      float32Input[i] = rgbBuffer[i] / 255.0;
    }
    final input = float32Input.reshape([1, _inputSize, _inputSize, 3]);

    // YOLOv8n TFLite output: [1, 84, 2100]
    // 84 = 4 (cx, cy, w, h) + 80 (class scores)
    // 2100 = candidate detections
    final output = List.generate(
      1,
      (_) => List.generate(_numValues, (_) => List.filled(_numCandidates, 0.0)),
    );

    try {
      _interpreter!.run(input, output);
    } catch (e) {
      dev.log('Inference error: $e', name: 'ModelHandler');
      return [];
    }

    // Transpose [84][2100] → [2100][84] for easier per-candidate parsing.
    final transposed = List.generate(
      _numCandidates,
      (i) => List.generate(_numValues, (j) => output[0][j][i]),
    );

    return _parseAndNms(transposed);
  }

  /// Parse raw YOLOv8n output [2100][84] into filtered detections with NMS.
  List<Detection> _parseAndNms(List<List<double>> raw) {
    final candidates = <Detection>[];

    for (int i = 0; i < _numCandidates; i++) {
      final row = raw[i]; // [84] values for this candidate

      // Find the class with the highest score (indices 4-83).
      int bestClassId = 0;
      double bestScore = 0.0;

      for (int c = 0; c < _numClasses; c++) {
        final score = row[4 + c];
        if (score > bestScore) {
          bestScore = score;
          bestClassId = c;
        }
      }

      // Use lower threshold for monitor/tv/laptop classes.
      final threshold = (bestClassId == 62 || bestClassId == 63)
          ? monitorConfidenceThreshold
          : confidenceThreshold;
      if (bestScore < threshold) continue;

      // Extract box: cx, cy, w, h (in pixels relative to input size).
      final cx = row[0];
      final cy = row[1];
      final w = row[2];
      final h = row[3];

      // Convert to normalized [0-1] left, top, right, bottom.
      final left = (cx - w / 2) / _inputSize;
      final top = (cy - h / 2) / _inputSize;
      final right = (cx + w / 2) / _inputSize;
      final bottom = (cy + h / 2) / _inputSize;

      candidates.add(
        Detection(
          classId: bestClassId,
          confidence: bestScore,
          boundingBox: Rect.fromLTRB(
            left.clamp(0.0, 1.0),
            top.clamp(0.0, 1.0),
            right.clamp(0.0, 1.0),
            bottom.clamp(0.0, 1.0),
          ),
        ),
      );
    }

    return _applyNms(candidates);
  }

  /// Apply Non-Maximum Suppression per class.
  ///
  /// Groups detections by class, sorts each group by confidence descending,
  /// and greedily suppresses overlapping boxes (IoU > threshold).
  List<Detection> _applyNms(List<Detection> candidates) {
    if (candidates.isEmpty) return [];

    // Group by class ID.
    final byClass = <int, List<Detection>>{};
    for (final d in candidates) {
      (byClass[d.classId] ??= []).add(d);
    }

    final results = <Detection>[];

    for (final group in byClass.values) {
      // Sort by confidence descending.
      group.sort((a, b) => b.confidence.compareTo(a.confidence));

      final kept = <Detection>[];
      final suppressed = List.filled(group.length, false);

      for (int i = 0; i < group.length; i++) {
        if (suppressed[i]) continue;
        kept.add(group[i]);

        // Suppress all lower-scoring boxes with high IoU.
        for (int j = i + 1; j < group.length; j++) {
          if (suppressed[j]) continue;
          if (_computeIou(group[i].boundingBox, group[j].boundingBox) >
              _nmsIouThreshold) {
            suppressed[j] = true;
          }
        }
      }

      results.addAll(kept);
    }

    return results;
  }

  /// Compute Intersection over Union between two rectangles.
  double _computeIou(Rect a, Rect b) {
    final interLeft = max(a.left, b.left);
    final interTop = max(a.top, b.top);
    final interRight = min(a.right, b.right);
    final interBottom = min(a.bottom, b.bottom);

    if (interRight <= interLeft || interBottom <= interTop) return 0.0;

    final interArea = (interRight - interLeft) * (interBottom - interTop);
    final aArea = a.width * a.height;
    final bArea = b.width * b.height;

    return interArea / (aArea + bArea - interArea);
  }

  /// Fully dispose the interpreter and release all memory.
  ///
  /// After calling this, [runInference] returns empty and [loadModel] throws.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isDisposed = true;
  }

  void _tryAddGpuDelegate(InterpreterOptions options) {
    try {
      if (Platform.isAndroid) {
        options.addDelegate(GpuDelegateV2());
        dev.log('GPU delegate (Android) added', name: 'ModelHandler');
      } else if (Platform.isIOS) {
        options.addDelegate(GpuDelegate());
        dev.log('GPU delegate (iOS Metal) added', name: 'ModelHandler');
      }
    } catch (e) {
      dev.log(
        'GPU delegate failed ($e), using CPU with 4 threads',
        name: 'ModelHandler',
      );
      options.threads = 4;
    }
  }

  /// Print input/output tensor shapes for debugging during initial integration.
  void _logTensorShapes() {
    final interp = _interpreter!;
    dev.log(
      'Input tensor: ${interp.getInputTensor(0).shape} ${interp.getInputTensor(0).type}',
      name: 'ModelHandler',
    );
    for (int i = 0; i < interp.getOutputTensors().length; i++) {
      dev.log(
        'Output tensor $i: ${interp.getOutputTensor(i).shape} ${interp.getOutputTensor(i).type}',
        name: 'ModelHandler',
      );
    }
  }
}
