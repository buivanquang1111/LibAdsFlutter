import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ad_method_channel.dart';

abstract class AdPlatform extends PlatformInterface {
  /// Constructs a EasyAd_2Platform.
  AdPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdPlatform _instance = MethodChannelAd();

  /// The default instance of [AdPlatform] to use.
  ///
  /// Defaults to [MethodChannelAd].
  static AdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdPlatform] when
  /// they register themselves.
  static set instance(AdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> getConsentResult() {
    throw UnimplementedError('consentResult() has not been implemented.');
  }

  Future<void> showLoadingAd(int color) {
    throw UnimplementedError('showLoadingInter() has not been implemented.');
  }

  Future<void> hideLoadingAd() {
    throw UnimplementedError('showLoadingInter() has not been implemented.');
  }
}
