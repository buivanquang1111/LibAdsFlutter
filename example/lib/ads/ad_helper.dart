import 'dart:io';
import 'dart:math';

enum AdSplashType { inter, open, none }

class AdHelper {
  static int lastTimeShowInter = -1;
  static int timeStartApp = -1;
  static bool isConnectInternet = false;

  static Future<void> init() async {
    lastTimeShowInter = -1;
    timeStartApp = DateTime.now().millisecondsSinceEpoch;
    try {
      final result = await InternetAddress.lookup('https://www.google.com/');
      if (result.isNotEmpty) {
        isConnectInternet = true;
      } else {
        isConnectInternet = false;
      }
    } on SocketException catch (_) {}
  }
}
