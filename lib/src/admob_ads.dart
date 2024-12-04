// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:amazic_ads_flutter/src/utils/preferences_util.dart';
import 'package:amazic_ads_flutter/src/utils/remote_config.dart';
import 'package:amazic_ads_flutter/src/utils/remote_config_key.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amazic_ads_flutter/src/utils/amazic_logger.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../adjust_config/call_organic_adjust.dart';
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
  bool _isShowAllAds = true;

  void setShowAllAds(bool value) => _isShowAllAds = value;

  bool get isShowAllAds => _isShowAllAds;

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

  ///Count time load ads
  Timer? _timer;
  int _second = 0;

  Future<void> initAllDataSplash({
    RequestConfiguration? admobConfiguration,
    required List<RemoteConfigKeyLib> remoteConfigKeys,
    bool enableLogger = true,
    bool debugUmp = false,
    Future<dynamic> Function(bool canRequestAds)? initMediationCallback,
    required String adjustToken,
    Widget? child,
    bool isShowWelComeScreenAfterAds = true,
    required List<String> listResumeId,
    required bool adResumeConfig,
    required Function() onSetRemoteConfigOrganic,
    required Function() onStartLoadBannerSplash,
    required Function() onNextAction,
    required String keyRateAOA,
    required String keyOpenSplash,
    required String keyInterSplash,
    required String keyIntervalBetweenInterstitial,
    required String keyInterstitialFromStart,
    required String nameAdsOpenSplash,
    required String nameAdsInterSplash,
    String? linkServer,
    String? appId,
    String? packageName,
    bool isIap = false,
  }) async {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _second++;
      },
    );

    final Completer<bool> organicCompleter = Completer<bool>();

    const timeoutDuration = Duration(seconds: 12);

    final Completer<void> timeoutCompleter = Completer<void>();

    Future.delayed(timeoutDuration).then((_) {
      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.completeError(
          TimeoutException('Operation timed out after $timeoutDuration'),
        );
      }
    });

    ///call remote config
    Future<void> initRemoteConfig =
        RemoteConfigLib.init(remoteConfigKeys: remoteConfigKeys).then(
      (value) {
        RemoteConfigLib.getRemoteConfig();
      },
    );

    ///call Organic
    Future<void> initOrganicAdjust =
        CallOrganicAdjust.instance.initOrganicAdjust(
            onOrganic: () {
              if (!organicCompleter.isCompleted) {
                organicCompleter.complete(true);
              }
            },
            onError: (p0) {
              if (!organicCompleter.isCompleted) {
                organicCompleter.complete(false);
              }
            },
            onNextAction: () {},
            appToken: adjustToken);

    ///call UMP
    Future<void> initUMP = initUMPAndAdmob(
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
      admobConfiguration: admobConfiguration,
      initMediationCallback: initMediationCallback,
      debugUmp: debugUmp,
      enableLogger: enableLogger,
      onInitialized: (canRequestAds) {},
    );

    final tasksFuture = Future.wait([
      initRemoteConfig,
      initOrganicAdjust,
      initUMP,
      organicCompleter.future,
    ]).then((_) {
      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.complete();
      }
    }).catchError((e) {
      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.completeError(e);
      }
    });

    try {
      await Future.any([tasksFuture, timeoutCompleter.future]);
      print('time_out_call: All tasks completed successfully.');
    } on TimeoutException catch (e) {
      print('time_out_call: Timeout ${e.message}');
      EventLogLib.logEvent("inter_splash_id_timeout");
      countOpenApp();
      onNextAction();
    } catch (e) {
      print('time_out_call: Error $e');
      EventLogLib.logEvent("inter_splash_error");
      countOpenApp();
      onNextAction();
    }

    ///set giá trị remote TH Organic
    bool isOrganic = await organicCompleter.future;
    if (isOrganic) {
      onSetRemoteConfigOrganic();
    }

    ///set k show all ads TH đã mua sub
    if (isIap) {
      IapMethodChannel.instance().setUpListener(
        onAction: () {},
      );
      bool isPurchase = await IapMethodChannel.instance().isPurchase();
      if (isPurchase) {
        //off all ads
        setShowAllAds(false);
      }
    }

    /// sau khi call xong thì load Bannner Splash luôn
    onStartLoadBannerSplash();

    ///set time
    setOpenAppTime(DateTime.now().millisecondsSinceEpoch);
    setTimeIntervalBetweenInter(RemoteConfigLib.configs[
        RemoteConfigKeyLib.getKeyByName(keyIntervalBetweenInterstitial).name]);
    setTimeIntervalInterFromStart(RemoteConfigLib.configs[
        RemoteConfigKeyLib.getKeyByName(keyInterstitialFromStart).name]);

    ///call id ads
    await NetworkRequest.instance
        .fetchAdsModel(
      linkServer: linkServer,
      appId: appId,
      packageName: packageName,
      onResponse: () {
        initAdsResumeAndSplash(
            keyRateAOA: keyRateAOA,
            keyOpenSplash: keyOpenSplash,
            keyInterSplash: keyInterSplash,
            onNextAction: onNextAction,
            listResumeId: listResumeId,
            adResumeConfig: adResumeConfig,
            nameAdsOpenSplash: nameAdsOpenSplash,
            nameAdsInterSplash: nameAdsInterSplash);
      },
      onError: (p0) {
        countOpenApp();
        onNextAction();
      },
    )
        .timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        initAdsResumeAndSplash(
            keyRateAOA: keyRateAOA,
            keyOpenSplash: keyOpenSplash,
            keyInterSplash: keyInterSplash,
            onNextAction: onNextAction,
            listResumeId: listResumeId,
            adResumeConfig: adResumeConfig,
            nameAdsOpenSplash: nameAdsOpenSplash,
            nameAdsInterSplash: nameAdsInterSplash);
        return;
      },
    );
  }

  //init ads resume and ads splash
  Future<void> initAdsResumeAndSplash({
    required String keyRateAOA,
    required String keyOpenSplash,
    required String keyInterSplash,
    required String nameAdsOpenSplash,
    required String nameAdsInterSplash,
    required Function() onNextAction,
    Widget? child,
    bool isShowWelComeScreenAfterAds = true,
    required List<String> listResumeId,
    required bool adResumeConfig,
  }) async {
    ///khởi tạo ads resume
    if (navigatorKey != null) {
      appLifecycleReactor = AppLifecycleReactor(
          navigatorKey: navigatorKey!,
          listId: listResumeId,
          config: adResumeConfig,
          adNetwork: AdNetwork.admob,
          child: child,
          isShowWelComeScreenAfterAds: isShowWelComeScreenAfterAds);
      appLifecycleReactor!.listenToAppStateChanges();
    }

    ///showAds inter/open Splash
    showAdsSplash(
        keyRateAOA: keyRateAOA,
        keyOpenSplash: keyOpenSplash,
        keyInterSplash: keyInterSplash,
        onNextAction: onNextAction,
        nameAdsOpenSplash: nameAdsOpenSplash,
        nameAdsInterSplash: nameAdsInterSplash);
  }

  ///init UMP
  Future<void> initUMPAndAdmob({
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    bool debugUmp = false,
    Future<dynamic> Function(bool canRequestAds)? initMediationCallback,
    required Function(bool canRequestAds) onInitialized,
  }) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    if (enableLogger) _logger.enable(enableLogger);

    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    ConsentManager.ins.debugUmp = debugUmp;
    ConsentManager.ins.testIdentifiers = admobConfiguration?.testDeviceIds;
    ConsentManager.ins.initMediation = initMediationCallback;

    if (debugUmp) {
      resetUmp();
    }
    ConsentManager.ins.handleRequestUmp(
        onPostExecute: () => onInitialized(ConsentManager.ins.canRequestAds));

    this.admobConfiguration = admobConfiguration;
    if (navigatorKey?.currentContext != null) {
      admobAdSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              MediaQuery.sizeOf(navigatorKey!.currentContext!).width.toInt());
    }
  }

  ///show Ads inter/open Splash
  void showAdsSplash(
      {required String keyRateAOA,
      required String keyOpenSplash,
      required String keyInterSplash,
      required String nameAdsOpenSplash,
      required String nameAdsInterSplash,
      required Function() onNextAction}) {
    final String rateAoa = RemoteConfigLib
        .configs[RemoteConfigKeyLib.getKeyByName(keyRateAOA).name];
    final bool isShowOpen = RemoteConfigLib
        .configs[RemoteConfigKeyLib.getKeyByName(keyOpenSplash).name];
    final bool isShowInter = RemoteConfigLib
        .configs[RemoteConfigKeyLib.getKeyByName(keyInterSplash).name];

    ///log Event
    bool idAdsCheck =
        NetworkRequest.instance.listAdsId.isNotEmpty ? true : false;

    EventLogLib.logEvent("inter_splash_tracking", parameters: {
      'splash_detail':
          '${ConsentManager.ins.canRequestAds}_${CallOrganicAdjust.instance.isOrganic()}_${isHaveInternet()}_${AdmobAds.instance.isShowAllAds}_${idAdsCheck}_$rateAoa',
      'ump': '${ConsentManager.ins.canRequestAds}',
      'organic': '${CallOrganicAdjust.instance.isOrganic()}',
      'haveinternet': '${isHaveInternet()}',
      'showallad': '${AdmobAds.instance.isShowAllAds}',
      'idcheck': '$idAdsCheck',
      'interremote_openremote_aoavalue': '${isShowInter}_${isShowOpen}_$rateAoa'
    });

    ///end Log

    AdsSplash.instance.init(isShowInter, isShowOpen, rateAoa);
    AdsSplash.instance.showAdSplash(
      listOpenId: NetworkRequest.instance.getListIDByName(nameAdsOpenSplash),
      listInterId: NetworkRequest.instance.getListIDByName(nameAdsInterSplash),
      onAdShowed: (adNetwork, adUnitType, data) {
        EventLogLib.logEvent('inter_splash_showad_time',
            parameters: {'showad_time': 'true_$_second'});
        _timer?.cancel();
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        AdmobAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        countOpenApp();
        onNextAction();
      },
      onDisabled: () {
        AdmobAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        countOpenApp();
        onNextAction();
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        AdmobAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        countOpenApp();
        onNextAction();
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        EventLogLib.logEvent("inter_splash_showad_time",
            parameters: {'showad_time': 'false_$_second'});
        _timer?.cancel();
        AdmobAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        countOpenApp();
        onNextAction();
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        EventLogLib.logEvent("inter_splash_true");
      },
      onAdImpression: (adNetwork, adUnitType, data) {
        EventLogLib.logEvent(
            "inter_splash_impression_${PreferencesUtilLib.getCountOpenApp()}");
      },
      onAdClicked: (adNetwork, adUnitType, data) {
        EventLogLib.logEvent(
            "inter_splash_click_${PreferencesUtilLib.getCountOpenApp()}");
      },
    );
  }

  ///count số lần vào app
  Future<void> countOpenApp() async {
    PreferencesUtilLib.increaseCountOpenApp();
  }

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
    Widget? child,
    bool isShowWelComeScreenAfterAds = true,

    ///init mediation callback
    Future<dynamic> Function(bool canRequestAds)? initMediationCallback,
    required Function(bool canRequestAds) onInitialized,
  }) async {
    // await PreferencesUtilLib.init();

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
          child: child,
          isShowWelComeScreenAfterAds: isShowWelComeScreenAfterAds);
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

  //load ads native trước
  Future<AdsBase?> loadNativeAds({
    required AdNetwork adNetwork,
    required String factoryId,
    required List<String> listId,
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
    if (!AdmobAds.instance.isShowAllAds ||
        await AdmobAds.instance.isDeviceOffline() ||
        !config ||
        !ConsentManager.ins.canRequestAds) {
      if (factoryId.toLowerCase().contains("intro_full")) {
        EventLogLib.logEvent("native_intro_full_false", parameters: {
          "reason":
              "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.isHaveInternet()}"
        });
      } else {
        EventLogLib.logEvent("native_intro_false", parameters: {
          "reason":
              "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.isHaveInternet()}"
        });
      }
      return null;
    }

    if (factoryId.toLowerCase().contains("intro_full")) {
      EventLogLib.logEvent("native_intro_full_true");
    } else {
      EventLogLib.logEvent("native_intro_true");
    }

    AdsBase? ad = AdmobAds.instance.createNative(
      adNetwork: adNetwork,
      factoryId: factoryId,
      listId: listId,
      onAdLoaded: onAdLoaded,
      onAdShowed: onAdShowed,
      onAdClicked: onAdClicked,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdFailedToShow: onAdFailedToShow,
      onAdDismissed: onAdDismissed,
      onEarnedReward: onEarnedReward,
      onPaidEvent: onPaidEvent,
    );
    await ad?.load();
    return ad;
  }

  //end

  AdsBase? createNative({
    required AdNetwork adNetwork,
    required String factoryId,
    required List<String> listId,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdImpression,
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
          onAdImpression: onAdImpression,
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
  //       // final String id =
  //       //     AdmobAds.instance.isDevMode ? TestAdsId.admobNativeId : adId;
  //       final String id = adId;
  //       ad = AdmobPreloadNativeAd(
  //         listId: [id],
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
    EasyAdCallback? onAdImpression,
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
          onAdImpression: onAdImpression,
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
    EasyAdCallback? onAdImpression,
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
          onAdImpression: onAdImpression,
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
    EasyAdCallback? onAdImpression,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
    Function? onDismissCollapse,
    Function? onCanRequestLogEvent,
  }) async {
    if (!isShowAllAds ||
        !config ||
        _isFullscreenAdShowing ||
        await isDeviceOffline() ||
        !ConsentManager.ins.canRequestAds) {
      onDisabled?.call();
      return;
    }
    // if () {
    //   onDisabled?.call();
    //   return;
    // }
    // if () {
    //   onDisabled?.call();
    //   return;
    // }
    // if () {
    //   onDisabled?.call();
    //   return;
    // }

    //logEvent có thể Request ads
    onCanRequestLogEvent?.call();

    final appOpen = createAppOpenAd(
      adNetwork: adNetwork,
      listId: listId,
      onAdClicked: onAdClicked,
      onAdDismissed: (adNetwork, adUnitType, data) async {
        onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: ondismiss_App_Open - $isFullscreenAdShowing');
        if (Platform.isIOS) {
          if (onDismissCollapse != null) {
            await onDismissCollapse();
          }
          LoadingChannel.closeAd();
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) async {
        if (onDismissCollapse != null) {
          await onDismissCollapse();
        }
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToLoad_App_Open - $isFullscreenAdShowing');
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) async {
        if (onDismissCollapse != null) {
          await onDismissCollapse();
        }
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToShow_App_Open - $isFullscreenAdShowing');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(seconds: 1), () async {
            if (onDismissCollapse != null) {
              await onDismissCollapse();
            }
            LoadingChannel.closeAd();
          });
        }
        onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: onPaidEvent,
      onAdImpression: onAdImpression,
    );

    if (appOpen == null) {
      return;
    }

    LoadingChannel.setMethodCallHandler(appOpen.show);
    AdmobAds.instance.setFullscreenAdShowing(true);
    print('check_full_screen_ads_show: end_App_Open - $isFullscreenAdShowing');

    AdPlatform.instance.showLoadingAd(getPrimaryColor());
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
    EasyAdCallback? onAdImpression,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) async {
    if (!isShowAllAds ||
        !config ||
        _isFullscreenAdShowing ||
        await isDeviceOffline() ||
        !ConsentManager.ins.canRequestAds) {
      _logger.logInfo('1. isEnabled: $isShowAllAds, config: $config');

      EventLogLib.logEvent("inter_intro_false", parameters: {
        "reason":
            "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.isHaveInternet()}"
      });
      onDisabled?.call();
      return;
    }
    // if () {
    //   _logger.logInfo('2. _isFullscreenAdShowing: $_isFullscreenAdShowing');
    //   onDisabled?.call();
    //   return;
    // }
    // if () {
    //   _logger.logInfo('3. isDeviceOffline: ${isDeviceOffline()}');
    //   onDisabled?.call();
    //   return;
    // }
    // if () {
    //   _logger.logInfo('4. canRequestAds: ${ConsentManager.ins.canRequestAds}');
    //   onDisabled?.call();
    //   return;
    // }

    ///check nếu là show ads màn Splash thì k cần check interval_interstitial_from_start
    if (isShowAdsSplash == false &&
        DateTime.now().millisecondsSinceEpoch - _openAppTime <
            _timeIntervalFromStart) {
      _logger.logInfo(
          '5. isShowAdsSplash: $isShowAdsSplash, timeMinus: ${DateTime.now().millisecondsSinceEpoch - _openAppTime}, _timeIntervalFromStart: $_timeIntervalFromStart');

      onDisabled?.call();
      return;
    }

    ///check timeinterval
    if (isShowAdsSplash == false &&
        DateTime.now().millisecondsSinceEpoch - _lastTimeDismissInter <=
            _timeInterval) {
      _logger.logInfo(
          '6. isShowAdsSplash: $isShowAdsSplash, timeMinus: ${DateTime.now().millisecondsSinceEpoch - _lastTimeDismissInter}, _timeInterval: $_timeInterval');
      onDisabled?.call();
      return;
    }

    EventLogLib.logEvent("inter_intro_true");

    final interstitialAd = createInterstitial(
      adNetwork: adNetwork,
      listId: listId,
      onAdClicked: onAdClicked,
      onAdDismissed: (adNetwork, adUnitType, data) {
        if (isShowAdsSplash == false)
          _lastTimeDismissInter = DateTime.now().millisecondsSinceEpoch;
        onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdDismiss_Inter - $isFullscreenAdShowing');
        if (Platform.isIOS) {
          LoadingChannel.closeAd();
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToLoad_Inter - $isFullscreenAdShowing');
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToShow_Inter - $isFullscreenAdShowing');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(seconds: 1), () {
            LoadingChannel.closeAd();
          });
        }
        onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: onPaidEvent,
      onAdImpression: onAdImpression,
    );
    if (interstitialAd == null) {
      return;
    }

    LoadingChannel.setMethodCallHandler(interstitialAd.show);
    AdmobAds.instance.setFullscreenAdShowing(true);
    print('check_full_screen_ads_show: end_Inter - $isFullscreenAdShowing');

    AdPlatform.instance.showLoadingAd(getPrimaryColor());
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
    if (!isShowAllAds || !config) {
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
        print(
            'check_full_screen_ads_show: onAdDismiss_Reward - $isFullscreenAdShowing');
        if (Platform.isIOS) {
          LoadingChannel.closeAd();
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToLoad_Reward - $isFullscreenAdShowing');
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        LoadingChannel.closeAd();
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print(
            'check_full_screen_ads_show: onAdFailedToShow_Reward - $isFullscreenAdShowing');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        onAdLoaded?.call(adNetwork, adUnitType, data);
        LoadingChannel.handleShowAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(seconds: 1), () {
            LoadingChannel.closeAd();
          });
        }
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
    print('check_full_screen_ads_show: end_Reward - $isFullscreenAdShowing');

    AdPlatform.instance.showLoadingAd(getPrimaryColor());
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
    if (!isShowAllAds) {
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
        connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.vpn) {
      return true;
    }
    return false;
  }

  bool isHaveInternet() {
    bool isNetwork = true;
    AdmobAds.instance.isDeviceOffline().then(
      (value) {
        isNetwork = value;
      },
    );
    return isNetwork;
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
