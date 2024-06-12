import 'dart:async';

import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';
import '../amazic_admob/admob_preload_native_ad.dart';
import 'loading_ads.dart';

class PreloadNativeController {
  final AdNetwork adNetwork;

  AdsBase? nativeNormal;
  final String? nativeNormalId;
  int loadTimesFailedNativeNormal = 0;

  AdsBase? nativeMedium;
  final String? nativeMediumId;
  int loadTimesFailedNativeMedium = 0;

  AdsBase? nativeHigh;
  final String? nativeHighId;
  int loadTimesFailedNativeHigh = 0;

  final int limitLoad;
  final bool autoReloadOnFinish;

  final ValueNotifier<bool> isPreparing = ValueNotifier(false);

  PreloadNativeController({
    this.adNetwork = AdNetwork.admob,
    required this.nativeNormalId,
    required this.nativeMediumId,
    required this.nativeHighId,
    this.limitLoad = 3,
    required this.autoReloadOnFinish,
  })

  /// Support admob only
  /// Other network will be implement soon!
  : assert(adNetwork == AdNetwork.admob);

  void dispose() {
    nativeNormal?.dispose();
    nativeNormal = null;

    nativeMedium?.dispose();
    nativeMedium = null;

    nativeHigh?.dispose();
    nativeHigh = null;

    isPreparing.dispose();
  }

  Future<void> load() async {
    if (!AdmobAds.instance.isEnabled) {
      return;
    }

    if (await AdmobAds.instance.isDeviceOffline()) {
      return;
    }

    if (nativeHigh == null || nativeHigh!.isAdLoadedFailed) {
      loadTimesFailedNativeHigh = 0;
      loadNativeHigh();
    }

    if (nativeMedium == null || nativeMedium!.isAdLoadedFailed) {
      loadTimesFailedNativeMedium = 0;
      loadNativeMedium();
    }

    if (nativeNormal == null || nativeNormal!.isAdLoadedFailed) {
      loadTimesFailedNativeNormal = 0;
      loadNativeNormal();
    }
  }

  Future<void> loadNativeNormal() async {
    if (nativeNormal != null) {
      nativeNormal!.dispose();
      nativeNormal = null;
    }

    if (!AdmobAds.instance.isEnabled) {
      return;
    }

    if (await AdmobAds.instance.isDeviceOffline()) {
      return;
    }
    if (nativeNormalId?.isNotEmpty != true) {
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      return;
    }

    nativeNormal = AdmobAds.instance.createPreloadNative(
      adNetwork: adNetwork,
      adId: nativeNormalId!,
      type: AdsPlacementType.normal,
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        if (loadTimesFailedNativeNormal < limitLoad) {
          loadTimesFailedNativeNormal++;
          Future.delayed(
            const Duration(milliseconds: 500),
            () => loadNativeNormal(),
          );
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        loadTimesFailedNativeNormal = 0;
      },
    );

    await nativeNormal!.load();
  }

  Future<void> loadNativeMedium() async {
    if (nativeMedium != null) {
      nativeMedium!.dispose();
      nativeMedium = null;
    }

    if (!AdmobAds.instance.isEnabled) {
      return;
    }

    if (await AdmobAds.instance.isDeviceOffline()) {
      return;
    }
    if (nativeMediumId?.isNotEmpty != true) {
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      return;
    }

    nativeMedium = AdmobAds.instance.createPreloadNative(
      adNetwork: adNetwork,
      adId: nativeMediumId!,
      type: AdsPlacementType.med,
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        if (loadTimesFailedNativeMedium < limitLoad) {
          loadTimesFailedNativeMedium++;
          Future.delayed(
            const Duration(milliseconds: 500),
            () => loadNativeMedium(),
          );
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        loadTimesFailedNativeMedium = 0;
      },
    );

    await nativeMedium!.load();
  }

  Future<void> loadNativeHigh() async {
    if (nativeHigh != null) {
      nativeHigh!.dispose();
      nativeHigh = null;
    }

    if (!AdmobAds.instance.isEnabled) {
      return;
    }

    if (await AdmobAds.instance.isDeviceOffline()) {
      return;
    }
    if (nativeHighId?.isNotEmpty != true) {
      return;
    }
    if (!ConsentManager.ins.canRequestAds) {
      return;
    }

    nativeHigh = AdmobAds.instance.createPreloadNative(
      adNetwork: adNetwork,
      adId: nativeHighId!,
      type: AdsPlacementType.high,
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        if (loadTimesFailedNativeHigh < limitLoad) {
          loadTimesFailedNativeHigh++;
          Future.delayed(
            const Duration(milliseconds: 500),
            () => loadNativeHigh(),
          );
        }
      },
      onAdLoaded: (adNetwork, adUnitType, data) {
        loadTimesFailedNativeHigh = 0;
      },
    );

