import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/app_open/app_open_ad_manager.dart';

class AppLifecycleReactor{
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges(BuildContext context){
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) {
      _onAppStateChanged(state, context);
    });
  }

  void _onAppStateChanged(AppState appState, BuildContext context){
    if(appState == AppState.foreground){
      appOpenAdManager.showAdIfAvailable(context);
    }
  }
}