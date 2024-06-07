import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_ads_flutter/banner/banner_ad_manager.dart';
import 'package:lib_ads_flutter/flutter_ads.dart';

class BannerAdView extends StatefulWidget {
  final String idAds;

  const BannerAdView({super.key, required this.idAds});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAdManager? _bannerAdManager;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initAd();
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: true,
        child: _bannerAdManager?.show() ??
            const SizedBox(
              height: 1,
              width: 1,
            ));
  }

  void _initAd() {
    if (_bannerAdManager != null) {
      _bannerAdManager = null;
    }
    _bannerAdManager = FlutterAds.instance.createBanner(
      context: context,
      idAds: widget.idAds,
      onAdLoaded: () {
        Fluttertoast.showToast(msg: 'onAdLoaded');
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: () {
        Fluttertoast.showToast(msg: 'onAdFailedToLoad');
      },
      onAdClicked: () {
        Fluttertoast.showToast(msg: 'onAdClicked');
      },
      onAdClosed: () {
        Fluttertoast.showToast(msg: 'onAdClosed');
      },
      onAdImpression: () {
        Fluttertoast.showToast(msg: 'onAdImpression');
        if (mounted) {
          setState(() {});
        }
      },
      onPaidEvent: () {
        Fluttertoast.showToast(msg: 'onPaidEvent');
      },
    );

    _bannerAdManager?.loadBanner();
    if (mounted) {
      setState(() {});
    }
  }
}
