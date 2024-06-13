import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ads_model.dart';

class NetworkRequest{
  NetworkRequest._instance();
  static final NetworkRequest instance = NetworkRequest._instance();

  LinkedHashMap<String, List<String>> listAdsId = LinkedHashMap<String, List<String>>();

  List<AdsModel> parseAdsModel(String response){
    List<dynamic> list = json.decode(response);
    List<AdsModel> listAds = list.map((e) => AdsModel.fromJson(e)).toList();
    return listAds;
  }
  void fetchAdsModel(String linkServer, String appId, String? packageName, Function() onResponse, Function onError) async{
    /// https://language-master.top/api/getidv2/ca-app-pub-4973559944609228~2346710863+com.example.lib
    var url = Uri.parse('$linkServer/api/getidv2/$appId+$packageName');
    var response = await http.get(url);
    if(response.statusCode == 200){
      print('body: ${response.body}');
      List<AdsModel> listAds = await compute(parseAdsModel, response.body);
      
      for(final model in listAds){
        if(model.name != null){
          // Khởi tạo danh sách nếu chưa tồn tại
          listAdsId.putIfAbsent(model.name!, () => []);

          if (model.adsId != null) {
            listAdsId[model.name!]!.add(model.adsId!);
          }
        }
      }
      
      onResponse.call();
    }else if(response.statusCode == 404){
      onError.call();
      throw Exception('Not Found');
    }else{
      onError.call();
      throw Exception('Can\'t get ads id');
    }
  }

  List<String> getListIDByName(String nameAds){
    List<String> listId = [];
    if(listAdsId[nameAds] != null){
      listId.addAll(listAdsId[nameAds]!);
    }
    return listId;
  }

}