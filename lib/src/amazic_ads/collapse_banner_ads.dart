import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../admob_ads_flutter.dart';

class CollapseBannerAds extends StatefulWidget {
  final AdNetwork adNetwork;

  final List<String> listId;
  final AdsBannerType type;

  /// refresh_rate_sec
  final int refreshRateSec;

  /// cb_fetch_interval_sec
  final int cbFetchIntervalSec;

  final String visibilityDetectorKey;
  final ValueNotifier<bool>? visibilityController;

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
  bool hideReloadWhenScreenChange;

  CollapseBannerAds({
    this.adNetwork = AdNetwork.admob,
    required this.listId,
    required this.type,
    required this.refreshRateSec,
    required this.cbFetchIntervalSec,
    required this.visibilityDetectorKey,
    this.visibilityController,
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
    this.hideReloadWhenScreenChange = false,
    Key? key,
  }) : super(key: key);

  void setHideReloadWhenScreenChange(bool value) {
    hideReloadWhenScreenChange = value;
  }

  @override
  State<CollapseBannerAds> createState() => CollapseBannerAdsState();
}

class CollapseBannerAdsState extends State<CollapseBannerAds>
    with WidgetsBindingObserver {
  AdsBase? _bannerAd;

  Timer? _timer;
  bool _isPaused = false;
  bool _isDestroy = false;
  late DateTime _lastCBRequestTime;

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
            child: _bannerAd?.show() ??
                const SizedBox(
                  height: 1,
                  width: 1,
                ),
            replacement: SizedBox(
              height: ConsentManager.ins.canRequestAds ? 50 : 1,
              width: MediaQuery.sizeOf(_).width,
            ),
          );
        },
      ),
    );
  }

  Future<void> _prepareAd() async {
    if (!AdmobAds.instance.isShowAllAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
      return;
    }
    if (await AdmobAds.instance.isDeviceOffline()) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
      return;
    }
    if (!widget.config) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
      return;
    }

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          _initAd();
        } else {
          widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
        }
      },
    );
  }

  Future<void> _initAd() async {
    _stopTimer();

    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
      if (mounted) {
        setState(() {});
      }
    }

    AdsBannerType type = widget.type;
    if (type == AdsBannerType.collapsible_bottom ||
        type == AdsBannerType.collapsible_top) {
      /// Check if need request collapsible
      bool shouldRequestCollapsible =
          DateTime.now().difference(_lastCBRequestTime).inSeconds >=
              widget.cbFetchIntervalSec;
      if (shouldRequestCollapsible) {
        _lastCBRequestTime = DateTime.now();
      } else {
        type = AdsBannerType.adaptive;
      }
    }

    _bannerAd = AdmobAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      listId: widget.listId,
      type: type,
      onAdLoaded: (adNetwork, adUnitType, data) {
        if (!_isDestroy && !_isPaused) {
          print('startTimer: onAdLoaded');
          _startTimer();
        }
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        if (!_isDestroy && !_isPaused) {
          print('startTimer: onAdFailedToLoad');
          _startTimer();
        }
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        isClicked = true;
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
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _lastCBRequestTime = DateTime.now()
        .subtract(Duration(seconds: widget.cbFetchIntervalSec + 1));
    visibilityController = widget.visibilityController ?? ValueNotifier(true);
    visibilityController.addListener(_listener);
  }

  late final ValueNotifier<bool> visibilityController;

  void _listener() {
    if (_bannerAd?.isAdLoading != true && visibilityController.value && !widget.hideReloadWhenScreenChange) {
      _prepareAd();
      print('check_reload_collapse --- _listener');
      return;
    }

    if (!visibilityController.value) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        if (mounted) {
          setState(() {});
        }
      }

      _stopTimer();
    }
  }

  @override
  void didChangeDependencies() {
    _prepareAd();
    print('check_reload_collapse --- didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    closeCollapse();
    onDestroyed();
    print('check state: 2.dispose $_isDestroy');

    super.dispose();
  }

  Future<void> closeCollapse() async {
    return _bannerAd?.dispose();
  }

  Future<void> reloadCollapseBanner() async{
    return _prepareAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('check state: 1.resume $_isDestroy');
      if (isClicked) {
        isClicked = false;
        _prepareAd();
        print('check_reload_collapse --- didChangeAppLifecycleState isClick');
      } else {
        onResume();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      print('check state: 1.inactive $_isDestroy');
      onPause();
    }
    super.didChangeAppLifecycleState(state);
  }

  void onResume() {
    _isPaused = false;
    if (!_isDestroy) {
      print('startTimer: onResume');
      _startTimer();
    }
  }

  void onPause() {
    _isPaused = true;
    _stopTimer();
  }

  void onVisible() {
    _isDestroy = false;
    if (!_isPaused) {
      print('startTimer: onVisible');
      _startTimer();
    }
  }

  void onDestroyed() {
    print('check state: 1.dispose $_isDestroy');
    _isDestroy = true;
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    print('startTimer: 1.');
    if (widget.refreshRateSec == 0) {
      return;
    }
    _stopTimer();
    print('startTimer: 2.');
    _timer = Timer.periodic(
      Duration(seconds: widget.refreshRateSec),
      (timer) {
        if (widget.hideReloadWhenScreenChange == false) {
          print('startTimer: 3.');
          print('check state: 5.resume $_isDestroy');
          _prepareAd();
          print(
              'check_reload_collapse --- _startTimer hideReloadWhenScreenChange: ${widget.hideReloadWhenScreenChange}');
        }
      },
    );
  }

  bool isClicked = false;
}
