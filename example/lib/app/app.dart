// ignore_for_file: empty_catches

import 'dart:async';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:example/config/global_colors.dart';
import 'package:example/config/global_constant.dart';
import 'package:example/screen/language/language.dart';
import 'package:example/screen/splash/splash.dart';
import 'package:example/utils/language_ultis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  final ValueNotifier<bool> _isShowAd = ValueNotifier(false);
  StreamSubscription? _streamSubscription;
  AppLifecycleState? _state;
  final languageCtrl = Get.put(LanguageController());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _streamSubscription = AdmobAds.instance.onEvent.listen((event) {
      if (event.type == AdEventType.onPaidEvent) {
        try {
          final Map<String, dynamic>? data =
              event.data as Map<String, dynamic>?;
          //   'revenue': revenue,
          // 'currencyCode': currencyCode,
          // 'network': network,
          // 'unit': unit,
          // 'placement': placement,
          final num? revenue = data?['revenue'];
          final String? currencyCode = data?['currencyCode'];
          final String? network = data?['network'];
          final String? unit = data?['unit'];
          final String? placement = data?['placement'];
          if (revenue != null && currencyCode != null) {
            AdjustAdRevenue adRevenue;
            switch (event.adNetwork) {
              default:
                adRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAdMob);
                break;
            }
            adRevenue.setRevenue(revenue, currencyCode);
            adRevenue.adRevenueNetwork = network;
            adRevenue.adRevenueUnit = unit;
            adRevenue.adRevenuePlacement = placement;
            Adjust.trackAdRevenueNew(adRevenue);
            final adjustEvent = AdjustEvent("f5l43s");
            adjustEvent.setRevenue(revenue, currencyCode);
            Adjust.trackEvent(adjustEvent);
          }
        } catch (e) {}
      }

      if (event.adUnitType == AdUnitType.appOpen) {
        if (event.type == AdEventType.adShowed) {
          _isShowAd.value = true;
        } else if (event.type == AdEventType.adDismissed) {
          _isShowAd.value = false;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isShowAd.dispose();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Adjust.onResume();
      if (_state == AppLifecycleState.paused) {
        AdmobAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      }
    } else if (state == AppLifecycleState.paused) {
      Adjust.onPause();
    }
    _state = state;
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Obx(
        () => GetMaterialApp(
          home: const SplashScreen(),
          navigatorKey: Get.key,
          locale: Locale(languageCtrl.currentLanguage.value),
          translations: LanguageUtil(),
          title: GlobalConstants.kAppName,
          supportedLocales: GlobalConstants.supportedLocales,
          theme: ThemeData(primaryColor: GlobalColors.primary),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          fallbackLocale: const Locale('en'),
          builder: (appContext, appChild) {
            return ValueListenableBuilder(
              valueListenable: _isShowAd,
              child: appChild,
              builder: (context, isShowingAd, child) {
                return Stack(
                  children: [
                    if (child != null) child,
                    Visibility(
                      visible: isShowingAd,
                      child: Container(
                        color: Colors.white,
                        height: context.height,
                        width: context.width,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
