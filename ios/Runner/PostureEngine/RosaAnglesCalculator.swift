import Foundation

/// Computes the ROSA-relevant body angles from a side-view set of landmarks.
/// Direct port of the Kotlin `RosaAnglesCalculator`.
enum RosaAnglesCalculator {

    private static let NOSE = 0
    private static let LEFT_EAR = 7
    private static let RIGHT_EAR = 8
    private static let LEFT_SHOULDER = 11
    private static let RIGHT_SHOULDER = 12
    private static let LEFT_ELBOW = 13
    private static let RIGHT_ELBOW = 14
    private static let LEFT_WRIST = 15
    private static let RIGHT_WRIST = 16
    private static let LEFT_HIP = 23
    private static let RIGHT_HIP = 24
    private static let LEFT_KNEE = 25
    private static let RIGHT_KNEE = 26
    private static let LEFT_ANKLE = 27
    private static let RIGHT_ANKLE = 28

    enum NeckState: String {
        case neutral = "NEUTRAL"
        case forwardHead = "FORWARD_HEAD"
        case mildFlexion = "MILD_FLEXION"
        case severeFlexion = "SEVERE_FLEXION"
        case headBack = "HEAD_BACK"
    }

    /// HIGH = knee angle is measured (or proxied from a visible knee); LOW = the
    /// knee itself was occluded and reconstructed, so the seat-height score is a
    /// best-effort guess. Raw value mirrors the Kotlin enum name for the bridge.
    enum LowerBodyConfidence: String { case high = "HIGH", low = "LOW" }

    struct Angles {
        let isLeftSide: Bool
        let kneeAngle: Float
        let trunkAngle: Float
        let elbowAngle: Float
        let neckAngle: Float
        let shrugGap: Float
        let neckFlexY: Float
        let neckState: NeckState
        let wristExtension: Float
        let mouseReach: Float
        let lowerBodyConfidence: LowerBodyConfidence
        /// trunkAngle signed: + leaning back, − leaning forward. Nil when the
        /// knee doesn't show which way the person faces. Recommendation only;
        /// the ROSA backrest score keeps using trunkAngle.
        var trunkRecline: Float? = nil
        /// Degrees the knee sits below the hip along the thigh (− = knee above
        /// hip). Tells feet tucked under the chair (sharp knee angle, level
        /// thigh) from a chair that is too low. Nil when the knee was hidden.
        var thighSlope: Float? = nil

        /// The measured body angles, for the Flutter review screen, plus the raw
        /// normalized offsets the scorer uses (shrugGap, wristExtension,
        /// mouseReach). Those are not shown; they are sent to the backend so it
        /// can score a photos-only scan once the ergonomist answers the checklist.
        ///
        /// `mirrored`: the frame was mirrored before pose detection (front
        /// camera), so the model's left/right labels are swapped relative to the
        /// person's real body side.
        func toMap(mirrored: Bool = false) -> [String: Any] {
            var map: [String: Any] = [
                "side": (isLeftSide != mirrored) ? "Left" : "Right",
                "knee_angle": Double(kneeAngle),
                "trunk_angle": Double(trunkAngle),
                "elbow_angle": Double(elbowAngle),
                "neck_angle": Double(neckAngle),
                "neck_state": neckState.rawValue,
                "lower_body_confidence": lowerBodyConfidence.rawValue,
                "shrug_gap": Double(shrugGap),
                "wrist_extension": Double(wristExtension),
                "mouse_reach": Double(mouseReach),
            ]
            if let r = trunkRecline { map["trunk_recline"] = Double(r) }
            if let t = thighSlope { map["thigh_slope"] = Double(t) }
            return map
        }
    }

    // The scorer's offset cutoffs (shrug −0.06, wrist 0.03, mouse reach 0.18) were
    // tuned as fractions of a 480×640 frame with the person 1.7–2.1 m away, where
    // the shoulder→hip length is about 0.19 of the frame height. Offsets are now
    // measured in torso lengths and scaled by these reference sizes, so the same
    // cutoffs (here and on the backend) hold for any lens, resolution or distance.
    private static let REF_TORSO_H: Float = 0.19             // torso / frame height
    private static let REF_TORSO_W: Float = 0.19 * 4 / 3     // torso / frame width (3:4 frame)

