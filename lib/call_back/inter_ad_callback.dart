import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterAdCallback{
  void Function()? onAdLoaded;

  void Function(LoadAdError)? onAdFailedToLoad;

  void Function()? onAdImpression;

   void Function(AdError)? onAdFailedToShow;

  void Function()? onAdClosed;

  void Function()? onAdClicked;

}