import 'package:flutter/services.dart';

class InternetChannel{
  static const internetChannel = MethodChannel('internet_channel');

  static Future<bool> isNetworkActive() async {
    final result = await internetChannel.invokeMethod('isNetworkActive');
    return result as bool;
  }

}