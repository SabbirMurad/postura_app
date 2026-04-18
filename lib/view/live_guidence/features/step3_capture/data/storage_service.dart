import 'dart:io';
import 'dart:developer' as dev;
import '../domain/storage_config.dart';

/// Manages captured image persistence based on [StorageConfig].
///
/// Decides whether to keep, delete, or skip raw/annotated images
/// after analysis completes. Score data is always returned to the
/// caller — only image files are managed here.
class StorageService {
  StorageService({StorageConfig config = StorageConfig.defaults})
    : _config = config;

  StorageConfig _config;

  /// Current storage configuration.
  StorageConfig get config => _config;

  /// Update the storage configuration at runtime
  /// (e.g., from an enterprise admin settings screen).
  void updateConfig(StorageConfig newConfig) {
    _config = newConfig;
    dev.log(
      'Storage config updated: option=${newConfig.option.name}, '
      'autoDelete=${newConfig.autoDelete}',
      name: 'StorageService',
    );
  }

  /// Apply storage policy to the captured raw image.
  ///
  /// Returns the path if the image should be kept, or null if deleted.
  Future<String?> applyToRawImage(String imagePath) async {
    if (_config.keepRawImage) {
      dev.log('Keeping raw image: $imagePath', name: 'StorageService');
      return imagePath;
    }

    // Delete the file.
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        dev.log('Deleted raw image: $imagePath', name: 'StorageService');
      }
    } catch (e) {
      dev.log('Failed to delete raw image: $e', name: 'StorageService');
    }
    return null;
  }

  /// Apply storage policy to an annotated image (with skeleton overlay).
  ///
  /// Returns the path if it should be kept, or null if deleted.
  Future<String?> applyToAnnotatedImage(String imagePath) async {
    if (_config.keepAnnotatedImage) {
      dev.log('Keeping annotated image: $imagePath', name: 'StorageService');
      return imagePath;
    }

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        dev.log('Deleted annotated image: $imagePath', name: 'StorageService');
      }
    } catch (e) {
      dev.log('Failed to delete annotated image: $e', name: 'StorageService');
    }
    return null;
  }
}
