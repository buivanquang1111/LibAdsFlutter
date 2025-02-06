import 'dart:async';

import 'package:flutter/material.dart';

import '../../adjust_config/call_organic_adjust.dart';
import '../../admob_ads_flutter.dart';
import 'loading_ads.dart';

class NativeAdsLang extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final List<String> listId;
  final double height;
  final bool config;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final EasyAdCallback? onAdLoaded;
  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdImpression;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToLoad;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdCallback? onAdDisabled;
  final EasyAdOnPaidEvent? onPaidEvent;
  final int refreshRateSec;
  final bool isReloadWhenResume;
  final bool isClickAdsNotShowResume;

  const NativeAdsLang({
    super.key,
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.listId,
    required this.height,
    required this.config,
    this.color,
    this.border,
    this.borderRadius = BorderRadius.zero,
    this.padding,
    this.margin,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdImpression,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onAdDisabled,
    this.onPaidEvent,
    this.refreshRateSec = 0,
    this.isReloadWhenResume = true,
    this.isClickAdsNotShowResume = true,
  });

  @override
  State<NativeAdsLang> createState() => NativeAdsLangState();
}

class NativeAdsLangState extends State<NativeAdsLang>
    with WidgetsBindingObserver {
  AdsBase? _nativeAd;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  Timer? _timer;
  bool firstLoadResumeTrick = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    //TH tắt load ads resume mới cần mở load lần đầu ở initstate
    print('check_remote_trick_screen --- initState');
    if (widget.isReloadWhenResume == false) {
      print(
          'check_remote_trick_screen --- start load ads initState off reload Resume');
      _prepareAd();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //TH dùng cho bật trick screen  và bật cả load ads ở resume => load trick lần 1 ở đây
    // if (widget.isReloadWhenResume == true &&
    //     AdmobAds.instance.isTrickScreenOpen == true) {
    //   print(
    //       'check_remote_trick_screen --- start load ads didChangeDependencies open Trick Screen lan 1');
    //   _prepareAd();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _nativeAd?.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if(widget.isReloadWhenResume == false && !firstLoadResumeTrick){
          print('check_remote_trick_screen --- resume load tric lan 2');
          firstLoadResumeTrick = true;
          _prepareAd();
        }

        if (widget.isReloadWhenResume == false) {
          // khởi tạo lại reload time
          print('check_remote_trick_screen --- 2.resume start reload');
          _startTimeReload();
        } else {
          //TH bật load ads resume lần đầu load ads sẽ ở đây
          print('check_remote_trick_screen --- 1.resume');
          _prepareAd();
        }
        break;
      case AppLifecycleState.paused:
        print('native_language --- AppLifecycleState.paused');
        _stopTimeReload();
        break;
      case AppLifecycleState.detached:
        print('native_language --- AppLifecycleState.detached');
        break;
      case AppLifecycleState.hidden:
        print('native_language --- AppLifecycleState.hidden');
        break;
      case AppLifecycleState.inactive:
        print('native_language --- AppLifecycleState.inactive');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.config && ConsentManager.ins.canRequestAds,
      child: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          return value
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: widget.border,
                    color: widget.color,
                  ),
                  padding: widget.padding,
                  margin: widget.margin,
                  child: ClipRRect(
                    borderRadius: widget.borderRadius,
                    child: SizedBox(
                      height: widget.height,
                      child: LoadingAds(
                        height: widget.height,
                      ),
                    ),
                  ),
                )
              : _nativeAd?.show(
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                    color: widget.color,
                    border: widget.border,
                    padding: widget.padding,
                    margin: widget.margin,
                  ) ??
                  Container();
        },
      ),
    );
  }

  Future<void> reloadNativeNow() async {
    print('check_remote_trick_screen --- reloadNativeNow');
    _prepareAd();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _prepareAd() async {
    if (!AdmobAds.instance.isShowAllAds ||
        AdmobAds.instance.checkInternet() == false ||
        !widget.config ||
        !ConsentManager.ins.canRequestAds) {
      if (_isLoading.value) {
        _isLoading.value = false;
      }
      EventLogLib.logEvent("native_language_false", parameters: {
        "reason":
            "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${AdmobAds.instance.checkInternet()}"
      });

      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (!_isLoading.value) {
      _isLoading.value = true;
    }
    //load ads
    if (_nativeAd != null) {
      _nativeAd?.dispose();
      _nativeAd = null;
    }

    _nativeAd = AdmobAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      listId: widget.listId,
      visibilityDetectorKey: 'native_lang',
      isClickAdsNotShowResume: widget.isClickAdsNotShowResume,
      onAdClicked: (adNetwork, adUnitType, data) {
        print('native_language --- onAdClicked');
        EventLogLib.logEvent(
            "native_language_click_${PreferencesUtilLib.getCountOpenApp() - 1}");
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        print('native_language --- onAdDismissed');
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        _isLoading.value = false;
        print('native_language --- onAdFailedToLoad');
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
        _startTimeReload();
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        _isLoading.value = false;
        print('native_language --- onAdFailedToShow');
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        print('native_language --- onAdLoaded');
        _isLoading.value = false;
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        _startTimeReload();
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        print('native_language --- onAdShowed');
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
      },
      onPaidEvent: (
          {required adNetwork,
          required adUnitType,
          required currencyCode,
          network,
          placement,
          required revenue,
          unit}) {
        print('native_language --- onPaidEvent');
        widget.onPaidEvent?.call(
            adNetwork: adNetwork,
            adUnitType: adUnitType,
            revenue: revenue,
            currencyCode: currencyCode,
            network: network,
            unit: unit,
            placement: placement);
      },
      onAdImpression: (adNetwork, adUnitType, data) {
        print('native_language --- onAdImpression');
        EventLogLib.logEvent(
            "native_language_impression_${PreferencesUtilLib.getCountOpenApp() - 1}");
        widget.onAdImpression?.call(adNetwork, adUnitType, data);
      },
    );
    _nativeAd?.load();
  }

  void _stopTimeReload() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimeReload() {
    if (widget.refreshRateSec == 0) {
      return;
    }

    _stopTimeReload();

    _timer = Timer.periodic(
      Duration(seconds: widget.refreshRateSec),
      (timer) {
        print('native_language --- timer reload');
        print('check_remote_trick_screen --- _startTimeReload');
        _prepareAd();
      },
    );
  }
}
