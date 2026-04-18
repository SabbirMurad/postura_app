import 'dart:io';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;
import 'package:image/image.dart' as img;

import '../../../core/constants/pose_constants.dart';
import '../../step2_pose/domain/pose_landmark.dart';
import '../../step2_pose/domain/pose_result.dart';
import '../../step2_pose/domain/side_selector.dart';
import '../../step3_capture/data/rosa_scorer.dart';
import '../../step3_capture/domain/rosa_score.dart';

/// Runs ML Kit pose detection + ROSA scoring on a single static image file.
///
/// Uses [PoseDetectionMode.single] (not stream) and
/// [InputImage.fromFilePath] — no smoothing, one clean detection pass.
class StaticImageScorer {
  mlkit.PoseDetector? _detector;

  Future<void> initialize() async {
    _detector = mlkit.PoseDetector(
      options: mlkit.PoseDetectorOptions(
        model: mlkit.PoseDetectionModel.accurate,
        mode: mlkit.PoseDetectionMode.single,
      ),
    );
  }

  /// Score one photo. Returns null if no pose detected.
  Future<RosaScore?> scoreImage(
    String imagePath, {
    int mouseCb = 1,
    int durationModifier = 1,
  }) async {
    if (_detector == null) await initialize();

    // 1. ML Kit detection from file path.
    final inputImage = mlkit.InputImage.fromFilePath(imagePath);
    final poses = await _detector!.processImage(inputImage);
    if (poses.isEmpty) return null;
    final pose = poses.first;

    // 2. Get image dimensions for coordinate normalization.
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final imgW = decoded.width.toDouble();
    final imgH = decoded.height.toDouble();

    // 3. Extract side likelihoods.
    final (leftScores, rightScores) = _extractSideLikelihoods(pose);

    // 4. Pick active side — run SideSelector 6 times to exceed hysteresis.
    final sideSelector = SideSelector();
    late BodyOrientation activeSide;
    for (int i = 0; i < 6; i++) {
      activeSide = sideSelector.update(rightScores, leftScores);
    }
    if (activeSide == BodyOrientation.unknown) {
      // Default to whichever side has higher average likelihood.
      final leftAvg = leftScores.isEmpty
          ? 0.0
          : leftScores.reduce((a, b) => a + b) / leftScores.length;
      final rightAvg = rightScores.isEmpty
          ? 0.0
          : rightScores.reduce((a, b) => a + b) / rightScores.length;
      activeSide = leftAvg >= rightAvg
          ? BodyOrientation.left
          : BodyOrientation.right;
    }

    // 5. Extract 8 normalized landmarks for active side.
    final landmarks = _extractActiveSideLandmarks(pose, activeSide, imgW, imgH);
    if (landmarks.length < 6) return null;

    // 6. Score.
    final scorer = RosaScorer();
    return scorer.score(
      landmarks,
      mouseCb: mouseCb,
      durationModifier: durationModifier,
    );
  }

  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }

  // ---------------------------------------------------------------------------
  // Helpers — copied from real_pose_detector.dart
  // ---------------------------------------------------------------------------

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

  List<PoseLandmark> _extractActiveSideLandmarks(
    mlkit.Pose pose,
    BodyOrientation side,
    double imageWidth,
    double imageHeight,
  ) {
    final useAnatomicalLeft = side == BodyOrientation.right;

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
