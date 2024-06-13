import 'dart:async';

import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';
import 'loading_ads.dart';

class Native3IdAds extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final List<String> listId;
  final String adIdHigh;
  final String adIdMedium;
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

  final EasyAdCallback? onAdMediumLoaded;
  final EasyAdCallback? onAdMediumShowed;
  final EasyAdCallback? onAdMediumClicked;
  final EasyAdFailedCallback? onAdMediumFailedToLoad;
  final EasyAdFailedCallback? onAdMediumFailedToShow;
  final EasyAdCallback? onAdMediumDismissed;
  final EasyAdCallback? onAdMediumDisabled;
  final EasyAdOnPaidEvent? onMediumPaidEvent;
  final bool configMedium;

  final EasyAdCallback? onAdHighLoaded;
  final EasyAdCallback? onAdHighShowed;
  final EasyAdCallback? onAdHighClicked;
  final EasyAdFailedCallback? onAdHighFailedToLoad;
  final EasyAdFailedCallback? onAdHighFailedToShow;
  final EasyAdCallback? onAdHighDismissed;
  final EasyAdCallback? onAdHighDisabled;
  final EasyAdOnPaidEvent? onHighPaidEvent;
  final bool configHigh;

  final Function(AdsPlacementType type)? onShowed;
  final Function(AdsPlacementType type)? onDismissed;
  final Function()? onFailedToLoad;
  final Function(AdsPlacementType type)? onFailedToShow;
  final Function(AdsPlacementType type)? onClicked;

  const Native3IdAds({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.listId,
    required this.adIdMedium,
    required this.adIdHigh,
    required this.height,
    this.color,
    this.border,
    this.padding,
    this.margin,
    this.borderRadius = BorderRadius.zero,
    this.onAdLoaded,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onAdDisabled,
    this.onPaidEvent,
    required this.config,
    this.onAdMediumLoaded,
    this.onAdMediumShowed,
    this.onAdMediumClicked,
    this.onAdMediumFailedToLoad,
    this.onAdMediumFailedToShow,
    this.onAdMediumDismissed,
    this.onAdMediumDisabled,
    this.onMediumPaidEvent,
    required this.configMedium,
    this.onAdHighLoaded,
    this.onAdHighShowed,
    this.onAdHighClicked,
    this.onAdHighFailedToLoad,
    this.onAdHighFailedToShow,
    this.onAdHighDismissed,
    this.onAdHighDisabled,
    this.onHighPaidEvent,
    required this.configHigh,
    required this.onShowed,
    required this.onDismissed,
    required this.onFailedToLoad,
    required this.onFailedToShow,
    required this.onClicked,
    Key? key,
  }) : super(key: key);

  @override
  State<Native3IdAds> createState() => _Native3IdAdsState();
}

class _Native3IdAdsState extends State<Native3IdAds> {
  AdsBase? _ad;
  late final AdsBase? _nativeAd;

  late final AdsBase? _nativeAdMedium;

