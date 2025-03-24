import 'dart:math';
import 'remote_config.dart';



enum AdSplashType { inter, open, none }

class AdHelper {
  static int _lastTimeShowInter = -1;
  static int _timeStartApp = -1;

  static void init() {
    _lastTimeShowInter = -1;
    _timeStartApp = DateTime.now().millisecondsSinceEpoch;
  }

  static bool canShowNextInterstitialAd() {
    if (_timeStartApp == -1) {
      return false;
    }

    final curDateTime = DateTime.now();
    if ((curDateTime.millisecondsSinceEpoch - _timeStartApp) / 1000 <
        RemoteConfig.interval_interstitial_from_start) {
      return false;
    }

    if (_lastTimeShowInter == -1) {
      return true;
    }

    if ((curDateTime.millisecondsSinceEpoch - _lastTimeShowInter) / 1000 >=
        RemoteConfig.interval_between_interstitial) {
      return true;
    }
    return false;
  }

  static void setLastTimeShowInter() {
    _lastTimeShowInter = DateTime.now().millisecondsSinceEpoch;
  }

  static AdSplashType get splashType {
    if (RemoteConfig.inter_splash && RemoteConfig.open_splash) {
      // ưu tiên bật tắt trước rồi mới xét tỉ lệ
      if (_isValidRate()) {
        if (_getRandomAd()) {
          if (RemoteConfig.open_splash) {
            return AdSplashType.open;
          } else {
            return AdSplashType.none;
          }
        } else {
          if (RemoteConfig.inter_splash) {
            return AdSplashType.inter;
          } else {
            return AdSplashType.none;
          }
        }
      } else {
        return AdSplashType.none;
      }
    } else {
      // nếu một trong hai tắt thì show cái còn lại
      if (RemoteConfig.open_splash) {
        return AdSplashType.open;
      }
      if (RemoteConfig.inter_splash) {
        return AdSplashType.inter;
      }
      return AdSplashType.none;
    }
  }

  static bool _isValidRate() {
    final String rateConfig = '0_100';
    final split = rateConfig.split('_');
    final int appOpenRate;
    final int interRate;

    if (split.length != 2) {
      appOpenRate = 30;
      interRate = 70;
    } else {
      appOpenRate = int.tryParse(split[0]) ?? 30;
      interRate = int.tryParse(split[1]) ?? 70;
    }

    return interRate + appOpenRate == 100 && interRate >= 0 && appOpenRate >= 0;
  }

  static bool _getRandomAd() {
    final String rateConfig = '0_100';
    final split = rateConfig.split('_');
    final int appOpenRate;

    if (split.length != 2) {
      appOpenRate = 30;
    } else {
      appOpenRate = int.tryParse(split[0]) ?? 30;
    }

    Random random = Random();
    int randomNumber = random.nextInt(100);
    return randomNumber <= appOpenRate;
  }

  /// handle welcome back
  static bool onSplashScreen = true;
  static bool isExcludeScreen = false;

  static void setOnSplashScreen(bool value) {
    onSplashScreen = value;
  }

  static void setIsExcludeScreen(bool value) {
    isExcludeScreen = value;
  }
}