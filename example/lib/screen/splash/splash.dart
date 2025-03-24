// ignore_for_file: collection_methods_unrelated_type

library splash;

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:example/ads/ads.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/config/global_constant.dart';
import 'package:example/config/global_txt_style.dart';
import 'package:example/language/l.dart';
import 'package:example/main.dart';
import 'package:example/screen/language/language.dart';

// PreloadNativeController? introAdCtrl;
AdsBase? preloadAds;
AdsBase? adsBase1;
AdsBase? adsBase2;
List<AdsBase?> listAds = [];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashState();
}

class SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    adIdManager = DevAdIdManager();
    // AdmobAds.instance.initAllDataSplash(
    //     turnOnOrganic: true,
    //     remoteConfigKeys: [
    //       RemoteConfigKeyLib(
    //           name: 'show_ads', defaultValue: true, valueType: bool),
    //       RemoteConfigKeyLib(
    //           name: 'open_splash', defaultValue: true, valueType: bool),
    //       RemoteConfigKeyLib(
    //           name: 'inter_splash', defaultValue: true, valueType: bool),
    //       RemoteConfigKeyLib(
    //           name: 'open_resume', defaultValue: true, valueType: bool),
    //       RemoteConfigKeyLib(
    //           name: 'banner_splash', defaultValue: true, valueType: bool),
    //       RemoteConfigKeyLib(
    //           name: 'rate_aoa_inter_splash',
    //           defaultValue: '0_100',
    //           valueType: String),
    //       RemoteConfigKeyLib(
    //           name: 'interstitial_from_start',
    //           defaultValue: 15,
    //           valueType: int),
    //       RemoteConfigKeyLib(
    //           name: 'interval_between_interstitial',
    //           defaultValue: 20,
    //           valueType: int),
    //     ],
    //     adjustToken: '',
    //     onSetRemoteConfigOrganic: () {},
    //     onStartLoadBannerSplash: () {
    //       // AdmobAds.instance
    //       //     .loadNativeAds(
    //       //         adNetwork: AdNetwork.admob,
    //       //         factoryId: 'native_language',
    //       //         listId: NetworkRequest.instance
    //       //             .getListIDByName('native_language'),
    //       //         config: true,
    //       //         visibilityDetectorKey: 'native_language')
    //       //     .then(
    //       //   (value) {
    //       //     listAds.add(value);
    //       //   },
    //       // );
    //       // AdmobAds.instance
    //       //     .loadNativeAds(
    //       //         adNetwork: AdNetwork.admob,
    //       //         factoryId: 'native_language',
    //       //         listId: NetworkRequest.instance
    //       //             .getListIDByName('native_language'),
    //       //         config: true,
    //       //         visibilityDetectorKey: 'native_language')
    //       //     .then(
    //       //   (value) {
    //       //     listAds.add(value);
    //       //   },
    //       // );
    //       setState(() {
    //         NetworkRequest.instance.listAdsId.putIfAbsent(
    //           'banner_splash',
    //           () => ['ca-app-pub-3940256099942544/6300978111'],
    //         );
    //       });
    //     },
    //     onNextAction: () {
    //       handleNavigate();
    //     },
    //     navigatorKey: Get.key,
    //     keyRateAOA: 'rate_aoa_inter_splash',
    //     keyOpenSplash: 'open_splash',
    //     keyInterSplash: 'inter_splash',
    //     keyIntervalBetweenInterstitial: 'interval_between_interstitial',
    //     keyInterstitialFromStart: 'interstitial_from_start',
    //     nameAdsInterSplash: 'inter_splash',
    //     nameAdsOpenSplash: 'open_splash',
    //     nameAdsResume: 'open_resume',
    //     keyResumeConfig: 'open_resume');

    AdmobAds.instance.initAllDataSplash(
      remoteConfigKeys: [
        RemoteConfigKeyLib(name: 'show_ads', defaultValue: true, valueType: bool),
        RemoteConfigKeyLib(name: 'open_splash', defaultValue: true, valueType: bool),
        RemoteConfigKeyLib(name: 'inter_splash', defaultValue: true, valueType: bool),
        RemoteConfigKeyLib(name: 'open_resume', defaultValue: true, valueType: bool),
        RemoteConfigKeyLib(name: 'banner_splash', defaultValue: true, valueType: bool),
        RemoteConfigKeyLib(name: 'rate_aoa_inter_splash', defaultValue: '0_100', valueType: String),
        RemoteConfigKeyLib(name: 'interstitial_from_start', defaultValue: 15, valueType: int),
        RemoteConfigKeyLib(name: 'interval_between_interstitial', defaultValue: 20, valueType: int),
      ],
      idAdsResume: adIdManager.appopen_resume,
      keyResumeConfig: 'open_resume',
      onStartLoadBannerSplash: () {},
      onNextAction: () {
        handleNavigate();
      },
      navigatorKey: Get.key,
      keyRateAOA: 'rate_aoa_inter_splash',
      keyOpenSplash: 'open_splash',
      keyInterSplash: 'inter_splash',
      keyIntervalBetweenInterstitial: 'interval_between_interstitial',
      keyInterstitialFromStart: 'interstitial_from_start',
      idAdsOpen: adIdManager.open_splash,
      idAdsInter: adIdManager.inter_splash,
    );
  }

  Future<void> handleNavigate() async {
    Get.offAll(const LanguageScreen(isFromSetting: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 210.h),
                  Container(
                    width: 120.w,
                    height: 120.h,
                    color: Colors.red,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    GlobalConstants.kAppName,
                    style: GlobalTextStyles.font32w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 233.w,
                    height: 4.h,
                    child: LinearProgressIndicator(
                      backgroundColor: GlobalColors.darkBlue,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(63.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    L.descSplash.tr,
                    style: GlobalTextStyles.font14w400.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              // child: ConsentManager.ins.canRequestAds == true
              //     ? BannerSplash(
              //         listIdAds: NetworkRequest.instance
              //             .getListIDByName('banner_splash'),
              //         remoteConfig: RemoteConfigLib.configs[
              //             RemoteConfigKeyLib.getKeyByName('banner_splash').name],
              //         visibilityDetectorKey: 'banner_splash',
              //         isDetectTestAd: true,
              //         onTestAdSuccess: () {
              //           print('check_detect_test_ad --- ok');
              //         },
              //         onTestAdError: (p0) {
              //           print('check_detect_test_ad --- false');
              //         },
              //         onNext: () {},
              //       )
              //     : Container(),
              // child: ConsentManager.ins.canRequestAds == true
              //     ? BannerSplashPlatform(
              //         listIdAds: NetworkRequest.instance.getListIDByName('banner_splash'),
              //         remoteConfig: RemoteConfigLib
              //             .configs[RemoteConfigKeyLib.getKeyByName('banner_splash').name],
              //       )
              //     : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
