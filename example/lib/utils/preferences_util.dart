import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtil {
  static SharedPreferences? _pref;

  static Future<void> init() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  static Future<void> putLanguage(String code) async {
    await _pref?.setString("lang", code);
  }

  static String getLanguage() {
    return _pref?.getString("lang") ?? (Get.deviceLocale?.languageCode ?? 'en');
  }

  static Future<void> putFirstTime(bool firstTime) async {
    await _pref?.setBool("firstTime", firstTime);
  }

  static bool getFirstTime() {
    return _pref?.getBool("firstTime") ?? true;
  }

  static Future<void> saveRate(int count) async{
    await _pref?.setInt("rate", count + 1);
  }

  static int getRate(){
    return _pref?.getInt("rate") ?? 0;
  }

  static Future<void> saveCanRate() async{
    await _pref?.setBool("can_rate", false);
  }

  static bool getCanRate(){
    return _pref?.getBool("can_rate") ?? true;
  }
}
