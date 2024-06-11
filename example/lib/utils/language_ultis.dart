import 'package:example/config/global_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:example/language/de.dart';
import 'package:example/language/en.dart';
import 'package:example/language/es.dart';
import 'package:example/language/fr.dart';
import 'package:example/language/hi.dart';
import 'package:example/language/id.dart';
import 'package:example/language/pt.dart';

class LanguageUtil extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static const supportLocale = GlobalConstants.supportedLocales;

  static void changeLocale(String languageCode) {
    final locale = _getLocaleFromLanguageCurrent(languageCode: languageCode);
    Get.updateLocale(locale);
  }

  static Locale _getLocaleFromLanguageCurrent({String? languageCode}) {
    final lang = languageCode ?? Get.deviceLocale!.languageCode;
    for (var i in supportLocale) {
      if (lang == i.languageCode) {
        return i;
      }
    }
    return Get.locale!;
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'en': enLanguagePackage,
        'es': esLanguagePackage,
        'hi': hiLanguagePackage,
        'de': deLanguagePackage,
        'fr': frLanguagePackage,
        'id': idLanguagePackage,
        'pt': ptLanguagePackage
      };
}