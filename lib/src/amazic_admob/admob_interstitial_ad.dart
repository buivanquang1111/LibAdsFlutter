import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../adjust_config/call_organic_adjust.dart';
import '../../admob_ads_flutter.dart';
import '../admob_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';
import '../utils/amazic_logger.dart';

class AdmobInterstitialAd extends AdsBase {
  final AdRequest adRequest;
  final bool isShowAdsSplash;
  final String? nameAds;

  AdmobInterstitialAd({
    required super.listId,
    required this.adRequest,
    required this.isShowAdsSplash,
    required this.nameAds,
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

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  Timer? _adShowTimeoutTimer;

  final AmazicLogger _logger = AmazicLogger();

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
    _adShowTimeoutTimer = null;
  }

  @override
  Future<void> load() async {
    _logger.logInfo('1.load inter');
    if (_isAdLoaded) return;
    _isAdLoading = true;
    if (isShowAdsSplash) {
      EventLogLib.logEvent("inter_splash_true");
      _adShowTimeoutTimer?.cancel();
      _adShowTimeoutTimer = Timer(
        const Duration(seconds: 20),
        () {
          EventLogLib.logEvent('inter_splash_id_timeout');
          _logger.logInfo('Ad Timeout: Timeout 20s ads Inter');
          onAdFailedToShow?.call(
              adNetwork, adUnitType, _interstitialAd, 'Ad timeout 20s');
        },
      );
    }else{
      if(nameAds != null) {
        EventLogLib.logEvent('${nameAds}_true', parameters: {
          'reason':
          'ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust
              .instance.isOrganic()}_internet_${AdmobAds.instance
              .checkInternet()}'
        });
      }
    }
    await InterstitialAd.load(
      adUnitId: listId.isNotEmpty ? listId[0] : '',
      request: adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _logger.logInfo('2.load inter onAdLoaded');
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
          _logger.logInfo('3.load inter onAdFailedToLoad');
          if (listId.length > 1) {
            _logger.logInfo('4.load inter onAdFailedToLoad removeAt 0');
            listId.removeAt(0);
            load();
          } else {
            _logger.logInfo('5.load inter onAdFailedToLoadMethod');
            _adShowTimeoutTimer?.cancel();
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
        _adShowTimeoutTimer?.cancel();
        AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _adShowTimeoutTimer?.cancel();
        AdmobAds.instance.onAdFailedToShowMethod(
            adNetwork, adUnitType, ad, error.toString());
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
      },
      onAdClicked: (ad) {
        AdmobAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
        onAdClicked?.call(adNetwork, adUnitType, ad);
      },
      onAdImpression: (ad) {
        _adShowTimeoutTimer?.cancel();
        onAdImpression?.call(adNetwork, adUnitType, ad);
      },
    );
    ad.setImmersiveMode(true);
    ad.show();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
