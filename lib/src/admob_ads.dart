// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amazic_ads_flutter/src/utils/amazic_logger.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../admob_ads_flutter.dart';
import '../channel/ad_platform_interface.dart';
import '../channel/loading_channel.dart';
import 'ads_base.dart';
import 'amazic_admob/admob_app_open_ad.dart';
import 'amazic_admob/admob_banner_ad.dart';
import 'amazic_admob/admob_interstitial_ad.dart';
import 'amazic_admob/admob_native_ad.dart';
import 'amazic_admob/admob_rewarded_ad.dart';
import 'amazic_ads/splash_ad_with_interstitial_and_app_open.dart';
part 'utils/ads_extension.dart';

class AdmobAds {
  AdmobAds._AdmobAds();

  static final AdmobAds instance = AdmobAds._AdmobAds();
  AppLifecycleReactor? appLifecycleReactor;
  GlobalKey<NavigatorState>? navigatorKey;

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  // late final IAdIdManager adIdManager;

  /// True value when there is exist an Ad and false otherwise.
  bool _isFullscreenAdShowing = false;

  void setFullscreenAdShowing(bool value) => _isFullscreenAdShowing = value;

  bool get isFullscreenAdShowing => _isFullscreenAdShowing;

  /// Enable or disable all ads
  bool _isEnabled = true;

  void enableAd(bool value) => _isEnabled = value;

  bool get isEnabled => _isEnabled;

  // final _eventController = EasyEventController();
  // Stream<AdEvent> get onEvent => _eventController.onEvent;

  Stream<AdEvent> get onEvent => _onEventController.stream;
  final _onEventController = StreamController<AdEvent>.broadcast();

  /// Preload interstitial normal
  AdsBase? interNormal;
  int loadTimesFailedInterNormal = 0;

  /// Preload interstitial priority
  AdsBase? interPriority;
  int loadTimesFailedInterPriority = 0;

  /// [_logger] is used to show Ad logs in the console
  final AmazicLogger _logger = AmazicLogger();
  AdSize? admobAdSize;

  RequestConfiguration? admobConfiguration;

  // bool _isDevMode = true;

  // bool get isDevMode => _isDevMode;

  bool _isAdmobInitialized = false;

  ///Khoảng thời gian giữa 2 lần hiển thị quảng cáo inter
  int _timeInterval = 0;
  int _lastTimeDismissInter = 0;

  ///Thời gian từ khi mở app tới khi bắt đầu show quảng cáo inter đầu tiên
  int _timeIntervalFromStart = 0;

  ///Thời gian mở app
  int _openAppTime = 0;

  Future<void> initAdmob() async {
    if (_isAdmobInitialized) {
      return;
    }

    // if (adIdManager.admobAdIds?.appId.isNotEmpty != true) {
    //   return;
    // }
    if (AdmobAds.instance.admobConfiguration != null) {
      await MobileAds.instance.updateRequestConfiguration(admobConfiguration!);
    }

    final initializationStatus = await MobileAds.instance.initialize();

    initializationStatus.adapterStatuses.forEach((key, value) {
      _logger.logInfo(
          'Adapter status for $key: ${value.description} | ${value.state}');
    });
    _isAdmobInitialized = true;
    fireNetworkInitializedEvent(
        AdNetwork.admob,
        initializationStatus.adapterStatuses.values.firstOrNull?.state ==
            AdapterInitializationState.ready);
  }

  Future<void> initAdNetwork() async {
    await initAdmob();
  }

  void resetUmp() {
    ConsentInformation.instance.reset();
  }

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  Future<void> initialize({
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    bool debugUmp = false,
    GlobalKey<NavigatorState>? navigatorKey,
    required List<String> listResumeId,
    required bool adResumeConfig,
    AdNetwork adResumeNetwork = AdNetwork.admob,

    ///init mediation callback
    Future<dynamic> Function(bool canRequestAds)? initMediationCallback,
    required Function(bool canRequestAds) onInitialized,
  }) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    if (enableLogger) _logger.enable(enableLogger);

