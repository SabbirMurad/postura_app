# Live Guidance — Auto-Capture Requirements

Source: `android/app/src/main/kotlin/com/sabbir/postura/PoseDetectionActivity.kt` (lines 135-1260), `TiltMonitor.kt` (lines 67-71). The iOS counterpart (`PoseDetectionViewController.swift`) mirrors this same logic.

## Phase 0 — Preconditions (must pass before any capture logic runs)

| Check | Threshold |
|---|---|
| Room light | Luminance between **0.25 – 0.85** (normalized Y-plane average) |
| Person detected | YOLO detects a person in frame |
| Monitor detected | YOLO detects a monitor in frame |
| Confirmation hold | Person + monitor both detected for **4 consecutive frames** |

## Phase 1 — Side-view auto-capture (3 shots)

All 5 conditions must be simultaneously true, held for **20 consecutive frames**, with a **2000ms cooldown** between shots:

| Condition | Requirement |
|---|---|
| **Tilt** | Phone pitch between **85°–95°** (near-vertical/upright) |
| **Rotation (roll)** | \|roll\| ≤ **15°** (phone not tilted sideways) |
| **Side view** | hip-spread ÷ torso-height ratio < **0.35** (accepts camera within ~30° of true side-on; uses hips only, not shoulders/ears, since those get thrown off by leaning or hair occlusion) |
| **Height** | Shoulder Y-position within **0.43–0.57** of frame height (keeps subject vertically centered/correctly framed) |
| **Distance** | Estimated distance between **1.7m – 2.1m** from camera |

- Steady-frame counter: **≥ 20 frames** of all-green
- Cooldown: **≥ 2000ms** since previous shot
- Repeats for **3 total side shots**, each baked with skeleton overlay + ROSA angles, face auto-blurred

## Phase 2 — Front-view auto-capture (1 shot, after the 3 side shots)

Triggered once the holder moves to the front of the person:

| Condition | Requirement |
|---|---|
| **Entry settle delay** | Must wait **1500ms** after entering front phase before capture can even be considered (stops premature capture while walking into position) |
| **Face visible** | Nose landmark visibility ≥ **0.5** |
| **Shoulders visible** | Both shoulder landmarks (11, 12) visibility ≥ **0.5** |
| **Hands visible** | Both wrist landmarks (15, 16) visibility ≥ **0.5** |
| **Rotation (roll)** | \|roll\| ≤ **15°** (no tilt/pitch gate required for front shot) |
| **Phone steadiness** | No shake (dynamic acceleration > 0.8 m/s²) for at least **400ms** prior |
| **Hold duration** | All conditions true for **30 consecutive frames** past the settle delay |

Once triggered: hand landmarks (finger/palm) are detected on the clean frame, face is blurred, skeleton is baked (excluding face/ears, wrist/palm points 0–10 & 15–22, and legs 25–32), shoulder-angle arcs are drawn, and two angles are computed and sent to Flutter:

- **Elbow abduction angle** — armrest-too-wide flag if ≥ **20°**
- **Wrist deviation angle** — keyboard-deviation flag if ≥ **15°**

## Output contract (native → Flutter, `MethodChannel: posture_detection`)

```json
{
  "side_captures": [ { "image_path": "...", "rosa_score": {}, "body_angles": {} } ],
  "front_capture": { "image_path": "...", "abduction_angle": 0.0, "wrist_deviation_angle": 0.0 }
}
```
