library language;

import 'dart:async';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:example/common/app_app_bar.dart';
import 'package:example/common/app_scafold.dart';
import 'package:example/const/resource.dart';
import 'package:example/screen/onboard/onboard_1.dart';
import 'package:example/screen/splash/splash.dart';
import 'package:example/utils/event_log.dart';
import 'package:example/utils/language_ultis.dart';
import 'package:example/utils/preferences_util.dart';
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
  final nativeKey = GlobalKey<NativeAdsReloadState>();

  //
  NativeAd? _currentNativeAd;
  NativeAd? _nextNativeAd;
  bool _isCurrentAdLoaded = false;
  bool _isNextAdLoaded = false;
  Key _adKey = UniqueKey(); // Key để ép Flutter rebuild UI

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print('appLifeState: initState');
    super.initState();
    _loadCurrentAd();
    _preloadNextAd();
  }

  void _loadCurrentAd() {
    _currentNativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      factoryId: 'native_language',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isCurrentAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _preloadNextAd() {
    _nextNativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      factoryId: 'native_language',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNextAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _showNextAd() {
    if (_isNextAdLoaded) {
      setState(() {
        _currentNativeAd = _nextNativeAd; // Gán NativeAd mới vào
        _adKey = UniqueKey(); // Tạo key mới để ép Flutter rebuild UI
        _isCurrentAdLoaded = true;
        _isNextAdLoaded = false;
      });

      _preloadNextAd(); // Load trước NativeAd tiếp theo
    }
  }

  @override
  void dispose() {
    _currentNativeAd?.dispose();
    _nextNativeAd?.dispose();
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
                      nameAds: 'inter_intro',
                      idAds: adIdManager.inter_intro,
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
                return LanguageItem(
                  controller.listLanguage[index],
                  onTap: () {
                    Fluttertoast.showToast(msg: 'click');
                    if (listAds.length > 1) {
                      listAds.removeAt(0);
                      nativeKey.currentState
                          ?.reloadAdsNative(adBase: listAds[0]);
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemCount: controller.listLanguage.length,
            ),
          ),
          // NativeAds(
          //   factoryId: 'native_language',
          //   listId: NetworkRequest.instance
          //       .getListIDByName('native_language'),
          //   height: adIdManager.largeNativeAdHeight,
          //   color: GlobalColors.lightGray,
          //   border: null,
          //   padding: null,
          //   config: true,
          //   refreshRateSec: 10,
          //   visibilityDetectorKey: 'native-lang',
          // ),
          NativeAdsReload(
            key: nativeKey,
            adsBase: listAds.isNotEmpty ? listAds[0] : null,
            idAds: adIdManager.native_language,
            refreshRateSec: 10,
            visibilityDetectorKey: 'native_language',
            factoryId: 'native_language',
            config: true,
            height: adIdManager.largeNativeAdHeight,
            borderRadius: BorderRadius.zero,
            isCanReloadHideView: true,
          ),
          // NativeAdsAdmob(
          //     key: nativeKey,
          //     nativeAd: nativeAd,
          //     idAds: 'ca-app-pub-3940256099942544/2247696110',
          //     refreshRateSec: 0,
          //     visibilityDetectorKey: 'native_language',
          //     factoryId: 'native_language',
          //     config: true,
          //     height: adIdManager.largeNativeAdHeight,
          //     borderRadius: BorderRadius.zero),
        ],
      ),
    );
  }
}
