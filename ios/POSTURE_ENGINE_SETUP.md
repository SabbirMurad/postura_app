# iOS PostureEngine — remaining Xcode setup

The native iOS posture-detection engine was copied into this project from the
`posture_detector` reference app. All the **text-editable** wiring is already
done:

- `Runner/PostureEngine/*.swift` + `TFLiteCAPI.h` — copied in.
- `Runner/Models/{pose_landmarker_full.task, hand_landmarker.task, yolov8n_float16.tflite}` — copied in.
- `Runner/AppDelegate.swift` — registers the `posture_detection` MethodChannel
  and presents `PoseDetectionViewController`.
- `Runner/Runner-Bridging-Header.h` — imports `PostureEngine/TFLiteCAPI.h`.
- `Podfile` — `platform :ios, '15.0'`, `pod 'MediaPipeTasksVision', '~> 0.10.21'`,
  and a post_install deployment-target bump.
- `Info.plist` — already has `NSCameraUsageDescription`.

## What still needs Xcode (macOS only — cannot be done on Windows)

The files above exist on disk but are **not yet registered in
`Runner.xcodeproj/project.pbxproj`**. In Xcode:

1. Open `ios/Runner.xcworkspace`.
2. Right-click the **Runner** group → *Add Files to "Runner"…* → select the
   `PostureEngine` folder → **Create groups**, target: **Runner**. Confirm the
   12 `.swift` files appear under **Build Phases → Compile Sources**.
   (`TFLiteCAPI.h` is a header — it should NOT be in Compile Sources.)
3. Add the `Models` folder the same way. Confirm the two `.task` files and
   `yolov8n_float16.tflite` appear under **Build Phases → Copy Bundle Resources**.
4. **Build Settings → Objective-C Bridging Header** should be
   `Runner/Runner-Bridging-Header.h` (Flutter projects usually set this already).
5. From `ios/`: `pod install`.
6. Build/run on a physical device (the camera + MediaPipe pipeline needs real
   hardware).

## Contract

The channel returns `{ photo_paths: [String], rosa_scores: [[String:Any]],
body_angles: [[String:Any]] }` (or `nil` on cancel), matching the Android side
and the Dart parser in `lib/view/assessment/camera_guide_screen.dart`.
