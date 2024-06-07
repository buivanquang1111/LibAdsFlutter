import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/call_back/inter_ad_callback.dart';
import 'package:lib_ads_flutter/banner/banner_ad_manager.dart';
import 'package:lib_ads_flutter/enums/ads_banner_type.dart';
import 'package:lib_ads_flutter/interstitial/interstitial_ad_manager.dart';
import 'package:lib_ads_flutter/native/native_ad_manager.dart';
import 'package:lib_ads_flutter/view_ads/banner_ad_view.dart';

import 'app_open/app_lifecycle_reactor.dart';
import 'app_open/app_open_ad_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late AppLifecycleReactor _appLifecycleReactor;
  // late BannerAdManager bannerAdManager = BannerAdManager();
  late InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  late NativeAdManager nativeAdManager = NativeAdManager();
  final double _adAspectRatioMedium = (370 / 355);

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAppOpenAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges(context);

    interstitialAdManager.loadAd();
    nativeAdManager.loadAd();
  }

  // void removeCollapse() async{
  //   await bannerAdManager.bannerAd!.dispose();
  //   bannerAdManager.isloaded = false;
  //   // bannerAdManager.loadCollapseBanner(context, AdsBannerType.collapsible_bottom, () {
  //   //   Fluttertoast.showToast(msg: "ok re load");
  //   //   setState(() {
  //   //
  //   //   });
  //   // });
  //   setState(() {
  //     bannerAdManager.loadCollapseBanner(context, AdsBannerType.collapsible_bottom, (){
  //
  //     });
  //   });
  // }

  // void init(){
  //   if(bannerAdManager.bannerAd != null){
  //     bannerAdManager.bannerAd!.dispose();
  //     bannerAdManager.bannerAd = null;
  //   }
  //   setState(() {
  //     bannerAdManager.loadAd(context, () {
  //       setState(() {
  //
  //       });
  //     },);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            // bannerAdManager.loadCollapseBanner(context, AdsBannerType.collapsible_bottom, () {});
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // removeCollapse();

                    // interstitialAdManager.show(
                    //     context,
                    //     2,
                    //     AdCallback()
                    //       ..onAdLoaded = () {
                    //         Fluttertoast.showToast(
                    //             msg: 'Ad successfully loaded!');
                    //       }
                    //       ..onAdFailedToLoad = (LoadAdError error) {
                    //         Fluttertoast.showToast(
                    //             msg: 'Failed to load ad: ${error.message}');
                    //       }
                    //       ..onAdImpression = () {
                    //         Fluttertoast.showToast(
                    //             msg: 'Ad impression recorded.');
                    //       }
                    //       ..onAdFailedToShow = (AdError error) {
                    //         Fluttertoast.showToast(
                    //             msg: 'Failed to show ad: ${error.message}');
                    //       }
                    //       ..onAdClosed = () {
                    //         Fluttertoast.showToast(
                    //             msg: 'Ad closed by the user.');
                    //       }
                    //       ..onAdClicked = () {
                    //         Fluttertoast.showToast(
                    //             msg: 'Ad clicked by the user.');
                    //       });
                  },
                  child: Text('show inter'),
                ),
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (nativeAdManager.nativeAdIsLoaded)
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width *
                          _adAspectRatioMedium,
                      child: AdWidget(
                        ad: nativeAdManager.nativeAd!,
                      ),
                    ),
                  ),
                BannerAdView(idAds: 'ca-app-pub-3940256099942544/6300978111'),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
