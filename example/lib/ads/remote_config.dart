// ignore_for_file: non_constant_identifier_names

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RemoteConfig {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: const Duration(seconds: 15),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void getRemoteConfig() {
    /// remote config value here
    banner_splash = _remoteConfig.getBool("banner_splash");
    open_splash = _remoteConfig.getBool("open_splash");
    inter_splash = _remoteConfig.getBool("inter_splash");
    native_language = _remoteConfig.getBool("native_language");
    native_intro = _remoteConfig.getBool("native_intro");
    inter_intro = _remoteConfig.getBool("inter_intro");
    native_permission = _remoteConfig.getBool("native_permission");
    inter_permission = _remoteConfig.getBool("inter_permission");
    appopen_resume = _remoteConfig.getBool("appopen_resume");
    banner_all = _remoteConfig.getBool("banner_all");
    native_home = _remoteConfig.getBool("native_home");
    collapse_banner_home = _remoteConfig.getBool("collapse_banner_home");
    inter_explore = _remoteConfig.getBool("inter_explore");
    inter_identify = _remoteConfig.getBool("inter_identify");
    native_identify = _remoteConfig.getBool("native_identify");
    collapse_banner_botanic = _remoteConfig.getBool("collapse_banner_botanic");
    native_botanic = _remoteConfig.getBool("native_botanic");
    collapse_banner_health = _remoteConfig.getBool("collapse_banner_health");
    native_health = _remoteConfig.getBool("native_health");
    inter_history = _remoteConfig.getBool("inter_history");
    collapse_banner_history = _remoteConfig.getBool("collapse_banner_history");
    native_history = _remoteConfig.getBool("native_history");
    inter_water = _remoteConfig.getBool("inter_water");
    native_water = _remoteConfig.getBool("native_water");
    inter_water_set_add = _remoteConfig.getBool("inter_water_set_add");
    collapse_banner_water = _remoteConfig.getBool("collapse_banner_water");
    inter_water_edit = _remoteConfig.getBool("inter_water_edit");
    collapse_banner_set_reminder =
        _remoteConfig.getBool("collapse_banner_set_reminder");
    native_plant_identifier = _remoteConfig.getBool("native_plant_identifier");
    inter_more_infor = _remoteConfig.getBool("inter_more_infor");
    collapse_banner_plant_list =
        _remoteConfig.getBool("collapse_banner_plant_list");
    show_ads = _remoteConfig.getBool("show_ads");
    // test_language = _remoteConfig.getBool("test_language");
    native_intro_full1 = _remoteConfig.getBool("native_intro_full1");
    native_intro_full2 = _remoteConfig.getBool("native_intro_full2");
    test_permission = _remoteConfig.getBool("test_permission");
    test_intro = _remoteConfig.getBool("test_intro");

    interval_between_interstitial =
        _remoteConfig.getInt("interval_between_interstitial");
    interval_interstitial_from_start =
        _remoteConfig.getInt("interval_interstitial_from_start");
    collap_reload_interval = _remoteConfig.getInt("collap_reload_interval");
    rate_aoa_inter_splash = _remoteConfig.getString("rate_aoa_inter_splash");

    show_sub_screen = _remoteConfig.getBool("show_sub_screen");
    sub_show_x_after = _remoteConfig.getInt("sub_show_x_after");

    test_lang = _remoteConfig.getInt("test_lang");
    native_interest = _remoteConfig.getBool("native_interest");
    native_popup = _remoteConfig.getBool("native_popup");
    time_native_reload = _remoteConfig.getInt("time_native_reload");
    test_intro_perhome = _remoteConfig.getInt("test_intro_perhome");

    native_resume = _remoteConfig.getBool("native_resume");

    if (test_intro_perhome == 1) {
      test_permission = false;
      test_intro = false;
    } else if (test_intro_perhome == 2) {
      test_permission = false;
      test_intro = true;
    } else if (test_intro_perhome == 3) {
      test_permission = true;
      test_intro = true;
    } else if (test_intro_perhome == 4) {
      test_permission = true;
      test_intro = false;
    }
  }

  static void disableAllAds() {
    banner_splash = false;
    open_splash = false;
    inter_splash = false;
    native_language = false;
    native_intro = false;
    inter_intro = false;
    inter_permission = false;
    native_permission = false;
    banner_all = false;
    native_home = false;
    appopen_resume = false;
    collapse_banner_home = false;
    inter_explore = false;
    inter_identify = false;
    native_identify = false;
    collapse_banner_botanic = false;
    collapse_banner_health = false;
    native_health = false;
    inter_history = false;
    collapse_banner_history = false;
    native_history = false;
    inter_water = false;
    inter_water_set_add = false;
    native_water = false;
    collapse_banner_water = false;
    inter_water_edit = false;
    collapse_banner_set_reminder = false;
    native_plant_identifier = false;
    inter_more_infor = false;
    collapse_banner_plant_list = false;
    native_botanic = false;
    // test_language = false;
    native_intro_full1 = false;
    native_intro_full2 = false;
    test_permission = false;
    test_intro = false;
    native_interest = false;
    native_popup = false;
    native_resume = false;
  }

  /// remote config value here
  static bool banner_splash = true;
  static bool open_splash = true;
  static bool inter_splash = true;
  static bool native_language = true;
  static bool native_intro = true;
  static bool inter_intro = true;
  static bool inter_permission = true;
  static bool native_permission = true;
  static bool banner_all = true;
  static bool native_home = true;
  static bool appopen_resume = true;
  static bool collapse_banner_home = true;
  static bool inter_explore = true;
  static bool inter_identify = true;
  static bool native_identify = true;
  static bool collapse_banner_botanic = true;
  static bool collapse_banner_health = true;
  static bool native_health = true;
  static bool inter_history = true;
  static bool collapse_banner_history = true;
  static bool native_history = true;
  static bool inter_water = true;
  static bool inter_water_set_add = true;
  static bool native_water = true;
  static bool collapse_banner_water = true;
  static bool inter_water_edit = true;
  static bool collapse_banner_set_reminder = true;
  static bool native_plant_identifier = true;
  static bool inter_more_infor = true;
  static bool collapse_banner_plant_list = true;
  static bool native_botanic = true;
  static bool show_ads = true;
  // static bool test_language = false;
  static bool native_intro_full1 = true;
  static bool native_intro_full2 = true;
  static bool test_permission = true;
  static bool test_intro = false;
  static bool native_resume = true;

  static int collap_reload_interval = 40;
  static int interval_between_interstitial = 20;
  static int interval_interstitial_from_start = 15;
  static String rate_aoa_inter_splash = "10_90";
  static bool show_sub_screen = true;
  static int sub_show_x_after = 3;

  static int test_lang = 3;
  static bool native_interest = true;
  static bool native_popup = true;
  static int test_intro_perhome = 1;
  static int time_native_reload = 10;
}
