import 'package:camera/camera.dart';

import '../../../core/constants/rosa_constants.dart';
import '../../../services/camera_service.dart';

/// Analyzes camera frame brightness by sampling the Y-plane (luminance).
///
/// Sparse sampling: reads every Nth pixel for speed (<5ms on 1080p).
abstract final class LuminanceAnalyzer {
  /// Returns average luminance (0.0–1.0) from a camera frame.
  static double analyze(CopiedCameraFrame frame) {
    if (frame.formatGroup == ImageFormatGroup.yuv420) {
      return _analyzeYuv420(frame);
    } else {
      return _analyzeBgra8888(frame);
    }
  }

  /// Whether luminance is within acceptable range.
  static bool isAcceptable(double luminance) {
    return luminance >= RosaConstants.minLuminance &&
        luminance <= RosaConstants.maxLuminance;
  }

  /// Guidance text for current luminance.
  static String? guidanceFor(double luminance) {
    if (luminance < RosaConstants.minLuminance) {
      return 'Increase lighting';
    }
    if (luminance > RosaConstants.maxLuminance) {
      return 'Avoid bright window behind the worker';
    }
    return null; // Acceptable.
  }

  /// Android YUV420: Y-plane bytes are direct luminance values (0-255).
  static double _analyzeYuv420(CopiedCameraFrame frame) {
    final yPlane = frame.planes[0];
    final bytesPerRow = yPlane.bytesPerRow;
    final bytes = yPlane.bytes;
    final step = RosaConstants.luminanceSampleStep;

    int sum = 0;
    int count = 0;
    for (int y = 0; y < frame.height; y += step) {
      final rowOffset = y * bytesPerRow;
      for (int x = 0; x < frame.width; x += step) {
        if (rowOffset + x < bytes.length) {
          sum += bytes[rowOffset + x];
          count++;
        }
      }
    }
    return count > 0 ? (sum / count) / 255.0 : 0.5;
  }

  /// iOS BGRA8888: compute luminance from RGB per sampled pixel.
  static double _analyzeBgra8888(CopiedCameraFrame frame) {
    final bytes = frame.planes[0].bytes;
    final bytesPerRow = frame.planes[0].bytesPerRow;
    final step = RosaConstants.luminanceSampleStep;

    double sum = 0;
    int count = 0;
    for (int y = 0; y < frame.height; y += step) {
      final rowOffset = y * bytesPerRow;
      for (int x = 0; x < frame.width; x += step) {
        final pixelOffset = rowOffset + x * 4;
        if (pixelOffset + 2 < bytes.length) {
          final b = bytes[pixelOffset];
          final g = bytes[pixelOffset + 1];
          final r = bytes[pixelOffset + 2];
          // ITU-R BT.601 luminance formula.
          sum += 0.299 * r + 0.587 * g + 0.114 * b;
          count++;
        }
      }
    }
    return count > 0 ? (sum / count) / 255.0 : 0.5;
  }
}
