import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../services/camera_service.dart';

/// Target dimensions for YOLOv8n input tensor.
const int _modelInputSize = 320;

/// Total bytes in the output RGB buffer: 320 * 320 * 3.
const int _outputBufferSize = _modelInputSize * _modelInputSize * 3;

/// Converts a [CopiedCameraFrame] to a flat RGB [Uint8List] of size 320x320x3,
/// suitable for feeding into the YOLOv8n input tensor.
///
/// Pipeline matches the official TensorFlow Flutter example:
///   1. Convert raw bytes → img.Image (platform-specific)
///   2. Rotate 90° CW on Android only (iOS frames are already portrait)
///   3. Resize to 320x320 with area-averaging interpolation
///   4. Extract flat RGB bytes
Uint8List preprocessCameraImage(CopiedCameraFrame frame) {
  // Step 1: Convert raw camera bytes to a full-resolution img.Image.
  img.Image image = switch (frame.formatGroup) {
    ImageFormatGroup.yuv420 => _yuv420ToImage(frame),
    ImageFormatGroup.bgra8888 => _bgra8888ToImage(frame),
    _ => throw UnsupportedError(
      'Unsupported camera image format: ${frame.formatGroup}',
    ),
  };

  // Step 2: Rotation — only Android needs it.
  // iOS camera plugin delivers frames already in display orientation.
  // Android camera delivers landscape frames from the sensor.
  // Reference: TensorFlow official Flutter example (detector_service.dart:237-239)
  if (Platform.isAndroid) {
    image = img.copyRotate(image, angle: 90);
  }

  // Step 3: Resize to 320x320 with area-averaging interpolation.
  final resized = img.copyResize(
    image,
    width: _modelInputSize,
    height: _modelInputSize,
    interpolation: img.Interpolation.average,
  );

  // Step 4: Extract flat RGB bytes.
  return _extractRgbBytes(resized);
}

/// Converts YUV420 (Android) camera frame to an [img.Image] at full resolution.
img.Image _yuv420ToImage(CopiedCameraFrame frame) {
  final int w = frame.width;
  final int h = frame.height;

  final yPlane = frame.planes[0];
  final uPlane = frame.planes[1];
  final vPlane = frame.planes[2];

  final int yRowStride = yPlane.bytesPerRow;
  final int uvRowStride = uPlane.bytesPerRow;
  final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

  final yBytes = yPlane.bytes;
  final uBytes = uPlane.bytes;
  final vBytes = vPlane.bytes;

  final result = img.Image(width: w, height: h);

  for (int row = 0; row < h; row++) {
    final int uvRow = row >> 1;
    for (int col = 0; col < w; col++) {
      final int y = yBytes[row * yRowStride + col];

      final int uvCol = col >> 1;
      final int uvIndex = uvRow * uvRowStride + uvCol * uvPixelStride;
      final int u = uBytes[uvIndex];
      final int v = vBytes[uvIndex];

      // BT.601 YUV → RGB conversion.
      final int r = (y + 1.402 * (v - 128)).round().clamp(0, 255);
      final int g = (y - 0.344136 * (u - 128) - 0.714136 * (v - 128))
          .round()
          .clamp(0, 255);
      final int b = (y + 1.772 * (u - 128)).round().clamp(0, 255);

      result.setPixelRgba(col, row, r, g, b, 255);
    }
  }

  return result;
}

/// Converts BGRA8888 (iOS) camera frame to an [img.Image].
/// iOS camera delivers bytes in B,G,R,A order — ChannelOrder.bgra tells
/// the image package to correctly swap R and B when reading pixels.
/// Using .rgba swaps red/blue which kills skin-tone detection (person).
img.Image _bgra8888ToImage(CopiedCameraFrame frame) {
  final plane = frame.planes[0];
  return img.Image.fromBytes(
    width: frame.width,
    height: frame.height,
    bytes: plane.bytes.buffer,
    numChannels: 4,
    order: img.ChannelOrder.bgra,
    rowStride: plane.bytesPerRow,
  );
}

/// Extracts a flat RGB [Uint8List] from a 320x320 [img.Image].
Uint8List _extractRgbBytes(img.Image image) {
  final output = Uint8List(_outputBufferSize);
  int idx = 0;
  for (int y = 0; y < _modelInputSize; y++) {
    for (int x = 0; x < _modelInputSize; x++) {
      final pixel = image.getPixel(x, y);
      output[idx++] = pixel.r.toInt();
      output[idx++] = pixel.g.toInt();
      output[idx++] = pixel.b.toInt();
    }
  }
  return output;
}
