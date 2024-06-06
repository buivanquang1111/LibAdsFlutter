import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/call_back/inter_ad_callback.dart';
import 'package:lib_ads_flutter/app_open/app_open_ad_manager.dart';
import 'package:lib_ads_flutter/dialog_loading/dialog_loading_inter.dart';

class InterstitialAdManager{
  InterstitialAd? _interstitialAd;
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  void loadAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {

            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void show(BuildContext context, int duration ,InterAdCallback adCallback){

    final ad = _interstitialAd;
    if(ad == null){
      loadAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      // Called when the ad showed the full screen content.
        onAdShowedFullScreenContent: (ad) {
          Fluttertoast.showToast(msg: 'onAdShowedFullScreenContent!');
          AppOpenAdManager().disableAppResume();
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (ad) {
          adCallback.onAdImpression!();
        },
        // Called when the ad failed to show full screen content.
        onAdFailedToShowFullScreenContent: (ad, err) {
          // Dispose the ad here to free resources.
          if(adCallback.onAdFailedToShow != null) {
            adCallback.onAdFailedToShow!(err);
          }
          ad.dispose();
        },
        // Called when the ad dismissed full screen content.
        onAdDismissedFullScreenContent: (ad) {
          Fluttertoast.showToast(msg: 'onAdDismissedFullScreenContent!');
          AppOpenAdManager().enableAppResume();
          // Dispose the ad here to free resources.
          adCallback.onAdClosed!();
          ad.dispose();
        },
        // Called when a click is recorded for an ad.
        onAdClicked: (ad) {
          adCallback.onAdClicked!();
        });

    showLoadingDialog(context, duration).then((value) => ad.show());
    _interstitialAd = null;
  }

}