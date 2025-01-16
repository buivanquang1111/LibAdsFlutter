import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'loading_ads.dart';

class BannerSplashPlatform extends StatefulWidget {
  final List<String> listIdAds;
  final bool remoteConfig;
  final Function()? onNext;
  final AdSize? adSize;
  final AdsBannerType type;

  const BannerSplashPlatform({
    super.key,
    required this.listIdAds,
    required this.remoteConfig,
    this.onNext,
    this.adSize,
    this.type = AdsBannerType.adaptive,
  });

  @override
  State<BannerSplashPlatform> createState() => _BannerSplashPlatformState();
}

class _BannerSplashPlatformState extends State<BannerSplashPlatform> {
  static const MethodChannel _methodChannel =
      MethodChannel('com.yourcompany.ads/banner');

  bool isShowAd = false;

  @override
  void initState() {
    super.initState();
    _listenToAdEvents();
  }

  void _listenToAdEvents() async {
    try {
      _methodChannel.setMethodCallHandler((call) async {
        final Map<String, dynamic>? event = call.arguments;
        switch (call.method) {
          case 'onAdLoaded':
            print('banner_splash_platform --- Ad Loaded');
            break;
          case 'onAdClicked':
            print('banner_splash_platform --- Ad Clicked');
            break;
          case 'onAdFailedToLoad':
            print(
                'banner_splash_platform --- Ad Failed to Load: ${event?['error']}');
            break;
          case 'onAdClosed':
            print('banner_splash_platform --- Ad Closed');
            break;
          case 'onAdImpression':
            print('banner_splash_platform --- Ad Impression');
            setState(() {
              isShowAd = true;
            });
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
    return Container(
      height: widget.adSize?.height.toDouble(),
      width: widget.adSize?.width.toDouble(),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Stack(
        children: [
          AndroidView(
            viewType: 'com.yourcompany.ads/banner',
            creationParams: {
              'adUnitId': widget.listIdAds[0],
              'adSize': {
                'width': widget.adSize?.width ??
                    AdmobAds.instance.getAdmobAdSize(type: widget.type).width,
                'height': widget.adSize?.height ??
                    AdmobAds.instance.getAdmobAdSize(type: widget.type).height
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
    );
  }
}
