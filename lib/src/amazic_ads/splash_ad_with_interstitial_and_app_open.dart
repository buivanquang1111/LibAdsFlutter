import 'dart:async';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/material.dart';

class SplashAdWithInterstitialAndAppOpen extends StatefulWidget {
  final AdNetwork adNetwork;
  final List<String> listInterId;
  final List<String> listOpenId;
  final void Function(AdUnitType type)? onShowed;
  final void Function(AdUnitType type)? onDismissed;
  final void Function()? onFailedToLoad;
  final void Function(AdUnitType type)? onFailedToShow;
  final Function(AdUnitType type)? onClicked;

  final EasyAdCallback? onAdInterstitialLoaded;
  final EasyAdCallback? onAdInterstitialShowed;
  final EasyAdCallback? onAdInterstitialClicked;
  final EasyAdFailedCallback? onAdInterstitialFailedToLoad;
  final EasyAdFailedCallback? onAdInterstitialFailedToShow;
  final EasyAdCallback? onAdInterstitialDismissed;
  final EasyAdOnPaidEvent? onInterstitialPaidEvent;
  final bool configInterstitial;

  final EasyAdCallback? onAdAppOpenLoaded;
  final EasyAdCallback? onAdAppOpenShowed;
  final EasyAdCallback? onAdAppOpenClicked;
  final EasyAdFailedCallback? onAdAppOpenFailedToLoad;
  final EasyAdFailedCallback? onAdAppOpenFailedToShow;
  final EasyAdCallback? onAdAppOpenDismissed;
  final EasyAdOnPaidEvent? onAppOpenPaidEvent;
  final bool configAppOpen;

  const SplashAdWithInterstitialAndAppOpen({
    Key? key,
    this.adNetwork = AdNetwork.admob,
    required this.listInterId,
    required this.listOpenId,
    required this.onShowed,
    required this.onDismissed,
    required this.onFailedToLoad,
    required this.onFailedToShow,
    required this.onClicked,
    this.onAdInterstitialLoaded,
    this.onAdInterstitialShowed,
    this.onAdInterstitialClicked,
    this.onAdInterstitialFailedToLoad,
    this.onAdInterstitialFailedToShow,
    this.onAdInterstitialDismissed,
    this.onInterstitialPaidEvent,
    required this.configInterstitial,
    this.onAdAppOpenLoaded,
    this.onAdAppOpenShowed,
    this.onAdAppOpenClicked,
    this.onAdAppOpenFailedToLoad,
    this.onAdAppOpenFailedToShow,
    this.onAdAppOpenDismissed,
    this.onAppOpenPaidEvent,
    required this.configAppOpen,
  }) : super(key: key);

  @override
  State<SplashAdWithInterstitialAndAppOpen> createState() =>
      _SplashAdWithInterstitialAndAppOpenState();
}

