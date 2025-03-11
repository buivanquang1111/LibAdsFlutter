import 'dart:async';
import 'dart:io';
import 'package:amazic_ads_flutter/in_app_purchase/premium_type.dart';
import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class MyInAppPurchase {
  static MyInAppPurchase? _instance;

  late final StreamSubscription<List<PurchaseDetails>> subscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  // final Set<String> _kIds = PremiumType.values.map((e) => e.productID).toSet();
  late final Set<String> _kIds;

  final List<ProductDetails> products = <ProductDetails>[];

  static MyInAppPurchase getInstance() {
    return _instance ??= MyInAppPurchase();
  }

  void initBilling(List<PremiumType> listId) async {
    await setListPremiumID(listId);
    await fetchProducts();
    completePendingPurchase();
  }

  Future<void> setListPremiumID(List<PremiumType> listId) async{
    _kIds = listId.map((e) => e.productID,).toSet();
  }

  void completePendingPurchase() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen(
        (List<PurchaseDetails> purchaseDetailsList) async {
      await _listenToPurchaseUpdated(purchaseDetailsList);
      // cancel subscription
      subscription.cancel();
    }, onDone: () {
      subscription.cancel();
    }, onError: (Object error) {
      // handle error here
      print('premium_screen---error: $error');
    });
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (!(purchaseDetails.status == PurchaseStatus.pending) &&
          purchaseDetails.pendingCompletePurchase) {
        print('premium_screen---pendingCompletePurchase');
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  Future<void> fetchProducts() async {
    if (!(await isAvailable())) {
      return;
    }
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      response.notFoundIDs.forEach((element) {
        print('my_in_app_purchase---notFoundIDs: $element');
      });
    }
    products.clear();
    products.addAll(response.productDetails);
  }

  ProductDetails? getProductById(String id) {
    return products.firstWhereOrNull((element) => element.id == id);
  }

  Future<void> clearTransactionsIos() async {
    if (Platform.isIOS) {
      var transactions = await SKPaymentQueueWrapper().transactions();
      for (var skPaymentTransactionWrapper in transactions) {
        print(
            'my_in_app_purchase---skPaymentTransactionWrapper: ${skPaymentTransactionWrapper.transactionIdentifier}');
        await SKPaymentQueueWrapper()
            .finishTransaction(skPaymentTransactionWrapper);
      }
    }
  }

  void buyProduct(ProductDetails productDetails) async {
    await clearTransactionsIos();
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _inAppPurchase
        .buyNonConsumable(purchaseParam: purchaseParam)
        .catchError((error) {
      print('my_in_app_purchase---error: $error');
      // Fluttertoast.showToast(
      //     msg: "Please try again later.", toastLength: Toast.LENGTH_SHORT);
    });
  }

  void restorePurchase() {
    _inAppPurchase.restorePurchases();
  }
}