    // _isDevMode = isDevMode;

    // adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    /// Handle UMP
    ConsentManager.ins.debugUmp = debugUmp;
    ConsentManager.ins.testIdentifiers = admobConfiguration?.testDeviceIds;
    ConsentManager.ins.initMediation = initMediationCallback;

    if (debugUmp) {
      resetUmp();
    }
    ConsentManager.ins.handleRequestUmp(
        onPostExecute: () => onInitialized(ConsentManager.ins.canRequestAds));

    // if (manager.admobAdIds?.appId != null) {
      this.admobConfiguration = admobConfiguration;
      if (navigatorKey?.currentContext != null) {
        admobAdSize =
            await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt());
      }
    // }

    if (navigatorKey != null) {
      this.navigatorKey = navigatorKey;
      appLifecycleReactor = AppLifecycleReactor(
        navigatorKey: navigatorKey,
        listId: listResumeId,
        config: adResumeConfig,
        adNetwork: adResumeNetwork,
      );
      appLifecycleReactor!.listenToAppStateChanges();
    }
  }

  /// Returns [AdsBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [admobAdSize] is used to provide ad banner size
  AdsBase? createBanner({
    required AdNetwork adNetwork,
    required List<String> listId,
    required AdsBannerType type,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    AdsBase? ad;
    if (adNetwork == AdNetwork.admob) {
      /// Get ad request
      AdRequest adRequest = _adRequest;
      if (type == AdsBannerType.collapsible_bottom) {
        adRequest = AdRequest(
          httpTimeoutMillis: _adRequest.httpTimeoutMillis,
          contentUrl: _adRequest.contentUrl,
          keywords: _adRequest.keywords,
          mediationExtras: _adRequest.mediationExtras,
          neighboringContentUrls: _adRequest.neighboringContentUrls,
          nonPersonalizedAds: _adRequest.nonPersonalizedAds,
          extras: {'collapsible': 'bottom'},
        );
      } else if (type == AdsBannerType.collapsible_top) {
        adRequest = AdRequest(
          httpTimeoutMillis: _adRequest.httpTimeoutMillis,
          contentUrl: _adRequest.contentUrl,
          keywords: _adRequest.keywords,
          mediationExtras: _adRequest.mediationExtras,
          neighboringContentUrls: _adRequest.neighboringContentUrls,
          nonPersonalizedAds: _adRequest.nonPersonalizedAds,
          extras: {'collapsible': 'top'},
        );
      }

      AdSize adSize = getAdmobAdSize(
        type: type,
      );

      // final String id = AdmobAds.instance.isDevMode
      //     ? (type == AdsBannerType.collapsible_bottom ||
      //             type == AdsBannerType.collapsible_top)
      //         ? TestAdsId.admobBannerCollapseId
      //         : TestAdsId.admobBannerId
      //     : adId;



      ad = AdmobBannerAd(
        listId: listId,
        adSize: adSize,
        adRequest: adRequest,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onEarnedReward: onEarnedReward,
        onPaidEvent: onPaidEvent,
      );
    }
    return ad;
  }

  AdsBase? createNative({
    required AdNetwork adNetwork,
    required String factoryId,
    required List<String> listId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    AdsBase? ad;
    switch (adNetwork) {
      default:
        // final String id =
        //     AdmobAds.instance.isDevMode ? TestAdsId.admobNativeId : adId;
        ad = AdmobNativeAd(
          listId: listId,
          factoryId: factoryId,
          adRequest: _adRequest,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  // AdsBase? createPreloadNative({
  //   required AdNetwork adNetwork,
  //   required AdsPlacementType type,
  //   required String adId,
  //   EasyAdCallback? onAdLoaded,
  //   EasyAdCallback? onAdShowed,
  //   EasyAdCallback? onAdClicked,
  //   EasyAdFailedCallback? onAdFailedToLoad,
  //   EasyAdFailedCallback? onAdFailedToShow,
  //   EasyAdCallback? onAdDismissed,
  //   EasyAdEarnedReward? onEarnedReward,
  //   EasyAdOnPaidEvent? onPaidEvent,
  // }) {
  //   AdsBase? ad;
  //   switch (adNetwork) {
  //     default:
  //       final String id =
  //           AdmobAds.instance.isDevMode ? TestAdsId.admobNativeId : adId;
  //       ad = AdmobPreloadNativeAd(
  //         adUnitId: id,
  //         type: type,
  //         adRequest: _adRequest,
  //         onAdLoaded: onAdLoaded,
  //         onAdShowed: onAdShowed,
  //         onAdClicked: onAdClicked,
  //         onAdFailedToLoad: onAdFailedToLoad,
  //         onAdFailedToShow: onAdFailedToShow,
  //         onAdDismissed: onAdDismissed,
  //         onEarnedReward: onEarnedReward,
  //         onPaidEvent: onPaidEvent,
  //       );
  //       break;
  //   }
  //
  //   return ad;
  // }

  AdsBase? createInterstitial({
    required AdNetwork adNetwork,
    required List<String> listId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    AdsBase? ad;
    switch (adNetwork) {
      default:
        // final String id =
        //     AdmobAds.instance.isDevMode ? TestAdsId.admobInterstitialId : adId;
        ad = AdmobInterstitialAd(
          listId: listId,
          adRequest: _adRequest,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }
    return ad;
  }

  AdsBase? createReward({
    required AdNetwork adNetwork,
    required List<String> listId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    AdsBase? ad;
    switch (adNetwork) {
      default:
        // final String id =
        //     AdmobAds.instance.isDevMode ? TestAdsId.admobRewardId : adId;
        ad = AdmobRewardedAd(
          listId: listId,
          adRequest: _adRequest,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  AdsBase? createAppOpenAd({
    required AdNetwork adNetwork,
    required List<String> listId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    AdsBase? ad;
    switch (adNetwork) {
      default:
        // String id =
        //     AdmobAds.instance.isDevMode ? TestAdsId.admobOpenResume : adId;
        ad = AdmobAppOpenAd(
          listId: listId,
          adRequest: _adRequest,
          onAdLoaded: onAdLoaded,
          onAdShowed: onAdShowed,
          onAdClicked: onAdClicked,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdFailedToShow: onAdFailedToShow,
          onAdDismissed: onAdDismissed,
          onEarnedReward: onEarnedReward,
          onPaidEvent: onPaidEvent,
        );
        break;
    }

    return ad;
  }

  Future<void> showAppOpen({
    AdNetwork adNetwork = AdNetwork.admob,
    required List<String> listId,
    Function()? onDisabled,
    required bool config,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      onDisabled?.call();
      return;
    }

    final appOpen = createAppOpenAd(
      adNetwork: adNetwork,
      listId: listId,
      onAdClicked: onAdClicked,
      onAdDismissed: (adNetwork, adUnitType, data) {
        onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        Future.delayed(const Duration(seconds: 1), () {
          LoadingChannel.closeAd();
        });
        onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: onPaidEvent,
    );

    if (appOpen == null) {
      return;
    }

    LoadingChannel.setMethodCallHandler(appOpen.show);
    AdmobAds.instance.setFullscreenAdShowing(true);

    // AdPlatform.instance.showLoadingAd(getPrimaryColor());
    appOpen.load();
  }

  Future<void> showInterstitialAd({
    AdNetwork adNetwork = AdNetwork.admob,
    required List<String> listId,
    Function()? onDisabled,
    required bool config,
    bool? isShowAdsSplash = false,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      _logger.logInfo('1. isEnabled: $isEnabled, config: $config');
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      _logger.logInfo('2. _isFullscreenAdShowing: $_isFullscreenAdShowing');
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      _logger.logInfo('3. isDeviceOffline: ${isDeviceOffline()}');
      onDisabled?.call();
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      _logger.logInfo('4. canRequestAds: ${ConsentManager.ins.canRequestAds}');
      onDisabled?.call();
      return;
    }

    ///check nếu là show ads màn Splash thì k cần check interval_interstitial_from_start
    if (isShowAdsSplash == false &&
        DateTime.now().millisecondsSinceEpoch - _openAppTime < _timeIntervalFromStart) {
      _logger.logInfo('5. isShowAdsSplash: $isShowAdsSplash, timeMinus: ${DateTime.now().millisecondsSinceEpoch - _openAppTime}, _timeIntervalFromStart: $_timeIntervalFromStart');

      onDisabled?.call();
      return;
    }

    ///check timeinterval
    if (isShowAdsSplash == false && DateTime.now().millisecondsSinceEpoch - _lastTimeDismissInter <=
        _timeInterval) {
      _logger.logInfo('6. isShowAdsSplash: $isShowAdsSplash, timeMinus: ${DateTime.now().millisecondsSinceEpoch - _lastTimeDismissInter}, _timeInterval: $_timeInterval');
      onDisabled?.call();
      return;
    }

    final interstitialAd = createInterstitial(
      adNetwork: adNetwork,
      listId: listId,
      onAdClicked: onAdClicked,
      onAdDismissed: (adNetwork, adUnitType, data) {
        if(isShowAdsSplash == false) _lastTimeDismissInter = DateTime.now().millisecondsSinceEpoch;
        onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        Future.delayed(const Duration(seconds: 1), () {
          LoadingChannel.closeAd();
        });
        onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: onPaidEvent,
    );
    if (interstitialAd == null) {
      return;
    }

    LoadingChannel.setMethodCallHandler(interstitialAd.show);
    AdmobAds.instance.setFullscreenAdShowing(true);

    // AdPlatform.instance.showLoadingAd(getPrimaryColor());
    interstitialAd.load();
  }

  int getPrimaryColor() {
    if (navigatorKey?.currentContext == null) {
      return Colors.black.value;
    }

    return Theme.of(navigatorKey!.currentContext!).primaryColor.value;
  }

  Future<void> showRewardAd({
    AdNetwork adNetwork = AdNetwork.admob,
    required List<String> listId,
    Function()? onDisabled,
    required bool config,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isEnabled || !config) {
      onDisabled?.call();
      return;
    }
    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      onDisabled?.call();
      return;
    }
    final rewardAd = createReward(
      adNetwork: adNetwork,
      listId: listId,
      onAdClicked: onAdClicked,
      onAdDismissed: (adNetwork, adUnitType, data) {
        onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        Future.delayed(const Duration(seconds: 1), () {
          LoadingChannel.closeAd();
        });
        onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: onPaidEvent,
      onEarnedReward: onEarnedReward,
    );
    if (rewardAd == null) {
      return;
    }

    LoadingChannel.setMethodCallHandler(rewardAd.show);
    AdmobAds.instance.setFullscreenAdShowing(true);

    // AdPlatform.instance.showLoadingAd(getPrimaryColor());
    rewardAd.load();
  }

  Future<void> showSplashAdWithInterstitialAndAppOpen({
    AdNetwork adNetwork = AdNetwork.admob,
    required List<String> listInterId,
    required List<String> listOpenId,
    required Function()? onDisabled,
    void Function(AdUnitType type)? onShowed,
    void Function(AdUnitType type)? onDismissed,
    void Function()? onFailedToLoad,
    void Function(AdUnitType type)? onFailedToShow,
    Function(AdUnitType type)? onClicked,
    EasyAdCallback? onAdInterstitialLoaded,
    EasyAdCallback? onAdInterstitialShowed,
    EasyAdCallback? onAdInterstitialClicked,
    EasyAdFailedCallback? onAdInterstitialFailedToLoad,
    EasyAdFailedCallback? onAdInterstitialFailedToShow,
    EasyAdCallback? onAdInterstitialDismissed,
    EasyAdOnPaidEvent? onInterstitialPaidEvent,
    required bool configInterstitial,
    EasyAdCallback? onAdAppOpenLoaded,
    EasyAdCallback? onAdAppOpenShowed,
    EasyAdCallback? onAdAppOpenClicked,
    EasyAdFailedCallback? onAdAppOpenFailedToLoad,
    EasyAdFailedCallback? onAdAppOpenFailedToShow,
    EasyAdCallback? onAdAppOpenDismissed,
    EasyAdOnPaidEvent? onAppOpenPaidEvent,
    required bool configAppOpen,
  }) async {
    if (!isEnabled) {
      onDisabled?.call();
      return;
    }
    if (!configAppOpen && !configInterstitial) {
      onDisabled?.call();
      return;
    }

    if (_isFullscreenAdShowing) {
      onDisabled?.call();
      return;
    }
    if (await isDeviceOffline()) {
      onDisabled?.call();
      return;
    }
    // ignore: use_build_context_synchronously
    navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (context) => SplashAdWithInterstitialAndAppOpen(
          adNetwork: adNetwork,
          listInterId: listInterId,
          listOpenId: listOpenId,
          onShowed: onShowed,
          onDismissed: onDismissed,
          onFailedToLoad: onFailedToLoad,
          onFailedToShow: onFailedToShow,
          onClicked: onClicked,
          onAdInterstitialLoaded: onAdInterstitialLoaded,
          onAdInterstitialShowed: onAdInterstitialShowed,
          onAdInterstitialClicked: onAdInterstitialClicked,
          onAdInterstitialFailedToLoad: onAdInterstitialFailedToLoad,
          onAdInterstitialFailedToShow: onAdInterstitialFailedToShow,
          onAdInterstitialDismissed: onAdInterstitialDismissed,
          onInterstitialPaidEvent: onInterstitialPaidEvent,
          configInterstitial: configInterstitial,
          onAdAppOpenLoaded: onAdAppOpenLoaded,
          onAdAppOpenShowed: onAdAppOpenShowed,
          onAdAppOpenClicked: onAdAppOpenClicked,
          onAdAppOpenFailedToLoad: onAdAppOpenFailedToLoad,
          onAdAppOpenFailedToShow: onAdAppOpenFailedToShow,
          onAdAppOpenDismissed: onAdAppOpenDismissed,
          onAppOpenPaidEvent: onAppOpenPaidEvent,
          configAppOpen: configAppOpen,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  AdSize getAdmobAdSize({
    AdsBannerType type = AdsBannerType.standard,
  }) {
    if (admobAdSize == null) {
      if (navigatorKey?.currentContext != null) {
        Future(
          () async {
            admobAdSize =
                await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                    MediaQuery.sizeOf(navigatorKey!.currentContext!)
                        .width
                        .toInt());
          },
        );
      }
      return AdSize.banner;
    }
    switch (type) {
      case AdsBannerType.standard:
        return AdSize.banner;
      case AdsBannerType.adaptive:
      case AdsBannerType.collapsible_bottom:
      case AdsBannerType.collapsible_top:
        return admobAdSize!;
    }
  }

  Future<bool> isDeviceOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.wifi &&
        connectivityResult != ConnectivityResult.mobile) {
      return true;
    }
    return false;
  }

  Future<bool?> getConsentResult() async {
    return await AdPlatform.instance.getConsentResult();
  }

  void logInfo(String message) => _logger.logInfo(message);

  void setTimeIntervalBetweenInter(int time) {
    _lastTimeDismissInter = 0;
    _timeInterval = time;
  }

  void setTimeIntervalInterFromStart(int time) {
    _timeIntervalFromStart = time;
  }

  void setOpenAppTime(int time) {
    _openAppTime = time;
  }
}
