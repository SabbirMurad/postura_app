import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../services/camera_service.dart';
import 'frame_preprocessor.dart';
import 'label_constants.dart';

/// Persistent background isolate that owns the TFLite interpreter.
/// All preprocessing + inference runs off the main thread.
class InferenceIsolate {
  Isolate? _isolate;
  SendPort? _commandPort;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Spawn the isolate and load the model inside it.
  /// [modelBytes] must be loaded from assets on the main thread
  /// (rootBundle doesn't work inside spawned isolates).
  Future<void> start(Uint8List modelBytes) async {
    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_isolateEntryPoint, [
      receivePort.sendPort,
      modelBytes,
    ]);

    // First message back is the isolate's SendPort.
    _commandPort = await receivePort.first as SendPort;
    _isRunning = true;
    dev.log('Persistent inference isolate started', name: 'InferenceIsolate');
  }

  /// Send a frame to the isolate for preprocessing + inference.
  /// Returns serialized detections. Returns empty if isolate not ready.
  Future<List<Map<String, dynamic>>> detect(CopiedCameraFrame frame) async {
    if (!_isRunning || _commandPort == null) return [];

    // One-shot port for this request's response.
    final responsePort = ReceivePort();

    // Serialize frame data (can't send CopiedCameraFrame directly).
    _commandPort!.send([
      responsePort.sendPort,
      frame.width,
      frame.height,
      frame.formatGroup.index,
      frame.sensorOrientation,
      frame.planes
          .map((p) => (p.bytes, p.bytesPerRow, p.bytesPerPixel))
          .toList(),
    ]);

    final result = await responsePort.first;
    return (result as List).cast<Map<String, dynamic>>();
  }

  /// Kill the isolate and release resources.
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _commandPort = null;
    _isRunning = false;
    dev.log('Inference isolate disposed', name: 'InferenceIsolate');
  }
}

// ---------------------------------------------------------------------------
// Isolate entry point — runs entirely off the main thread.
// ---------------------------------------------------------------------------

void _isolateEntryPoint(List<dynamic> args) async {
  final mainSendPort = args[0] as SendPort;
  final modelBytes = args[1] as Uint8List;

  final receivePort = ReceivePort();
  // Send our port back so the main thread can talk to us.
  mainSendPort.send(receivePort.sendPort);

  // Load interpreter with best available acceleration.
  // Priority: GPU → NNAPI → XNNPack+CPU (industry standard fallback chain).
  late final Interpreter interpreter;
  final loaded = await _tryLoadWithDelegates(modelBytes);
  if (loaded == null) {
    dev.log('All delegate attempts failed', name: 'InferenceIsolate');
    return;
  }
  interpreter = loaded;

  // Warm-up: run one dummy inference to trigger JIT compilation.
  // First real frame will be fast instead of having a cold-start penalty.
  _warmUp(interpreter);

  // Constants matching ModelHandler.
  const inputSize = 320;
  const numClasses = 80;
  const numValues = 4 + numClasses;
  const numCandidates = 2100;
  const nmsIouThreshold = 0.45;

  // Listen for frame data, preprocess, infer, respond.
  await for (final message in receivePort) {
    final replyPort = message[0] as SendPort;
    final width = message[1] as int;
    final height = message[2] as int;
    final formatIndex = message[3] as int;
    final sensorOrientation = message[4] as int;
    final planesRaw = message[5] as List;

    try {
      // Reconstruct frame.
      final formatGroup = ImageFormatGroup.values[formatIndex];
      final planes = planesRaw
          .cast<(Uint8List, int, int?)>()
          .map(
            (p) => CopiedPlane(
              bytes: p.$1,
              bytesPerRow: p.$2,
              bytesPerPixel: p.$3,
            ),
          )
          .toList();

      final frame = CopiedCameraFrame(
        width: width,
        height: height,
        formatGroup: formatGroup,
        sensorOrientation: sensorOrientation,
        planes: planes,
      );

      // Step 1: Preprocess — raw bytes → 320x320 RGB.
      final rgbBuffer = preprocessCameraImage(frame);

      // Step 2: Inference.
      final float32Input = Float32List(rgbBuffer.length);
      for (int i = 0; i < rgbBuffer.length; i++) {
        float32Input[i] = rgbBuffer[i] / 255.0;
      }
      final input = float32Input.reshape([1, inputSize, inputSize, 3]);

      final output = List.generate(
        1,
        (_) => List.generate(numValues, (_) => List.filled(numCandidates, 0.0)),
      );

      interpreter.run(input, output);

      // Step 3: Transpose + parse + NMS.
      final detections = _parseAndNms(
        output[0],
        inputSize,
        numClasses,
        numValues,
        numCandidates,
        nmsIouThreshold,
      );

      // Step 4: Serialize (can't send Rect across isolate boundary).
      final serialized = detections
          .map(
            (d) => <String, dynamic>{
              'classId': d.classId,
              'confidence': d.confidence,
              'left': d.left,
              'top': d.top,
              'right': d.right,
              'bottom': d.bottom,
            },
          )
          .toList();

      replyPort.send(serialized);
    } catch (e) {
      dev.log('Isolate inference error: $e', name: 'InferenceIsolate');
      replyPort.send(<Map<String, dynamic>>[]);
    }
  }
}

