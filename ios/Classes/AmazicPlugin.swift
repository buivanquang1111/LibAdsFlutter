import Flutter
  import UIKit

  public class AmazicPlugin: NSObject, FlutterPlugin {
      static let TAG = "AmazicPlugin"
      private var context: UIApplication!
      private var mActivity: UIViewController!
      private var dialog: FullscreenLoadingDialog?

      private static var channel: FlutterMethodChannel?
      public static var loadingChannel: FlutterMethodChannel?


      public static func register(with registrar: FlutterPluginRegistrar) {
          if channel == null {
              channel = FlutterMethodChannel(name: "easy_ads_flutter", binaryMessenger: registrar.messenger())
              let instance = AmazicPlugin()
              registrar.addMethodCallDelegate(instance, channel: channel!)
          }

          if loadingChannel == null {
              loadingChannel = FlutterMethodChannel(name: "loadingChannel", binaryMessenger: registrar.messenger())
          }
      }

      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          switch call.method {
          case "getPlatformVersion":
              result("iOS " + UIDevice.current.systemVersion)
          case "hasConsentForPurposeOne":
              hasConsentForPurposeOne(result: result)
          case "showLoadingAd":
              if let colorValue = call.arguments as? Int {
                  showOverlayLoading(color: UIColor(hex: colorValue))
              }
          case "hideLoadingAd":
              hideOverlayLoading()
          default:
              result(FlutterMethodNotImplemented)
          }
      }

      private func hasConsentForPurposeOne(result: FlutterResult) {
          let defaults = UserDefaults.standard
          if let purposeConsents = defaults.string(forKey: "IABTCF_PurposeConsents") {
              let purposeOneString = String(purposeConsents.prefix(1))
              let hasConsentForPurposeOne = purposeOneString == "1"
              result(hasConsentForPurposeOne)
          } else {
              result(null)
          }
      }

      private func showOverlayLoading(color: UIColor) {
          if dialog == null {
              dialog = FullscreenLoadingDialog(color: color)
              dialog?.modalPresentationStyle = .overFullScreen
              mActivity.present(dialog!, animated: true, completion: null)
          }
      }

      private func hideOverlayLoading() {
          if dialog != null {
              dialog?.dismiss(animated: true, completion: null)
              dialog = null
          }
      }
  }

  extension UIColor {
      convenience init(hex: Int) {
          let red = CGFloat((hex >> 16) & 0xFF) / 255.0
          let green = CGFloat((hex >> 8) & 0xFF) / 255.0
          let blue = CGFloat(hex & 0xFF) / 255.0
          self.init(red: red, green: green, blue: blue, alpha: 1.0)
      }
  }


// import Flutter
// import UIKit
//
// public class AmazicPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "easy_ads_flutter", binaryMessenger: registrar.messenger())
//     let instance = AmazicPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//   }
//
//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     switch call.method {
//     case "getPlatformVersion":
//       result("iOS " + UIDevice.current.systemVersion)
//     case "hasConsentForPurposeOne":
//        result(true)
//     case "showLoadingAd":
//         break;
//        //result(true)
//     case "hideLoadingAd":
//         break;
//       //result(true)
//     default:
//       result(FlutterMethodNotImplemented)
//     }
//   }
// }