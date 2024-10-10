// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final GlobalKey<NavigatorState> navigatorKey;
  final List<String> listId;
  final AdNetwork adNetwork;
  final Widget? child;

  bool _onSplashScreen = true;
  bool _isExcludeScreen = false;
  bool config;
  bool _isDisplayAppOpenResume = true;
  bool _isShowScreenWellCome = false;

  AppLifecycleReactor({required this.navigatorKey,
    required this.listId,
    this.config = true,
    required this.adNetwork,
    this.child});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void setDisplayAppOpenResume(bool value) {
    _isDisplayAppOpenResume = value;
  }

  void setShowScreenWellCome(bool value){
    _isShowScreenWellCome = value;
  }

  bool isShowScreenWellCome(){
    return _isShowScreenWellCome;
  }

  void showScreenWelCome() {
    setShowScreenWellCome(true);
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return child!;
      },
    );
  }

  void _onAppStateChanged(AppState appState) async {
    if (_onSplashScreen) return;
    if (!config) {
      if (child != null) {
        if(!_isShowScreenWellCome) {
          showScreenWelCome();
        }
      }
      return;
    }

    if (navigatorKey.currentContext == null) return;

    if (!_isDisplayAppOpenResume) return;

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

        if (listId.isNotEmpty != true) return;

        AdmobAds.instance.showAppOpen(
          listId: listId,
          config: true,
          onAdDismissed: (adNetwork, adUnitType, data) {
            if (child != null) {
              if(!_isShowScreenWellCome) {
                showScreenWelCome();
              }
            }
          },
          onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
            if (child != null) {
              if(!_isShowScreenWellCome) {
                showScreenWelCome();
              }
            }
          },
          onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
            if (child != null) {
              if(!_isShowScreenWellCome) {
                showScreenWelCome();
              }
            }
          },
          onDisabled: () {
            if (child != null) {
              if(!_isShowScreenWellCome) {
                showScreenWelCome();
              }
            }
          },
        );
      } else {
        _isExcludeScreen = false;
      }
    }
  }
}
