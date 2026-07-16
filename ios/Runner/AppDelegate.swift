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
          let vc = PoseDetectionViewController(workstationModifiers: mods)
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