class _SplashAdWithInterstitialAndAppOpenState
    extends State<SplashAdWithInterstitialAndAppOpen> with WidgetsBindingObserver {
  //
  AdsBase? _ads;
  late final AdsBase? _interstitialAd;
  late final AdsBase? _appOpenAd;

  Timer? _timer;

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;
  bool _isAdShowed = false;

  Future<void> _showAd() => Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed && !_isAdShowed) {
            if (_ads != null && mounted) {
              _ads!.show();
              _isAdShowed = true;
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AdmobAds.instance.setFullscreenAdShowing(true);
    print('check_full_screen_ads_show: init_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          _initAds();
        } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
          widget.onFailedToLoad?.call();
          AdmobAds.instance.setFullscreenAdShowing(false);
          print('check_full_screen_ads_show: onPostExecute_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
        }
      },
    );
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow && !_isAdShowed) {
      _showAd();
    } else if (state == AppLifecycleState.paused) {}
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading Ads',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initAds() {
    _interstitialAd = AdmobAds.instance.createInterstitial(
      adNetwork: widget.adNetwork,
      listId: widget.listInterId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdInterstitialClicked?.call(adNetwork, adUnitType, data);
        widget.onClicked?.call(AdUnitType.interstitial);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        if (widget.onShowed == null) {
          Navigator.of(context).pop();
        }
        widget.onAdInterstitialDismissed?.call(adNetwork, adUnitType, data);
        widget.onDismissed?.call(AdUnitType.interstitial);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: inter_onDismiss_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdInterstitialFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        Navigator.of(context).pop();
        widget.onAdInterstitialFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        widget.onFailedToShow?.call(AdUnitType.interstitial);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: inter_onAdFailedToShow_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdInterstitialLoaded?.call(adNetwork, adUnitType, data);
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (widget.onShowed != null) {
          Navigator.of(context).pop();
          widget.onShowed!.call(AdUnitType.interstitial);
        }
        widget.onAdInterstitialShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: ({
        required AdNetwork adNetwork,
        required AdUnitType adUnitType,
        required double revenue,
        required String currencyCode,
        String? network,
        String? unit,
        String? placement,
      }) {
        widget.onInterstitialPaidEvent?.call(
          adNetwork: adNetwork,
          adUnitType: adUnitType,
          revenue: revenue,
          currencyCode: currencyCode,
          network: network,
          unit: unit,
          placement: placement,
        );
      },
    );

    _appOpenAd = AdmobAds.instance.createAppOpenAd(
      adNetwork: widget.adNetwork,
      listId: widget.listOpenId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdAppOpenClicked?.call(adNetwork, adUnitType, data);
        widget.onClicked?.call(AdUnitType.appOpen);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        if (widget.onShowed == null) {
          Navigator.of(context).pop();
        }
        widget.onAdAppOpenDismissed?.call(adNetwork, adUnitType, data);
        widget.onDismissed?.call(AdUnitType.appOpen);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: open_onDismiss_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdAppOpenFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        Navigator.of(context).pop();
        widget.onAdAppOpenFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        widget.onFailedToShow?.call(AdUnitType.appOpen);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: open_OnDismiss_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdAppOpenLoaded?.call(adNetwork, adUnitType, data);
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (widget.onShowed != null) {
          Navigator.of(context).pop();
          widget.onShowed!.call(AdUnitType.appOpen);
        }
        widget.onAdAppOpenShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: ({
        required AdNetwork adNetwork,
        required AdUnitType adUnitType,
        required double revenue,
        required String currencyCode,
        String? network,
        String? unit,
        String? placement,
      }) {
        widget.onAppOpenPaidEvent?.call(
          adNetwork: adNetwork,
          adUnitType: adUnitType,
          revenue: revenue,
          currencyCode: currencyCode,
          network: network,
          unit: unit,
          placement: placement,
        );
      },
    );

    if (widget.configAppOpen) {
      _appOpenAd?.load();
    }

    if (widget.configInterstitial) {
      _interstitialAd?.load();
    }
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_ads != null) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      if (_appOpenAd?.isAdLoaded == true) {
        _timer?.cancel();
        _timer = null;
        _ads = _appOpenAd;
      } else if (_interstitialAd?.isAdLoaded == true &&
          (_appOpenAd?.isAdLoadedFailed == true || !widget.configAppOpen)) {
        _timer?.cancel();
        _timer = null;
        _ads = _interstitialAd;
      } else if ((_appOpenAd?.isAdLoadedFailed == true || !widget.configAppOpen) &&
          (_interstitialAd?.isAdLoadedFailed == true || !widget.configInterstitial)) {
        _timer?.cancel();
        _timer = null;
        Navigator.of(context).pop();
        widget.onFailedToLoad?.call();
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: end_Splash_And_Open - ${AdmobAds.instance.isFullscreenAdShowing}');
        return;
      }

      if (_ads != null) {
        _showAd();
      }
    });
  }
}
