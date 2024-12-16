import 'dart:async';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../adjust_config/call_organic_adjust.dart';

class BannerAds extends StatefulWidget {
  final AdNetwork adNetwork;
  final List<String> listId;
  final AdsBannerType type;
  final AdSize? adSize;

  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdCallback? onAdDisabled;
  final EasyAdEarnedReward? onEarnedReward;
  final EasyAdOnPaidEvent? onPaidEvent;
  final bool config;
  final bool reloadOnClick;
  final bool reloadResume;
  final bool onSplashScreen;

  final String visibilityDetectorKey;
  final ValueNotifier<bool>? visibilityController;

  final bool shouldReload;

  const BannerAds({
    this.adNetwork = AdNetwork.admob,
    required this.listId,
    this.type = AdsBannerType.standard,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onAdDisabled,
    this.onEarnedReward,
    this.onPaidEvent,
    required this.config,
    this.reloadOnClick = false,
    required this.visibilityDetectorKey,
    this.visibilityController,
    this.shouldReload = true,
    this.reloadResume = true,
    this.onSplashScreen = false,
    this.adSize,
    Key? key,
  }) : super(key: key);

  @override
  State<BannerAds> createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> with WidgetsBindingObserver {
  AdsBase? _bannerAd;
  int loadFailedCount = 0;
  static const int maxFailedTimes = 3;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.visibilityDetectorKey),
      onVisibilityChanged: (info) {
        if (!mounted) {
          return;
        }
        try {
          if (info.visibleFraction < 0.1) {
            if (visibilityController.value) {
              visibilityController.value = false;
            }
          } else {
            if (!visibilityController.value) {
              visibilityController.value = true;
            }
          }
        } catch (e) {
          /// visibility error
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: visibilityController,
        builder: (_, isVisible, __) {
          return Visibility(
            visible: isVisible,
            maintainState: false,
            maintainAnimation: false,
            maintainSize: false,
            maintainSemantics: false,
            maintainInteractivity: false,
            child: _bannerAd?.show() ??
                const SizedBox(
                  height: 1,
                  width: 1,
                ),
            replacement: SizedBox(
              height: ConsentManager.ins.canRequestAds ? 50 : 1,
              width: MediaQuery.sizeOf(context).width,
            ),
          );
        },
      ),
    );
  }

  Future<void> _prepareAd() async {
    // if (loadFailedCount == maxFailedTimes) {
    //   return;
    // }

    if (!AdmobAds.instance.isShowAllAds ||
        await AdmobAds.instance.isDeviceOffline() ||
        !widget.config ||
        !ConsentManager.ins.canRequestAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);

      if (widget.onSplashScreen) {
        EventLogLib.logEvent("banner_splash_false", parameters: {
          "reason":
              "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.isHaveInternet()}"
        });
      }
      return;
    }
    // if () {
    //   widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
    //   return;
    // }
    //
    // if () {
    //   widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
    //   return;
    // }
    // if () {
    //   widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
    //   return;
    // }

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          if (widget.onSplashScreen) {
            EventLogLib.logEvent("banner_splash_true");
          }
          _initAd();
        } else {
          widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
        }
      },
    );
  }

  late final ValueNotifier<bool> visibilityController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    visibilityController = widget.visibilityController ?? ValueNotifier(true);
    visibilityController.addListener(_listener);
  }

  void _listener() {
    if (!widget.shouldReload) {
      return;
    }
    if (_bannerAd?.isAdLoading != true && visibilityController.value) {
      print('check_ads_banner --- _listener ${widget.visibilityDetectorKey}');
      _prepareAd();
      return;
    }

    if (!visibilityController.value) {
      loadFailedCount = 0;
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    print('check_ads_banner --- didChangeDependencies ${widget.visibilityDetectorKey}');
    _prepareAd();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    visibilityController.removeListener(_listener);
    visibilityController.dispose();
    super.dispose();
  }

  bool isClicked = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.reloadResume && widget.onSplashScreen == false) {
          print('check_ads_banner --- resumed ${widget.visibilityDetectorKey}');
          _prepareAd();
        }

        // if (isClicked) {
        //   isClicked = false;
        //   _prepareAd();
        // }

        break;
      // case AppLifecycleState.paused:
      //   if ((widget.type == AdsBannerType.collapsible_bottom ||
      //           widget.type == AdsBannerType.collapsible_top) &&
      //       _bannerAd != null) {
      //     _bannerAd!.dispose();
      //     _bannerAd = null;
      //     if (mounted) {
      //       setState(() {});
      //     }
      //   }

      //   break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _initAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
      if (mounted) {
        setState(() {});
      }
    }

    _bannerAd ??= AdmobAds.instance.createBanner(
      adSize: widget.adSize,
      adNetwork: widget.adNetwork,
      listId: widget.listId,
      type: widget.type,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        isClicked = widget.reloadOnClick;
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        loadFailedCount++;
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        loadFailedCount = 0;
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
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
        if (mounted) {
          setState(() {});
        }
      },
    );

    _bannerAd?.load();
    if (mounted) {
      setState(() {});
    }
    if (!visibilityController.value) {
      visibilityController.value = true;
    }
  }
}
