import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../admob_ads_flutter.dart';
import '../admob_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class AdmobInterstitialAd extends AdsBase {
  final AdRequest adRequest;

  AdmobInterstitialAd({
    required super.listId,
    required this.adRequest,
    super.onAdLoaded,
    super.onAdShowed,
    super.onAdClicked,
    super.onAdFailedToLoad,
    super.onAdFailedToShow,
    super.onAdDismissed,
    super.onEarnedReward,
    super.onPaidEvent,
  });

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  Future<void> dispose() async {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    if(listId.isEmpty) {
      AdmobAds.instance.onAdFailedToLoadMethod(
          adNetwork, adUnitType, null, 'list empty');
      onAdFailedToLoad?.call(
          adNetwork, adUnitType, null, 'list empty');
      return;
    }
    _isAdLoading = true;
    await InterstitialAd.load(
      adUnitId: listId[0],
      request: adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd?.onPaidEvent = (ad, revenue, type, currencyCode) {
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
          };
          _isAdLoaded = true;
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          AdmobAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          if(listId.length > 1){
            listId.removeAt(0);
            load();
          }else {
            _interstitialAd = null;
            _isAdLoaded = false;
            _isAdLoading = false;
            _isAdLoadedFailed = true;
            AdmobAds.instance.onAdFailedToLoadMethod(
                adNetwork, adUnitType, error, error.toString());
            onAdFailedToLoad?.call(
                adNetwork, adUnitType, error, error.toString());
          }
        },
      ),
    );
  }

  @override
  show({
    double? height,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        AdmobAds.instance.onAdFailedToShowMethod(
            adNetwork, adUnitType, ad, error.toString());
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
      },
      onAdClicked: (ad) {
        AdmobAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
        onAdClicked?.call(adNetwork, adUnitType, ad);
      },
    );
    ad.setImmersiveMode(true);
    ad.show();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
