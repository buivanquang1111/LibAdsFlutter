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
    required List<String> listOpenId,
    required List<String> listInterId,
    EasyAdFailedCallback? onAdFailedToShow,
    EasyAdFailedCallback? onAdFailedToLoad,
    Function()? onDisabled,
    EasyAdCallback? onAdDismissed,
    EasyAdCallback? onAdShowed,
    EasyAdCallback? onAdLoaded,
    EasyAdCallback? onAdImpression,
    EasyAdCallback? onAdClicked,
  }) {
    if (getState() == StateAdSplash.open) {
      AdmobAds.instance.showAppOpen(
        listId: listOpenId,
        config: configAdsOpen!,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onDisabled: () {
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
        listId: listInterId,
        config: configAdsInter!,
        isShowAdsSplash: true,
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToShow?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          onAdFailedToLoad?.call(adNetwork, adUnitType, data, errorMessage);
        },
        onDisabled: () {
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

  void checkShowInterOrOpenSplash(String rate) {
    final int rateInter;
    final int rateOpen;

    if (isValidFormat(rate)) {
      rateOpen = int.tryParse(rate.split('_')[0]) ?? 30;
      rateInter = int.tryParse(rate.split('_')[1]) ?? 70;
      print('rateOpen: $rateOpen');
      print('rateInter: $rateInter');

      if (rateInter >= 0 && rateOpen >= 0 && (rateInter + rateOpen) == 100) {
        bool isShowOpenSplash = Random().nextInt(100) + 1 < rateOpen;
        setState(isShowOpenSplash ? StateAdSplash.open : StateAdSplash.inter);
      } else {
        setState(StateAdSplash.noAds);
      }
    } else {
      setState(StateAdSplash.noAds);
    }
  }

  bool isValidFormat(String input) {
    // Kiểm tra độ dài chuỗi phải ít nhất là 4 ký tự (ví dụ: "x_yy")
    if (input.length < 4) {
      return false;
    }

    // Tách chuỗi thành mảng các phần tử bởi dấu "_"
    List<String> parts = input.split('_');

    // Kiểm tra xem có đúng hai phần tử được tách ra hay không
    if (parts.length != 2) {
      return false;
    }

    // Chuyển đổi từng phần tử thành số
    int firstNumber;
    int secondNumber;
    try {
      firstNumber = int.parse(parts[0]);
      secondNumber = int.parse(parts[1]);
    } catch (e) {
      // Nếu có lỗi khi chuyển đổi thành số, trả về false
      return false;
    }

    // Kiểm tra điều kiện: số trước "_" cộng với số sau "_" bằng 100
    if (firstNumber + secondNumber == 100) {
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
