
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:get/get.dart';

class ConnectivityService extends SuperController implements GetxService {
  final isDeviceOffLine = false.obs;

  @override
  void onInit() {
    EasyAds.instance
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
    EasyAds.instance
        .isDeviceOffline()
        .then((value) => isDeviceOffLine.value = value);
  }

  @override
  void onResumed() {
    EasyAds.instance
        .isDeviceOffline()
        .then((value) => isDeviceOffLine.value = value);
  }
}
