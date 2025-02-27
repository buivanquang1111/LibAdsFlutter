import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../admob_ads_flutter.dart';

class NativeAdsReload extends StatefulWidget {
  /// refresh_rate_sec
  final int refreshRateSec;

  final AdNetwork adNetwork;
  final String factoryId;
  final List<String> listId;
  final double height;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdCallback? onAdDisabled;
  final EasyAdOnPaidEvent? onPaidEvent;
  final bool config;

  final bool reloadOnClick;

  final String visibilityDetectorKey;
  final ValueNotifier<bool>? visibilityController;
  final bool isClickAdsNotShowResume;
  final bool isCanReloadHideView;
  final int countRequest;

  const NativeAdsReload({
    this.adNetwork = AdNetwork.admob,
    required this.listId,
    required this.refreshRateSec,
    required this.visibilityDetectorKey,
    this.visibilityController,
    required this.factoryId,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onAdDisabled,
    this.onPaidEvent,
    required this.config,
    Key? key,
    required this.height,
    this.color,
    required this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.reloadOnClick = false,
    this.isClickAdsNotShowResume = true,
    this.isCanReloadHideView = true,
    this.countRequest = 0,
  }) : super(key: key);

  @override
  State<NativeAdsReload> createState() => _NativeAdsReloadState();
}

class _NativeAdsReloadState extends State<NativeAdsReload>
    with WidgetsBindingObserver {
  AdsBase? _nativeAd;

  Timer? _timer;
  bool _isPaused = false;
  bool _isDestroy = false;

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
            replacement: SizedBox(
              height: ConsentManager.ins.canRequestAds ? widget.height : 1,
              width: MediaQuery.sizeOf(context).width,
            ),
            child: _nativeAd?.show(
                  height: widget.height,
                  borderRadius: widget.borderRadius,
                  color: widget.color,
                  border: widget.border,
                  padding: widget.padding,
                  margin: widget.margin,
                ) ??
                SizedBox(
                  height: 1,
                  width: MediaQuery.sizeOf(context).width,
                ),
          );
        },
      ),
    );
  }

  Future<void> _prepareAd({required bool isFirstLoad}) async {
    if (!AdmobAds.instance.isShowAllAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
      return;
    }
    if (!AdmobAds.instance.isHaveInternet) {
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
          if (isFirstLoad) {
            if (widget.countRequest == 0) {
              print('native_ads_reload --- TH1 count = 0');
              _initAd(text: 'TH1 count = 0');
            } else {
              for (int i = 0; i < widget.countRequest; i++) {
                print('native_ads_reload --- TH2 index = $i');
                _initAd(text: 'TH2 index = $i');
                Future.delayed(Duration(seconds: 2));
              }
            }
          } else {
            _initAd(text: 'TH load khac');
          }
        } else {
          widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.banner, null);
        }
      },
    );
  }

  Future<void> _initAd({required String text}) async {
    _stopTimer();

    // if (_nativeAd != null) {
    //   _nativeAd!.dispose();
    //   _nativeAd = null;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // }

    _nativeAd = AdmobAds.instance.createNative(
      visibilityDetectorKey: widget.visibilityDetectorKey,
      adNetwork: widget.adNetwork,
      listId: widget.listId,
      isClickAdsNotShowResume: widget.isClickAdsNotShowResume,
      onAdLoaded: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdLoaded');
        if (!_isDestroy && !_isPaused) {
          _startTimer();
        }
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdFailedToLoad');
        if (!_isDestroy && !_isPaused) {
          _startTimer();
        }
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdClicked: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdClicked');
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        isClicked = true;
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdDismissed');
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdFailedToShow');
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdShowed');
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdImpression: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onAdImpression');
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
        print(
            'native_ads_reload ---$text ${widget.visibilityDetectorKey} onPaidEvent');
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
      factoryId: widget.factoryId,
    );
    _nativeAd?.load();
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

    visibilityController = widget.visibilityController ?? ValueNotifier(true);
    visibilityController.addListener(_listener);
  }

  late final ValueNotifier<bool> visibilityController;

  void _listener() {
    if (!widget.isCanReloadHideView) {
      return;
    }

    if (_nativeAd?.isAdLoading != true && visibilityController.value) {
      print(
          'native_ads_reload --- ${widget.visibilityDetectorKey} start _listener');
      _prepareAd(isFirstLoad: false);
      return;
    }

    if (!visibilityController.value) {
      if (_nativeAd != null) {
        _nativeAd!.dispose();
        _nativeAd = null;
        if (mounted) {
          setState(() {});
        }
      }

      _stopTimer();
    }
  }

  @override
  void didChangeDependencies() {
    print(
        'native_ads_reload --- ${widget.visibilityDetectorKey} start didChangeDependencies');
    _prepareAd(isFirstLoad: true);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nativeAd?.dispose();
    onDestroyed();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isClicked) {
        isClicked = false;
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} start didChangeAppLifecycleState click');
        _prepareAd(isFirstLoad: false);
      } else {
        onResume();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      onPause();
    }
    super.didChangeAppLifecycleState(state);
  }

  void onResume() {
    _isPaused = false;
    if (!_isDestroy) {
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
      _startTimer();
    }
  }

  void onDestroyed() {
    _isDestroy = true;
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    if (widget.refreshRateSec == 0) {
      return;
    }
    _stopTimer();
    _timer = Timer.periodic(
      Duration(seconds: widget.refreshRateSec),
      (timer) {
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} start _startTimer');
        _prepareAd(isFirstLoad: false);
      },
    );
  }

  bool isClicked = false;
}
