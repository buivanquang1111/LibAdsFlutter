import 'dart:math';

import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:amazic_ads_flutter/src/enums/state_ad_splash.dart';

import 'ads_base.dart';

class AdsSplash {
  AdsSplash._instance();

  static final AdsSplash instance = AdsSplash._instance();

  StateAdSplash state = StateAdSplash.noAds;

  bool? configAdsOpen;
  bool? configAdsInter;

  init(bool showInter, bool showOpen, String rate) {
    configAdsOpen = showOpen;
    configAdsInter = showInter;
    if (showInter && showOpen) {
      checkShowInterOrOpenSplash(rate);
    } else if (showInter) {
      setState(StateAdSplash.inter);
    } else if (showOpen) {
      setState(StateAdSplash.open);
    } else {
      setState(StateAdSplash.noAds);
    }
  }

  void showAdSplash({
    required String idOpen,
    required String idInter,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdFailedCallback? onAdFailedToLoad,
    Function()? onDisabled,
    EasyAdCallback? onAdDismissed,
    EasyAdCallback? onAdShowed,
  }) {
    if (getState() == StateAdSplash.open) {
      AdmobAds.instance.showAppOpen(
        adId: idOpen,
        config: configAdsOpen!,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToShow?.call(adNetwork,adUnitType,data,errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToLoad?.call(adNetwork,adUnitType,data,errorMessage);
        },
        onDisabled: () {
          onDisabled?.call();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          onAdDismissed?.call(adNetwork,adUnitType,data);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          onAdShowed?.call(adNetwork,adUnitType,data);
        },
      );
    } else if (getState() == StateAdSplash.inter) {
      AdmobAds.instance.showInterstitialAd(
          adId: idInter,
          config: configAdsInter!,
        isShowAdsSplash: true,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToShow?.call(adNetwork,adUnitType,data,errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToLoad?.call(adNetwork,adUnitType,data,errorMessage);
        },
        onDisabled: () {
          onDisabled?.call();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
         onAdDismissed?.call(adNetwork,adUnitType,data);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          onAdShowed?.call(adNetwork,adUnitType,data);
        }
      );
    } else {
      onDisabled?.call();
    }
  }

  void checkShowInterOrOpenSplash(String rate) {
    final int rateInter;
    final int rateOpen;

    rateOpen = int.tryParse(rate.split('_')[0]) ?? 30;
    rateInter = int.tryParse(rate.split('_')[1]) ?? 70;

    if (rateInter >= 0 && rateOpen >= 0 && (rateInter + rateOpen) == 100) {
      bool isShowOpenSplash = Random().nextInt(100) + 1 < rateOpen;
      setState(isShowOpenSplash ? StateAdSplash.open : StateAdSplash.inter);
    } else {
      setState(StateAdSplash.noAds);
    }
  }

  void setState(StateAdSplash stateAdSplash) {
    state = stateAdSplash;
  }

  StateAdSplash getState() {
    return state;
  }
}
