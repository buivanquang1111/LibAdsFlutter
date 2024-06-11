import 'dart:io';

class TestAdsId {
  /// App_Id
  static final String admobAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : "ca-app-pub-3940256099942544~1458002511";

  /// Ad_Open_Resume
  static final String admobOpenResume = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : "ca-app-pub-3940256099942544/5575463023";

  /// Ad_Banner
  static final String admobBannerId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : "ca-app-pub-3940256099942544/2435281174";

  /// Ad_Banner_Collapse
  static final String admobBannerCollapseId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2014213617'
      : "ca-app-pub-3940256099942544/2934735716";

  /// Ad_Interstitial
  static final String admobInterstitialId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : "ca-app-pub-3940256099942544/4411468910";

  /// Ad_Interstitial_Video
  static final String admobInterstitialVideoId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/8691691433'
      : "ca-app-pub-3940256099942544/5135589807";

  /// Ad_Native
  static final String admobNativeId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : "ca-app-pub-3940256099942544/3986624511";

  /// Ad_Native_Video
  static final String admobNativeVideo = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1044960115'
      : "ca-app-pub-3940256099942544/2521693316";

  /// Ad_Reward
  static final String admobRewardId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : "ca-app-pub-3940256099942544/1712485313";
}
