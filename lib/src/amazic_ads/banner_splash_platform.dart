import 'dart:io';
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../adjust_config/call_organic_adjust.dart';
import 'loading_ads.dart';

class BannerSplashPlatform extends StatefulWidget {
  final List<String> listIdAds;
  final bool remoteConfig;
  final Function()? onNext;
  final AdSize? adSize;
  final AdsBannerType type;
  final Function()? onAdLoaded;
  final Function()? onAdClicked;
  final Function(String)? onAdFailedToLoad;
  final Function()? onAdClosed;
  final Function()? onAdImpression;
  final Function()? onCoreTechnologyTestAd;

  const BannerSplashPlatform({
    super.key,
    required this.listIdAds,
    required this.remoteConfig,
    this.onNext,
    this.adSize,
    this.type = AdsBannerType.adaptive,
    this.onAdLoaded,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdClosed,
    this.onAdImpression,
    this.onCoreTechnologyTestAd,
  });

  @override
  State<BannerSplashPlatform> createState() => _BannerSplashPlatformState();
}

class _BannerSplashPlatformState extends State<BannerSplashPlatform> {
  static const MethodChannel _methodChannel =
      MethodChannel('com.yourcompany.ads/banner');

  bool isShowAd = false;
  bool isVisibility = true;

  @override
  void initState() {
    super.initState();
    _listenToAdEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdmobAds.instance.isShowAllAds ||
        AdmobAds.instance.isDeviceOffline ||
        !widget.remoteConfig ||
        !ConsentManager.ins.canRequestAds) {
      EventLogLib.logEvent('banner_splash_false', parameters: {
        "reason":
            "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${!AdmobAds.instance.isDeviceOffline}"
      });
      setState(() {
        isVisibility = false;
      });
    }
  }

  void _listenToAdEvents() async {
    try {
      _methodChannel.setMethodCallHandler((call) async {
        final Map<String, dynamic>? event = call.arguments;
        switch (call.method) {
          case 'onRequestAds':
            EventLogLib.logEvent('banner_splash_true', parameters: {
              'reason':
                  'ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust.instance.isOrganic()}_internet_${!AdmobAds.instance.isDeviceOffline}'
            });
            break;
          case 'onAdLoaded':
            print('banner_splash_platform --- Ad Loaded');
            widget.onAdLoaded?.call();
            break;
          case 'onAdClicked':
            print('banner_splash_platform --- Ad Clicked');
            widget.onAdClicked?.call();
            break;
          case 'onAdFailedToLoad':
            print(
                'banner_splash_platform --- Ad Failed to Load: ${event?['error']}');
            widget.onAdFailedToLoad?.call(event?['error']);
            break;
          case 'onAdClosed':
            print('banner_splash_platform --- Ad Closed');
            widget.onAdClosed?.call();
            break;
          case 'onAdImpression':
            print('banner_splash_platform --- Ad Impression');
            widget.onAdImpression?.call();
            setState(() {
              isShowAd = true;
            });
            break;
          case 'coreTechnologyTestAd':
            print('banner_splash_platform --- coreTechnologyTestAd');
            AdmobAds.instance.setIsTestAd(value: true);
            widget.onCoreTechnologyTestAd?.call();
            break;
          default:
            print('banner_splash_platform --- Unknown event: ${call.method}');
        }
      });
    } catch (e) {
      print('banner_splash_platform --- Error listening to ad events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisibility,
      child: Container(
        height: widget.adSize?.height.toDouble() ?? 60,
        width: widget.adSize?.width.toDouble() ?? double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black, width: 2),
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Stack(
          children: [
            if (Platform.isAndroid)
              if (widget.listIdAds.isNotEmpty)
                AndroidView(
                  viewType: 'com.yourcompany.ads/banner',
                  creationParams: {
                    'adUnitId': widget.listIdAds[0],
                    'adSize': {
                      'width': widget.adSize?.width ??
                          AdmobAds.instance
                              .getAdmobAdSize(type: widget.type)
                              .width,
                      'height': widget.adSize?.height ??
                          AdmobAds.instance
                              .getAdmobAdSize(type: widget.type)
                              .height
                    }
                  },
                  creationParamsCodec: const StandardMessageCodec(),
                )
              else if (Platform.isIOS)
                UiKitView(
                  viewType: 'com.yourcompany.ads/banner',
                  creationParams: {
                    'adUnitId': widget.listIdAds[0],
                    'adSize': {
                      'width': widget.adSize?.width ??
                          AdmobAds.instance
                              .getAdmobAdSize(type: widget.type)
                              .width,
                      'height': widget.adSize?.height ??
                          AdmobAds.instance
                              .getAdmobAdSize(type: widget.type)
                              .height
                    }
                  },
                  creationParamsCodec: const StandardMessageCodec(),
                ),
            if (!isShowAd)
              LoadingAds(
                height: widget.adSize?.height.toDouble() ?? 60,
              ),
          ],
        ),
      ),
    );
  }
}
