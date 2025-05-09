import 'package:flutter/services.dart';

class InternetChannel {
  static const internetChannel = MethodChannel('internet_channel');

  static Future<bool> isNetworkActive() async {
    try {
      final result = await internetChannel.invokeMethod('isNetworkActive');
      return result;
    } on PlatformException catch (e) {
      print("Error checking network: $e");
      return false;
    }
  }
}