    // Neck posture cutoffs, in true degrees. Head pitch is the ear→nose line below
    // horizontal; it sits around 12° (6–17°) when looking at an eye-level monitor
    // and about 22° looking down at a laptop in the reference scans.
    private static let HEAD_BACK_MAX_PITCH_DEG: Float = -5
    private static let MILD_FLEXION_MIN_PITCH_DEG: Float = 20
    private static let SEVERE_FLEXION_MIN_PITCH_DEG: Float = 35
    private static let FORWARD_HEAD_MIN_NECK_DEG: Float = 20

    /// `landmarks` are normalised (0–1); `imageWidth`×`imageHeight` is the frame
    /// they were detected on. Everything is measured in pixels: normalised x and y
    /// use different scales on a non-square frame, which skews every angle.
    ///
    /// `forceLeft` pins which body side is measured (true = left landmarks), so
    /// the shots of one scan all measure the same side; nil picks it here.
    static func compute(_ landmarks: [LandmarkPoint], imageWidth: Int, imageHeight: Int,
                        forceLeft: Bool? = nil) -> Angles? {
        if landmarks.count < 29 || imageWidth <= 0 || imageHeight <= 0 { return nil }
        let lm = landmarks.map {
            LandmarkPoint(x: $0.x * Float(imageWidth), y: $0.y * Float(imageHeight), estimated: $0.estimated)
        }

        let nose = lm[NOSE]

        // Near (visible) side — in a side view the near ear sits farther from
        // the nose in 2D than the occluded far ear.
        let leftEarDist = hypotf(nose.x - lm[LEFT_EAR].x, nose.y - lm[LEFT_EAR].y)
        let rightEarDist = hypotf(nose.x - lm[RIGHT_EAR].x, nose.y - lm[RIGHT_EAR].y)
        // Near (camera-facing) side. The visibly-detected leg — the one MediaPipe
        // actually saw, rather than LegEstimator reconstructing it — is a reliable
        // near-side signal in a profile view. The ear heuristic alone is unreliable
        // here (in profile both ears project near the back of the head), so it's
        // only a fallback when leg visibility is ambiguous.
        let leftLegVisible = !lm[LEFT_KNEE].estimated
        let rightLegVisible = !lm[RIGHT_KNEE].estimated
        let useLeft: Bool
        if let forced = forceLeft {
            useLeft = forced
        } else if leftLegVisible && !rightLegVisible {
            useLeft = true
        } else if rightLegVisible && !leftLegVisible {
            useLeft = false
        } else {
            useLeft = leftEarDist >= rightEarDist   // near ear sits farther from nose
        }

        let ear = useLeft ? lm[LEFT_EAR] : lm[RIGHT_EAR]
        let shoulder = useLeft ? lm[LEFT_SHOULDER] : lm[RIGHT_SHOULDER]
        let elbow = useLeft ? lm[LEFT_ELBOW] : lm[RIGHT_ELBOW]
        let wrist = useLeft ? lm[LEFT_WRIST] : lm[RIGHT_WRIST]
        let hip = useLeft ? lm[LEFT_HIP] : lm[RIGHT_HIP]
        let knee = useLeft ? lm[LEFT_KNEE] : lm[RIGHT_KNEE]
        let ankle = useLeft ? lm[LEFT_ANKLE] : lm[RIGHT_ANKLE]

        // Knee/ankle may be reconstructed (LegEstimator) when occluded. A fabricated
        // ankle straight below the knee distorts angleBetween(), so when only the
        // ankle is estimated, fall back to a hip-knee vertical-gap proxy.
        // Shoulder→hip length in pixels: the body-size unit for every offset below.
        let torso = hypotf(shoulder.x - hip.x, shoulder.y - hip.y)
        if torso < 1 { return nil }

        let kneeDrop = (knee.y - hip.y) / torso
        let gapProxyAngle: Float
        if kneeDrop < -0.1 {
            gapProxyAngle = 70
        } else if kneeDrop > 0.8 {
            gapProxyAngle = 115
        } else {
            gapProxyAngle = 92
        }

        let kneeAngle: Float
        let lowerBodyConfidence: LowerBodyConfidence
        if knee.estimated {
            kneeAngle = gapProxyAngle
            lowerBodyConfidence = .low
        } else if ankle.estimated {
            // A proxy is one of three fixed values, not a measurement.
            kneeAngle = gapProxyAngle
            lowerBodyConfidence = .low
        } else {
            let measured = angleBetween(hip, knee, ankle)
            // >160° is essentially a straight leg — implausible while seated and
            // more likely a pose-estimation glitch than a real measurement.
            if measured > 160 {
                kneeAngle = gapProxyAngle
                lowerBodyConfidence = .low
            } else {
                kneeAngle = measured
                lowerBodyConfidence = .high
            }
        }

        let thighSlope: Float? = knee.estimated ? nil
            : Float(atan2(Double(knee.y - hip.y), Double(abs(knee.x - hip.x))) * (180.0 / .pi))
        let elbowAngle = angleBetween(shoulder, elbow, wrist)

        let dx = Double(abs(hip.x - shoulder.x))
        let dy = Double(abs(hip.y - shoulder.y))
        let trunkAngle: Float = dy < 1e-6 ? 90 : Float(atan2(dx, dy) * (180.0 / .pi))
        // Seated in profile, the knee is in front of the hip, which gives the
        // facing direction. A shoulder behind the hip is a recline.
        let facing = (knee.x - hip.x) / torso
        let trunkRecline: Float? = abs(facing) < 0.08 ? nil
            : ((shoulder.x - hip.x) * facing <= 0 ? trunkAngle : -trunkAngle)

        let neckDx = Double(abs(ear.x - shoulder.x))
        let neckDy = Double(abs(shoulder.y - ear.y))
        let neckAngle: Float = neckDy < 1e-6 ? 90 : Float(atan2(neckDx, neckDy) * (180.0 / .pi))

        let shrugGap = (ear.y - shoulder.y) / torso * REF_TORSO_H
        let neckFlexY = (ear.y - nose.y) / torso * REF_TORSO_H

        // The nose is in front of the ear, which gives the way the head faces —
        // so the rules below work whichever way the person sits.
        let headFacing: Float = nose.x >= ear.x ? 1 : -1
        // Ear→nose line below horizontal (image y grows downward): + looking
        // down, − looking up.
        let headPitch = Float(atan2(Double(nose.y - ear.y), Double(abs(nose.x - ear.x))) * (180.0 / .pi))
        // Neck angle signed: + when the ear is ahead of the shoulder.
        let forwardNeck = (ear.x - shoulder.x) * headFacing > 0 ? neckAngle : -neckAngle

        let neckState: NeckState
        if headPitch <= HEAD_BACK_MAX_PITCH_DEG {
            neckState = .headBack
        } else if headPitch >= SEVERE_FLEXION_MIN_PITCH_DEG {
            neckState = .severeFlexion
        } else if headPitch >= MILD_FLEXION_MIN_PITCH_DEG {
            neckState = .mildFlexion
        } else if forwardNeck >= FORWARD_HEAD_MIN_NECK_DEG {
            neckState = .forwardHead
        } else {
            neckState = .neutral
        }

        let wristExtension = (elbow.y - wrist.y) / torso * REF_TORSO_H
        let mouseReach = abs(wrist.x - shoulder.x) / torso * REF_TORSO_W

        return Angles(
            isLeftSide: useLeft,
            kneeAngle: kneeAngle,
            trunkAngle: trunkAngle,
            elbowAngle: elbowAngle,
            neckAngle: neckAngle,
            shrugGap: shrugGap,
            neckFlexY: neckFlexY,
            neckState: neckState,
            wristExtension: wristExtension,
            mouseReach: mouseReach,
            lowerBodyConfidence: lowerBodyConfidence,
            trunkRecline: trunkRecline,
            thighSlope: thighSlope
        )
    }

    private static func angleBetween(_ p1: LandmarkPoint, _ vertex: LandmarkPoint, _ p2: LandmarkPoint) -> Float {
        let ax = Double(p1.x - vertex.x)
        let ay = Double(p1.y - vertex.y)
        let bx = Double(p2.x - vertex.x)
        let by = Double(p2.y - vertex.y)
        let dot = ax * bx + ay * by
        let m1 = (ax * ax + ay * ay).squareRoot()
        let m2 = (bx * bx + by * by).squareRoot()
        if m1 < 1e-6 || m2 < 1e-6 { return 90 }
        let cosv = min(max(dot / (m1 * m2), -1.0), 1.0)
        return Float(acos(cosv) * (180.0 / .pi))
    }
}
