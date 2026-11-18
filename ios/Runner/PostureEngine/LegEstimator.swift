import Foundation

/// Estimates hidden lower-body landmarks for a seated, side-view subject.
///
/// Stateful — keeps a rolling vote for facing direction so it doesn't flip
/// frame-to-frame. Call `reset()` whenever the camera restarts.
///
/// Direct port of the Kotlin `LegEstimator`; takes `[RawLandmark]` for the raw
/// (visibility-bearing) input instead of MediaPipe's `NormalizedLandmark`.
final class LegEstimator {

    private var lockedFacingSign: Float?
    private var facingVotes: [Float] = []

    func reset() {
        lockedFacingSign = nil
        facingVotes.removeAll()
    }

    /// `aspect` is frame width / height. Normalised x and y use different scales
    /// on a non-square frame, so lengths are measured in frame heights.
    func estimate(raw: [RawLandmark], smoothed: [LandmarkPoint], aspect: Float) -> [LandmarkPoint] {
        if raw.count < 33 || smoothed.count < 33 || aspect <= 0 { return smoothed }

        var out = smoothed

        // ── Torso geometry ───────────────────────────────────────────────────
        let shoulderMidX = (smoothed[Idx.lShoulder].x + smoothed[Idx.rShoulder].x) / 2
        let shoulderMidY = (smoothed[Idx.lShoulder].y + smoothed[Idx.rShoulder].y) / 2
        let hipMidX = (smoothed[Idx.lHip].x + smoothed[Idx.rHip].x) / 2
        let hipMidY = (smoothed[Idx.lHip].y + smoothed[Idx.rHip].y) / 2
        // In frame heights.
        let torsoLen = dist(shoulderMidX * aspect, shoulderMidY, hipMidX * aspect, hipMidY)
        if torsoLen < 0.01 { return smoothed }

        // The thigh runs horizontally, so it is converted back to normalised x.
        let thighLen = torsoLen * Const.thighRatio / aspect
        let shinLen = torsoLen * Const.shinRatio

        // ── Standing guard ────────────────────────────────────────────────────
        let standingThreshold = torsoLen * 0.50
        let standingDetected =
            (isHighConf(raw[Idx.lKnee]) && smoothed[Idx.lKnee].y - hipMidY > standingThreshold) ||
            (isHighConf(raw[Idx.rKnee]) && smoothed[Idx.rKnee].y - hipMidY > standingThreshold)
        if standingDetected { return smoothed }

        // ── Facing direction (nose offset from shoulder midpoint) ─────────────
        updateFacingVote(noseX: smoothed[Idx.nose].x, shoulderMidX: shoulderMidX)
        let facingSign = lockedFacingSign ?? (smoothed[Idx.nose].x > shoulderMidX ? 1 : -1)

        // A knee the pose model reports as visible is still not trusted when the
        // thigh ending at it is too short for this body. The model's visibility
        // score is reliable for joints outside the frame or behind the person's own
        // body, but often stays high when a desk, cloth or bag covers the legs. It
        // then puts the "knee" where the thigh disappears behind the object, and
        // invents a shin and foot below it, which get scored as a real knee angle.
        // A seated thigh seen from the side is about as long as the torso
        // (shoulder to hip): 0.91-1.02 on scans with visible legs, 0.69-0.74 on two
        // with the lower legs behind a cloth-covered desk. Below Const.minThighRatio the
        // knee is treated as hidden: estimated, drawn dashed, and scored through the
        // low-confidence fallback. A thigh angled towards the camera also reads
        // short; that errs the same safe way (no measurement rather than a wrong one).
        // Lengths in frame heights, so x and y count the same on a non-square frame.
        func kneeTrusted(_ hipIdx: Int, _ kneeIdx: Int) -> Bool {
            guard isHighConf(raw[kneeIdx]) else { return false }
            let thigh = dist(smoothed[hipIdx].x * aspect, smoothed[hipIdx].y,
                             smoothed[kneeIdx].x * aspect, smoothed[kneeIdx].y)
            return thigh >= torsoLen * Const.minThighRatio
        }
        let lKneeTrusted = kneeTrusted(Idx.lHip, Idx.lKnee)
        let rKneeTrusted = kneeTrusted(Idx.rHip, Idx.rKnee)

        // ── Left leg (anchored to L_HIP) ──────────────────────────────────────
        let lKneeX: Float
        let lKneeY: Float
        if lKneeTrusted {
            lKneeX = smoothed[Idx.lKnee].x
            lKneeY = smoothed[Idx.lKnee].y
        } else {
            lKneeX = smoothed[Idx.lHip].x + facingSign * thighLen
            lKneeY = smoothed[Idx.lHip].y + Const.seatedThighDrop * torsoLen
            out[Idx.lKnee] = LandmarkPoint(x: lKneeX, y: lKneeY, estimated: true)
        }
        // An ankle hanging off an untrusted knee is not trusted either.
        if !isHighConf(raw[Idx.lAnkle]) || !lKneeTrusted {
            out[Idx.lAnkle] = LandmarkPoint(x: lKneeX, y: lKneeY + shinLen, estimated: true)
        }

        // ── Right leg (anchored to R_HIP) ─────────────────────────────────────
        let rKneeX: Float
        let rKneeY: Float
        if rKneeTrusted {
            rKneeX = smoothed[Idx.rKnee].x
            rKneeY = smoothed[Idx.rKnee].y
        } else {
            rKneeX = smoothed[Idx.rHip].x + facingSign * thighLen
            rKneeY = smoothed[Idx.rHip].y + Const.seatedThighDrop * torsoLen
            out[Idx.rKnee] = LandmarkPoint(x: rKneeX, y: rKneeY, estimated: true)
        }
        if !isHighConf(raw[Idx.rAnkle]) || !rKneeTrusted {
            out[Idx.rAnkle] = LandmarkPoint(x: rKneeX, y: rKneeY + shinLen, estimated: true)
        }

        // ── Heels & foot indices — collapse to ankle to avoid stray lines ─────
        let footPairs = [(Idx.lHeel, Idx.lAnkle), (Idx.rHeel, Idx.rAnkle),
                         (Idx.lFoot, Idx.lAnkle), (Idx.rFoot, Idx.rAnkle)]
        for (footIdx, ankleIdx) in footPairs {
            let kneeOk = ankleIdx == Idx.lAnkle ? lKneeTrusted : rKneeTrusted
            if !isHighConf(raw[footIdx]) || !kneeOk {
                out[footIdx] = LandmarkPoint(x: out[ankleIdx].x, y: out[ankleIdx].y, estimated: true)
            }
        }

        return out
    }

