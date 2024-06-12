
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:get/get.dart';

class ConnectivityService extends SuperController implements GetxService {
  final isDeviceOffLine = false.obs;

  @override
  void onInit() {
    AdmobAds.instance
        .isDeviceOffline()
        .then((value) => isDeviceOffLine.value = value);
    super.onInit();
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    AdmobAds.instance
        .isDeviceOffline()
        .then((value) => isDeviceOffLine.value = value);
  }

  @override
  void onResumed() {
    AdmobAds.instance
        .isDeviceOffline()
        .then((value) => isDeviceOffLine.value = value);
  }
}
