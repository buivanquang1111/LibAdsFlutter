import 'package:amazic_ads_flutter/src/enums/ad_network.dart';
import 'package:amazic_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../adjust_config/call_organic_adjust.dart';
import '../../admob_ads_flutter.dart';
import '../amazic_ads/loading_ads.dart';
import '../admob_ads.dart';
import '../utils/amazic_logger.dart';

class AdmobNativeAd extends AdsBase {
  final AdRequest adRequest;
  final String factoryId;
  final String visibilityDetectorKey;
  final bool isClickAdsNotShowResume; //click ads default true - not show

  AdmobNativeAd({
    required super.listId,
    required this.adRequest,
    required this.factoryId,
    required this.visibilityDetectorKey,
    required this.isClickAdsNotShowResume,
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

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  final AmazicLogger _logger = AmazicLogger();

  @override
  AdUnitType get adUnitType => AdUnitType.native;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  Future<void> dispose() async {
    _isAdLoaded = false;
    _isAdLoadedFailed = false;
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    EventLogLib.logEvent('${visibilityDetectorKey}_true', parameters: {
      'reason':
          'ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.checkInternet()}'
    });
    _nativeAd = NativeAd(
      adUnitId: listId.isNotEmpty ? listId[0] : '',
      factoryId: factoryId,
      request: adRequest,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          _nativeAd = ad as NativeAd?;
          _isAdLoaded = true;
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          AdmobAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          print('check_show_native: onAdLoaded');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (listId.length > 1) {
            listId.removeAt(0);
            load();
          } else {
            _nativeAd = null;
            _isAdLoaded = false;
            _isAdLoading = false;
            _isAdLoadedFailed = true;
            AdmobAds.instance.onAdFailedToLoadMethod(
                adNetwork, adUnitType, ad, error.toString());
            onAdFailedToLoad?.call(adNetwork, adUnitType, ad, error.toString());
            ad.dispose();
            print('check_show_native: onAdFailedToLoad');
          }
        },
        onAdClicked: (ad) {
          if (isClickAdsNotShowResume) {
            AdmobAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
          }
          AdmobAds.instance.onAdClickedMethod(adNetwork, adUnitType, ad);
          onAdClicked?.call(adNetwork, adUnitType, ad);
        },
        onAdClosed: (Ad ad) {
          AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
          onAdDismissed?.call(adNetwork, adUnitType, ad);
        },
        onAdImpression: (Ad ad) {
          AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
          onAdShowed?.call(adNetwork, adUnitType, ad);
          onAdImpression?.call(adNetwork, adUnitType, ad);
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
    );
    _nativeAd?.load();
    _isAdLoading = true;
    print('check_show_native: xong');
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
    NativeAd? ads = _nativeAd;
    if (ads == null && !_isAdLoaded) {
      return const SizedBox(
        height: 1,
        width: 1,
      );
    }
    print(
        'check_show_native: 3. ad: $ads, isAdLoaded: $isAdLoaded , _isAdLoading: $_isAdLoading');
    _logger.logInfo('ad: $ads, isAdLoaded: $isAdLoaded');
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: border,
        color: color,
      ),
      padding: padding,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(
          color: color,
          height: height,
          child: Stack(
            children: [
              if (ads != null && isAdLoaded) AdWidget(ad: ads),
              if (_isAdLoading) LoadingAds(height: height ?? 0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get isAdLoading => _isAdLoading;
}
