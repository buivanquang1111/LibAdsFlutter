// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:flutter/material.dart';

import '../../admob_ads_flutter.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final GlobalKey<NavigatorState> navigatorKey;
  final List<String> listId;
  final AdNetwork adNetwork;
  final Widget? child;
  final bool
      isShowWelComeScreenAfterAds; //hiển thị màn Welcome sau quảng cáo resume

  bool _onSplashScreen = true;
  bool _isExcludeScreen = false;
  bool config;
  bool _isDisplayAppOpenResume = true;
  bool _isShowScreenWellCome = false;
  Function()? _onDismissCollapse;
  Function()? _onReloadCollapse;

  AppLifecycleReactor(
      {required this.navigatorKey,
      required this.listId,
      this.config = true,
      required this.adNetwork,
      this.child,
      required this.isShowWelComeScreenAfterAds});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void setDismissCollapseWhenResume({
    required Function()? onDismissCollapseWhenResume,
    required Function()? onReloadCollapseWhenTurnOffWelCome,
  }) {
    _onDismissCollapse = onDismissCollapseWhenResume;
    _onReloadCollapse = onReloadCollapseWhenTurnOffWelCome;
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

  void setShowScreenWellCome(bool value) {
    _isShowScreenWellCome = value;
  }

  bool isShowScreenWellCome() {
    return _isShowScreenWellCome;
  }

  void showScreenWelCome() {
    setShowScreenWellCome(true);
    if (Platform.isAndroid) {
      showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: (context) {
          return child!;
        },
      ).then(
            (value) {
          if (_onReloadCollapse != null) {
            _onReloadCollapse!();
          }
        },
      );
    } else {
      showGeneralDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return child!;
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Bắt đầu từ dưới lên
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          }).then(
            (value) {
          if (_onReloadCollapse != null) {
            _onReloadCollapse!();
          }
        },
      );
    }
  }

  void _onAppStateChanged(AppState appState) async {
    if (_onSplashScreen) return;
    if (!config) {
      if (child != null) {
        if (!_isShowScreenWellCome) {
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

        if (isShowWelComeScreenAfterAds) {
          AdmobAds.instance.showAppOpen(
              listId: listId,
              config: config,
              onAdDismissed: (adNetwork, adUnitType, data) {
                if (child != null) {
                  if (!_isShowScreenWellCome) {
                    showScreenWelCome();
                  }
                }
              },
              onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
                if (child != null) {
                  if (!_isShowScreenWellCome) {
                    showScreenWelCome();
                  }
                }
              },
              onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
                if (child != null) {
                  if (!_isShowScreenWellCome) {
                    showScreenWelCome();
                  }
                }
              },
              onDisabled: () {
                if (child != null) {
                  if (!_isShowScreenWellCome) {
                    showScreenWelCome();
                  }
                }
              },
              onDismissCollapse: () {
                if (_onDismissCollapse != null) {
                  _onDismissCollapse!();
                }
              });
        } else {
          if (child != null) {
            if (!_isShowScreenWellCome) {
              showScreenWelCome();
            }
          }
        }
      } else {
        _isExcludeScreen = false;
      }
    }
  }

  void showAppOpenResumeAds({
    Function()? onDisabled,
    EasyAdFailedCallback? onAdFailedToLoad,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdCallback? onAdDismissed,
    Function? onDismissCollapse,
  }) {
    AdmobAds.instance.showAppOpen(
        listId: listId,
        config: config,
        onAdDismissed: onAdDismissed,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdFailedToShow: onAdFailedToShow,
        onDisabled: onDisabled,
        onDismissCollapse: () {
          if(onDismissCollapse != null){
            onDismissCollapse();
          }
          if (_onDismissCollapse != null) {
            _onDismissCollapse!();
          }
        });
  }

  void showAppOpenResumeAdsAfter() {}
}
