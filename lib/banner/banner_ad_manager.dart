import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/enums/ads_banner_type.dart';
import 'package:lib_ads_flutter/view_ads/shimmer_loading_ad.dart';

class BannerAdManager {
  final String idAds;
  final AdRequest adRequest;
  final AdSize adSize;
  final void Function() onAdLoaded;
  final void Function() onAdFailedToLoad;
  final void Function() onAdClicked;
  final void Function() onAdClosed;
  final void Function() onAdImpression;
  final void Function() onPaidEvent;




  BannerAdManager({
   required this.idAds,
    required this.adRequest,
    required this.adSize,
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
    required this.onAdClicked,
    required this.onAdClosed,
    required this.onAdImpression,
    required this.onPaidEvent,
});


  // final adUnitId = Platform.isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // final adUnitIdCollapsible = Platform.isAndroid
  //     ? 'ca-app-pub-3940256099942544/2014213617'
  //     : 'ca-app-pub-3940256099942544/8388050270';

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFalse = false;

  bool get isAdLoaded => _isAdLoaded;
  bool get isAdLoading => _isAdLoading;
  bool get isAdLoadedFalse => _isAdLoadedFalse;

  Future<void> loadBanner() async{
    if(_isAdLoaded) return;

    _bannerAd = BannerAd(
        size: adSize,
        adUnitId: idAds,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd?;
            _isAdLoaded = true;
            _isAdLoadedFalse = false;
            onAdLoaded();
          },
          onAdFailedToLoad: (ad, error) {
            _bannerAd = null;
            _isAdLoaded = false;
            _isAdLoading = false;
            _isAdLoadedFalse = false;
            ad.dispose();
            onAdFailedToLoad();
          },
          onAdClicked: (ad) {
            onAdClicked();
          },
          onAdClosed: (ad) {
            onAdClosed();
          },
          onAdImpression: (ad) async {
            await Future.delayed(
              const Duration(milliseconds: 500),
                  () {
                _isAdLoading = false;
              },
            );
            onAdImpression();
          },
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            onPaidEvent();
          },
        ),
        request: adRequest
    );
    _isAdLoading = true;
    _bannerAd?.load();

  }

  dynamic show(){

    print('_isAdLoading: $_isAdLoading, _isAdLoaded: $_isAdLoaded');

    final ad = _bannerAd;
    if(ad == null && !_isAdLoaded){
      return const SizedBox(
        height: 1,
        width: 1,
      );
    }
    return Center(
      child: Container(
        height: adSize.height.toDouble(),
        width:  adSize.width.toDouble(),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black, width: 1),
            bottom: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: Stack(
          children: [
            if(ad != null && isAdLoaded)
              AdWidget(ad: ad,),
            if(isAdLoading)
              Container(
                color: Colors.white,
                child: ShimmerLoadingAd(height: adSize.height.toDouble(),),
              )
          ],
        ),
      ),
    );
  }



  // void loadAdBanner(BuildContext context, Function loadSuccess) async {
  //   AdSize adSize =
  //       (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
  //           MediaQuery.sizeOf(context).width.truncate())) as AdSize;
  //   BannerAd(
  //           size: adSize,
  //           adUnitId: adUnitId,
  //           listener: BannerAdListener(
  //             onAdLoaded: (ad) {
  //               bannerAd = ad as BannerAd;
  //               isloaded = true;
  //               loadSuccess();
  //             },
  //             onAdFailedToLoad: (ad, error) {
  //               ad.dispose();
  //             },
  //             onAdOpened: (Ad ad) {},
  //             onAdClosed: (Ad ad) {},
  //             onAdImpression: (Ad ad) {},
  //           ),
  //           request: const AdRequest())
  //       .load();
  // }
  //
  // void loadCollapseBanner(
  //     BuildContext context, AdsBannerType type, Function loadSuccess) async {
  //   Fluttertoast.showToast(msg: "start");
  //
  //   AdSize adSize =
  //       (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
  //           MediaQuery.sizeOf(context).width.truncate())) as AdSize;
  //
  //   AdRequest _adRequest = new AdRequest();
  //   if (type == AdsBannerType.collapsible_bottom) {
  //     _adRequest = const AdRequest(
  //       extras: {'collapsible': 'bottom'},
  //     );
  //   } else if (type == AdsBannerType.collapsible_top) {
  //     _adRequest = const AdRequest(
  //       extras: {'collapsible': 'top'},
  //     );
  //   }
  //   Fluttertoast.showToast(msg: "body");
  //   await BannerAd(
  //       size: adSize,
  //       adUnitId: adUnitIdCollapsible,
  //       request: _adRequest,
  //       listener: BannerAdListener(
  //         onAdLoaded: (ad) {
  //           Fluttertoast.showToast(msg: "onAdLoaded");
  //           bannerAd = ad as BannerAd;
  //           isloaded = true;
  //           loadSuccess();
  //         },
  //         onAdFailedToLoad: (ad, error) {
  //           ad.dispose();
  //           Fluttertoast.showToast(msg: "onAdFailedToLoad");
  //         },
  //         onAdOpened: (Ad ad) {
  //           Fluttertoast.showToast(msg: "onAdOpened");
  //         },
  //         onAdClosed: (Ad ad) {
  //           Fluttertoast.showToast(msg: "onAdClosed");
  //         },
  //         onAdImpression: (Ad ad) {
  //           Fluttertoast.showToast(msg: "onAdImpression");
  //         },
  //       )).load();
  //   Fluttertoast.showToast(msg: "end");
  // }
  //
  // void loadAd(BuildContext context, Function() onAdLoad) async {
  //   // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
  //   final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
  //       MediaQuery.sizeOf(context).width.truncate());
  //
  //   if (size == null) {
  //     // Unable to get width of anchored banner.
  //     return;
  //   }
  //
  //   BannerAd(
  //     adUnitId: adUnitIdCollapsible,
  //     request: const AdRequest(extras: {'collapsible': 'bottom'}),
  //     size: size,
  //     listener: BannerAdListener(
  //       // Called when an ad is successfully received.
  //       onAdLoaded: (ad) {
  //         bannerAd = ad as BannerAd;
  //         isloaded = true;
  //         onAdLoad();
  //       },
  //       // Called when an ad request failed.
  //       onAdFailedToLoad: (ad, err) {
  //         ad.dispose();
  //       },
  //       // Called when an ad opens an overlay that covers the screen.
  //       onAdOpened: (Ad ad) {},
  //       // Called when an ad removes an overlay that covers the screen.
  //       onAdClosed: (Ad ad) {},
  //       // Called when an impression occurs on the ad.
  //       onAdImpression: (Ad ad) {},
  //     ),
  //   ).load();
  // }
}
