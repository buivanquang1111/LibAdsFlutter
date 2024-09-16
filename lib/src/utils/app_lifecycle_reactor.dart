// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final GlobalKey<NavigatorState> navigatorKey;
  final List<String> listId;
  final AdNetwork adNetwork;

  bool _onSplashScreen = true;
  bool _isExcludeScreen = false;
  bool config;
  bool _isDisplayAppOpenResume = false;

  AppLifecycleReactor({
    required this.navigatorKey,
    required this.listId,
    this.config = true,
    required this.adNetwork,
  });

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void setDisplayAppOpenResume(bool value){
    _isDisplayAppOpenResume = value;
  }

  void _onAppStateChanged(AppState appState) async {
    if (_onSplashScreen) return;
    if (!config) return;

    if (navigatorKey.currentContext == null) return;

    if(_isDisplayAppOpenResume) return;

    // Show AppOpenAd when back to foreground but do not show on excluded screens
    if (appState == AppState.foreground) {
      if (!_isExcludeScreen) {
        if (AdmobAds.instance.isFullscreenAdShowing) {
          return;
        }
        if (!AdmobAds.instance.isEnabled) {
          return;
        }
        if (await AdmobAds.instance.isDeviceOffline()) {
          return;
        }
        if (!ConsentManager.ins.canRequestAds) {
          return;
        }

        // final String id = AdmobAds.instance.isDevMode ? TestAdsId.admobOpenResume : adId!;
        if (listId.isNotEmpty != true) return;
        AdmobAds.instance.showAppOpen(
          listId: listId,
          config: true,
        );

        // navigatorKey.currentState?.push(
        //   AppOpenAds.getRoute(
        //     context: navigatorKey.currentContext!,
        //     adId: id,
        //     adNetwork: adNetwork,
        //   ),
        // );
      } else {
        _isExcludeScreen = false;
      }
    }
  }
}
