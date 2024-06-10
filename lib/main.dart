import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lib_ads_flutter/ads_splash.dart';
import 'package:lib_ads_flutter/easy_ads.dart';
import 'package:lib_ads_flutter/screen2.dart';
import 'package:lib_ads_flutter/utils/easy_banner_ad.dart';
import 'package:lib_ads_flutter/utils/i_ad_id_manager.dart';
import 'package:lib_ads_flutter/utils/test_ad_id_manager.dart';

import 'enums/ad_network.dart';
import 'enums/ad_unit_type.dart';

const IAdIdManager adIdManager = TestAdIdManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyAds.instance.initialize(
    isShowAppOpenOnAppStateChange: true,
    adIdManager,
    unityTestMode: true,
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
    fbTestingId: '73f92d66-f8f6-4978-999f-b5e0dd62275a',
    fbTestMode: true,
    showAdBadge: Platform.isIOS,
    fbiOSAdvertiserTrackingEnabled: true,
  );
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
  StreamSubscription? _streamSubscription;

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AdsSplash.instance.init(true, true, "50_50");
    AdsSplash.instance.showAdsSplash(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  // bannerAdManager.loadCollapseBanner(context, AdsBannerType.collapsible_bottom, () {});
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _showAd(AdNetwork.admob, AdUnitType.appOpen);
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
                    ],
                  );
                },
              ),
            ),
          ),
          const EasyBannerAd(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showAd(AdNetwork adNetwork, AdUnitType adUnitType) {
    if (EasyAds.instance.showAd(
      adUnitType,
      adNetwork: adNetwork,
      context: context,
      loaderDuration: 1,
    )) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = EasyAds.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen();
        }
      });
    } else {
      goToNextScreen();
    }
  }

  void goToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Screen2(),
      ),
    );
  }
}
