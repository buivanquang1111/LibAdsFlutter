import 'dart:async';

import 'package:flutter/material.dart';

import '../../adjust_config/call_organic_adjust.dart';
import '../../admob_ads_flutter.dart';
import '../utils/amazic_logger.dart';

class AdmobAppOpenAd extends AdsBase {
  final AdRequest adRequest;
  final bool isShowAdsSplash;
  final String? nameAds;

  AdmobAppOpenAd({
    required super.idAds,
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

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  Timer? _adShowTimeoutTimer;
  final AmazicLogger _logger = AmazicLogger();

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  Future<void> dispose() async {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
    _adShowTimeoutTimer?.cancel();
  }

  @override
  Future<void> load() async {
    if (isAdLoaded) return Future.value();

    _isAdLoading = true;
    if (isShowAdsSplash) {
      EventLogLib.logEvent("open_splash_true");
      _adShowTimeoutTimer?.cancel();
      _adShowTimeoutTimer = Timer(
        const Duration(seconds: 20),
        () {
          EventLogLib.logEvent('open_splash_id_timeout');
          _logger.logInfo('Ad Timeout: Timeout 20s ads Open');
          onAdFailedToShow?.call(adNetwork, adUnitType, _appOpenAd, 'Ad timeout 20s');
        },
      );
    } else {
      if (nameAds != null) {
        EventLogLib.logEvent('${nameAds}_true', parameters: {
          'reason':
              'ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.isHaveInternet}'
        });
      }
    }
    return AppOpenAd.load(
      adUnitId: idAds,
      request: adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _appOpenAd?.onPaidEvent = (ad, revenue, type, currencyCode) {
            final info = ad.responseInfo?.loadedAdapterResponseInfo;
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
              network: info?.adSourceName,
            );
          };
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          _isAdLoaded = true;
          AdmobAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _adShowTimeoutTimer?.cancel();
          _appOpenAd = null;
          _isAdLoading = false;
          _isAdLoadedFailed = true;
          _isAdLoaded = false;
          AdmobAds.instance.onAdFailedToLoadMethod(adNetwork, adUnitType, error, error.toString());
          onAdFailedToLoad?.call(adNetwork, adUnitType, error, error.toString());
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
  }) async {
    if (!isAdLoaded) {
      await load();
      return;
    }

    if (_isShowingAd) {
      AdmobAds.instance.onAdFailedToShowMethod(
          adNetwork, adUnitType, null, 'Tried to show ad while already showing an ad.');
      onAdFailedToShow?.call(
          adNetwork, adUnitType, null, 'Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _adShowTimeoutTimer?.cancel();
        _isShowingAd = true;

        AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;

        AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
        onAdDismissed?.call(adNetwork, adUnitType, ad);
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _adShowTimeoutTimer?.cancel();
        _isShowingAd = false;

        AdmobAds.instance.onAdFailedToShowMethod(adNetwork, adUnitType, ad, error.toString());
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
        _appOpenAd = null;
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

    _appOpenAd!.show();
    _appOpenAd = null;
    _isShowingAd = false;
    _isAdLoaded = false;
  }
}
