import 'package:easy_ads_flutter/easy_ads_flutter.dart';

abstract class AppAdIdManager extends IAdIdManager {
  AppAdIdManager();
  String get admobAppId;

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: admobAppId,
      );

  @override
  AppAdIds? get appLovinAdIds => null;

  double get largeNativeAdHeight => 265;
  double get smallNativeAdHeight => 137;
  double get mediumNativeAdHeight => 176;


  String get interSplash;
  String get openSplash;
  String get appOpenResume;

  String get nativeLanguageFactory => 'native_language';
  String get nativeLanguage;

  String get nativeIntro1;
  String get nativeIntro2;
  String get nativeIntro3;
  String get nativeIntro4;
  String get nativeIntroFactory => 'native_intro';

  String get interIntro;

  String get nativeLoading;
  String get nativeLoadingFactory => 'native_loanding';

  String get bannerAll;

  String get nativeHome;
  String get nativeHomeFactory => 'native_home';

  String get collapseHome;

  String get additionalToolNative;
  String get additionalToolNativeFactory => 'native_additional_tools';

  String get compareListNative;
  String get compareListNativeFactory => 'native_compare';

  String get personalLoanNative;
  String get personalLoanNativeFactory => 'native_personal';

  String get bussinessLoanNative;
  String get bussinessLoanNativeFactory => 'native_business';

  String get autoLoanNative;
  String get autoLoanNativeFactory => 'native_auto';

  String get nativeSetting;
  String get nativeSettingFactory => 'native_setting';

  String get nativeFd;
  String get nativeFdFactory => 'native_fd';

  String get nativeRd;
  String get nativeRdFactory => 'native_rd';

  String get mainFunctionInter;

  String get nativeResults;
  String get nativeResultsFactory => 'native_results';

  String get nativeExchangeRate;
  String get nativeExchangeRateFactory => 'native_exrate';

  String get nativeLengthConvert;
  String get nativeLengthConvertFactory => 'native_length';

  String get nativeMassConvert;
  String get nativeMassConvertFactory => 'native_mass';

  String get nativeSpeedConvert;
  String get nativeSpeedConvertFactory => 'native_speed';

  String get nativeTemConvert;
  String get nativeTemConvertFactory => 'native_tem';

  String get colapseWorldClock;
}
