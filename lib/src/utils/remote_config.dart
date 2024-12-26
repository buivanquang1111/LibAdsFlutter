import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:amazic_ads_flutter/src/utils/remote_config_key.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigLib {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  // static List<RemoteConfigKey> listRemoteConfigKey = [];
  static Map<String, dynamic> configs = {};

  static bool getConfigBool({required String name, bool defaultValue = true}) {
    try {
      return configs[RemoteConfigKeyLib.getKeyByName(name).name];
    } catch (e) {
      return defaultValue;
    }
  }

  static int getConfigInt({required String name, int defaultValue = 0}) {
    try {
      return configs[RemoteConfigKeyLib.getKeyByName(name).name];
    } catch (e) {
      return defaultValue;
    }
  }

  static String getConfigString(
      {required String name, String defaultValue = '30_70'}) {
    try {
      return configs[RemoteConfigKeyLib.getKeyByName(name).name];
    } catch (e) {
      return defaultValue;
    }
  }

  static Future<void> init(
      {required List<RemoteConfigKeyLib> remoteConfigKeys}) async {
    try {
      if (AdmobAds.instance.isHaveInternet() == false) {
        print('check_remote_config: no internet');
        getRemoteConfigDefault();
      } else {
        print('check_remote_config: have internet init');
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 30),
            minimumFetchInterval: const Duration(seconds: 15),
          ),
        );
        print('check_remote_config: set up config');

        await _remoteConfig.fetchAndActivate().then(
          (update) {
            if (update) {
              print('check_remote_config: update remote');
            } else {
              print('check_remote_config: no update remote');
            }
            getRemoteConfig();
          },
        );
      }
    } catch (e) {
      print('check_remote_config: Remote Config init error: $e');
      getRemoteConfigDefault();
    }
  }

  static void getRemoteConfig() {
    var showAds =
        _remoteConfig.getBool(RemoteConfigKeyLib.getKeyByName('show_ads').name);
    print('CHECK_REMOTE_CONFIG: 1. showAds - $showAds');

    // try {
    //   showAds = _remoteConfig.getBool(RemoteConfigKeyLib.getKeyByName('show_ads').name);
    //   print('CHECK_REMOTE_CONFIG: 2. showAds - $showAds');
    // } catch (e) {
    //   print('CHECK_REMOTE_CONFIG: 3. showAds - $showAds');
    // }

    for (var key in RemoteConfigKeyLib.listRemoteConfigKey) {
      try {
        switch (key.valueType) {
          case const (String):
            configs[key.name] = _remoteConfig.getString(key.name);
            break;
          case const (int):
            configs[key.name] = _remoteConfig.getInt(key.name);
            break;
          case const (bool):
            configs[key.name] = _remoteConfig.getBool(key.name) && showAds;
            break;
        }
      } catch (e) {
        if (key.valueType == bool) {
          configs[key.name] = key.defaultValue && showAds;
        } else {
          configs[key.name] = key.defaultValue;
        }
      }
      if (kDebugMode) {
        print(
            'CHECK_REMOTE_CONFIG, key: ${key.name} - value: ${configs[key.name]}');
      }
    }
  }

  static void getRemoteConfigDefault() {
    var showAds = RemoteConfigKeyLib.getKeyByName('show_ads').defaultValue;
    print('CHECK_REMOTE_CONFIG: 1. showAds - $showAds');

    for (var key in RemoteConfigKeyLib.listRemoteConfigKey) {
      try {
        switch (key.valueType) {
          case const (String):
            configs[key.name] =
                RemoteConfigKeyLib.getKeyByName(key.name).defaultValue;
            break;
          case const (int):
            configs[key.name] =
                RemoteConfigKeyLib.getKeyByName(key.name).defaultValue;
            break;
          case const (bool):
            configs[key.name] =
                RemoteConfigKeyLib.getKeyByName(key.name).defaultValue &&
                    showAds;
            break;
        }
      } catch (e) {
        if (key.valueType == bool) {
          configs[key.name] = key.defaultValue && showAds;
        } else {
          configs[key.name] = key.defaultValue;
        }
      }
      if (kDebugMode) {
        print(
            'CHECK_REMOTE_CONFIG_Default, key: ${key.name} - value: ${configs[key.name]}');
      }
    }
  }
}
