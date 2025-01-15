import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BannerSplashPlatform extends StatefulWidget {
  final List<String> listIdAds;
  final bool remoteConfig;
  final Function()? onNext;

  const BannerSplashPlatform({
    super.key,
    required this.listIdAds,
    required this.remoteConfig,
    this.onNext,
  });

  @override
  State<BannerSplashPlatform> createState() => _BannerSplashPlatformState();
}

class _BannerSplashPlatformState extends State<BannerSplashPlatform> {
  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'com.yourcompany.ads/banner',
      creationParams: {'adUnitId': widget.listIdAds[0]},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
