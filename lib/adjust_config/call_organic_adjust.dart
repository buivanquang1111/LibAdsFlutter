import 'dart:convert';
import 'dart:io';
import 'package:advertising_id/advertising_id.dart';
import 'package:http/http.dart';

import '../src/utils/preferences_util.dart';

class CallOrganicAdjust {
  var trackerName = "Organic";

  CallOrganicAdjust._instance();

  static final CallOrganicAdjust instance = CallOrganicAdjust._instance();

  bool isOrganic() {
    return PreferencesUtilLib.isOrganicAdjust();
  }

  Future<void> initOrganicAdjust(
      {required Function() onOrganic,
      required Function(String) onError,
      required Function() onNextAction,
      required String appToken,
      String bearToken = 'mpBYiG4WNndUpojp7pez'}) async {
    if (!CallOrganicAdjust.instance.isOrganic()) {
      CallOrganicAdjust.instance.getAdvertisingId().then(
        (value) {
          print('advertisingId: $value');
          if (value != null) {
            CallOrganicAdjust.instance
                .getOrganic(
                    bearerToken: bearToken,
                    appToken: appToken,
                    advertisingId: value)
                .then(
              (value) {
                if (value) {
                  onOrganic();
                  onNextAction();
                } else {
                  onError('not organic');
                  onNextAction();
                }
              },
            );
          } else {
            onError('can not get advertisingId');
            onNextAction();
          }
        },
      );
    } else {
      onOrganic();
      onNextAction();
    }
  }

  Future<bool> getOrganic(
      {required String bearerToken,
      required String appToken,
      required String advertisingId}) async {
    try {
      final res = await get(
          Uri.parse(
              'https://api.adjust.com/device_service/api/v2/inspect_device?advertising_id=$advertisingId&app_token=$appToken'),
          headers: {HttpHeaders.authorizationHeader: "Bearer $bearerToken"});

      final data = jsonDecode(utf8.decode(res.bodyBytes));

      print('adjustJson: $data');
      print('adjustJson: TrackerName - ${data['TrackerName']}');

      if (trackerName.toLowerCase() ==
          data['TrackerName'].toString().toLowerCase()) {
        // PreferencesUtilLib.setTestAd();
        PreferencesUtilLib.setOrganicAdjust();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAdvertisingId() async {
    String? advertisingId;
    try {
      advertisingId = await AdvertisingId.id(true);
    } catch (e) {
      advertisingId = null;
    }
    return advertisingId;
  }
}
