/// Configurable storage options for captured photos (per enterprise client).
///
/// Each option controls what gets persisted after capture & analysis.
enum StorageOption {
  /// Option A: Keep blurred raw image + annotated image (with skeleton overlay).
  blurredAndAnnotated,

  /// Option B: Keep only the annotated image (with skeleton overlay).
  annotatedOnly,

  /// Option C: No image — only ROSA score and angle values are kept.
  scoreOnly,
}

/// Storage configuration for a capture session.
class StorageConfig {
  const StorageConfig({required this.option, required this.autoDelete});

  /// Which storage option is active.
  final StorageOption option;

  /// If true, delete all images immediately after analysis completes.
  /// Overrides `option` — score data still persists.
  final bool autoDelete;

  /// Default config: keep blurred + annotated, no auto-delete.
  static const StorageConfig defaults = StorageConfig(
    option: StorageOption.blurredAndAnnotated,
    autoDelete: false,
  );

  /// Whether the raw (blurred) image should be kept.
  bool get keepRawImage =>
      !autoDelete && option == StorageOption.blurredAndAnnotated;

  /// Whether the annotated image should be kept.
  bool get keepAnnotatedImage =>
      !autoDelete &&
      (option == StorageOption.blurredAndAnnotated ||
          option == StorageOption.annotatedOnly);

  /// Whether ANY image is kept.
  bool get keepAnyImage => keepRawImage || keepAnnotatedImage;

  StorageConfig copyWith({StorageOption? option, bool? autoDelete}) {
    return StorageConfig(
      option: option ?? this.option,
      autoDelete: autoDelete ?? this.autoDelete,
    );
  }
}
