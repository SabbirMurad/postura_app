import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;
import '../../../core/constants/pose_constants.dart';
import '../../../services/camera_service.dart';
import '../domain/landmark_smoother.dart';
import '../domain/pose_landmark.dart';
import '../domain/pose_result.dart';
import '../domain/side_selector.dart';
import 'pose_detector.dart';

/// Real pose detector using Google ML Kit (MediaPipe Accurate model).
///
/// Runs on the main isolate — ML Kit uses platform channels and its native
/// code runs inference on its own background thread. The Dart side is not
/// blocked during native processing.
class RealPoseDetector implements PoseDetector {
  mlkit.PoseDetector? _mlkitDetector;
  final LandmarkSmoother _smoother = LandmarkSmoother();
  final SideSelector _sideSelector = SideSelector();
  bool _isShutdown = false;
  int _frameNumber = 0;

  @override
  Future<void> initialize() async {
    _mlkitDetector = mlkit.PoseDetector(
      options: mlkit.PoseDetectorOptions(
        model: mlkit.PoseDetectionModel.accurate,
        mode: mlkit.PoseDetectionMode.stream,
      ),
    );

    dev.log(
      'Pose detector initialized (Accurate, Stream)',
      name: 'RealPoseDetector',
    );
  }

  @override
  Future<PoseResult> processFrame(CopiedCameraFrame frame) async {
    if (_isShutdown || _mlkitDetector == null) {
      return const PoseResult.empty();
    }

    _frameNumber++;

    try {
      // Build InputImage from camera frame.
      final inputImage = _buildInputImage(frame);

      // ML Kit returns coordinates based on the rotated image.
      // Android: sensor delivers landscape (1280x720), rotation=90 → swap to portrait.
      // iOS: camera plugin delivers portrait (720x1280), rotation=90 but DON'T swap
      //       because the frame is already in portrait orientation.
      final isAndroidRotated =
          Platform.isAndroid &&
          (frame.sensorOrientation == 90 || frame.sensorOrientation == 270);
      final imgW = isAndroidRotated
          ? frame.height.toDouble()
          : frame.width.toDouble();
      final imgH = isAndroidRotated
          ? frame.width.toDouble()
          : frame.height.toDouble();

      dev.log(
        'Frame #$_frameNumber: ${frame.width}x${frame.height} '
        'fmt=${frame.formatGroup} rot=${frame.sensorOrientation} '
        'normSize=${imgW}x$imgH',
        name: 'RealPoseDetector',
      );

      // ML Kit inference — async, native runs on its own thread.
      final poses = await _mlkitDetector!.processImage(inputImage);

      dev.log(
        'ML Kit returned ${poses.length} poses',
        name: 'RealPoseDetector',
      );

      if (poses.isEmpty) {
        return PoseResult(
          landmarks: const [],
          activeSide: _sideSelector.currentSide,
          isStable: false,
          frameNumber: _frameNumber,
        );
      }

      // ML Kit returns at most 1 pose in stream mode.
      final pose = poses.first;

      // Extract left and right landmarks + determine active side.
      // ML Kit uses anatomical left/right (person's perspective).
      // Back camera sees the person mirrored — swap left/right
      // so "LEFT SIDE" means the side facing camera's left.
      final (leftLikelihoods, rightLikelihoods) = _extractSideLikelihoods(pose);
      final activeSide = _sideSelector.update(
        rightLikelihoods, // Swap: anatomical right → camera left
        leftLikelihoods, // Swap: anatomical left → camera right
      );

      // Pick the active-side landmarks.
      final rawLandmarks = _extractActiveSideLandmarks(
        pose,
        activeSide,
        imgW,
        imgH,
      );

      // Smooth landmarks with One Euro filter.
      final timestampMs = DateTime.now().millisecondsSinceEpoch;
      final smoothed = _smoother.smooth(rawLandmarks, timestampMs);

      final result = PoseResult(
        landmarks: smoothed,
        activeSide: activeSide,
        isStable: _smoother.isStable,
        frameNumber: _frameNumber,
      );

      dev.log(
        'Pose: ${smoothed.length} landmarks, '
        'side=${activeSide.name}, '
        'reliable=${result.reliableLandmarkCount}/8, '
        'stable=${result.isStable}',
        name: 'RealPoseDetector',
      );

      return result;
    } catch (e) {
      dev.log('Pose detection error: $e', name: 'RealPoseDetector');
      return PoseResult(
        landmarks: const [],
        activeSide: _sideSelector.currentSide,
        isStable: false,
        frameNumber: _frameNumber,
      );
    }
  }

