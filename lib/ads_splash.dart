import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_ads_flutter/easy_ads.dart';
import 'package:lib_ads_flutter/enums/ad_network.dart';
import 'package:lib_ads_flutter/enums/ad_unit_type.dart';

enum STATE { INTER, OPEN, NO_ADS }

class AdsSplash {
  AdsSplash._adsSplash();

  static final AdsSplash instance = AdsSplash._adsSplash();

  STATE _state = STATE.NO_ADS;

  void init(bool showInter, bool showOpen, String rate) {
    Fluttertoast.showToast(msg: 'init');
    if (showInter & showOpen) {
      _checkShowInterOrOpen(rate);
      Fluttertoast.showToast(msg: '_checkShowInterOrOpen');
    } else if (showInter) {
      setState(STATE.INTER);
      Fluttertoast.showToast(msg: 'INTER');
    } else if (showOpen) {
      setState(STATE.OPEN);
      Fluttertoast.showToast(msg: 'OPEN');
    } else {
      setState(STATE.NO_ADS);
      Fluttertoast.showToast(msg: 'NO_ADS');
    }
  }

  Future<STATE> getState() async {
    return _state;
  }

  void setState(STATE state) {
    _state = state;
  }

  void _checkShowInterOrOpen(String rate) {
    final int rateInter;
    final int rateOpen;

    rateOpen = int.tryParse(rate.split('_')[0].trim()) ?? 70;
    rateInter = int.tryParse(rate.split('_')[1].trim()) ?? 30;

    if (rateOpen >= 0 && rateInter >= 0 && rateOpen + rateInter == 100) {
      bool isShowOpenSplash = Random().nextInt(100) + 1 < rateOpen;
      setState(isShowOpenSplash ? STATE.OPEN : STATE.INTER);
    } else {
      setState(STATE.NO_ADS);
    }
  }

  void showAdsSplash(BuildContext context) async{
    Fluttertoast.showToast(msg: 'showAdsSplash ${getState()}');
    if (await getState() == STATE.OPEN) {
      Fluttertoast.showToast(msg: 'OPEN');
      _showAd(context, AdNetwork.admob, AdUnitType.appOpen);
    } else if (await getState() == STATE.INTER) {
      Fluttertoast.showToast(msg: 'INTER');
      _showAd(context, AdNetwork.admob, AdUnitType.interstitial);
    } else {

    }
  }

  void _showAd(BuildContext context,AdNetwork adNetwork, AdUnitType adUnitType) {
    if (EasyAds.instance.showAd(
      adUnitType,
      adNetwork: adNetwork,
      context: context,
      loaderDuration: 1,
    )) {
      // Canceling the last callback subscribed
      Fluttertoast.showToast(msg: ' oke');
    } else {
      Fluttertoast.showToast(msg: ' no no');
    }
  }
}
