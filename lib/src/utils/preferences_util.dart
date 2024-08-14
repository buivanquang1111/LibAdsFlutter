import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtil{
  static SharedPreferences? _pref;

  static Future<void> init() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  static Future<void> setTestAd() async {
    await _pref?.setBool("test_ad", true);
  }

  static bool isTestAd() {
    return _pref?.getBool("test_ad") ?? false;
  }
}