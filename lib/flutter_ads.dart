import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/banner/banner_ad_manager.dart';
import 'package:lib_ads_flutter/enums/ads_banner_type.dart';

import 'app_open/app_lifecycle_reactor.dart';
import 'app_open/app_open_ad_manager.dart';

class FlutterAds {
  FlutterAds._flutterAds();

  static final FlutterAds instance = FlutterAds._flutterAds();

  AdRequest _adRequest = const AdRequest();
  AdSize? admobAdSize;
  GlobalKey<NavigatorState>? navigatorKey;
  AppLifecycleReactor? appLifecycleReactor;

  Future<void> initalize({
    AdRequest? adRequest,
    GlobalKey<NavigatorState>? navigatorKey,
    String? idAdsResume,
})async {
    if(adRequest != null){
      _adRequest = adRequest;
    }

    //UMP

    Fluttertoast.showToast(msg: 'init');
    if(navigatorKey?.currentContext != null){
      Fluttertoast.showToast(msg: 'currentContext');
      admobAdSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt()
      );
    }

    if(navigatorKey != null){
      Fluttertoast.showToast(msg: 'navigatorKey');
      this.navigatorKey = navigatorKey;

      AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAppOpenAd();
      appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      appLifecycleReactor?.listenToAppStateChanges(navigatorKey!.currentContext!);
    }

  }

  BannerAdManager createBanner({
    required BuildContext context,
    required String idAds,
    required Function() onAdLoaded,
    required Function() onAdFailedToLoad,
    required Function() onAdClicked,
    required Function() onAdClosed,
    required Function() onAdImpression,
    required Function() onPaidEvent,
  }) {
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

    AdSize? adSize = getAdmobAdSize();

    bannerAdManager = BannerAdManager(
        idAds: idAds,
        adRequest: adRequest,
        adSize: adSize!,
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdClicked: onAdClicked,
        onAdClosed: onAdClosed,
        onAdImpression: onAdImpression,
        onPaidEvent: onPaidEvent);
    return bannerAdManager;
  }

  AdSize? getAdmobAdSize() {
    if (admobAdSize == null) {
      if (navigatorKey?.currentContext != null) {
        Future(
              () async {
            admobAdSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt());
          },
        );
      }
      return AdSize.banner;
    }
    return admobAdSize;
  }

}