import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/utils/ad_event.dart';
import 'package:lib_ads_flutter/utils/auto_hiding_loader_dialog.dart';
import 'package:lib_ads_flutter/utils/easy_event_controller.dart';
import 'package:lib_ads_flutter/utils/easy_logger.dart';
import 'package:lib_ads_flutter/utils/extensions.dart';
import 'package:lib_ads_flutter/utils/i_ad_id_manager.dart';

import 'easy_ad_base.dart';
import 'easy_admob/app_lifecycle_reactor.dart';
import 'easy_admob/easy_admob_app_open_ad.dart';
import 'easy_admob/easy_admob_banner_ad.dart';
import 'easy_admob/easy_admob_interstitial_ad.dart';
import 'easy_admob/easy_admob_rewarded_ad.dart';
import 'enums/ad_network.dart';
import 'enums/ad_unit_type.dart';

class EasyAds {
  EasyAds._easyAds();
  static final EasyAds instance = EasyAds._easyAds();

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  late final IAdIdManager adIdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  final _eventController = EasyEventController();
  Stream<AdEvent> get onEvent => _eventController.onEvent;

  List<EasyAdBase> get _allAds => [..._interstitialAds, ..._rewardedAds];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _appOpenAds = [];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _interstitialAds = [];

  /// All the rewarded ads will be stored in it
  final List<EasyAdBase> _rewardedAds = [];

  /// [_logger] is used to show Ad logs in the console
  final EasyLogger _logger = EasyLogger();

  /// On banner, ad badge will appear
  bool get showAdBadge => _showAdBadge;
  bool _showAdBadge = false;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  /// [fbTestingId] can be obtained by running the app once without the testingId.
  Future<void> initialize(
    IAdIdManager manager, {
    bool unityTestMode = false,
    bool fbTestMode = false,
    bool isShowAppOpenOnAppStateChange = false,
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    String? fbTestingId,
    bool isAgeRestrictedUserForApplovin = false,
    bool fbiOSAdvertiserTrackingEnabled = false,
    bool showAdBadge = false,
  }) async {
    _showAdBadge = showAdBadge;
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    if (admobConfiguration != null) {
      MobileAds.instance.updateRequestConfiguration(admobConfiguration);
    }

    final admobAdId = manager.admobAdIds?.appId;
    if (admobAdId != null && admobAdId.isNotEmpty) {
      final response = await MobileAds.instance.initialize();
      final status = response.adapterStatuses.values.firstOrNull?.state;

      response.adapterStatuses.forEach((key, value) {
        _logger.logInfo(
            'Google-mobile-ads Adapter status for $key: ${value.description}');
      });

      _eventController.fireNetworkInitializedEvent(
          AdNetwork.admob, status == AdapterInitializationState.ready);

      // Initializing admob Ads
      await EasyAds.instance._initAdmob(
        appOpenAdUnitId: manager.admobAdIds?.appOpenId,
        interstitialAdUnitId: manager.admobAdIds?.interstitialId,
        rewardedAdUnitId: manager.admobAdIds?.rewardedId,
        isShowAppOpenOnAppStateChange: isShowAppOpenOnAppStateChange,
      );
    }

  }

