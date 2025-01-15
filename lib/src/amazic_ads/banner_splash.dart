import 'dart:io';

import 'package:amazic_ads_flutter/adjust_config/call_organic_adjust.dart';
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../utils/detect_test_ad.dart';

class BannerSplash extends StatefulWidget {
  final List<String> listIdAds;
  final bool remoteConfig;
  final String visibilityDetectorKey;
  final Function()? onNext;
  final Function()? onTestAdSuccess;
  final Function(String)? onTestAdError;
  final String bearToken;
  final String appToken;
  final bool isDetectTestAd;

  const BannerSplash(
      {super.key,
      required this.listIdAds,
      required this.remoteConfig,
      required this.visibilityDetectorKey,
      this.onNext,
      this.onTestAdSuccess,
      this.onTestAdError,
      this.bearToken = 'mpBYiG4WNndUpojp7pez',
      this.appToken = '',
      this.isDetectTestAd = false});

  @override
  State<BannerSplash> createState() => _BannerSplashState();
}

class _BannerSplashState extends State<BannerSplash> {
  ScreenshotController screenshotController = ScreenshotController();
  bool checkAdsShow = false;
  GlobalKey adWidgetKey = GlobalKey();

  void detectTestAd(double pixelRatio) {
    // if (!DetectTestAd.instance.isTestAd()) {
    //   print('check_detect_test_ad --- 1');
      screenshotController
          .capture(
              pixelRatio: pixelRatio, delay: const Duration(milliseconds: 10))
          .then((capturedImage) async {
        if (capturedImage != null) {
          final directory = await getApplicationDocumentsDirectory();
          String fileName =
              'banner_ads_splash_${DateTime.now().microsecondsSinceEpoch}';
          final imageFile =
              await File('${directory.path}/$fileName.png').create();
          await imageFile.writeAsBytes(capturedImage);
          // print('check_detect_test_ad --- 1. $fileName');
          DetectTestAd.instance.detectImageToText(
            imageFile: imageFile,
            onSuccess: () {
              print('check_detect_test_ad --- true');
              if (widget.onTestAdSuccess != null && widget.onNext != null) {
                widget.onTestAdSuccess!();
                widget.onNext!();
              }
            },
            onError: (p0) {
              print('check_detect_test_ad --- false $p0');
              if (widget.onTestAdError != null && widget.onNext != null) {
                widget.onTestAdError!(p0);
                widget.onNext!();
              }
            },
          );
        }
      }).catchError((e) {
        print('check_detect_test_ad --- error $e');
        if (widget.onTestAdError != null && widget.onNext != null) {
          widget.onTestAdError!(e.toString());
          widget.onNext!();
        }
      });
    // } else {
    //   print('check_detect_test_ad --- 2');
    //   if (widget.onTestAdSuccess != null && widget.onNext != null) {
    //     print('check_detect_test_ad --- 2.1');
    //     widget.onTestAdSuccess!();
    //     widget.onNext!();
    //   }
    // }
  }

  // void callOrganicAdjust() {
  //   print('Banner_Splash: Use call Organic Adjust');
  //   if (!CallOrganicAdjust.instance.isOrganic()) {
  //     CallOrganicAdjust.instance.getAdvertisingId().then(
  //       (value) {
  //         print('advertisingId: $value');
  //         if (value != null) {
  //           CallOrganicAdjust.instance
  //               .getOrganic(
  //                   bearerToken: widget.bearToken,
  //                   appToken: widget.appToken,
  //                   advertisingId: value)
  //               .then(
  //             (value) {
  //               if (value) {
  //                 if (widget.onTestAdSuccess != null && widget.onNext != null) {
  //                   widget.onTestAdSuccess!();
  //                   widget.onNext!();
  //                 }
  //               } else {
  //                 if (widget.onTestAdError != null && widget.onNext != null) {
  //                   widget.onTestAdError!('not organic');
  //                   widget.onNext!();
  //                 }
  //               }
  //             },
  //           );
  //         } else {
  //           if (widget.onTestAdError != null && widget.onNext != null) {
  //             widget.onTestAdError!('can not get advertisingId');
  //             widget.onNext!();
  //           }
  //         }
  //       },
  //     );
  //   } else {
  //     if (widget.onTestAdSuccess != null && widget.onNext != null) {
  //       widget.onTestAdSuccess!();
  //       widget.onNext!();
  //     }
  //   }
  // }

  void logAdContentInWidget(GlobalKey adWidgetKey) {
    final context = adWidgetKey.currentContext;
    if (context != null) {
      // Lấy các widget con của widget cha
      context.visitChildElements((element) {
        final widget = element.widget;

        // Kiểm tra nếu widget là Text
        if (widget is Text) {
          print("log_banner --- Found Ad Content Text: ${widget.data}");
        }

        // Kiểm tra nếu widget là Image
        else if (widget is Image) {
          print("log_banner --- Found Ad Content Image: ${widget.image}");
        }

        // Kiểm tra nếu widget là bất kỳ widget nào khác (có thể là phần tử trong quảng cáo)
        else {
          print("log_banner --- Other Widget detected: $widget");
        }
      });
    } else {
      print("log_banner --- No context found for the provided key.");
    }
  }


  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Screenshot(
      controller: screenshotController,
      child: BannerAds(
        key: adWidgetKey,
        onSplashScreen: true,
        type: AdsBannerType.adaptive,
        listId: widget.listIdAds,
        config: widget.remoteConfig,
        visibilityDetectorKey: widget.visibilityDetectorKey,
        onAdLoaded: (adNetwork, adUnitType, data) {

        },
        onAdDisabled: (adNetwork, adUnitType, data) {
          if (widget.onNext != null) {
            widget.onNext!();
          }
        },
        onAdDismissed: (adNetwork, adUnitType, data) {
          if (widget.onNext != null) {
            widget.onNext!();
          }
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          if (widget.onNext != null) {
            widget.onNext!();
          }
        },
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          if (widget.onNext != null) {
            widget.onNext!();
          }
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          // if (!checkAdsShow) {
          //   if (widget.onNext != null) {
          //     checkAdsShow = true;
          //     widget.onNext!();
          //   }
          // }
          print('check_detect_test_ad --- onAdShowed');
          if (widget.isDetectTestAd == true) {
            detectTestAd(pixelRatio);
          }
        },
        onAdImpression: (adNetwork, adUnitType, data) {
          // logAdContentInWidget(adWidgetKey);
        },
      ),
    );
  }
}
