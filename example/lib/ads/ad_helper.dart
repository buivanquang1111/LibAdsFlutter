import 'dart:io';
import 'dart:math';

import 'package:example/utils/remote_config.dart';

enum AdSplashType { inter, open, none }

class AdHelper {
  static int lastTimeShowInter = -1;
  static int timeStartApp = -1;
  static bool isConnectInternet = false;

  static Future<void> init() async {
    lastTimeShowInter = -1;
    timeStartApp = DateTime.now().millisecondsSinceEpoch;
    try {
      final result = await InternetAddress.lookup('https://www.google.com/');
      if (result.isNotEmpty) {
        isConnectInternet = true;
      } else {
        isConnectInternet = false;
      }
    } on SocketException catch (_) {}
  }

  static bool canShowNextInterstitialAd() {
    if (timeStartApp == -1) {
      return false;
    }

    final curDateTime = DateTime.now();
    if ((curDateTime.millisecondsSinceEpoch - timeStartApp) / 1000 <
        RemoteConfig.configs[RemoteConfigKey.interval_from_start.name]) {
      return false;
    }

    if (lastTimeShowInter == -1) {
      return true;
    }

    if ((curDateTime.millisecondsSinceEpoch - lastTimeShowInter) / 1000 >=
        RemoteConfig
            .configs[RemoteConfigKey.interval_between_interstitial.name]) {
      return true;
    }
    return false;
  }

  static AdSplashType get splashType {
    if (RemoteConfig.configs[RemoteConfigKey.inter_splash.name] &&
        RemoteConfig.configs[RemoteConfigKey.open_splash.name]) {
      // ưu tiên bật tắt trước rồi mới xét tỉ lệ
      if (_isValidRate()) {
        if (_getRandomAd()) {
          if (RemoteConfig.configs[RemoteConfigKey.open_splash.name]) {
            return AdSplashType.open;
          } else {
            return AdSplashType.none;
          }
        } else {
          if (RemoteConfig.configs[RemoteConfigKey.inter_splash.name]) {
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
      if (RemoteConfig.configs[RemoteConfigKey.open_splash.name]) {
        return AdSplashType.open;
      }
      if (RemoteConfig.configs[RemoteConfigKey.inter_splash.name]) {
        return AdSplashType.inter;
      }
      return AdSplashType.none;
    }
  }

  static bool _isValidRate() {
    final String rateConfig =
        RemoteConfig.configs[RemoteConfigKey.rate_aoa_inter_splash.name];
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
    final String rateConfig =
        RemoteConfig.configs[RemoteConfigKey.rate_aoa_inter_splash.name];
    final split = rateConfig.split('_');
    final int appOpenRate;

    if (split.length != 2) {
      appOpenRate = 30;
    } else {
      appOpenRate = int.tryParse(split[0]) ?? 30;
    }

    Random random = Random();
    int randomNumber = random.nextInt(100);
    if (randomNumber < appOpenRate) {
      return true;
    } else {
      return false;
    }
  }
}
