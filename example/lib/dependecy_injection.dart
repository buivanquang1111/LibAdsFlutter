import 'package:example/screen/language/language.dart';
import 'package:example/utils/preferences_util.dart';
import 'package:get/get.dart';
import 'package:example/utils/connectivity.dart';

Future<void> init() async {
  await PreferencesUtil.init();

  final connectService = ConnectivityService();
  Get.put(connectService);

  final languageController = LanguageController();
  Get.lazyPut(() => languageController, fenix: true);
}
