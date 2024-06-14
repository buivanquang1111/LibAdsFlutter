import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';

class AdjustConfigFlutter{
  AdjustConfigFlutter._instance();
  static final AdjustConfigFlutter instance = AdjustConfigFlutter._instance();

  void setupAdjust({required String adjustToken, bool? isDebug = true }){
    AdjustConfig config = AdjustConfig(adjustToken, isDebug == true ?  AdjustEnvironment.sandbox : AdjustEnvironment.production);
    config.logLevel = AdjustLogLevel.verbose;
    config.defaultTracker = adjustToken;
    Adjust.start(config);
  }
}