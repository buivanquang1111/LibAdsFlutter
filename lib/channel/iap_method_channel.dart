import 'package:flutter/services.dart';

class IapMethodChannel{
  static IapMethodChannel? _instance;
  static IapMethodChannel instance(){
    return _instance ??= IapMethodChannel();
  }

  static const platform = MethodChannel('channel_iap');

  Future<void> initBilling(List<String> productIds) async {
    await platform.invokeMethod('initBilling', {'productIds': productIds});
  }

  void setUpListener({required Function() onAction}) {
    platform.setMethodCallHandler(
          (call) async {
        if (call.method == 'onNextAction') {
          print('check_method: flutter --- load gì đó ở đây ${call.arguments}');
          onAction();
        }
      },
    );
  }

  Future<bool> isPurchase() async{
    try{
      final isPurchase = await platform.invokeMethod('isPurchase');
      return isPurchase;
    }catch(e){
      print("failed: $e");
      return false;
    }
  }

  Future<String?> getSalePrice(String idSub) async {
    try {
      final priceSub = await platform.invokeMethod('getSalePrice', idSub);
      print('check_method: getSalePrice $idSub -- $priceSub');
      return priceSub;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<String?> getOriginalPrice(
      {required String idSub, required int percentSale}) async {
    try {
      print('check_method: percentSale: $percentSale');
      final originalPrice = await platform.invokeMethod(
          'getOriginalPrice', {'idSub': idSub, 'percentSale': percentSale});
      return originalPrice;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<String?> getPricePerWeek({required String idSub, required int numberWeek}) async{
    try {
      final pricePerWeek = await platform.invokeMethod(
          'getPricePerWeek', {'idSub': idSub, 'numberWeek': numberWeek});
      return pricePerWeek;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<String?> getPrice(String idSub) async {
    try {
      final price = await platform.invokeMethod('getPrice', idSub);
      print('check_method: getPrice $idSub -- $price');
      return price;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<String?> getCurrency(String idSub) async {
    try {
      final currency = await platform.invokeMethod('getCurrency', idSub);
      print('check_method: getCurrency $idSub -- $currency');
      return currency;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<double?> getPriceWithoutCurrency(String idSub) async {
    try {
      final priceWithoutCurrency =
      await platform.invokeMethod('getPriceWithoutCurrency', idSub);
      print(
          'check_method: getPriceWithoutCurrency $idSub -- $priceWithoutCurrency');
      return priceWithoutCurrency;
    } catch (e) {
      print("failed: $e");
      return null;
    }
  }

  Future<void> initPurchase() async{
    await platform.invokeMethod('purchaseListener');
  }

  Future<void> setPurchaseListener({required Function() onSuccessfulPurchase}) async {

    platform.setMethodCallHandler(
          (call) async {
        if (call.method == 'onSuccessfulPurchase') {
          print('check_method: xử lí sau khi mua thành công');
          onSuccessfulPurchase();
        }
      },
    );
  }

  Future<void> buySubscribe({required String idSub}) async{
    await platform.invokeMethod('buySubscribe', idSub);
  }
}