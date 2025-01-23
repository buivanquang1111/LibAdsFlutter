import 'dart:ffi';
import 'dart:math';

import 'package:amazic_ads_flutter/adjust_config/call_organic_adjust.dart';
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:amazic_ads_flutter/src/enums/state_ad_splash.dart';
import 'package:amazic_ads_flutter/src/utils/event_log.dart';

import 'ads_base.dart';

class AdsSplash {
  AdsSplash._instance();

  static final AdsSplash instance = AdsSplash._instance();

  StateAdSplash state = StateAdSplash.noAds;

  init(bool showInter, bool showOpen, String rate) {
    if (showInter && showOpen) {
      if(isValidFormat(rateAoa: rate)){
        if(getRandomOpenRate(rateAoa: rate)){
          if(showOpen){
            setState(StateAdSplash.open);
          }else{
            EventLogLib.logEvent('rate_aoa_no_ads');
            setState(StateAdSplash.noAds);
          }
        }else{
          if(showInter){
            setState(StateAdSplash.inter);
          }else{
            EventLogLib.logEvent('rate_aoa_no_ads');
            setState(StateAdSplash.noAds);
          }
        }
      }else{
        EventLogLib.logEvent('rate_aoa_no_ads');
        setState(StateAdSplash.noAds);
      }
    } else {
      if (showOpen) {
        setState(StateAdSplash.open);
      } else if (showInter) {
        setState(StateAdSplash.inter);
      } else {
        EventLogLib.logEvent('rate_aoa_no_ads');
        setState(StateAdSplash.noAds);
      }
    }
  }

  void showAdSplash({
    required List<String> listOpenId,
    required List<String> listInterId,
    required bool configAdsOpen,
    required bool configAdsInter,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdFailedCallback? onAdFailedToLoad,
    Function()? onDisabled,
    EasyAdCallback? onAdDismissed,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdImpression,
    EasyAdCallback? onAdClicked,
    required bool isTrickScreen,
  }) {
    if (getState() == StateAdSplash.open) {
      AdmobAds.instance.showAppOpen(
        nameAds: null,
        listId: listOpenId,
        config: configAdsOpen,
        isShowAdsSplash: true,
        isTrickScreen: false,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          EventLogLib.logEvent('rate_aoa_failed_to_show_open');
          onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          EventLogLib.logEvent('rate_aoa_failed_to_load_open');
          onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onDisabled: () {
          EventLogLib.logEvent('rate_aoa_disabled_open');
          onDisabled?.call();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          onAdDismissed?.call(adNetwork, adUnitType, data);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          onDisabled?.call();
          onAdShowed?.call(adNetwork, adUnitType, data);
        },
        onAdLoaded: (adNetwork, adUnitType, data) {
          onAdLoaded?.call(adNetwork, adUnitType, data);
        },
        onAdImpression: (adNetwork, adUnitType, data) {
          onAdImpression?.call(adNetwork, adUnitType, data);
        },
        onAdClicked: (adNetwork, adUnitType, data) {
          onAdClicked?.call(adNetwork, adUnitType, data);
        },
      );
    } else if (getState() == StateAdSplash.inter) {
      AdmobAds.instance.showInterstitialAd(
        nameAds: null,
        listId: listInterId,
        config: configAdsInter,
        isShowAdsSplash: true,
        isTrickScreen: false,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          EventLogLib.logEvent('rate_aoa_failed_to_show_inter');
          onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          EventLogLib.logEvent('rate_aoa_failed_to_load_inter');
          onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onDisabled: () {
          EventLogLib.logEvent('rate_aoa_disabled_inter');
          onDisabled?.call();
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          onAdDismissed?.call(adNetwork, adUnitType, data);
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          onDisabled?.call();
          onAdShowed?.call(adNetwork, adUnitType, data);
        },
        onAdLoaded: (adNetwork, adUnitType, data) {
          onAdLoaded?.call(adNetwork, adUnitType, data);
        },
        onAdImpression: (adNetwork, adUnitType, data) {
          onAdImpression?.call(adNetwork, adUnitType, data);
        },
        onAdClicked: (adNetwork, adUnitType, data) {
          onAdClicked?.call(adNetwork, adUnitType, data);
        },
      );
    } else {
      onDisabled?.call();
    }
  }

  bool isValidFormat({required String rateAoa}) {
    final split = rateAoa.split('_');
    final int openRate;
    final int interRate;

    if (split.length != 2) {
      openRate = 30;
      interRate = 70;
    } else {
      openRate = int.tryParse(split[0]) ?? 30;
      interRate = int.tryParse(split[1]) ?? 70;
    }

    return (openRate + interRate == 100) && openRate >= 0 && openRate >= 0;
  }

  bool getRandomOpenRate({required String rateAoa}) {
    final split = rateAoa.split('_');
    final int openRate;

    if (split.length != 2) {
      openRate = 30;
    } else {
      openRate = int.tryParse(split[0]) ?? 30;
    }

    Random random = Random();
    int randomNumber = random.nextInt(100);
    if (randomNumber < openRate) {
      return true;
    } else {
      return false;
    }
  }

  void setState(StateAdSplash stateAdSplash) {
    state = stateAdSplash;
  }

  StateAdSplash getState() {
    return state;
  }
}
