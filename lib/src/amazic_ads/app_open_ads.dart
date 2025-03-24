import 'dart:async';

import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';

class AppOpenAds extends StatefulWidget {
  final AdNetwork adNetwork;
  final String idAds;
  final String nameAds;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;

  const AppOpenAds({
    Key? key,
    this.adNetwork = AdNetwork.admob,
    required this.idAds,
    required this.nameAds,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onEarnedReward,
    this.onPaidEvent,
  }) : super(key: key);

  /// return the current route of this class, use to remove from stack
  static DialogRoute? currentRoute;

  static DialogRoute getRoute({
    required BuildContext context,
    required String idAds,
    required String nameAds,
    AdNetwork adNetwork = AdNetwork.admob,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdEarnedReward? onEarnedReward,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    currentRoute = null;
    currentRoute = DialogRoute(
      context: context,
      builder: (context) => AppOpenAds(
        nameAds: nameAds,
        idAds: idAds,
        adNetwork: adNetwork,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onEarnedReward: onEarnedReward,
        onPaidEvent: onPaidEvent,
      ),
    );

    return currentRoute!;
  }

  @override
  State<AppOpenAds> createState() => _AppOpenAdsState();
}

class _AppOpenAdsState extends State<AppOpenAds> with WidgetsBindingObserver {
  late final AdsBase? _appOpenAd;

  Future<void> _showAd() => Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _appOpenAd!.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  void _closeAd() {
    if (AppOpenAds.currentRoute != null) {
      Navigator.of(context).removeRoute(AppOpenAds.currentRoute as Route);
      AppOpenAds.currentRoute = null;
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AdmobAds.instance.setFullscreenAdShowing(true);
    print('check_full_screen_ads_show: init_App_Open_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          initAndLoadAd();
        } else {
          if (mounted) {
            _closeAd();
          }
          widget.onAdFailedToLoad?.call(widget.adNetwork, AdUnitType.appOpen, null, "");
          AdmobAds.instance.setFullscreenAdShowing(false);
          print('check_full_screen_ads_show: onPostExecute_UMP_App_Open_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
        }
      },
    );
    super.initState();
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initAndLoadAd() {
    _appOpenAd = AdmobAds.instance.createAppOpenAd(
      nameAds: widget.nameAds,
      adNetwork: widget.adNetwork,
      idAds: widget.idAds,
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        _showAd();
      },
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        if (widget.onAdShowed == null) {
          _closeAd();
        }
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdDismiss_App_Open_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          _closeAd();
        }
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdFailedToLoad_App_Open_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          _closeAd();
        }
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdFailedToShow_App_Open_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        if (widget.onAdShowed != null) {
          _closeAd();
          widget.onAdShowed!.call(adNetwork, adUnitType, data);
        }
      },
      onEarnedReward: (adNetwork, adUnitType, rewardType, rewardAmount) {
        widget.onEarnedReward?.call(adNetwork, adUnitType, rewardType, rewardAmount);
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
        widget.onPaidEvent?.call(
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
    _appOpenAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
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
              'Welcome back',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
