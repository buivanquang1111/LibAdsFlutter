// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:amazic_ads_flutter/adjust_config/call_organic_adjust.dart';
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
  String nameConfig;
  bool _isDisplayAppOpenResume = true;
  bool _isShowScreenWellCome = false;
  Function()? _onDismissCollapse;
  Function()? _onReloadCollapse;

  AppLifecycleReactor({required this.navigatorKey,
    required this.listId,
    this.config = true,
    required this.nameConfig,
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
          return PopScope(
            canPop: false,
            child: child!,
          );
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
        if (!AdmobAds.instance.isShowAllAds) {
          return;
        }
        if (!(await AdmobAds.instance.checkInternet())) {
          return;
        }
        if (!ConsentManager.ins.canRequestAds) {
          return;
        }

        if (listId.isNotEmpty != true) return;

        print(
            'check_app_resume --- 1.isShowWelComeScreenAfterAds: $isShowWelComeScreenAfterAds');
        if (isShowWelComeScreenAfterAds) {
          AdmobAds.instance.showAppOpen(
              nameAds: nameConfig,
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
              onDisabled: () async {
                EventLogLib.logEvent("open_resume_false", parameters: {
                  "reason":
                  "ump_${ConsentManager.ins
                      .canRequestAds}_org_${CallOrganicAdjust.instance
                      .isOrganic()}_internet_${await AdmobAds.instance
                      .checkInternet()}"
                });

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
          print('check_app_resume --- child: $child');
          if (child != null) {
            if (!_isShowScreenWellCome) {
              print(
                  'check_app_resume --- 2._isShowScreenWellCome: $_isShowScreenWellCome');
              showScreenWelCome();
            }
          }
        }
      } else {
        print('check_app_resume --- _isExcludeScreen: $_isExcludeScreen');
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
      nameAds: nameConfig,
      listId: listId,
      config: config,
      onAdDismissed: (adNetwork, adUnitType, data) {
        setShowScreenWellCome(false);
        onAdDismissed?.call(adNetwork, adUnitType, data);
      },
      onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
        setShowScreenWellCome(false);
        onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
        setShowScreenWellCome(false);
        onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
      },
      onDisabled: () async {
        setShowScreenWellCome(false);
        EventLogLib.logEvent("open_resume_false", parameters: {
          "reason":
          "ump_${ConsentManager.ins.canRequestAds}_org_${CallOrganicAdjust
              .instance.isOrganic()}_internet_${await AdmobAds.instance
              .checkInternet()}"
        });
        onDisabled?.call();
      },
      onDismissCollapse: () {
        setShowScreenWellCome(false);
        if (onDismissCollapse != null) {
          onDismissCollapse();
        }
        if (_onDismissCollapse != null) {
          _onDismissCollapse!();
        }
      },
    );
  }

  void showAppOpenResumeAdsAfter() {}
}
