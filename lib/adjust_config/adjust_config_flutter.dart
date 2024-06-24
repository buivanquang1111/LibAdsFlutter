import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:amazic_ads_flutter/src/utils/ad_event.dart';

class AdjustConfigFlutter{
  AdjustConfigFlutter._instance();
  static final AdjustConfigFlutter instance = AdjustConfigFlutter._instance();

  void setupAdjust({required String adjustToken}){
    // AdjustConfig config = AdjustConfig(adjustToken, isDebug == true ?  AdjustEnvironment.sandbox : AdjustEnvironment.production);
    AdjustConfig config = AdjustConfig(adjustToken, AdjustEnvironment.production);
    config.logLevel = AdjustLogLevel.verbose;
    config.defaultTracker = adjustToken;
    Adjust.start(config);
  }

  void trackRevenue(AdEvent event) {
    final Map<String, dynamic>? data = event.data as Map<String, dynamic>?;

    final num? revenue = data?['revenue'];
    final String? currencyCode = data?['currencyCode'];
    final String? network = data?['network'];
    final String? unit = data?['unit'];
    final String? placement = data?['placement'];

    if (revenue != null && currencyCode != null) {
      AdjustAdRevenue adRevenue;
      switch (event.adNetwork) {
        default:
          adRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAdMob);
          break;
      }
      adRevenue.setRevenue(revenue, currencyCode);
      adRevenue.adRevenueNetwork = network;
      adRevenue.adRevenueUnit = unit;
      adRevenue.adRevenuePlacement = placement;
      Adjust.trackAdRevenueNew(adRevenue);
      // final adjustEvent = AdjustEvent("f5l43s");
      // adjustEvent.setRevenue(revenue, currencyCode);
      // Adjust.trackEvent(adjustEvent);
    }
  }

}