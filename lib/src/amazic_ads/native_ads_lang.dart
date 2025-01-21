import 'package:flutter/material.dart';

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
  State<NativeAdsLang> createState() => _NativeAdsLangState();
}

class _NativeAdsLangState extends State<NativeAdsLang>
    with WidgetsBindingObserver {
  AdsBase? _nativeAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareAd();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _nativeAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.config && ConsentManager.ins.canRequestAds,
      child: _nativeAd != null
          ? _nativeAd?.show(
              height: widget.height,
              borderRadius: widget.borderRadius,
              color: widget.color,
              border: widget.border,
              padding: widget.padding,
              margin: widget.margin)
          : Container(
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
            ),
    );
  }

  Future<void> _prepareAd() async {
    if (!AdmobAds.instance.isShowAllAds ||
        !(await AdmobAds.instance.checkInternet()) ||
        !widget.config ||
        !ConsentManager.ins.canRequestAds) {
      widget.onAdDisabled?.call(widget.adNetwork, AdUnitType.native, null);
      return;
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
      visibilityDetectorKey: '',
      isClickAdsNotShowResume: widget.isClickAdsNotShowResume,
      onAdClicked: (adNetwork, adUnitType, data) {
        widget.onAdClicked?.call(adNetwork, adUnitType, data);
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        widget.onAdDismissed?.call(adNetwork, adUnitType, data);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToLoad
            ?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        widget.onAdFailedToShow
            ?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        widget.onAdLoaded?.call(adNetwork, adUnitType, data);
      },
      onAdShowed: (adNetwork, adUnitType, data) {
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
        widget.onAdImpression?.call(adNetwork, adUnitType, data);
      },
    );
    _nativeAd?.load();
    if (mounted) {
      setState(() {});
    }
  }
}
