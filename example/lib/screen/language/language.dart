library language;

import 'dart:async';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:example/common/app_app_bar.dart';
import 'package:example/common/app_scafold.dart';
import 'package:example/const/resource.dart';
import 'package:example/screen/onboard/onboard_1.dart';
import 'package:example/utils/connectivity.dart';
import 'package:example/utils/event_log.dart';
import 'package:example/utils/language_ultis.dart';
import 'package:example/utils/preferences_util.dart';
import 'package:example/utils/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/config/global_txt_style.dart';
import 'package:example/language/l.dart';
import 'package:example/main.dart';

part 'controller/language_controller.dart';

part 'widgets/language_item.dart';

class LanguageScreen extends StatefulWidget {
  final bool isFromSetting;

  const LanguageScreen({
    super.key,
    required this.isFromSetting,
  });

  @override
  State<StatefulWidget> createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen>
    with WidgetsBindingObserver {
  final controller = Get.find<LanguageController>();
  final key = GlobalKey<CollapseBannerAdsState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print('appLifeState: initState');

    EventLog.logScreenView("LanguageScreen", "LanguageScreen");
    EventLog.logEvent("language_fo_open", null);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('appLifeState: didChangeAppLifecycleState');
    if (state == AppLifecycleState.resumed) {
      print('appLifeState: resumed');
    } else if (state == AppLifecycleState.paused) {
      print('appLifeState: paused');
    } else if (state == AppLifecycleState.inactive) {
      print('appLifeState: inactive');
    } else if (state == AppLifecycleState.hidden) {
      print('appLifeState: hide');
    } else if (state == AppLifecycleState.detached) {
      print('appLifeState: detached');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return AppScafold(
      isHome: false,
      isPortrait: true,
      isDecor: true,
      appBar: !widget.isFromSetting
          ? AppAppBar(
              leadingWidth: 0,
              leading: const SizedBox(),
              title: Text(
                L.language.tr,
                style: GlobalTextStyles.font22w700Leelaw.copyWith(
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // key.currentState?.closeCollapse().then(
                    //   (value) {
                    //     Timer(
                    //       const Duration(milliseconds: 800),
                    //       () {
                    AdmobAds.instance.showInterstitialAd(
                      listId: NetworkRequest.instance
                          .getListIDByName('inter_intro'),
                      config: true,
                      onDisabled: () {
                        controller.foSave();
                      },
                      onAdFailedToLoad:
                          (adNetwork, adUnitType, data, errorMessage) {
                        controller.foSave();
                      },
                      onAdFailedToShow:
                          (adNetwork, adUnitType, data, errorMessage) {
                        controller.foSave();
                      },
                      onAdDismissed: (adNetwork, adUnitType, data) {
                        controller.foSave();
                      },
                    );
                    // },
                    //     );
                    //   },
                    // );
                  },
                  icon: const Icon(
                    Icons.done,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : AppAppBar(
              leading: IconButton(
                onPressed: () => controller.back(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 24.w,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: Text(
                L.language.tr,
                style: GlobalTextStyles.font22w700Leelaw.copyWith(
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    controller.save();
                  },
                  icon: const Icon(
                    Icons.done,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 24.h,
              ),
              itemBuilder: (context, index) {
                return LanguageItem(controller.listLanguage[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemCount: controller.listLanguage.length,
            ),
          ),
          // !widget.isFromSetting
          //     ?
          // CollapseBannerAds(
          //     key: key,
          //     type: AdsBannerType.collapsible_bottom,
          //     listId: NetworkRequest.instance
          //         .getListIDByName('collapse_banner'),
          //     refreshRateSec: 10,
          //     cbFetchIntervalSec: 5,
          //     config: RemoteConfig.configs[RemoteConfigKey.banner_all.name],
          //     visibilityDetectorKey: 'collapse_banner_lang')
          NativeAds(
            factoryId: 'native_language',
            listId: NetworkRequest.instance
                .getListIDByName('native_language'),
            height: adIdManager.largeNativeAdHeight,
            color: GlobalColors.lightGray,
            border: null,
            padding: null,
            config: true,
            visibilityDetectorKey: 'native-lang',
          ),
          // BannerSplash(
          //   listIdAds: NetworkRequest.instance.getListIDByName('banner_splash'),
          //   remoteConfig: true,
          //   visibilityDetectorKey: 'banner-splash',
          //   onNext: () {},
          //   onTestAdSuccess: () {
          //     Fluttertoast.showToast(msg: 'Success');
          //   },
          //   onTestAdError: (p0) {
          //     Fluttertoast.showToast(msg: 'Error $p0');
          //     print('ErrorDetect: $p0');
          //   },
          // )
        ],
      ),
    );
  }
}
