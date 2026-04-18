import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

import '../../step2_pose/domain/pose_landmark.dart';

/// Blurs the face region in a captured image using landmark positions.
///
/// Uses nose + ear landmarks to compute face bounding box with generous
/// margin, then applies Gaussian blur to that region only.
abstract final class FaceBlurrer {
  /// Blur face in image at [imagePath] using [landmarks].
  ///
  /// Returns the path to the blurred image (overwrites original).
  static Future<String> blurFace({
    required String imagePath,
    required List<PoseLandmark> landmarks,
    int blurRadius = 25,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return imagePath;

    final noseLm = landmarks.where((l) => l.part == BodyPart.nose).firstOrNull;
    final earLm = landmarks.where((l) => l.part == BodyPart.ear).firstOrNull;

    if (noseLm == null && earLm == null) return imagePath;

    // Compute face center from available landmarks.
    final cx = (noseLm?.x ?? earLm!.x) * image.width;
    final cy = (noseLm?.y ?? earLm!.y) * image.height;

    // Estimate face size from nose-ear distance or fallback to 15% of height.
    double faceRadius;
    if (noseLm != null && earLm != null) {
      final dx = (noseLm.x - earLm.x) * image.width;
      final dy = (noseLm.y - earLm.y) * image.height;
      faceRadius = sqrt(dx * dx + dy * dy) * 1.8; // Generous margin.
    } else {
      faceRadius = image.height * 0.08;
    }

    // Compute bounding box.
    final left = (cx - faceRadius).round().clamp(0, image.width - 1);
    final top = (cy - faceRadius).round().clamp(0, image.height - 1);
    final right = (cx + faceRadius).round().clamp(0, image.width - 1);
    final bottom = (cy + faceRadius).round().clamp(0, image.height - 1);

    if (right <= left || bottom <= top) return imagePath;

    // Extract face region, blur it, then paste it back.
    final faceRegion = img.copyCrop(
      image,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
    final blurred = img.gaussianBlur(faceRegion, radius: blurRadius);

    img.compositeImage(image, blurred, dstX: left, dstY: top);

    // Save.
    final encoded = img.encodeJpg(image, quality: 90);
    await file.writeAsBytes(encoded);

    return imagePath;
  }
}
