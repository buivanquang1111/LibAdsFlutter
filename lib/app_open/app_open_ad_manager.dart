import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/dialog_loading/dialog_loading.dart';

class AppOpenAdManager {
  // Singleton instance
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  // Factory constructor
  factory AppOpenAdManager() {
    return _instance;
  }
  // Private constructor
  AppOpenAdManager._internal();

  String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/5575463023';


  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool get isAdAvailable{
    return _appOpenAd != null;
  }
  bool isShowResumeEnable = true;

  DialogLoading dialogLoading = DialogLoading();

  void disableAppResume(){
    isShowResumeEnable = false;
    Fluttertoast.showToast(msg: 'disableAppResume $isShowResumeEnable');
  }

  void enableAppResume(){
    isShowResumeEnable = true;
    Fluttertoast.showToast(msg: 'enableAppResume $isShowResumeEnable');
  }

  void loadAppOpenAd() async {
    AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
            onAdFailedToLoad: (LoadAdError error) {
              print('CheckAdsFlutter: onAdFailedToLoad Resume');
            },
            onAdLoaded: (AppOpenAd ad) {
              print('CheckAdsFlutter: onAdLoaded Resume');
              _appOpenAd = ad;
              _appOpenLoadTime = DateTime.now();
            })
    );
  }

  void showAdIfAvailable(BuildContext context){
    dialogLoading.showLoading(context, 'loading', 'description');
    Fluttertoast.showToast(msg: 'start show resume! $isShowResumeEnable');
    if(!isShowResumeEnable){
      Fluttertoast.showToast(msg: 'not show resume!');
      //TH ads inter hiện thì k show resume
      return;
    }

    if(!isAdAvailable){
      //TH chưa có dữ liệu id quảng cáo
      loadAppOpenAd();
      return;
    }

    if(_isShowingAd){
      //TH đã có quảng cáo app open đang hiện -> thì k hiện nữa
      return;
    }

    //TH time hiện tại trừ đi time max có giống time của _appOpenLoadTime k
    if(DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)){
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }

    //show ads open
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad){
        print('CheckAdsFlutter: onAdShowedFullScreenContent Resume');
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error){
        print('CheckAdsFlutter: onAdFailedToShowFullScreenContent Resume');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad){
        print('CheckAdsFlutter: onAdDismissedFullScreenContent Resume');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      }
    );
    _appOpenAd?.show();

    dialogLoading.dismissLoading();
  }

}
