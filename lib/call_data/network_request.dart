import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_ads_flutter/call_data/ads_model.dart';
import 'package:http/http.dart' as http;

class NetworkRequest{
  static List<AdsModel> parseAdsModel(String response){
    List<dynamic> list = json.decode(response);
    List<AdsModel> listAds = list.map((e) => AdsModel.fromJson(e)).toList();
    return listAds;
  }
  static Future<List<AdsModel>> fetchAdsModel() async{
    var url = Uri.parse('https://language-master.top/api/getidv2/ca-app-pub-4973559944609228~2346710863');
    var response = await http.get(url);
    if(response.statusCode == 200){
      Fluttertoast.showToast(msg: '200');
      print('body: ${response.body}');
      return compute(parseAdsModel, response.body);
    }else if(response.statusCode == 404){
      Fluttertoast.showToast(msg: '404');
      throw Exception('Not Found');
    }else{
      Fluttertoast.showToast(msg: 'no no');
      throw Exception('Can\'t get ads id');
    }
  }
}