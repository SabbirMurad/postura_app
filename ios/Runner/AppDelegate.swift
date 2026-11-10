import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  private let postureChannelName = "posture_detection"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(name: "device_integrity", binaryMessenger: controller.binaryMessenger)
        .setMethodCallHandler { call, result in
          if call.method == "check" {
            result(DeviceIntegrity.check())
          } else {
            result(FlutterMethodNotImplemented)
          }
        }

      let channel = FlutterMethodChannel(name: postureChannelName,
                                         binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak controller] call, result in
        switch call.method {
        case "startDetection":
          guard let controller = controller else {
            result(nil)
            return
          }
          let answers = call.arguments as? [String: Any]
          let mods = RosaScorer.WorkstationModifiers.fromMap(answers)
          let frontPhotoAvailable = answers?["front_photo_available"] as? Bool ?? true
          let vc = PoseDetectionViewController(
            workstationModifiers: mods, frontPhotoAvailable: frontPhotoAvailable)
          vc.onComplete = { detectionResult in
            // nil on cancel, else ["photo_paths": [String],
            // "rosa_scores": [[String: Any]], "body_angles": [[String: Any]]]
            result(detectionResult)
          }
          vc.modalPresentationStyle = .fullScreen
          controller.present(vc, animated: true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// On-device jailbreak check. These are deterrents, not a
/// guarantee: a determined attacker can hide a jailbreak. The backend validates
/// everything it receives regardless.
enum DeviceIntegrity {
  static var isSimulator: Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }

  private static let jailbreakPaths = [
    "/Applications/Cydia.app",
    "/Applications/Sileo.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt",
    "/private/var/lib/apt/",
    "/var/jb",
  ]

  static var isJailbroken: Bool {
    if isSimulator { return false }
    if jailbreakPaths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
      return true
    }
    // A normal app can't write outside its sandbox.
    let probe = "/private/postura_jb_probe.txt"
    do {
      try "x".write(toFile: probe, atomically: true, encoding: .utf8)
      try? FileManager.default.removeItem(atPath: probe)
      return true
    } catch {
      return false
    }
  }

  static func check() -> [String: Bool] {
    ["rooted": isJailbroken]
  }
}
