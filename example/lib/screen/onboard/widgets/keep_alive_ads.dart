// import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:example/config/global_colors.dart';
// import 'package:example/main.dart';
// import 'package:example/screen/splash/splash.dart';
//
// class KeepAliveAds extends StatefulWidget {
//   const KeepAliveAds({super.key});
//
//   @override
//   State<KeepAliveAds> createState() => _KeepAliveAdsState();
// }
//
// class _KeepAliveAdsState extends State<KeepAliveAds>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     if (introAdCtrl != null) {
//       print("introAdCtrl != null");
//       return EasyPreloadNativeAd(
//         key: UniqueKey(),
//         controller: introAdCtrl!,
//         factoryId: adIdManager.nativeIntroFactory,
//         height: adIdManager.smallNativeAdHeight,
//         color: GlobalColors.lightGray,
//         onAdShowed: (adNetwork, adUnitType, data) {},
//         onPaidEvent: ({
//           required adNetwork,
//           required adUnitType,
//           required currencyCode,
//           network,
//           placement,
//           required revenue,
//           unit,
//         }) {},
//       );
//     } else {
//       return const SizedBox();
//     }
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
