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
       //result(true)
    case "hideLoadingAd":
      //result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
