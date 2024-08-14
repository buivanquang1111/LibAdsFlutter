import 'dart:io';

import 'package:amazic_ads_flutter/adjust_config/call_organic_adjust.dart';
import 'package:amazic_ads_flutter/admob_ads_flutter.dart';
import 'package:amazic_ads_flutter/src/utils/detect_test_ad.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class BannerSplash extends StatefulWidget {
  final List<String> listIdAds;
  final bool remoteConfig;
  final String visibilityDetectorKey;
  final Function() onNext;
  final Function() onTestAdSuccess;
  final Function(String) onTestAdError;
  final bool
      isDetectOrOrganic; //true - use Detect Test Ad, false - use Adjust Organic

  const BannerSplash(
      {super.key,
      required this.listIdAds,
      required this.remoteConfig,
      required this.visibilityDetectorKey,
      required this.onNext,
      required this.onTestAdSuccess,
      required this.onTestAdError,
      this.isDetectOrOrganic = true});

  @override
  State<BannerSplash> createState() => _BannerSplashState();
}

class _BannerSplashState extends State<BannerSplash> {
  ScreenshotController screenshotController = ScreenshotController();

  void detectTestAd(double pixelRatio) {
    print('Banner_Splash: Use Detect Test Ad');
    if (!DetectTestAd.instance.isTestAd()) {
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

          DetectTestAd.instance.detectImageToText(
            imageFile: imageFile,
            onSuccess: () {
              widget.onTestAdSuccess();
              widget.onNext();
            },
            onError: (p0) {
              widget.onTestAdError(p0);
              widget.onNext();
            },
          );
        }
      }).catchError((onError) {
        widget.onTestAdError(onError.toString());
        widget.onNext();
      });
    } else {
      widget.onTestAdSuccess();
      widget.onNext();
    }
  }

  void callOrganicAdjust() {
    print('Banner_Splash: Use call Organic Adjust');
    if (!CallOrganicAdjust.instance.isTestAd()) {
      CallOrganicAdjust.instance.getAdvertisingId().then(
        (value) {
          print('advertisingId: $value');
          if (value != null) {
            CallOrganicAdjust.instance
                .getOrganic(
                    bearerToken: 'mpBYiG4WNndUpojp7pez',
                    appToken: 'xz7hat0yjchs',
                    advertisingId: value)
                .then(
              (value) {
                if (value) {
                  widget.onTestAdSuccess();
                  widget.onNext();
                } else {
                  widget.onTestAdError('not organic');
                  widget.onNext();
                }
              },
            );
          } else {
            widget.onTestAdError('can not get advertisingId');
            widget.onNext();
          }
        },
      );
    } else {
      widget.onTestAdSuccess();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Screenshot(
      controller: screenshotController,
      child: BannerAds(
        onSplashScreen: true,
        type: AdsBannerType.adaptive,
        listId: widget.listIdAds,
        config: widget.remoteConfig,
        visibilityDetectorKey: widget.visibilityDetectorKey,
        onAdDismissed: (adNetwork, adUnitType, data) {
          widget.onNext();
        },
        onAdFailedToLoad: (adNetwork, adUnitType, data, errorMessage) {
          widget.onNext();
        },
        onAdFailedToShow: (adNetwork, adUnitType, data, errorMessage) {
          widget.onNext();
        },
        onAdShowed: (adNetwork, adUnitType, data) {
          widget.isDetectOrOrganic
              ? detectTestAd(pixelRatio)
              : callOrganicAdjust();
        },
      ),
    );
  }
}
