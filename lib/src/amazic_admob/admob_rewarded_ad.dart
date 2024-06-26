import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../admob_ads_flutter.dart';
import '../admob_ads.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class AdmobRewardedAd extends AdsBase {
  final AdRequest adRequest;

  AdmobRewardedAd({
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

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.rewarded;

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
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    _isAdLoading = true;
    await RewardedAd.load(
      adUnitId: listId.isNotEmpty ? listId[0] : '',
      request: adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _rewardedAd?.onPaidEvent = (ad, revenue, type, currencyCode) {
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
          _isAdLoadedFailed = false;
          _isAdLoading = false;
          AdmobAds.instance.onAdLoadedMethod(adNetwork, adUnitType, ad);
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (listId.length > 1) {
            listId.removeAt(0);
            load();
          } else {
            _rewardedAd = null;
            _isAdLoaded = false;
            _isAdLoadedFailed = true;
            _isAdLoading = false;
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
  dynamic show({
    double? height,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        AdmobAds.instance.onAdShowedMethod(adNetwork, adUnitType, ad);
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        AdmobAds.instance.onAdDismissedMethod(adNetwork, adUnitType, ad);
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
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
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        AdmobAds.instance.onEarnedRewardMethod(
            adNetwork, adUnitType, reward.type, reward.amount);
        onEarnedReward?.call(adNetwork, adUnitType, reward.type, reward.amount);
      },
    );
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