    // ── Facing direction ──────────────────────────────────────────────────────

    private func updateFacingVote(noseX: Float, shoulderMidX: Float) {
        facingVotes.append(noseX > shoulderMidX ? 1 : -1)
        if facingVotes.count > Const.voteWindow { facingVotes.removeFirst() }
        if facingVotes.count >= Const.voteWindow {
            let fraction = Float(facingVotes.filter { $0 > 0 }.count) / Float(facingVotes.count)
            if fraction >= Const.lockFraction {
                lockedFacingSign = 1
            } else if fraction <= 1 - Const.lockFraction {
                lockedFacingSign = -1
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private func isHighConf(_ lm: RawLandmark) -> Bool {
        guard let v = lm.visibility else { return false }
        return v >= Const.highConfidence
    }

    private func dist(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) -> Float {
        ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)).squareRoot()
    }

    private enum Const {
        static let highConfidence: Float = 0.65
        static let thighRatio: Float = 0.90
        static let shinRatio: Float = 0.90
        static let seatedThighDrop: Float = 0.08
        /// Shortest believable thigh (hip to knee) as a fraction of the torso.
        static let minThighRatio: Float = 0.82
        static let voteWindow = 20
        static let lockFraction: Float = 0.70
    }

    private enum Idx {
        static let nose = 0
        static let lShoulder = 11, rShoulder = 12
        static let lHip = 23, rHip = 24
        static let lKnee = 25, rKnee = 26
        static let lAnkle = 27, rAnkle = 28
        static let lHeel = 29, rHeel = 30
        static let lFoot = 31, rFoot = 32
    }
}
