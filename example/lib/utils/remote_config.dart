// ignore_for_file: constant_identifier_names, empty_catches

import 'dart:convert';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:example/model/intro_update.dart';

enum RemoteConfigKey {
  open_splash,
  inter_splash,
  native_language,
  native_intro,
  inter_intro,
  native_loanding,
  appopen_resume,
  banner_all,
  native_home,
  native_additional_tools,
  native_compare,
  native_personal,
  native_business,
  native_auto,
  native_fd,
  native_rd,
  inter_calculate,
  native_results,
  native_exrate,
  native_length,
  native_mass,
  native_speed,
  native_tem,
  interval_between_interstitial,
  interval_from_start,
  remote_update,
  rate_aoa_inter_splash;

  dynamic get defaultValue {
    switch (this) {
      case remote_update:
        return '''{"name": "Test_native_intro","desc": "Test_native_intro","date": "28/03/2024","apply": 1}''';
      case rate_aoa_inter_splash:
        return '0_100';
      case interval_between_interstitial:
        return 20;
      case interval_from_start:
        return 15;
      default:
        if (this == inter_intro) {
          return false;
        } else {
          return true;
        }
    }
  }

  Type get valueType {
    switch (this) {
      case remote_update:
      case rate_aoa_inter_splash:
        return String;
      case interval_between_interstitial:
      case interval_from_start:
        return int;
      default:
        return bool;
    }
  }
}

class RemoteConfig {
  // static final _remoteConfig = FirebaseRemoteConfig.instance;
  // static int remoteUpdate = 1;
  // static Future<void> init() async {
  //   try {
  //     await _remoteConfig.setConfigSettings(RemoteConfigSettings(
  //       fetchTimeout: const Duration(seconds: 30),
  //       minimumFetchInterval: const Duration(seconds: 15),
  //     ));
  //     await _remoteConfig.fetchAndActivate();
  //   } catch (e) {}
  // }
  //
  // static Map<String, dynamic> get defaultParameters {
  //   return {
  //     for (var element in RemoteConfigKey.values)
  //       element.name: element.defaultValue
  //   };
  // }

  static void getRemoteConfig() {
    /// remote config value here
    for (var key in RemoteConfigKey.values) {
      configs[key.name] = key.defaultValue;
      // try {
      //   switch (key.valueType) {
      //     case const (String):
      //       configs[key.name] = _remoteConfig.getString(key.name);
      //       break;
      //     case const (int):
      //       configs[key.name] = _remoteConfig.getInt(key.name);
      //       break;
      //     case const (bool):
      //       configs[key.name] = _remoteConfig.getBool(key.name);
      //       break;
      //   }
      // } catch (e) {
      //   configs[key.name] = key.defaultValue;
      // }
    }
    // remoteUpdate =  IntroUpdate.fromJson(jsonDecode(configs[RemoteConfigKey.remote_update.name])).apply ?? 1;
  }

  static Map<String, dynamic> configs = {};
}
