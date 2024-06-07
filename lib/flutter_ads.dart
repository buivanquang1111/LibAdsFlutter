import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/banner/banner_ad_manager.dart';
import 'package:lib_ads_flutter/enums/ads_banner_type.dart';

class FlutterAds{
  FlutterAds._flutterAds();

  static final FlutterAds instance = FlutterAds._flutterAds();

  AdRequest _adRequest = const AdRequest();
  AdSize? admobAdSize = AdSize.banner;

  BannerAdManager createBanner({
    required BuildContext context ,
    required String idAds,
    required Function() onAdLoaded,
    required Function() onAdFailedToLoad,
    required Function() onAdClicked,
    required Function() onAdClosed,
    required Function() onAdImpression,
    required Function() onPaidEvent,
  }){
    BannerAdManager bannerAdManager;
    
    AdRequest adRequest = _adRequest;
    // if(type == AdsBannerType.collapsible_bottom){
    //   adRequest = const AdRequest(
    //     extras: {'collapsible': 'bottom'},
    //   );
    // }else if(type == AdsBannerType.collapsible_top){
    //   adRequest = const AdRequest(
    //     extras: {'collapsible': 'top'},
    //   );
    // }

    // Future(
    //       () async {
    //         admobAdSize = (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
    //         MediaQuery.sizeOf(context).width.toInt()));
    //   },
    // );

    bannerAdManager = BannerAdManager(
        idAds: idAds,
        adRequest: adRequest,
        adSize: admobAdSize!,
    onAdLoaded: onAdLoaded,
    onAdFailedToLoad: onAdFailedToLoad,
    onAdClicked: onAdClicked,
    onAdClosed: onAdClosed,
    onAdImpression: onAdImpression,
    onPaidEvent: onPaidEvent);
    return bannerAdManager;
  }

}