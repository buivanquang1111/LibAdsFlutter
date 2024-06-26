import UIKit
import Flutter

// COMPLETE: Import google_mobile_ads
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  GeneratedPluginRegistrant.register(with: self)
//     GeneratedPluginRegistrant.register(with: self)
//
// //     // COMPLETE: REgister ListTileNativeAdFactory
// //     let listTileFactory = ListTileNativeAdFactory()
// //     FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
// //         self, factoryId: "listTile", nativeAdFactory: listTileFactory)
// //
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)

        self.flutterEngine = FlutterEngine(name: "my flutter engine")
        self.flutterEngine?.run()

        if let controller = window?.rootViewController as? FlutterViewController {
            AmazicPlugin.register(with: controller.registrar(forPlugin: "AmazicPlugin")!)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
