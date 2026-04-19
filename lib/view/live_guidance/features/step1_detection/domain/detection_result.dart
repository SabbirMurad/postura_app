import 'dart:ui';

/// A single detected object with class, confidence, and bounding box.
class DetectedObject {
  const DetectedObject({
    required this.classId,
    required this.confidence,
    required this.boundingBox,
  });

  final int classId;
  final double confidence;

  /// Bounding box in normalized coordinates (0.0 – 1.0).
  final Rect boundingBox;
}

/// Per-frame result returned by [MlDetector.processFrame].
class DetectionResult {
  const DetectionResult({
    required this.personDetected,
    required this.monitorDetected,
    this.personConfidence,
    this.monitorConfidence,
    this.detectedObjects = const [],
  });

  final bool personDetected;
  final bool monitorDetected;
  final double? personConfidence;
  final double? monitorConfidence;

  /// All detected objects with bounding boxes for overlay drawing.
  final List<DetectedObject> detectedObjects;

  bool get bothDetected => personDetected && monitorDetected;
  bool get isPartial => (personDetected || monitorDetected) && !bothDetected;
}
