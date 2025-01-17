import Flutter
import UIKit

public class AmazicPlugin: NSObject, FlutterPlugin {

    public static var loadingChannel: FlutterMethodChannel?
    private var dialog: FullscreenLoadingDialog?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "easy_ads_flutter", binaryMessenger: registrar.messenger())
        let instance = AmazicPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        if loadingChannel == nil {
            print("FullscreenLoadingDialog", "init loadingChannel")
            loadingChannel = FlutterMethodChannel(name: "loadingChannel", binaryMessenger: registrar.messenger())
        }

        registrar.register(
                    AdsPlatformViewFactory(messenger: registrar.messenger()),
                    withId: "com.yourcompany.ads/banner"
                )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "hasConsentForPurposeOne":
            hasConsentForPurposeOne(result: result)
        case "showLoadingAd":
            print("FullscreenLoadingDialog", "showLoadingAd")
            showOverlayLoading()
            result(nil)
        case "hideLoadingAd":
            // log what is happening
            print("FullscreenLoadingDialog", "hideLoadingAd")
            hideOverlayLoading()
            result(nil)
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
            result(nil)
        }
    }

    private func showOverlayLoading() {
        if dialog == nil {
            dialog = FullscreenLoadingDialog(color: .black)
            dialog?.modalPresentationStyle = .overFullScreen
        }
        UIApplication.shared.windows.last { $0.isKeyWindow }?.rootViewController?.present(dialog!, animated: true, completion: nil)
    }

    private func hideOverlayLoading() {
//      if dialog != nil {
//          dialog?.dismiss(animated: true, completion: nil)
//          dialog = nil
//      }
    }
}