  /// Returns [EasyAdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  EasyAdBase? createBanner(
      {required AdNetwork adNetwork, AdSize adSize = AdSize.banner}) {
    EasyAdBase? ad;

    switch (adNetwork) {
      case AdNetwork.admob:
        final bannerId = adIdManager.admobAdIds?.bannerId;
        assert(bannerId != null,
            'You are trying to create a banner and Admob Banner id is null in ad id manager');
        if (bannerId != null) {
          ad = EasyAdmobBannerAd(bannerId,
              adSize: adSize, adRequest: _adRequest);
          _eventController.setupEvents(ad);
        }
        break;
      case AdNetwork.unity:
        // final bannerId = adIdManager.unityAdIds?.bannerId;
        // assert(bannerId != null,
        //     'You are trying to create a banner and Unity Banner id is null in ad id manager');
        // if (bannerId != null) {
        //   ad = EasyUnityBannerAd(bannerId, adSize: adSize);
        //   _eventController.setupEvents(ad);
        // }
        break;
      case AdNetwork.facebook:
        // final bannerId = adIdManager.fbAdIds?.bannerId;
        // assert(bannerId != null,
        //     'You are trying to create a banner and Facebook Banner id is null in ad id manager');
        // if (bannerId != null) {
        //   ad = EasyFacebookBannerAd(bannerId, adSize: adSize);
        //   _eventController.setupEvents(ad);
        // }
        break;
      case AdNetwork.appLovin:
        // final bannerId = adIdManager.appLovinAdIds?.bannerId;
        // assert(bannerId != null,
        //     'You are trying to create a banner and Applovin Banner id is null in ad id manager');
        // if (bannerId != null) {
        //   ad = EasyApplovinBannerAd(bannerId);
        //   _eventController.setupEvents(ad);
        // }
        break;
      default:
        ad = null;
    }
    return ad;
  }

  Future<void> _initAdmob({
    String? appOpenAdUnitId,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
    bool immersiveModeEnabled = true,
    bool isShowAppOpenOnAppStateChange = true,
  }) async {
    // init interstitial ads
    if (interstitialAdUnitId != null &&
        _interstitialAds.doesNotContain(
            AdNetwork.admob, AdUnitType.interstitial)) {
      final ad = EasyAdmobInterstitialAd(
          interstitialAdUnitId, _adRequest, immersiveModeEnabled);
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedAdUnitId != null &&
        _rewardedAds.doesNotContain(AdNetwork.admob, AdUnitType.rewarded)) {
      final ad = EasyAdmobRewardedAd(
          rewardedAdUnitId, _adRequest, immersiveModeEnabled);
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    if (appOpenAdUnitId != null &&
        _appOpenAds.doesNotContain(AdNetwork.admob, AdUnitType.appOpen)) {
      final appOpenAdManager = EasyAdmobAppOpenAd(appOpenAdUnitId, _adRequest);
      await appOpenAdManager.load();
      if (isShowAppOpenOnAppStateChange) {
        _appLifecycleReactor =
            AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
        _appLifecycleReactor.listenToAppStateChanges();
      }
      _appOpenAds.add(appOpenAdManager);
      _eventController.setupEvents(appOpenAdManager);
    }
  }


  /// Displays [adUnitType] ad from [adNetwork]. It will check if first ad it found from list is loaded,
  /// it will be displayed if [adNetwork] is not mentioned otherwise it will load the ad.
  ///
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  /// if [adNetwork] is provided, only that network's ad would be displayed
  /// if [loaderDuration] is > 0 then it will show loader before showing ad, and use [loaderDuration] in seconds. Also, you have to provide build context.
  bool showAd(AdUnitType adUnitType,
      {AdNetwork adNetwork = AdNetwork.any,
      int loaderDuration = 0,
      BuildContext? context}) {
    Fluttertoast.showToast(msg: '1.$loaderDuration');
    if (loaderDuration > 0) {
      assert(context != null,
          "Loader duration is greater than zero, context has to be provided in order to show dialog");
    }
    Fluttertoast.showToast(msg: '1.1 $adUnitType');
    List<EasyAdBase> ads = [];
    if (adUnitType == AdUnitType.rewarded) {
      Fluttertoast.showToast(msg: '1.rewarded');
      ads = _rewardedAds;
    } else if (adUnitType == AdUnitType.interstitial) {
      Fluttertoast.showToast(msg: '1.interstitial');
      ads = _interstitialAds;
    } else if (adUnitType == AdUnitType.appOpen) {
      Fluttertoast.showToast(msg: '1.appOpen');
      ads = _appOpenAds;
    }
    Fluttertoast.showToast(msg: '2');
    if (adNetwork != AdNetwork.any) {
      Fluttertoast.showToast(msg: '3');
      final ad = ads.firstWhereOrNull((e) => adNetwork == e.adNetwork);
      if (ad?.isAdLoaded == true) {
        Fluttertoast.showToast(msg: '4');
        if (ad?.adUnitType == AdUnitType.interstitial &&
            loaderDuration > 0 &&
            context != null) {
          showLoaderDialog(context, loaderDuration).then((_) => ad?.show());
        } else {
          ad?.show();
        }
        return true;
      } else {
        Fluttertoast.showToast(msg: '5');
        _logger.logInfo(
            '${ad?.adNetwork} ${ad?.adUnitType} was not loaded, so called loading');
        ad?.load();
        return false;
      }
    }

    for (final ad in ads) {
      if (ad.isAdLoaded) {
        if (adNetwork == AdNetwork.any || adNetwork == ad.adNetwork) {
          Fluttertoast.showToast(msg: '6');
          if (ad.adUnitType == AdUnitType.interstitial &&
              loaderDuration > 0 &&
              context != null) {
            showLoaderDialog(context, loaderDuration).then((_) => ad.show());
          } else {
            ad.show();
          }
          return true;
        }
      } else {
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} was not loaded, so called loading');
        ad.load();
      }
    }
    Fluttertoast.showToast(msg: '7');
    return false;
  }

  /// This will load both rewarded and interstitial ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad will be loaded
  /// if [adUnitType] is provided, only that unit type will be loaded, otherwise all unit types will be loaded
  void loadAd({AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    if (adUnitType == null || adUnitType == AdUnitType.rewarded) {
      for (final e in _rewardedAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }

    if (adUnitType == null || adUnitType == AdUnitType.interstitial) {
      for (final e in _interstitialAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }

    if (adUnitType == null || adUnitType == AdUnitType.appOpen) {
      for (final e in _appOpenAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isRewardedAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _rewardedAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isInterstitialAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _interstitialAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isAppOpenAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _appOpenAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Do not call this method until unless you want to remove ads entirely from the app.
  /// Best user case for this method could be removeAds In app purchase.
  ///
  /// After this, ads would stop loading. You would have to call initialize again.
  ///
  /// if [adNetwork] is provided only that network's ads will be disposed otherwise it will be ignored
  /// if [adUnitType] is provided only that ad unit type will be disposed, otherwise it will be ignored
  void destroyAds(
      {AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    for (final e in _allAds) {
      if ((adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
          (adUnitType == null || adUnitType == e.adUnitType)) {
        e.dispose();
      }
    }
  }
}
