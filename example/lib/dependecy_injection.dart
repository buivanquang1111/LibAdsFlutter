import 'package:example/screen/language/language.dart';
import 'package:example/utils/preferences_util.dart';
import 'package:get/get.dart';

Future<void> init() async {
  await PreferencesUtil.init();

  final languageController = LanguageController();
  Get.lazyPut(() => languageController, fenix: true);
}
