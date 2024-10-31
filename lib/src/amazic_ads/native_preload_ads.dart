import 'package:flutter/cupertino.dart';

import '../../admob_ads_flutter.dart';
import 'loading_ads.dart';

class NativePreloadAds extends StatefulWidget {
  final AdsBase? preloadedAd;
  final double height;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool config;

  const NativePreloadAds({
    super.key,
    this.preloadedAd,
    required this.height,
    this.color,
    this.border,
    this.padding,
    this.margin,
    this.borderRadius = BorderRadius.zero,
    required this.config,
  });

  @override
  State<NativePreloadAds> createState() => _NativePreloadAdsState();
}

class _NativePreloadAdsState extends State<NativePreloadAds> {
  @override
  Widget build(BuildContext context) {
    print(
        'load_native: lib --- ${widget.preloadedAd} --- ${widget.preloadedAd != null} --- ${widget.preloadedAd?.show(height: widget.height) != null}');
    return Visibility(
        visible: widget.config,
        child: widget.preloadedAd != null &&
                widget.preloadedAd?.show(height: widget.height) != null
            ? widget.preloadedAd?.show(
                height: widget.height,
                borderRadius: widget.borderRadius,
                color: widget.color,
                border: widget.border,
                padding: widget.padding,
                margin: widget.margin,
              )
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
              ));
  }
}