    await nativeHigh!.load();
  }

  Future<void> prepareAds(Function(AdsBase? adBase)? onPrepaired) async {
    if (!AdmobAds.instance.isEnabled) {
      onPrepaired?.call(null);
      return;
    }

    if (await AdmobAds.instance.isDeviceOffline()) {
      onPrepaired?.call(null);
      return;
    }

    if (!isPreparing.value) {
      isPreparing.value = true;
    }

    // Todo: Must check network later
    if (nativeHigh?.isAdLoaded == true && !(nativeHigh as AdmobPreloadNativeAd).isAdShowed) {
      onPrepaired?.call(nativeHigh!);
      return;
    }

    // Todo: Must check network later
    if (nativeMedium?.isAdLoaded == true &&
        !(nativeMedium as AdmobPreloadNativeAd).isAdShowed) {
      onPrepaired?.call(nativeMedium!);
      return;
    }

    // Todo: Must check network later
    if (nativeNormal?.isAdLoaded == true &&
        !(nativeNormal as AdmobPreloadNativeAd).isAdShowed) {
      onPrepaired?.call(nativeNormal!);
      return;
    }

    // Todo: Must check network later
    if ((nativeHigh == null ||
            nativeHigh!.isAdLoadedFailed ||
            (nativeHigh as AdmobPreloadNativeAd).isAdShowed) &&
        (nativeMedium == null ||
            nativeMedium!.isAdLoadedFailed ||
            (nativeMedium as AdmobPreloadNativeAd).isAdShowed) &&
        (nativeNormal == null ||
            nativeNormal!.isAdLoadedFailed ||
            (nativeNormal as AdmobPreloadNativeAd).isAdShowed)) {
      onPrepaired?.call(null);
      return;
    }

    Future.delayed(
      const Duration(milliseconds: 500),
      () => prepareAds(onPrepaired),
    );
  }

  void finishPreloadAd(AdsPlacementType type) {
    switch (type) {
      case AdsPlacementType.normal:
        if (nativeNormal != null) {
          nativeNormal!.dispose();
          nativeNormal = null;
        }
        if (autoReloadOnFinish) {
          loadNativeNormal();
        }

        break;
      case AdsPlacementType.med:
        if (nativeMedium != null) {
          nativeMedium!.dispose();
          nativeMedium = null;
        }
        if (autoReloadOnFinish) {
          loadNativeMedium();
        }

        break;
      case AdsPlacementType.high:
        if (nativeHigh != null) {
          nativeHigh!.dispose();
          nativeHigh = null;
        }
        if (autoReloadOnFinish) {
          loadNativeHigh();
        }

        break;
    }
  }
}

class EasyPreloadNativeAd extends StatefulWidget {
  final PreloadNativeController controller;
  final String factoryId;

  final double height;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final EasyAdCallback? onAdShowed;
  final EasyAdCallback? onAdClicked;
  final EasyAdFailedCallback? onAdFailedToShow;
  final EasyAdCallback? onAdDismissed;
  final EasyAdOnPaidEvent? onPaidEvent;

  const EasyPreloadNativeAd({
    super.key,
    required this.controller,
    required this.factoryId,
    required this.height,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.padding,
    this.margin,
    this.onAdShowed,
    this.onAdClicked,
    this.onAdFailedToShow,
    this.onAdDismissed,
    this.onPaidEvent,
  });

  @override
  State<EasyPreloadNativeAd> createState() => _EasyPreloadNativeAdState();
}

class _EasyPreloadNativeAdState extends State<EasyPreloadNativeAd> {
  AdsBase? adBase;
  AdsPlacementType? type;

  @override
  void dispose() {
    if (type != null) {
      widget.controller.finishPreloadAd(type!);
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    widget.controller.prepareAds(
      (adBase) async {
        if (adBase == null) {
          widget.controller.isPreparing.value = false;
          return;
        }

        switch (widget.controller.adNetwork) {
          default:
            final admobPreloadNativeAd = adBase as AdmobPreloadNativeAd;
            await admobPreloadNativeAd.setPlatformView(
              factoryId: widget.factoryId,
            );
            admobPreloadNativeAd.updateListener(
              onAdClicked: widget.onAdClicked,
              onAdDismissed: widget.onAdDismissed,
              onAdShowed: widget.onAdShowed,
              onPaidEvent: widget.onPaidEvent,
              onAdFailedToShow: widget.onAdFailedToShow,
            );
            type = admobPreloadNativeAd.type;
            this.adBase = admobPreloadNativeAd;
            break;
        }

        widget.controller.isPreparing.value = false;

        if (mounted) {
          setState(() {});
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.isPreparing,
      builder: (_, isPreparing, __) {
        if (isPreparing) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: widget.border,
              color: widget.color,
            ),
            padding: widget.padding,
            margin: widget.margin,
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: Container(
                color: widget.color,
                height: widget.height,
                child: LoadingAds(height: widget.height),
              ),
            ),
          );
        }
        if (adBase != null) {
          return adBase!.show(
            height: widget.height,
            color: widget.color,
            border: widget.border,
            borderRadius: widget.borderRadius,
            padding: widget.padding,
            margin: widget.margin,
          );
        }
        return const SizedBox(
          height: 1,
          width: 1,
        );
      },
    );
  }
}
