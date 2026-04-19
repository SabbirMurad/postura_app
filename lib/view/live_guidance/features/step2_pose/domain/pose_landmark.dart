/// The 8 body parts tracked for ROSA scoring.
enum BodyPart { nose, ear, shoulder, elbow, wrist, hip, knee, ankle }

/// A single pose landmark with normalized coordinates.
class PoseLandmark {
  /// Which body part this landmark represents.
  final BodyPart part;

  /// Normalized x coordinate (0.0 – 1.0 relative to image width).
  final double x;

  /// Normalized y coordinate (0.0 – 1.0 relative to image height).
  final double y;

  /// ML Kit confidence score (0.0 – 1.0).
  final double likelihood;

  /// Whether this landmark meets the confidence threshold.
  final bool isReliable;

  const PoseLandmark({
    required this.part,
    required this.x,
    required this.y,
    required this.likelihood,
    required this.isReliable,
  });

  PoseLandmark copyWith({
    double? x,
    double? y,
    double? likelihood,
    bool? isReliable,
  }) {
    return PoseLandmark(
      part: part,
      x: x ?? this.x,
      y: y ?? this.y,
      likelihood: likelihood ?? this.likelihood,
      isReliable: isReliable ?? this.isReliable,
    );
  }

  @override
  String toString() =>
      '${part.name}(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}) '
      '${(likelihood * 100).toInt()}%${isReliable ? '' : ' [low]'}';
}
