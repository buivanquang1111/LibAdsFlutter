import 'dart:async';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/amazic_logger.dart';

class InterstitialAds extends StatefulWidget {
  final AdNetwork adNetwork;
  final List<String> listId;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdOnPaidEvent? onPaidEvent;

  const InterstitialAds({
    Key? key,
    required this.adNetwork,
    required this.listId,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onPaidEvent,
  }) : super(key: key);

  /// return the current route of this class, use to remove from stack
  static DialogRoute? currentRoute;

  static DialogRoute getRoute({
    required BuildContext context,
    required List<String> listId,
    AdNetwork adNetwork = AdNetwork.admob,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdClicked,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    EasyAdOnPaidEvent? onPaidEvent,
  }) {
    currentRoute = null;
    currentRoute = DialogRoute(
      context: context,
      builder: (context) => InterstitialAds(
        listId: listId,
        adNetwork: adNetwork,
        onAdLoaded: onAdLoaded,
        onAdShowed: onAdShowed,
        onAdClicked: onAdClicked,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onAdDismissed: onAdDismissed,
        onPaidEvent: onPaidEvent,
      ),
    );

    return currentRoute!;
  }

  @override
  State<InterstitialAds> createState() => _InterstitialAdsState();
}

class _InterstitialAdsState extends State<InterstitialAds>
    with WidgetsBindingObserver {
  late final AdsBase? _interstitialAd;
  final AmazicLogger _logger = AmazicLogger();

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _interstitialAd?.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  void _closeAd() {
    if (InterstitialAds.currentRoute != null) {
      Navigator.of(context)
          .removeRoute(InterstitialAds.currentRoute as Route);
      InterstitialAds.currentRoute = null;
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AdmobAds.instance.setFullscreenAdShowing(true);
    print('check_full_screen_ads_show: init_Inter_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          _initAd();
        } else {
          if (mounted) {
            _closeAd();
          }
          widget.onAdFailedToLoad
              ?.call(widget.adNetwork, AdUnitType.appOpen, null, "");
          AdmobAds.instance.setFullscreenAdShowing(false);
          print('check_full_screen_ads_show: onPostExecute_Inter_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
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
    _interstitialAd?.dispose();
    super.dispose();
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

  void _initAd() {
    _interstitialAd = AdmobAds.instance.createInterstitial(
      adNetwork: widget.adNetwork,
      listId: widget.listId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        _logger.logInfo('onAdDismissed');
        if (widget.onAdShowed == null) {
          _closeAd();
        }
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdDismiss_Inter_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        _logger.logInfo('onAdFailedToLoad');
        _closeAd();
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdFailedToLoad_Inter_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        _logger.logInfo('onAdFailedToShow');
        _closeAd();
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
        AdmobAds.instance.setFullscreenAdShowing(false);
        print('check_full_screen_ads_show: onAdFailedToShow_Inter_Ads - ${AdmobAds.instance.isFullscreenAdShowing}');
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        _logger.logInfo('onAdLoaded');
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        _showAd();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        _logger.logInfo('onAdShowed');
        if (widget.onAdShowed != null) {
          _closeAd();
          widget.onAdShowed!.call(adNetwork, adUnitType, data);
        }
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
    _interstitialAd?.load();
  }
}
