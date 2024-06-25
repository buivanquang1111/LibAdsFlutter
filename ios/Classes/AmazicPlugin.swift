import Flutter
import UIKit

public class AmazicPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "easy_ads_flutter", binaryMessenger: registrar.messenger())
    let instance = AmazicPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "hasConsentForPurposeOne":
       result(true)
    case "showLoadingAd":
        break;
       //result(true)
    case "hideLoadingAd":
        break;
      //result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
