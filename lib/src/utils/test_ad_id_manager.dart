import 'package:amazic_ads_flutter/admob_ads_flutter.dart';

class TestAdIdManager extends IAdIdManager {
  @override
  AppAdIds? get admobAdIds => const AppAdIds(appId: TestAdsId.admobAppId);
}
