import UIKit
import GoogleMobileAds
import Flutter

class AdsPlatformView: NSObject, FlutterPlatformView {
    private var containerView: UIView
    private var adView: GADBannerView
    private var methodChannel: FlutterMethodChannel

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        self.containerView = UIView()
        self.adView = GADBannerView()
        self.methodChannel = FlutterMethodChannel(
            name: "com.yourcompany.ads/banner",
            binaryMessenger: binaryMessenger
        )

        super.init()

        if let params = args as? [String: Any],
           let adUnitId = params["adUnitId"] as? String,
           let adSizeParams = params["adSize"] as? [String: Int],
           let width = adSizeParams["width"],
           let height = adSizeParams["height"] {

            let adSize = GADAdSizeFromCGSize(CGSize(width: CGFloat(width), height: CGFloat(height)))
            adView.adSize = adSize
            adView.adUnitID = adUnitId
            adView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            adView.delegate = self
            containerView.addSubview(adView)

            // Load the ad
            adView.load(GADRequest())
        }
    }

    func view() -> UIView {
        return containerView
    }

    func detectTestAd(in view: UIView) -> Bool {
        for subview in view.subviews {
            if subview is UILabel {
                print("detectTestAd: Tìm thấy UILabel")
                return true
            } else if !subview.subviews.isEmpty {
//                 if detectTestAd(in: subview) {
//                     return true
//                 }

                    return detectTestAd(in: subview)
            }
        }
        return false
    }
}

extension AdsPlatformView: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        methodChannel.invokeMethod("onAdLoaded", nil)
        let isTestAd = detectTestAd(in: containerView)
        if isTestAd {
           print("Đây là quảng cáo thử nghiệm (Test Ad).")
        } else {
           print("Không phát hiện quảng cáo thử nghiệm.")
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        methodChannel.invokeMethod("onAdFailedToLoad", ["error": error.localizedDescription])
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        methodChannel.invokeMethod("onAdClicked", nil)
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        methodChannel.invokeMethod("onAdClosed", nil)
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        methodChannel.invokeMethod("onAdImpression", nil)
    }
}