// ---------------------------------------------------------------------------
// Delegate loading chain: GPU → NNAPI → XNNPack+CPU.
// ---------------------------------------------------------------------------

Future<Interpreter?> _tryLoadWithDelegates(Uint8List modelBytes) async {
  const tag = 'InferenceIsolate';

  // Attempt 1: GPU delegate (fastest if hardware supports it).
  try {
    final opts = InterpreterOptions()..threads = 2;
    if (Platform.isAndroid) {
      opts.addDelegate(GpuDelegateV2());
    } else if (Platform.isIOS) {
      opts.addDelegate(GpuDelegate());
    }
    final interp = Interpreter.fromBuffer(modelBytes, options: opts);
    interp.allocateTensors();
    dev.log(
      'Model loaded (GPU) — ${interp.getOutputTensor(0).shape}',
      name: tag,
    );
    return interp;
  } catch (e) {
    dev.log('GPU failed: $e', name: tag);
  }

  // Attempt 2: CoreML delegate (iOS only — Apple Neural Engine).
  if (Platform.isIOS) {
    try {
      final opts = InterpreterOptions()..threads = 2;
      opts.addDelegate(CoreMlDelegate());
      final interp = Interpreter.fromBuffer(modelBytes, options: opts);
      interp.allocateTensors();
      dev.log(
        'Model loaded (CoreML) — ${interp.getOutputTensor(0).shape}',
        name: tag,
      );
      return interp;
    } catch (e) {
      dev.log('CoreML failed: $e', name: tag);
    }
  }

  // Attempt 3: XNNPack + CPU (industry standard, works everywhere).
  try {
    final opts = InterpreterOptions()
      ..threads = 4
      ..addDelegate(XNNPackDelegate());
    final interp = Interpreter.fromBuffer(modelBytes, options: opts);
    interp.allocateTensors();
    dev.log(
      'Model loaded (XNNPack CPU 4 threads) — ${interp.getOutputTensor(0).shape}',
      name: tag,
    );
    return interp;
  } catch (e) {
    dev.log('XNNPack failed: $e', name: tag);
  }

  // Attempt 4: Plain CPU fallback (no delegates).
  try {
    final opts = InterpreterOptions()..threads = 4;
    final interp = Interpreter.fromBuffer(modelBytes, options: opts);
    interp.allocateTensors();
    dev.log(
      'Model loaded (plain CPU 4 threads) — ${interp.getOutputTensor(0).shape}',
      name: tag,
    );
    return interp;
  } catch (e) {
    dev.log('Plain CPU failed: $e', name: tag);
  }

  return null;
}

