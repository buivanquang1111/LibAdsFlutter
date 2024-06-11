// ignore_for_file: collection_methods_unrelated_type

library splash;

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:example/ads/ad_helper.dart';
import 'package:example/ads/ads.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/config/global_constant.dart';
import 'package:example/config/global_txt_style.dart';
import 'package:example/language/l.dart';
import 'package:example/main.dart';
import 'package:example/screen/language/language.dart';
import 'package:example/utils/connectivity.dart';
import 'package:example/utils/event_log.dart';
import 'package:example/utils/remote_config.dart';

EasyPreloadNativeController? introAdCtrl;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashState();
}

class SplashState extends State<SplashScreen> {
  final connectService = Get.find<ConnectivityService>();

  @override
  void initState() {
    super.initState();
    EventLog.logScreenView("SplashScreen", "SplashScreen");
    initAdModule();
    EventLog.logEvent("splash_open", null);
  }

  Future<void> handleNavigate() async {
    Get.offAll(const LanguageScreen(isFromSetting: false));
  }

  Future<void> initAdModule() async {
    adIdManager = DevAdIdManager();
    try {
      await EasyAds.instance.initialize(
        adIdManager,
        adResumeConfig:
            RemoteConfig.configs[RemoteConfigKey.appopen_resume.name],
        adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
        admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
        navigatorKey: Get.key,
        adResumeId: adIdManager.appOpenResume,
        initMediationCallback: (bool canRequestAds) {
          print('initMediationCallback: $canRequestAds');
          return const MethodChannel('channel')
              .invokeMethod<bool>('init_mediation', canRequestAds);
        },
        isDevMode: appFlavor != 'prod',
        onInitialized: (bool canRequestAds) {
          if (canRequestAds) {
            if (RemoteConfig.configs[RemoteConfigKey.native_intro.name]) {
              introAdCtrl = EasyPreloadNativeController(
                autoReloadOnFinish: false,
                nativeNormalId: adIdManager.nativeIntro1,
                nativeMediumId: null,
                nativeHighId: null,
              );
              if (introAdCtrl != null) {
                introAdCtrl!.load();
              }
            }
            // initAndLoadAd();
            showAdsSplash();
          } else {
            handleNavigate();
          }
        },
      );
    } catch (e) {
      handleNavigate();
    }
  }

  void initAndLoadAd() {
    if (AdHelper.splashType == AdSplashType.open) {
      EasyAds.instance.showAppOpen(
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onDisabled: () {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          handleNavigate();
        },
        adId: adIdManager.openSplash,
        config: RemoteConfig.configs[RemoteConfigKey.open_splash.name],
      );
    } else if (AdHelper.splashType == AdSplashType.inter) {
      EasyAds.instance.showInterstitialAd(
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onDisabled: () {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
          handleNavigate();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          handleNavigate();
        },
        adId: adIdManager.interSplash,
        config: RemoteConfig.configs[RemoteConfigKey.inter_splash.name],
      );
    } else {
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      handleNavigate();
    }
  }

  void showAdsSplash(){
    final String rateAoa = RemoteConfig.configs[RemoteConfigKey.rate_aoa_inter_splash.name];
    final bool isShowOpen = RemoteConfig.configs[RemoteConfigKey.open_splash.name];
    final bool isShownInter = RemoteConfig.configs[RemoteConfigKey.inter_splash.name];

    AdsSplash.instance.init(isShownInter, isShowOpen, rateAoa);
    AdsSplash.instance.showAdSplash(
        idOpen: adIdManager.openSplash,
        idInter: adIdManager.interSplash,
      onAdShowed: (adNetwork, adUnitType, data) {
        handleNavigate();
      },
      onAdDismissed: (adNetwork, adUnitType, data) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      },
      onDisabled: () {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        handleNavigate();
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        handleNavigate();
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        handleNavigate();
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
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
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30.h)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
