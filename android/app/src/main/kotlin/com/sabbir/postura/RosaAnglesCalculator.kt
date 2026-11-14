package com.sabbir.postura

import kotlin.math.*

object RosaAnglesCalculator {

    private const val NOSE           = 0
    private const val LEFT_EAR       = 7
    private const val RIGHT_EAR      = 8
    private const val LEFT_SHOULDER  = 11
    private const val RIGHT_SHOULDER = 12
    private const val LEFT_ELBOW     = 13
    private const val RIGHT_ELBOW    = 14
    private const val LEFT_WRIST     = 15
    private const val RIGHT_WRIST    = 16
    private const val LEFT_HIP       = 23
    private const val RIGHT_HIP      = 24
    private const val LEFT_KNEE      = 25
    private const val RIGHT_KNEE     = 26
    private const val LEFT_ANKLE     = 27
    private const val RIGHT_ANKLE    = 28

    enum class NeckState { NEUTRAL, FORWARD_HEAD, MILD_FLEXION, SEVERE_FLEXION, HEAD_BACK }

    // HIGH = knee angle is measured (or proxied from a visible knee); LOW = the
    // knee itself was occluded and reconstructed, so the seat-height score is
    // a best-effort guess.
    enum class LowerBodyConfidence { HIGH, LOW }

    data class Angles(
        val isLeftSide: Boolean,    // which side was selected (true = left landmarks used)
        val kneeAngle: Float,       // degrees — seat height
        val trunkAngle: Float,      // degrees from vertical — backrest
        val elbowAngle: Float,      // degrees shoulder→elbow→wrist — arm/keyboard
        val neckAngle: Float,       // degrees from vertical — neck/monitor score
        // The four offsets are in torso lengths × the reference torso size (see
        // REF_TORSO_H / REF_TORSO_W), i.e. frame fractions at the reference setup.
        val shrugGap: Float,        // ear.y − shoulder.y — armrest
        val neckFlexY: Float,       // ear.y − nose.y — neck flexion (raw)
        val neckState: NeckState,   // derived neck posture state — used for ROSA scoring
        val wristExtension: Float,  // elbow.y − wrist.y — keyboard
        val mouseReach: Float,      // |wrist.x − shoulder.x| — mouse
        val lowerBodyConfidence: LowerBodyConfidence, // reliability of kneeAngle
        // trunkAngle signed: + leaning back, − leaning forward. Null when the
        // knee doesn't show which way the person faces. Recommendation only;
        // the ROSA backrest score keeps using trunkAngle.
        val trunkRecline: Float? = null,
        // Degrees the knee sits below the hip along the thigh (− = knee above
        // hip). Tells feet tucked under the chair (sharp knee angle, level
        // thigh) from a chair that is too low. Null when the knee was hidden.
        val thighSlope: Float? = null,
    ) {
        /// The measured body angles, for the Flutter review screen, plus the raw
        /// normalized offsets the scorer uses (shrugGap, wristExtension,
        /// mouseReach). Those are not shown; they are sent to the backend so it
        /// can score a photos-only scan once the ergonomist answers the checklist.
        ///
        /// [mirrored]: the frame was mirrored before pose detection (front
        /// camera), so the model's left/right labels are swapped relative to the
        /// person's real body side.
        fun toMap(mirrored: Boolean = false): Map<String, Any> = hashMapOf<String, Any>(
            "side"                  to if (isLeftSide != mirrored) "Left" else "Right",
            "knee_angle"            to kneeAngle.toDouble(),
            "trunk_angle"           to trunkAngle.toDouble(),
            "elbow_angle"           to elbowAngle.toDouble(),
            "neck_angle"            to neckAngle.toDouble(),
            "neck_state"            to neckState.name,
            "lower_body_confidence" to lowerBodyConfidence.name,
            "shrug_gap"             to shrugGap.toDouble(),
            "wrist_extension"       to wristExtension.toDouble(),
            "mouse_reach"           to mouseReach.toDouble(),
        ).apply {
            trunkRecline?.let { put("trunk_recline", it.toDouble()) }
            thighSlope?.let { put("thigh_slope", it.toDouble()) }
        }
    }

