import 'package:example/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:example/ads/ad_helper.dart';
import 'package:example/ads/app_ad_id_manager.dart';
import 'package:example/dependecy_injection.dart' as dependecy_injection;
import 'package:example/utils/preferences_util.dart';

AppAdIdManager adIdManager = AppAdIdManager();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // AdjustConfig config = AdjustConfig(
  //     'mdud78xjmtxc',
  //     appFlavor == "prod"
  //         ? AdjustEnvironment.production
  //         : AdjustEnvironment.sandbox);
  // Adjust.start(config);
  _hideSystemUI();
  initCrashlytics();
  AdHelper.init();

  await dependecy_injection.init();
  runApp(const App());
}

void initCrashlytics() {
  // if (kDebugMode) {
  //   FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // } else {
  //   FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // }
}

void _hideSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
    ),
  );

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    if (systemOverlaysAreVisible) {
      await Future.delayed(const Duration(seconds: 3));
      SystemChrome.restoreSystemUIOverlays();
    }
  });
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  Get.updateLocale(Locale(PreferencesUtil.getLanguage()));
}