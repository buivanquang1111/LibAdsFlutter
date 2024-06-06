import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/enums/ads_banner_type.dart';

class BannerAdManager {
  // Singleton instance
  static final BannerAdManager _instance = BannerAdManager._internal();

  // Factory constructor
  factory BannerAdManager() {
    return _instance;
  }

  // Private constructor
  BannerAdManager._internal();

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final adUnitIdCollapsible = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2014213617'
      : 'ca-app-pub-3940256099942544/8388050270';

  BannerAd? bannerAd;
  bool isloaded = false;

  void loadAdBanner(BuildContext context, Function loadSuccess) async {
    AdSize adSize =
        (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(context).width.truncate())) as AdSize;
    BannerAd(
            size: adSize,
            adUnitId: adUnitId,
            listener: BannerAdListener(
              onAdLoaded: (ad) {
                bannerAd = ad as BannerAd;
                isloaded = true;
                loadSuccess();
              },
              onAdFailedToLoad: (ad, error) {
                ad.dispose();
              },
              onAdOpened: (Ad ad) {},
              onAdClosed: (Ad ad) {},
              onAdImpression: (Ad ad) {},
            ),
            request: const AdRequest())
        .load();
  }

  void loadCollapseBanner(
      BuildContext context, AdsBannerType type, Function loadSuccess) async {
    Fluttertoast.showToast(msg: "start");

    AdSize adSize =
        (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(context).width.truncate())) as AdSize;

    AdRequest _adRequest = new AdRequest();
    if (type == AdsBannerType.collapsible_bottom) {
      _adRequest = const AdRequest(
        extras: {'collapsible': 'bottom'},
      );
    } else if (type == AdsBannerType.collapsible_top) {
      _adRequest = const AdRequest(
        extras: {'collapsible': 'top'},
      );
    }
    Fluttertoast.showToast(msg: "body");
    await BannerAd(
        size: adSize,
        adUnitId: adUnitIdCollapsible,
        request: _adRequest,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            Fluttertoast.showToast(msg: "onAdLoaded");
            bannerAd = ad as BannerAd;
            isloaded = true;
            loadSuccess();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            Fluttertoast.showToast(msg: "onAdFailedToLoad");
          },
          onAdOpened: (Ad ad) {
            Fluttertoast.showToast(msg: "onAdOpened");
          },
          onAdClosed: (Ad ad) {
            Fluttertoast.showToast(msg: "onAdClosed");
          },
          onAdImpression: (Ad ad) {
            Fluttertoast.showToast(msg: "onAdImpression");
          },
        )).load();
    Fluttertoast.showToast(msg: "end");
  }

  void loadAd(BuildContext context, Function() onAdLoad) async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      // Unable to get width of anchored banner.
      return;
    }

    BannerAd(
      adUnitId: adUnitIdCollapsible,
      request: const AdRequest(extras: {'collapsible': 'bottom'}),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          isloaded = true;
          onAdLoad();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }
}