// ---------------------------------------------------------------------------
// Warm-up: eliminates first-frame JIT lag.
// ---------------------------------------------------------------------------

void _warmUp(Interpreter interpreter) {
  const inputSize = 320;
  const numValues = 84;
  const numCandidates = 2100;

  final dummyInput = Float32List(
    inputSize * inputSize * 3,
  ).reshape([1, inputSize, inputSize, 3]);
  final dummyOutput = List.generate(
    1,
    (_) => List.generate(numValues, (_) => List.filled(numCandidates, 0.0)),
  );

  try {
    interpreter.run(dummyInput, dummyOutput);
    dev.log('Warm-up inference complete', name: 'InferenceIsolate');
  } catch (e) {
    dev.log('Warm-up failed (non-fatal): $e', name: 'InferenceIsolate');
  }
}

// ---------------------------------------------------------------------------
// Lightweight detection record for isolate serialization.
// ---------------------------------------------------------------------------

class _RawDetection {
  final int classId;
  final double confidence;
  final double left, top, right, bottom;
  const _RawDetection({
    required this.classId,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

// ---------------------------------------------------------------------------
// Parse + NMS (same logic as ModelHandler, but standalone for isolate).
// ---------------------------------------------------------------------------

List<_RawDetection> _parseAndNms(
  List<List<double>> output84x2100,
  int inputSize,
  int numClasses,
  int numValues,
  int numCandidates,
  double nmsIouThreshold,
) {
  final candidates = <_RawDetection>[];

  for (int i = 0; i < numCandidates; i++) {
    int bestClassId = 0;
    double bestScore = 0.0;

    for (int c = 0; c < numClasses; c++) {
      final score = output84x2100[4 + c][i];
      if (score > bestScore) {
        bestScore = score;
        bestClassId = c;
      }
    }

    final threshold = (bestClassId == 62 || bestClassId == 63)
        ? monitorConfidenceThreshold
        : confidenceThreshold;
    if (bestScore < threshold) continue;

    final cx = output84x2100[0][i];
    final cy = output84x2100[1][i];
    final w = output84x2100[2][i];
    final h = output84x2100[3][i];

    candidates.add(
      _RawDetection(
        classId: bestClassId,
        confidence: bestScore,
        left: ((cx - w / 2) / inputSize).clamp(0.0, 1.0),
        top: ((cy - h / 2) / inputSize).clamp(0.0, 1.0),
        right: ((cx + w / 2) / inputSize).clamp(0.0, 1.0),
        bottom: ((cy + h / 2) / inputSize).clamp(0.0, 1.0),
      ),
    );
  }

  return _applyNms(candidates, nmsIouThreshold);
}

List<_RawDetection> _applyNms(
  List<_RawDetection> candidates,
  double iouThreshold,
) {
  if (candidates.isEmpty) return [];

  final byClass = <int, List<_RawDetection>>{};
  for (final d in candidates) {
    (byClass[d.classId] ??= []).add(d);
  }

  final results = <_RawDetection>[];
  for (final group in byClass.values) {
    group.sort((a, b) => b.confidence.compareTo(a.confidence));
    final suppressed = List.filled(group.length, false);

    for (int i = 0; i < group.length; i++) {
      if (suppressed[i]) continue;
      results.add(group[i]);
      for (int j = i + 1; j < group.length; j++) {
        if (suppressed[j]) continue;
        if (_computeIou(group[i], group[j]) > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
  }
  return results;
}

double _computeIou(_RawDetection a, _RawDetection b) {
  final interLeft = max(a.left, b.left);
  final interTop = max(a.top, b.top);
  final interRight = min(a.right, b.right);
  final interBottom = min(a.bottom, b.bottom);

  if (interRight <= interLeft || interBottom <= interTop) return 0.0;

  final interArea = (interRight - interLeft) * (interBottom - interTop);
  final aArea = (a.right - a.left) * (a.bottom - a.top);
  final bArea = (b.right - b.left) * (b.bottom - b.top);

  return interArea / (aArea + bArea - interArea);
}
