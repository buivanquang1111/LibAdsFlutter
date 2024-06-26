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

  AdmobBannerAd({
    required super.listId,
    required this.adRequest,
    this.adSize = AdSize.banner,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
  });

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

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
    if (!AdmobAds.instance.isEnabled) {
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
}