  @override
  Future<void> shutdown() async {
    _isShutdown = true;
    await _mlkitDetector?.close();
    _mlkitDetector = null;
    _smoother.reset();
    _sideSelector.reset();
    dev.log('Pose detector shut down', name: 'RealPoseDetector');
  }

  /// Build ML Kit InputImage from CopiedCameraFrame.
  mlkit.InputImage _buildInputImage(CopiedCameraFrame frame) {
    final rotation = _rotationFromDegrees(frame.sensorOrientation);

    if (frame.formatGroup == ImageFormatGroup.yuv420) {
      // Android: YUV_420_888 → NV21.
      // On most Android devices with pixelStride=2, the V plane already
      // contains interleaved VU data (NV21 layout). Just use Y + V planes.
      final yPlane = frame.planes[0];
      final vPlane =
          frame.planes[2]; // V plane with interleaved VU on most devices
      final uvPixelStride = frame.planes[1].bytesPerPixel ?? 1;

      Uint8List nv21Bytes;

      if (uvPixelStride == 2) {
        // Fast path: V plane is already interleaved VUVU (NV21 native).
        // Just concatenate Y + V plane bytes.
        final ySize = yPlane.bytesPerRow * frame.height;
        nv21Bytes = Uint8List(ySize + vPlane.bytes.length);
        nv21Bytes.setRange(0, ySize, yPlane.bytes);
        nv21Bytes.setRange(ySize, ySize + vPlane.bytes.length, vPlane.bytes);
      } else {
        // Slow path: manually interleave V and U.
        final uPlane = frame.planes[1];
        final w = frame.width;
        final h = frame.height;
        nv21Bytes = Uint8List(w * h * 3 ~/ 2);

        // Copy Y.
        for (int row = 0; row < h; row++) {
          nv21Bytes.setRange(
            row * w,
            row * w + w,
            yPlane.bytes,
            row * yPlane.bytesPerRow,
          );
        }
        // Interleave VU.
        int offset = w * h;
        final uvRowStride = uPlane.bytesPerRow;
        for (int row = 0; row < h ~/ 2; row++) {
          for (int col = 0; col < w ~/ 2; col++) {
            final uvIdx = row * uvRowStride + col;
            nv21Bytes[offset++] = vPlane.bytes[uvIdx];
            nv21Bytes[offset++] = uPlane.bytes[uvIdx];
          }
        }
      }

      return mlkit.InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: mlkit.InputImageMetadata(
          size: Size(frame.width.toDouble(), frame.height.toDouble()),
          rotation: rotation,
          format: mlkit.InputImageFormat.nv21,
          bytesPerRow: yPlane.bytesPerRow,
        ),
      );
    } else {
      // iOS: BGRA8888 — pass bytes directly.
      return mlkit.InputImage.fromBytes(
        bytes: frame.planes[0].bytes,
        metadata: mlkit.InputImageMetadata(
          size: Size(frame.width.toDouble(), frame.height.toDouble()),
          rotation: rotation,
          format: mlkit.InputImageFormat.bgra8888,
          bytesPerRow: frame.planes[0].bytesPerRow,
        ),
      );
    }
  }

  mlkit.InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 0:
        return mlkit.InputImageRotation.rotation0deg;
      case 90:
        return mlkit.InputImageRotation.rotation90deg;
      case 180:
        return mlkit.InputImageRotation.rotation180deg;
      case 270:
        return mlkit.InputImageRotation.rotation270deg;
      default:
        return mlkit.InputImageRotation.rotation0deg;
    }
  }

  /// Extract left and right side likelihoods for side selection.
  (List<double>, List<double>) _extractSideLikelihoods(mlkit.Pose pose) {
    final leftTypes = [
      mlkit.PoseLandmarkType.leftEar,
      mlkit.PoseLandmarkType.leftShoulder,
      mlkit.PoseLandmarkType.leftElbow,
      mlkit.PoseLandmarkType.leftWrist,
      mlkit.PoseLandmarkType.leftHip,
      mlkit.PoseLandmarkType.leftKnee,
      mlkit.PoseLandmarkType.leftAnkle,
    ];
    final rightTypes = [
      mlkit.PoseLandmarkType.rightEar,
      mlkit.PoseLandmarkType.rightShoulder,
      mlkit.PoseLandmarkType.rightElbow,
      mlkit.PoseLandmarkType.rightWrist,
      mlkit.PoseLandmarkType.rightHip,
      mlkit.PoseLandmarkType.rightKnee,
      mlkit.PoseLandmarkType.rightAnkle,
    ];

    final leftScores = <double>[];
    final rightScores = <double>[];

    for (final type in leftTypes) {
      final lm = pose.landmarks[type];
      if (lm != null) leftScores.add(lm.likelihood);
    }
    for (final type in rightTypes) {
      final lm = pose.landmarks[type];
      if (lm != null) rightScores.add(lm.likelihood);
    }

    return (leftScores, rightScores);
  }

  /// Extract the 8 landmarks from the active side, normalized to 0-1.
  List<PoseLandmark> _extractActiveSideLandmarks(
    mlkit.Pose pose,
    BodyOrientation side,
    double imageWidth,
    double imageHeight,
  ) {
    // Back camera mirrors left/right. When camera shows "LEFT SIDE",
    // the person's anatomical RIGHT side faces the camera's left.
    // So we pick the OPPOSITE anatomical side.
    final useAnatomicalLeft = side == BodyOrientation.right;

    // Map: BodyPart → ML Kit landmark type (mirrored).
    final mapping = <BodyPart, mlkit.PoseLandmarkType>{
      BodyPart.nose: mlkit.PoseLandmarkType.nose,
      BodyPart.ear: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftEar
          : mlkit.PoseLandmarkType.rightEar,
      BodyPart.shoulder: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftShoulder
          : mlkit.PoseLandmarkType.rightShoulder,
      BodyPart.elbow: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftElbow
          : mlkit.PoseLandmarkType.rightElbow,
      BodyPart.wrist: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftWrist
          : mlkit.PoseLandmarkType.rightWrist,
      BodyPart.hip: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftHip
          : mlkit.PoseLandmarkType.rightHip,
      BodyPart.knee: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftKnee
          : mlkit.PoseLandmarkType.rightKnee,
      BodyPart.ankle: useAnatomicalLeft
          ? mlkit.PoseLandmarkType.leftAnkle
          : mlkit.PoseLandmarkType.rightAnkle,
    };

    final landmarks = <PoseLandmark>[];

    for (final entry in mapping.entries) {
      final lm = pose.landmarks[entry.value];
      if (lm == null) continue;

      // ML Kit returns pixel coordinates — normalize to 0-1.
      final nx = (lm.x / imageWidth).clamp(0.0, 1.0);
      final ny = (lm.y / imageHeight).clamp(0.0, 1.0);
      final reliable = lm.likelihood >= PoseConstants.minLikelihood;

      landmarks.add(
        PoseLandmark(
          part: entry.key,
          x: nx,
          y: ny,
          likelihood: lm.likelihood,
          isReliable: reliable,
        ),
      );
    }

    return landmarks;
  }
}
