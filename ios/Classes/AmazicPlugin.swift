import Flutter
import UIKit
import SystemConfiguration

public class AmazicPlugin: NSObject, FlutterPlugin {

    public static var internetChannel: FlutterMethodChannel?
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

        if internetChannel == nil {
            print("InternetChannel", "init internetChannel")
            internetChannel = FlutterMethodChannel(name: "internet_channel", binaryMessenger: registrar.messenger())
        }

//         registrar.register(
//                     AdsPlatformViewFactory(messenger: registrar.messenger()),
//                     withId: "com.yourcompany.ads/banner"
//                 )
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

        case "isNetworkActive":
            result(isNetworkConnected())

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

    private func isNetworkConnected() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return isReachable && !needsConnection
    }

}

