import 'package:amazic_ads_flutter/adjust_config/call_organic_adjust.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../admob_ads_flutter.dart';
import '../amazic_ads/loading_ads.dart';
import '../admob_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class AdmobBannerAd extends AdsBase {
  final AdRequest adRequest;
  final AdSize adSize;
  final String visibilityDetectorKey;

  AdmobBannerAd({
    required super.listId,
    required this.adRequest,
    required this.visibilityDetectorKey,
    this.adSize = AdSize.banner,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
    super.onAdImpression,
  });

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  // GlobalKey adWidgetKey = GlobalKey();

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  Future<void> dispose() async {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    EventLogLib.logEvent('${visibilityDetectorKey}_true', parameters: {
      'reason':
          'ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.checkInternet()}'
    });

    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: listId.isNotEmpty ? listId[0] : '',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerAd = ad as BannerAd?;
          _isAdLoaded = true;
          _isAdLoadedFailed = false;
          AdmobAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (listId.length > 1) {
            listId.removeAt(0);
            load();
          } else {
            _bannerAd = null;
            _isAdLoaded = false;
            _isAdLoading = false;
            _isAdLoadedFailed = true;
            AdmobAds.instance.onAdFailedToLoadMethod(
                adNetwork, adUnitType, ad, error.toString());
            onAdFailedToLoad?.call(adNetwork, adUnitType, ad, error.toString());
            ad.dispose();
          }
        },
        onAdClicked: (ad) {
          AdmobAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
          AdmobAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
          onAdClicked?.call(adNetwork, adUnitType, ad);
        },
        onAdClosed: (Ad ad) {
          AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
          onAdDismissed?.call(adNetwork, adUnitType, ad);
        },
        onAdImpression: (Ad ad) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              _isAdLoading = false;
              AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
              onAdShowed?.call(adNetwork, adUnitType, ad);
            },
          );
          onAdImpression?.call(adNetwork, adUnitType, ad);
          // logAdContentInWidget(adWidgetKey);
        },
        onPaidEvent: (ad, revenue, type, currencyCode) {
          AdmobAds.instance.onPaidEventMethod(
            adNetwork: adNetwork,
            adUnitType: adUnitType,
            revenue: revenue / 1000000,
            currencyCode: currencyCode,
            network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
          );
          onPaidEvent?.call(
            adNetwork: adNetwork,
            adUnitType: adUnitType,
            revenue: revenue / 1000000,
            currencyCode: currencyCode,
            network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
          );
        },
      ),
      request: adRequest,
    );
    _isAdLoading = true;
    _bannerAd?.load();
  }

  @override
  dynamic show({
    double? height,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    if (!AdmobAds.instance.isShowAllAds) {
      return const SizedBox(
        height: 1,
        width: 1,
      );
    }
    final ad = _bannerAd;
    if (ad == null && !isAdLoaded) {
      return const SizedBox(
        height: 1,
        width: 1,
      );
    }
    return Center(
      child: Container(
        height: adSize.height.toDouble(),
        width: adSize.width.toDouble(),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black, width: 2),
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Stack(
          children: [
            if (ad != null && isAdLoaded)
              AdWidget(
                // key: adWidgetKey,
                ad: ad,
              ),
            if (_isAdLoading)
              Container(
                color: Colors.white,
                child: LoadingAds(
                  height: adSize.height.toDouble(),
                ),
              ),
          ],
        ),
      ),
    );
  }

// void logAdContentInWidget(GlobalKey adWidgetKey) {
//   final context = adWidgetKey.currentContext;
//   if (context != null) {
//     // Lấy các widget con của widget cha
//     context.visitChildElements((element) {
//       final widget = element.widget;
//
//       // Kiểm tra nếu widget là PlatformViewLink
//       if (widget is PlatformViewLink) {
//         print("log_banner --- Found PlatformViewLink: $widget");
//
//         // Kiểm tra các thành phần con bên trong PlatformViewLink
//         element.visitChildElements((childElement) {
//           final childWidget = childElement.widget;
//           print("log_banner --- Found child widget of PlatformViewLink: $childWidget");
//         });
//       }
//
//       // Kiểm tra nếu widget là Text
//       else if (widget is Text) {
//         print("log_banner --- Found Ad Content Text: ${widget.data}");
//       }
//
//       // Kiểm tra nếu widget là Image
//       else if (widget is Image) {
//         print("log_banner --- Found Ad Content Image: ${widget.image}");
//       }
//
//       // Kiểm tra nếu widget là bất kỳ widget nào khác
//       else {
//         print("log_banner --- Other Widget detected: $widget");
//       }
//     });
//   } else {
//     print("log_banner --- No context found for the provided key.");
//   }
// }
}
