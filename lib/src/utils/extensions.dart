import '../../admob_ads_flutter.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

extension AdBaseListExtension on List<AdsBase> {
  bool doesNotContain(AdNetwork adNetwork, AdUnitType type) =>
      indexWhere((e) => e.adNetwork == adNetwork && e.adUnitType == type) == -1;
}
