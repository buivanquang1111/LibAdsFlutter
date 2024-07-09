part of '../language.dart';

class LanguageController extends GetxController implements GetxService {
  var currentLanguage = PreferencesUtil.getLanguage().obs;
  var previousLanguage = PreferencesUtil.getLanguage().obs;
  final connectService = Get.find<ConnectivityService>();
  final List<String> lstLang = ['en', 'hi', 'es', 'fr', 'de', 'id', 'pt'];

  var listLanguage = [
    const LanguageModel(
        name: "English", code: "en", icon: R.ASSETS_IMAGES_EN_FLAG_PNG),
    const LanguageModel(
        name: "Hindi", code: "hi", icon: R.ASSETS_IMAGES_HI_FLAG_PNG),
    const LanguageModel(
        name: "Spanish", code: "es", icon: R.ASSETS_IMAGES_ES_FLAG_PNG),
    const LanguageModel(
        name: "French", code: "fr", icon: R.ASSETS_IMAGES_FR_FLAG_PNG),
    const LanguageModel(
        name: "German", code: "de", icon: R.ASSETS_IMAGES_DE_FLAG_PNG),
    const LanguageModel(
        name: "Indonesian", code: "id", icon: R.ASSETS_IMAGES_ID_FLAG_PNG),
    const LanguageModel(
        name: "Portuguese", code: "pt", icon: R.ASSETS_IMAGES_PT_FLAG_PNG),
  ];

  @override
  void onInit() {
    if (lstLang.contains(currentLanguage.value)) {
    } else {
      currentLanguage.value = 'en';
    }
    pushCurrentLangOnTop();
    super.onInit();
  }

  pushCurrentLangOnTop() {
    for (var i in listLanguage) {
      if (i.code == currentLanguage.value) {
        listLanguage.remove(i);
        listLanguage.insert(0, i);
      }
    }
  }

  Future<void> confirmChangeLanguage(code) async {
    currentLanguage.value = code;
  }

  save() async {
    await PreferencesUtil.putLanguage(currentLanguage.value);
    previousLanguage = PreferencesUtil.getLanguage().obs;
    LanguageUtil.changeLocale(currentLanguage.value);
    pushCurrentLangOnTop();
    Get.back();
  }

  foSave() async {
    await PreferencesUtil.putLanguage(currentLanguage.value);
    previousLanguage = PreferencesUtil.getLanguage().obs;
    LanguageUtil.changeLocale(currentLanguage.value);
    EventLog.logEvent("language_fo_save_click",
        {"language_fo_save_click": currentLanguage.value});
    pushCurrentLangOnTop();
    Get.to(const OnboardScreen1());
  }

  void back() {
    currentLanguage.value = previousLanguage.value;
    LanguageUtil.changeLocale(previousLanguage.value);
    Get.back();
  }
}

class LanguageModel {
  final String name;
  final String code;
  final String icon;

  const LanguageModel({
    required this.name,
    required this.code,
    required this.icon,
  });
}