  late final AdsBase? _nativeAdHigh;
  Timer? _timer;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareAds();
  }

  Future<void> _prepareAds() async {
    if (!AdmobAds.instance.isEnabled) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdMediumDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdHighDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (await AdmobAds.instance.isDeviceOffline()) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdMediumDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdHighDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }
    if (!widget.config) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
    }

    if (!widget.configMedium) {
      widget.onAdMediumDisabled?.call(widget.adNetwork, AdUnitType.native, null);
    }

    if (!widget.configHigh) {
      widget.onAdHighDisabled?.call(widget.adNetwork, AdUnitType.native, null);
    }

    if (!widget.config && !widget.configMedium && !widget.configHigh) {
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdMediumDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      widget.onAdHighDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
    }

    ConsentManager.ins.handleRequestUmp(
      onPostExecute: () {
        if (ConsentManager.ins.canRequestAds) {
          _initAds();
        } else {
          _isAdLoading = false;
          widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
          widget.onAdMediumDisabled?.call(widget.adNetwork, AdUnitType.native, null);
          widget.onAdHighDisabled?.call(widget.adNetwork, AdUnitType.native, null);
        }
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAdMedium?.dispose();
    _nativeAdHigh?.dispose();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoading) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: widget.border,
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
      );
    }
    if (_ad == null || !_isAdLoaded) {
      return const SizedBox();
    }
    return _ad!.show(
      height: widget.height,
      borderRadius: widget.borderRadius,
      color: widget.color,
      border: widget.border,
      padding: widget.padding,
      margin: widget.margin,
    );
  }

  void _initAds() {
    _nativeAd = AdmobAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      listId: widget.listId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
        widget.onClicked?.call(AdsPlacementType.normal);
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
        widget.onDismissed?.call(AdsPlacementType.normal);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        widget.onFailedToShow?.call(AdsPlacementType.normal);
        if (mounted) {
          setState(() {});
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        widget.onAdShowed?.call(adNetwork, adUnitType, data);
        widget.onShowed?.call(AdsPlacementType.normal);
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

    _nativeAdMedium = AdmobAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      listId: widget.listId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdMediumClicked?.call(adNetwork, adUnitType, data);
        widget.onClicked?.call(AdsPlacementType.med);
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdMediumDismissed?.call(adNetwork, adUnitType, data);
        widget.onDismissed?.call(AdsPlacementType.med);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdMediumFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdMediumFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        widget.onFailedToShow?.call(AdsPlacementType.med);
        if (mounted) {
          setState(() {});
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdMediumLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        widget.onAdMediumShowed?.call(adNetwork, adUnitType, data);
        widget.onShowed?.call(AdsPlacementType.med);
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
        widget.onMediumPaidEvent?.call(
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

    _nativeAdHigh = AdmobAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      listId: widget.listId,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdHighClicked?.call(adNetwork, adUnitType, data);
        widget.onClicked?.call(AdsPlacementType.high);
        if (mounted) {
          setState(() {});
        }
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdHighDismissed?.call(adNetwork, adUnitType, data);
        widget.onDismissed?.call(AdsPlacementType.high);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdHighFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdHighFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        widget.onFailedToShow?.call(AdsPlacementType.high);
        if (mounted) {
          setState(() {});
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdHighLoaded?.call(adNetwork, adUnitType, data);
        if (mounted) {
          setState(() {});
        }
      },
      onAdShowed: (adNetwork, adUnitType, data) {
        widget.onAdHighShowed?.call(adNetwork, adUnitType, data);
        widget.onShowed?.call(AdsPlacementType.high);
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
        widget.onHighPaidEvent?.call(
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

    _isAdLoading = true;
    if (mounted) {
      setState(() {});
    }

    if (widget.configHigh) {
      _nativeAdHigh?.load();
    }

    if (widget.configMedium) {
      _nativeAdMedium?.load();
    }

    if (widget.config) {
      _nativeAd?.load();
    }

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_nativeAdHigh?.isAdLoaded == true) {
        _timer?.cancel();
        _timer = null;
        _ad = _nativeAdHigh;
        _isAdLoaded = true;
        if (mounted) {
          setState(() {});
        }
      } else if (_nativeAdMedium?.isAdLoaded == true &&
          (_nativeAdHigh?.isAdLoadedFailed == true || !widget.configHigh)) {
        _timer?.cancel();
        _timer = null;
        _ad = _nativeAdMedium;
        _isAdLoaded = true;
        if (mounted) {
          setState(() {});
        }
      } else if (_nativeAd?.isAdLoaded == true &&
          (_nativeAdHigh?.isAdLoadedFailed == true || !widget.configHigh) &&
          (_nativeAdMedium?.isAdLoadedFailed == true || !widget.configMedium)) {
        _timer?.cancel();
        _timer = null;
        _ad = _nativeAd;
        _isAdLoaded = true;
        if (mounted) {
          setState(() {});
        }
      } else if ((_nativeAd?.isAdLoadedFailed == true || !widget.config) &&
          (_nativeAdHigh?.isAdLoadedFailed == true || !widget.configHigh) &&
          (_nativeAdMedium?.isAdLoadedFailed == true || !widget.configMedium)) {
        _timer?.cancel();
        _timer = null;
        widget.onFailedToLoad?.call();
        _isAdLoaded = false;
        if (mounted) {
          setState(() {});
        }
      }
      if (_timer == null) {
        _isAdLoading = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}
