import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtilLib {
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

  static Future<void> setOrganicAdjust() async {
    await _pref?.setBool("organic_adjust", true);
  }

  static bool isOrganicAdjust() {
    return _pref?.getBool("organic_adjust") ?? false;
  }
}
