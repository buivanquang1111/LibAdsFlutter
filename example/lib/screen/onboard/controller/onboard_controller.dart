import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:example/ads/ad_helper.dart';
import 'package:example/const/resource.dart';
import 'package:example/language/l.dart';
import 'package:example/screen/onboard/widgets/onboard_item.dart';
import 'package:example/utils/event_log.dart';
import 'package:example/utils/preferences_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../utils/remote_config.dart';

class OnboardController extends GetxController {
  final pgCtrl = PageController(initialPage: 0);
  var index = 0.obs;
  var txt = L.nextBtn.obs;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var rawData = "";

  @override
  void onInit() {
    EventLog.logScreenView("OnBoardScreen", "OnBoardScreen");
    EventLog.logEvent("Onboarding1_view", null);
    super.onInit();
  }

  void onchange(i) {
    index.value = i;
    if (index.value < 2) {
      txt.value = L.nextBtn;
    } else {
      txt.value = L.getStart;
    }
  }

  void onPress() {
    if (index.value < 2) {
      if (index.value == 1) {
        EventLog.logEvent("Onboarding2_view", null);
      } else {
        EventLog.logEvent("Onboarding3_view", null);
      }
      txt.value = L.nextBtn;
      index.value += 1;
      pgCtrl.animateToPage(
        index.value,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    } else {
      EventLog.logEvent("Onboarding3_start", null);
      if (AdHelper.canShowNextInterstitialAd()) {
        EasyAds.instance.showInterstitialAd(
          adId: adIdManager.interIntro,
          config: RemoteConfig.configs[RemoteConfigKey.inter_intro.name],
          onDisabled: () => handleNavigate(),
          onAdShowed: (adNetwork, adUnitType, data) => handleNavigate(),
          onAdDismissed: (adNetwork, adUnitType, data) => {
            AdHelper.lastTimeShowInter = DateTime.now().millisecondsSinceEpoch
          },
          onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) =>
              handleNavigate(),
          onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) =>
              handleNavigate(),
        );
      } else {
        handleNavigate();
      }
    }
  }

  handleNavigate() async {
    final data = await deviceInfo.androidInfo;
    // if (PreferencesUtil.getFirstTime()) {
    //   if (data.version.sdkInt < 33) {
    //     Get.offAll(const LoadingDataScreen());
    //   } else {
    //     Get.offAll(const PermissionScreen());
    //   }
    // } else {
    //   Get.offAll(const MainPage());
    // }
  }

  final lstOnboardImg = [
    const OnboardImg(
      path: R.ASSETS_IMAGES_ONBOARD1_PNG,
      title: L.titleBoarding1,
      content: L.contentBoarding1,
    ),
    const OnboardImg(
      path: R.ASSETS_IMAGES_ONBOARD2_PNG,
      title: L.titleBoarding2,
      content: L.contentBoarding2,
    ),
    const OnboardImg(
      path: R.ASSETS_IMAGES_ONBOARD3_PNG,
      title: L.titleBoarding3,
      content: L.contentBoarding3,
    )
  ];
}
