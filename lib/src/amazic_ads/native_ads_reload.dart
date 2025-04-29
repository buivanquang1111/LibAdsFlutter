import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../admob_ads_flutter.dart';

class NativeAdsReload extends StatefulWidget {
  /// refresh_rate_sec
  final int refreshRateSec;

  final AdNetwork adNetwork;
  final String factoryId;
  final String idAds;
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
  final AdmobNativeAd? adsBase;

  const NativeAdsReload({
    this.adNetwork = AdNetwork.admob,
    required this.idAds,
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
    this.adsBase,
  }) : super(key: key);

  @override
  State<NativeAdsReload> createState() => NativeAdsReloadState();
}

class NativeAdsReloadState extends State<NativeAdsReload>
    with WidgetsBindingObserver {
  // AdmobNativeAd? _nativeAd;
  final List<AdmobNativeAd?> _listNativeAd = [];

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
          print('native_ads_reload --- ${widget.visibilityDetectorKey} isVisible: $isVisible -- _listNativeAd.length: ${_listNativeAd.length}');
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
            child: Stack(
              children: [
                for (var element in _listNativeAd) ...[
                  element?.show(
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                    color: widget.color,
                    border: widget.border,
                    padding: widget.padding,
                    margin: widget.margin,
                    showShimmer: _listNativeAd.length == 1,
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  void _addAndCleanListNativeAd(AdmobNativeAd? admobNativeAd) {
    _listNativeAd.add(admobNativeAd);
    _cleanListNativeAd();
    print("native_ads_reload - ${_listNativeAd.firstOrNull?.factoryId} --- size of _listNativeAd: ${_listNativeAd.length}");
  }

  void _cleanListNativeAd() {
    // luôn giữ item cuối cùng, sau đó chỉ giữ lại 2 item cuối mà _isAdLoaded = true và _nativeAd != null
    if (_listNativeAd.length <= 2) {
      return;
    }

    final List<AdmobNativeAd?> keepList = [];

    // Luôn giữ item cuối cùng
    if (_listNativeAd.isNotEmpty) {
      keepList.add(_listNativeAd.last);
    }

    // Tìm 2 item gần cuối mà isAdLoaded = true && nativeAd != null
    for (int i = _listNativeAd.length - 2; i >= 0; i--) {
      final ad = _listNativeAd[i];
      if (ad != null && ad.isAdLoaded && ad.nativeAd != null) {
        keepList.insert(0, ad); // chèn vào đầu danh sách
        if (keepList.length == 3) {
          break;
        }
      }
    }

    // Nếu keepList = 1 -> thêm item gần cuối, mục tiêu giữ cho có ít nhất 2 phần tử
    if (keepList.length == 1) {
      keepList.add(_listNativeAd[_listNativeAd.length - 2]);
    }

    // Dispose các ad cũ không cần giữ
    // for (var ad in _listNativeAd) {
    //   if (!keepList.contains(ad)) {
    //     ad?.dispose();
    //   }
    // }
    /* Nếu không comment đoạn trên thì sẽ bị lỗi nháy đen khi reload native :)) */

    _listNativeAd
      ..clear()
      ..addAll(keepList);
  }

  Future<void> _prepareAd() async {
    if (!AdmobAds.instance.isShowAllAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (!(await AdmobAds.instance.isHaveInternet)) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (!widget.config) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          _initAd();
        } else {
          widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
        }
      },
    );
  }

  Future<void> _initAd() async {
    _stopTimer();

    // if (_nativeAd != null) {
    //   _nativeAd!.dispose();
    //   _nativeAd = null;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // }

    final nativeAd = AdmobAds.instance.createNative(
      visibilityDetectorKey: widget.visibilityDetectorKey,
      adNetwork: widget.adNetwork,
      idAds: widget.idAds,
      isClickAdsNotShowResume: widget.isClickAdsNotShowResume,
      onAdLoaded: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdLoaded');
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
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdFailedToLoad');
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
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdClicked');
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        isClicked = true;
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdDismissed');
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdFailedToShow');
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        print(
            'native_ads_reload --- ${widget.visibilityDetectorKey} onAdShowed');
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdImpression: (adNetwork, adUnitType, data) {},
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
            'native_ads_reload --- ${widget.visibilityDetectorKey} onPaidEvent');
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
    await nativeAd?.load();
    _addAndCleanListNativeAd(nativeAd);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.adsBase != null) {
        _addAndCleanListNativeAd(widget.adsBase);
        print(
            'native_ads_reload ---1. adsBase have data - ${visibilityController.value}');
        _startTimer();
        if (mounted) {
          setState(() {});
        }
        visibilityController.value = true;
      } else {
        print('native_ads_reload ---2. not data');
        _prepareAd();
      }
    });
  }

  reloadAdsNative({required AdmobNativeAd? adBase}) {
    if (adBase != null) {
      _addAndCleanListNativeAd(adBase);
      _startTimer();
      if (mounted) {
        setState(() {});
      }
      visibilityController.value = true;
    }
  }

  reloadAdsNow() {
    _prepareAd();
  }

  late final ValueNotifier<bool> visibilityController;

  void _listener() {
    if (!widget.isCanReloadHideView) {
      return;
    }

    if (_listNativeAd.lastOrNull?.isAdLoading != true && visibilityController.value) {
      print(
          'native_ads_reload --- ${widget.visibilityDetectorKey} start _listener');
      _prepareAd();
      return;
    }

    if (!visibilityController.value) {
      if (_listNativeAd.lastOrNull != null) {
        disposeAll();
        if (mounted) {
          setState(() {});
        }
      }

      _stopTimer();
    }
  }

  void disposeAll() {
    print("native-ads_reload --- disposeAll - ${widget.visibilityDetectorKey}");
    for (var element in _listNativeAd) {
      element?.dispose();
    }
    _listNativeAd.clear();
  }

  @override
  void didChangeDependencies() {
    // print(
    //     'native_ads_reload --- ${widget.visibilityDetectorKey} start didChangeDependencies');
    // if(widget.adsBase != null){
    //   print('native_ads_reload ---1. adsBase have data');
    //   _startTimer();
    //   if (mounted) {
    //     setState(() {});
    //   }
    // }else {
    //   print('native_ads_reload ---2. not data');
    //   _prepareAd(isLoadAdsWithCount: true);
    // }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeAll();
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
        _prepareAd();
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
    print('native_ads_reload --- ${widget.visibilityDetectorKey} start onDestroyed');
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
        _prepareAd();
      },
    );
  }

  bool isClicked = false;
}
