import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdManager {
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  BannerAd? bannerAd;
  final AdSize adSize = const AdSize(width: 300, height: 50);
  bool isloaded = false;

  void loadAdBanner(BuildContext context, Function loadSuccess) async {
    BannerAd(
        size: adSize,
        adUnitId: adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            bannerAd = ad as BannerAd;
            isloaded = true;
            loadSuccess(bannerAd);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
          onAdOpened: (Ad ad) {},
          onAdClosed: (Ad ad) {},
          onAdImpression: (Ad ad) {},
        ),
        request: const AdRequest()).load();
  }
}
