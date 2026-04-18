import 'dart:developer' as dev;
import 'dart:math' as math;
import '../../step2_pose/domain/pose_landmark.dart';
import '../../../core/constants/rosa_constants.dart';
import '../domain/rosa_score.dart';
import 'angle_calculator.dart';

/// ROSA scoring engine — exact Dart mirror of the validated Python
/// `score()` function (100% ±1 congruence on 71 photos, Cornell/Sonne 2011).
///
/// Inputs are 8 best-side landmarks — side selection is done upstream in
/// `RealPoseDetector` via `SideSelector`, so the scorer does not need to
/// re-implement Python's "Trick 2 — best side selection".
class RosaScorer {
  /// Compute a ROSA score from pose landmarks.
  ///
  /// [landmarks] — 8 body parts (nose, ear, shoulder, elbow, wrist, hip,
  ///   knee, ankle) already selected from the best visible side.
  /// [mouseCb] — mouse callback modifier: 0 (disabled), 1 (normal), 2 (+1).
  /// [durationModifier] — Cornell ROSA duration rule: -1, 0, or +1.
  RosaScore score(
    List<PoseLandmark> landmarks, {
    int mouseCb = 1,
    int durationModifier = 1,
  }) {
    final map = <BodyPart, PoseLandmark>{
      for (final lm in landmarks) lm.part: lm,
    };

    final nose = map[BodyPart.nose]!;
    final ear = map[BodyPart.ear]!;
    final shoulder = map[BodyPart.shoulder]!;
    final elbow = map[BodyPart.elbow]!;
    final wrist = map[BodyPart.wrist]!;
    final hip = map[BodyPart.hip]!;
    final knee = map[BodyPart.knee]!;
    final ankle = map[BodyPart.ankle]!;

    final int dur = durationModifier;
    const double minVis = RosaConstants.ankleMinVisibility;

    // ── CHAIR: seat height (knee angle) ──────────────────────────
    double kneeAngle;
    if (ankle.likelihood >= minVis && knee.likelihood >= minVis) {
      kneeAngle = AngleCalculator.angleBetween(hip, knee, ankle);
      // Trick 1 — knee sanity check: >160° is physically impossible
      // seated; fall back to knee-hip vertical-gap proxy.
      if (kneeAngle > RosaConstants.kneeSanityMax) {
        kneeAngle = _kneeProxyFromGap(knee.y - hip.y);
      }
    } else if (knee.likelihood >= minVis) {
      // Ankle occluded but knee visible — use proxy directly.
      kneeAngle = _kneeProxyFromGap(knee.y - hip.y);
    } else {
      // Both occluded — neutral default, do not penalise.
      kneeAngle = RosaConstants.kneeProxyMidAngle;
    }

    final int seatHeightScore;
    if (kneeAngle < RosaConstants.kneeNeutralMin) {
      seatHeightScore = 2; // too low
    } else if (kneeAngle > RosaConstants.kneeVeryHighThreshold) {
      seatHeightScore = 3; // very high (feet off floor)
    } else if (kneeAngle > RosaConstants.kneeNeutralMax) {
      seatHeightScore = 2; // too high
    } else {
      seatHeightScore = 1; // neutral
    }

    // ── CHAIR: backrest (trunk angle) ────────────────────────────
    final double trunkAngle = AngleCalculator.trunkAngleFromVertical(
      shoulder,
      hip,
    );
    final int backrestScore =
        trunkAngle > RosaConstants.backrestMaxAngleFromVertical ? 2 : 1;

    // ── CHAIR: armrest (shoulder shrug) ──────────────────────────
    final double shrugGap = ear.y - shoulder.y;
    final int armrestScore = shrugGap > RosaConstants.armrestShrugGapThreshold
        ? 2
        : 1;

    // ── CHAIR: combined via TABLE A ──────────────────────────────
    final int seatCombined = (seatHeightScore + 1).clamp(2, 8);
    final int armsCombined = (armrestScore + backrestScore).clamp(2, 9);
    final int chairScore =
        (RosaConstants.lookupTable(
                  RosaConstants.tableA,
                  seatCombined,
                  armsCombined,
                ) +
                dur)
            .clamp(1, 10);

    // ── MONITOR: neck posture ────────────────────────────────────
    final double neckFlexY = ear.y - nose.y;
    final double noseAboveEar = nose.y - ear.y;
    final double earForward = shoulder.x - ear.x;
    final double earShoulderVert = (ear.y - shoulder.y).abs();

    final int monitorScore;
    if (noseAboveEar > RosaConstants.monitorHeadBackThreshold) {
      monitorScore = 3; // head tilted back
    } else if (earShoulderVert <
            RosaConstants.monitorSevereFlexionEarShoulderVert &&
        neckFlexY > 0) {
      monitorScore = 3; // severe flexion
    } else if (neckFlexY > RosaConstants.monitorMildFlexionNeckY) {
      monitorScore = 2; // mild flexion
    } else if (earForward > RosaConstants.forwardHeadThreshold) {
      monitorScore = 2; // forward head
    } else {
      monitorScore = 1; // neutral
    }

    final int sectB = RosaConstants.lookupTable(
      RosaConstants.tableB,
      (0 + dur).clamp(0, 6),
      (monitorScore + dur).clamp(0, 7),
    );

    // ── KEYBOARD: wrist extension ────────────────────────────────
    // Signed value — kb=3 only when wrist is significantly ABOVE elbow.
    final double wristDelta = elbow.y - wrist.y;
    final int keyboardScore;
    if (wristDelta > RosaConstants.wristExtensionSevere) {
      keyboardScore = 3;
    } else if (wristDelta > RosaConstants.wristExtensionMild) {
      keyboardScore = 2;
    } else {
      keyboardScore = 1;
    }

    // ── MOUSE: lateral reach ─────────────────────────────────────
    int mouseScore;
    if (mouseCb == 0) {
      mouseScore = 1;
    } else {
      final double lateral = (wrist.x - shoulder.x).abs();
      mouseScore = lateral > RosaConstants.mouseReachThreshold ? 2 : 1;
      if (mouseCb == 2) {
        mouseScore = math.min(3, mouseScore + 1);
      }
    }

    final int sectC = RosaConstants.lookupTable(
      RosaConstants.tableC,
      (mouseScore + dur).clamp(0, 7),
      (keyboardScore + dur).clamp(0, 7),
    );

    // ── COMBINE: peripherals → final ─────────────────────────────
    final int peripheralScore = RosaConstants.lookupTable(
      RosaConstants.tableD,
      sectB.clamp(1, 9),
      sectC.clamp(1, 9),
    );

    final int finalScore = RosaConstants.lookupTable(
      RosaConstants.tableE,
      chairScore.clamp(1, 10),
      peripheralScore.clamp(1, 10),
    );

    dev.log(
      '\n'
      '╔══════════════ ROSA DEBUG ══════════════╗\n'
      '║  RAW MEASUREMENTS\n'
      '║  kneeAngle      = ${kneeAngle.toStringAsFixed(1)}°\n'
      '║  trunkAngle     = ${trunkAngle.toStringAsFixed(1)}° (threshold: ${RosaConstants.backrestMaxAngleFromVertical}°)\n'
      '║  shrugGap       = ${shrugGap.toStringAsFixed(4)} (threshold: ${RosaConstants.armrestShrugGapThreshold})\n'
      '║  neckFlexY      = ${neckFlexY.toStringAsFixed(4)} (nose–ear y-gap)\n'
      '║  noseAboveEar   = ${noseAboveEar.toStringAsFixed(4)}\n'
      '║  earForward     = ${earForward.toStringAsFixed(4)} (threshold: ${RosaConstants.forwardHeadThreshold})\n'
      '║  earShoulderVert= ${earShoulderVert.toStringAsFixed(4)}\n'
      '║  wristDelta     = ${wristDelta.toStringAsFixed(4)} (elbow.y - wrist.y)\n'
      '║  lateral        = ${(wrist.x - shoulder.x).abs().toStringAsFixed(4)} (threshold: ${RosaConstants.mouseReachThreshold})\n'
      '╠════════════════════════════════════════╣\n'
      '║  SUB-SCORES\n'
      '║  seatHeightScore= $seatHeightScore\n'
      '║  backrestScore  = $backrestScore  (trunk ${trunkAngle.toStringAsFixed(1)}° ${trunkAngle > RosaConstants.backrestMaxAngleFromVertical ? ">" : "≤"} ${RosaConstants.backrestMaxAngleFromVertical}°)\n'
      '║  armrestScore   = $armrestScore\n'
      '║  monitorScore   = $monitorScore\n'
      '║  keyboardScore  = $keyboardScore\n'
      '║  mouseScore     = $mouseScore\n'
      '╠════════════════════════════════════════╣\n'
      '║  COMBINED\n'
      '║  seatCombined   = $seatCombined  armsCombined= $armsCombined\n'
      '║  chairScore     = $chairScore   (tableA[$seatCombined][$armsCombined] + dur=$dur)\n'
      '║  sectB          = $sectB   (tableB)\n'
      '║  sectC          = $sectC   (tableC)\n'
      '║  peripheralScore= $peripheralScore  (tableD)\n'
      '║  ► FINAL ROSA   = $finalScore  (tableE[$chairScore][$peripheralScore])\n'
      '╚══════════════════════════════════════╝',
      name: 'ROSA',
    );

    return RosaScore(
      finalScore: finalScore,
      chairScore: chairScore,
      monitorScore: monitorScore,
      keyboardScore: keyboardScore,
      mouseScore: mouseScore,
      peripheralScore: peripheralScore,
      seatHeightScore: seatHeightScore,
      backrestScore: backrestScore,
      armrestScore: armrestScore,
      kneeAngle: kneeAngle,
      trunkAngle: trunkAngle,
      neckFlexion: neckFlexY,
      forwardHead: earForward,
      wristExtension: wristDelta,
    );
  }

  /// Discrete knee proxy — Python literal `70 / 92 / 115`.
  double _kneeProxyFromGap(double gap) {
    if (gap < RosaConstants.kneeProxyLowGap) {
      return RosaConstants.kneeProxyLowAngle;
    }
    if (gap > RosaConstants.kneeProxyHighGap) {
      return RosaConstants.kneeProxyHighAngle;
    }
    return RosaConstants.kneeProxyMidAngle;
  }
}
