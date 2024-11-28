import 'package:firebase_analytics/firebase_analytics.dart';

class EventLog {
  static final FirebaseAnalytics _log = FirebaseAnalytics.instance;

  static void logEvent(String name, {Map<String, Object>? parameters}) {
    _log.logEvent(name: name, parameters: parameters);
  }
}
