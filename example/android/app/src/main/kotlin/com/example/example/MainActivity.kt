package com.example.example

import android.os.Bundle
import com.applovin.sdk.AppLovinPrivacySettings
import com.unity3d.ads.metadata.MetaData
import com.vungle.ads.VunglePrivacySettings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import org.json.JSONException
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(),
            "channel"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "init_mediation" -> {
                    val canRequestAds = call.arguments as Boolean
                    initMediation(canRequestAds)
                    result.success(true)
                }

                // "flavor" -> result.success(BuildConfig.FLAVOR)
            }
        }

        MethodChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(),
            "main_channel"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "init_mediation" -> {
                    val canRequestAds = call.arguments as Boolean
                    initMediation(canRequestAds)
                    result.success(true)
                }

                // "flavor" -> result.success(BuildConfig.FLAVOR)
            }
        }

        initAdFactory(flutterEngine)
    }

    private fun initMediation(canRequestAds: Boolean) {
        VunglePrivacySettings.setGDPRStatus(canRequestAds, null)
        AppLovinPrivacySettings.setHasUserConsent(canRequestAds, this)
        val gdprMetaData: MetaData = MetaData(this)
        gdprMetaData.set("gdpr.consent", canRequestAds)
        gdprMetaData.commit()
        val consentObject = JSONObject()
        try {
            consentObject.put("gdpr", if (canRequestAds) "1" else "0")
        } catch (exception: JSONException) {
            exception.printStackTrace()
        }
    }

    private fun initAdFactory(flutterEngine: FlutterEngine) {
        /// native_language
        val languageAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_language",
            languageAdFactory
        )

        /// native_intro
        val introAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_intro",
            introAdFactory
        )

        /// native_loading
        val loadingDataAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_loanding",
            loadingDataAdFactory
        )

        /// native_home
        val homeAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdRight(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_home",
            homeAdFactory
        )

        /// native_additional_tools
        val additionalAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdRight(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_additional_tools",
            additionalAdFactory
        )

        /// native_compare
        val compareAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_compare",
            compareAdFactory
        )

        /// native_personal
        val personalAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_personal",
            personalAdFactory
        )

        /// native_business
        val businessAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_business",
            businessAdFactory
        )

        /// native_auto
        val autoAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_auto",
            autoAdFactory
        )


        /// native-fd
        val fdAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_fd",
            fdAdFactory
        )

        /// native-rd
        val rdAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_rd",
            rdAdFactory
        )

        /// native_exrate
        val exrateAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_exrate",
            exrateAdFactory
        )

        /// native_length
        val lengthAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_length",
            lengthAdFactory
        )

        /// native_mass
        val massAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_mass",
            massAdFactory
        )

        /// native_speed
        val speedAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_speed",
            speedAdFactory
        )

        /// native_tem
        val temAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = SmallNativeAdDown(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_tem",
            temAdFactory
        )

        /// native_results_personal
        val resultAdFactory: GoogleMobileAdsPlugin.NativeAdFactory = LargeNativeAdUp(
            getLayoutInflater()
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_results",
            resultAdFactory
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_language"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_intro"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_loanding"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_home"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_additional_tools"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_compare"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_personal"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_business"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_fd"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_rd"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_exrate"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_length"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_mass"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_speed"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_tem"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "native_results"
        )
    }
}