    // The scorer's offset cutoffs (shrug −0.06, wrist 0.03, mouse reach 0.18) were
    // tuned as fractions of a 480×640 frame with the person 1.7–2.1 m away, where
    // the shoulder→hip length is about 0.19 of the frame height. Offsets are now
    // measured in torso lengths and scaled by these reference sizes, so the same
    // cutoffs (here and on the backend) hold for any lens, resolution or distance.
    private const val REF_TORSO_H = 0.19f           // torso / frame height
    private const val REF_TORSO_W = 0.19f * 4f / 3f // torso / frame width (3:4 frame)

    // Neck posture cutoffs, in true degrees. Head pitch is the ear→nose line below
    // horizontal; it sits around 12° (6–17°) when looking at an eye-level monitor
    // and about 22° looking down at a laptop in the reference scans.
    private const val HEAD_BACK_MAX_PITCH_DEG      = -5f
    private const val MILD_FLEXION_MIN_PITCH_DEG   = 20f
    private const val SEVERE_FLEXION_MIN_PITCH_DEG = 35f
    private const val FORWARD_HEAD_MIN_NECK_DEG    = 20f

    /**
     * [landmarks] are normalised (0–1); [imageWidth]×[imageHeight] is the frame
     * they were detected on. Everything is measured in pixels: normalised x and y
     * use different scales on a non-square frame, which skews every angle.
     *
     * [forceLeft] pins which body side is measured (true = left landmarks), so
     * the shots of one scan all measure the same side; null picks it here.
     */
    fun compute(
        landmarks: List<LandmarkPoint>,
        imageWidth: Int,
        imageHeight: Int,
        forceLeft: Boolean? = null,
    ): Angles? {
        if (landmarks.size < 29 || imageWidth <= 0 || imageHeight <= 0) return null
        val lm = landmarks.map {
            LandmarkPoint(it.x * imageWidth, it.y * imageHeight, it.estimated)
        }

        val nose = lm[NOSE]

        // Near (visible) side — in a side view the near ear sits farther from
        // the nose in 2D than the occluded far ear.
        val leftEarDist  = hypot(nose.x - lm[LEFT_EAR].x,  nose.y - lm[LEFT_EAR].y)
        val rightEarDist = hypot(nose.x - lm[RIGHT_EAR].x, nose.y - lm[RIGHT_EAR].y)
        // Near (camera-facing) side. The visibly-detected leg — the one MediaPipe
        // actually saw, rather than LegEstimator reconstructing it — is a reliable
        // near-side signal in a profile view. The ear heuristic alone is unreliable
        // here (both ears project near the back of the head), so it's only a
        // fallback when leg visibility is ambiguous.
        val leftLegVisible  = !lm[LEFT_KNEE].estimated
        val rightLegVisible = !lm[RIGHT_KNEE].estimated
        val useLeft = forceLeft ?: when {
            leftLegVisible && !rightLegVisible -> true
            rightLegVisible && !leftLegVisible -> false
            else                               -> leftEarDist >= rightEarDist
        }

        val ear      = if (useLeft) lm[LEFT_EAR]      else lm[RIGHT_EAR]
        val shoulder = if (useLeft) lm[LEFT_SHOULDER]  else lm[RIGHT_SHOULDER]
        val elbow    = if (useLeft) lm[LEFT_ELBOW]     else lm[RIGHT_ELBOW]
        val wrist    = if (useLeft) lm[LEFT_WRIST]     else lm[RIGHT_WRIST]
        val hip      = if (useLeft) lm[LEFT_HIP]       else lm[RIGHT_HIP]
        val knee     = if (useLeft) lm[LEFT_KNEE]      else lm[RIGHT_KNEE]
        val ankle    = if (useLeft) lm[LEFT_ANKLE]     else lm[RIGHT_ANKLE]

        // Knee/ankle may be reconstructed (LegEstimator) when occluded. A fabricated
        // ankle straight below the knee distorts angleBetween(), so when only the
        // ankle is estimated, fall back to a hip-knee vertical-gap proxy — the same
        // category a trained observer would read off a visible knee. If the knee
        // itself is estimated, keep the geometric angle but flag low confidence.
        // Shoulder→hip length in pixels: the body-size unit for every offset below.
        val torso = hypot(shoulder.x - hip.x, shoulder.y - hip.y)
        if (torso < 1f) return null

        val kneeDrop = (knee.y - hip.y) / torso
        val gapProxyAngle = when {
            kneeDrop < -0.1f -> 70f
            kneeDrop > 0.8f  -> 115f
            else                      -> 92f
        }
        val (kneeAngle, lowerBodyConfidence) = when {
            knee.estimated -> gapProxyAngle to LowerBodyConfidence.LOW
            // A proxy is one of three fixed values, not a measurement.
            ankle.estimated -> gapProxyAngle to LowerBodyConfidence.LOW
            else -> {
                val measured = angleBetween(hip, knee, ankle)
                // >160° is essentially a straight leg — implausible while seated and
                // more likely a pose-estimation glitch than a real measurement.
                if (measured > 160f) gapProxyAngle to LowerBodyConfidence.LOW
                else measured to LowerBodyConfidence.HIGH
            }
        }
        val thighSlope = if (knee.estimated) null else
            (atan2((knee.y - hip.y).toDouble(), abs(knee.x - hip.x).toDouble()) * (180.0 / PI)).toFloat()
        val elbowAngle = angleBetween(shoulder, elbow, wrist)

        val dx = abs(hip.x - shoulder.x).toDouble()
        val dy = abs(hip.y - shoulder.y).toDouble()
        val trunkAngle = if (dy < 1e-6) 90f else (atan2(dx, dy) * (180.0 / PI)).toFloat()
        // Seated in profile, the knee is in front of the hip, which gives the
        // facing direction. A shoulder behind the hip is a recline.
        val facing = (knee.x - hip.x) / torso
        val trunkRecline = if (abs(facing) < 0.08f) null
            else if ((shoulder.x - hip.x) * facing <= 0f) trunkAngle else -trunkAngle

        val neckDx    = abs(ear.x - shoulder.x).toDouble()
        val neckDy    = abs(shoulder.y - ear.y).toDouble()
        val neckAngle = if (neckDy < 1e-6) 90f else (atan2(neckDx, neckDy) * (180.0 / PI)).toFloat()

        val shrugGap  = (ear.y - shoulder.y) / torso * REF_TORSO_H
        val neckFlexY = (ear.y - nose.y) / torso * REF_TORSO_H

        // The nose is in front of the ear, which gives the way the head faces —
        // so the rules below work whichever way the person sits.
        val headFacing = if (nose.x >= ear.x) 1f else -1f
        // Ear→nose line below horizontal (image y grows downward): + looking
        // down, − looking up.
        val headPitch = (atan2((nose.y - ear.y).toDouble(), abs(nose.x - ear.x).toDouble())
            * (180.0 / PI)).toFloat()
        // Neck angle signed: + when the ear is ahead of the shoulder.
        val forwardNeck = if ((ear.x - shoulder.x) * headFacing > 0f) neckAngle else -neckAngle

        val neckState = when {
            headPitch <= HEAD_BACK_MAX_PITCH_DEG      -> NeckState.HEAD_BACK
            headPitch >= SEVERE_FLEXION_MIN_PITCH_DEG -> NeckState.SEVERE_FLEXION
            headPitch >= MILD_FLEXION_MIN_PITCH_DEG   -> NeckState.MILD_FLEXION
            forwardNeck >= FORWARD_HEAD_MIN_NECK_DEG  -> NeckState.FORWARD_HEAD
            else                                      -> NeckState.NEUTRAL
        }

        val wristExtension = (elbow.y - wrist.y) / torso * REF_TORSO_H
        val mouseReach     = abs(wrist.x - shoulder.x) / torso * REF_TORSO_W

        return Angles(useLeft, kneeAngle, trunkAngle, elbowAngle, neckAngle, shrugGap, neckFlexY, neckState, wristExtension, mouseReach, lowerBodyConfidence, trunkRecline, thighSlope)
    }

    private fun angleBetween(p1: LandmarkPoint, vertex: LandmarkPoint, p2: LandmarkPoint): Float {
        val ax = (p1.x - vertex.x).toDouble()
        val ay = (p1.y - vertex.y).toDouble()
        val bx = (p2.x - vertex.x).toDouble()
        val by = (p2.y - vertex.y).toDouble()
        val dot = ax * bx + ay * by
        val m1  = sqrt(ax * ax + ay * ay)
        val m2  = sqrt(bx * bx + by * by)
        if (m1 < 1e-6 || m2 < 1e-6) return 90f
        return (acos((dot / (m1 * m2)).coerceIn(-1.0, 1.0)) * (180.0 / PI)).toFloat()
    }
}
