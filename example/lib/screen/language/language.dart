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

class LanguageScreenState extends State<LanguageScreen> {
  final controller = Get.find<LanguageController>();
  final key = GlobalKey<CollapseBannerAdsState>();

  @override
  void initState() {
    EventLog.logScreenView("LanguageScreen", "LanguageScreen");
    EventLog.logEvent("language_fo_open", null);
    super.initState();
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
                    key.currentState?.closeCollapse().then(
                      (value) {
                        Timer(
                          const Duration(milliseconds: 800),
                          () {
                            AdmobAds.instance.showInterstitialAd(
                              listId: NetworkRequest.instance
                                  .getListIDByName('inter_intro'),
                              config: true,
                              onDisabled: () {
                                Fluttertoast.showToast(msg: 'onDisabled');
                                controller.foSave();
                              },
                              onAdFailedToLoad:
                                  (adNetwork, adUnitType, data, errorMessage) {
                                Fluttertoast.showToast(msg: 'onAdFailedToLoad');
                                controller.foSave();
                              },
                              onAdFailedToShow:
                                  (adNetwork, adUnitType, data, errorMessage) {
                                Fluttertoast.showToast(msg: 'onAdFailedToShow');
                                controller.foSave();
                              },
                              onAdDismissed: (adNetwork, adUnitType, data) {
                                Fluttertoast.showToast(msg: 'onAdDismissed');
                                controller.foSave();
                              },
                            );
                          },
                        );
                      },
                    );
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
          !widget.isFromSetting
              ? CollapseBannerAds(
                  key: key,
                  type: AdsBannerType.collapsible_bottom,
                  listId: NetworkRequest.instance
                      .getListIDByName('collapse_banner'),
                  refreshRateSec: 10,
                  cbFetchIntervalSec: 5,
                  config: RemoteConfig.configs[RemoteConfigKey.banner_all.name],
                  visibilityDetectorKey: 'banner-lang')
              : NativeAds(
                  factoryId: 'native_language',
                  listId: NetworkRequest.instance
                      .getListIDByName('native_language'),
                  height: 265,
                  color: GlobalColors.lightGray,
                  border: null,
                  padding: null,
                  config: RemoteConfig
                      .configs[RemoteConfigKey.native_language.name],
                  visibilityDetectorKey: 'native-lang',
                ),
        ],
      ),
    );
  }
}
