package com.amazic.ad;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.PixelFormat;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.amazic.ad.ads.AdsPlatformViewFactory;
import com.amazic.ad.ui.FullscreenLoadingDialog;

import io.flutter.FlutterInjector;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;

import android.text.SpannableString;
import android.util.Log;

import com.amazic.ad.iap.BillingCallback;
import com.amazic.ad.iap.IAPManager;
import com.amazic.ad.iap.ProductDetailCustom;
import com.amazic.ad.iap.PurchaseCallback;
import com.amazic.ad.utils.NetworkUtil;

import java.util.ArrayList;
import java.util.List;

import java.util.Objects;

/**
 * EasyAd_2Plugin
 */
public class AmazicPlugin
        implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private MethodChannel channel;
    public static MethodChannel loadingChannel;
    private Context context;
    private Activity mActivity;

    static final String TAG = "AmazicPlugin";

    private static final String CHANNEL_IAP = "channel_iap";
    private MethodChannel methodChannel;
    private IAPManager iapManager;

    @Override
    public void onAttachedToEngine(
            @NonNull FlutterPluginBinding flutterPluginBinding
    ) {
        Log.d(TAG, "onDetachedFromEngine");
        if (channel == null) {
            channel =
                    new MethodChannel(
                            flutterPluginBinding.getBinaryMessenger(),
                            "easy_ads_flutter"
                    );
            channel.setMethodCallHandler(this);
        }

        this.context = flutterPluginBinding.getApplicationContext();

        if (loadingChannel == null) {
            loadingChannel =
                    new MethodChannel(
                            flutterPluginBinding.getBinaryMessenger(),
                            "loadingChannel"
                    );
        }

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_IAP);
        methodChannel.setMethodCallHandler(this);
        iapManager = new IAPManager();

        // Đăng ký Native View
        MethodChannel methodChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                "com.yourcompany.ads/banner"
        );
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        "com.yourcompany.ads/banner",
                        new AdsPlatformViewFactory(flutterPluginBinding.getApplicationContext(), methodChannel)
                );

        //check internet
        MethodChannel internetChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                "internet_channel"
        );

        internetChannel.setMethodCallHandler(this);

    }

    @Override
    public void onMethodCall(
            @NonNull MethodCall call,
            @NonNull MethodChannel.Result result
    ) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "hasConsentForPurposeOne": {
                SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(
                        context
                );
                // Example value: "1111111111"
                String purposeConsents = sharedPref.getString(
                        "IABTCF_PurposeConsents",
                        ""
                );
                android.util.Log.d("check_purposeConsents", "purposeConsents: " + purposeConsents);


                // Purposes are zero-indexed. Index 0 contains information about Purpose 1.
                if (!purposeConsents.isEmpty()) {
                    String purposeOneString = String.valueOf(purposeConsents.charAt(0));
                    boolean hasConsentForPurposeOne = Objects.equals(
                            purposeOneString,
                            "1"
                    );
                    result.success(hasConsentForPurposeOne);
                } else {
                    result.success(null);
                }
                break;
            }
            case "showLoadingAd": {
                long color = (long) call.arguments;
                showOverlayLoading((int) color);
                break;
            }
            case "hideLoadingAd": {
                hideOverlayLoading();
                break;
            }

            //iap
            case "initBilling":
                List<String> productIds = call.argument("productIds");
                if (productIds == null) productIds = new ArrayList<>();
                List<String> finalProductIds = productIds;

                final boolean[] isResultCalled = {false};
                initializePurchases(productIds, () -> {
                    if (!isResultCalled[0]) {
                        methodChannel.invokeMethod("onNextAction", finalProductIds);
                        result.success(true);
                        isResultCalled[0] = true;
                    }
                });
                break;

            case "isPurchase":
                boolean isPurchase = iapManager.isPurchase();
                result.success(isPurchase);
                break;

            case "getSalePrice":
                String idSub = call.arguments.toString();
                String price = iapManager.getPriceSub(idSub);
                result.success(price);
                break;

            case "getOriginalPrice":
                handleGetOriginalPrice(call, result);
                break;

            case "getPricePerWeek":
                handleGetPricePerWeek(call, result);
                break;

            case "getPrice":
                String id = call.arguments.toString();
                String priceValue = iapManager.getPrice(id);
                result.success(priceValue);
                break;

            case "getCurrency":
                String currencyId = call.arguments.toString();
                String currency = iapManager.getCurrency(currencyId, IAPManager.typeSub);
                result.success(currency);
                break;

            case "getPriceWithoutCurrency":
                String priceId = call.arguments.toString();
                double priceWithoutCurrency = iapManager.getPriceWithoutCurrency(priceId, IAPManager.typeSub);
                result.success(priceWithoutCurrency);
                break;

            case "buySubscribe":
                String subId = call.arguments.toString();
                iapManager.subscribe(mActivity, subId);
                result.success(true);
                break;

            case "purchaseListener":
                iapManager.setPurchaseListener(new PurchaseCallback() {
                    @Override
                    public void onProductPurchased(String productId, String transactionDetails) {
                        super.onProductPurchased(productId, transactionDetails);
                        Log.e("android", "check_method --- onProductPurchased");
                        methodChannel.invokeMethod("onSuccessfulPurchase", null);
                        result.success(true);
                    }
                });
                break;
            //end

            case "isNetworkActive":
                boolean isConnected = NetworkUtil.isNetworkActive(context);
                result.success(isConnected);

            default:
                result.notImplemented();
                break;
        }
    }

    private View loadingOverlayView;
    private final WindowManager.LayoutParams loadingOverlayParams = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
    );

    private FullscreenLoadingDialog dialog;

    void showOverlayLoading(int color) {
        //        Intent loadingIntent = new Intent(mActivity, FullscreenLoadingActivity.class);
        //        mActivity.startActivity(loadingIntent);

        if (dialog == null) {
            dialog = new FullscreenLoadingDialog(mActivity, color);
        }

        dialog.show();
    }

    void hideOverlayLoading() {
        if (dialog != null) {
            dialog.dismiss();
            dialog = null;
        }
        //        if (loadingOverlayView != null) {
        //            WindowManager wm = (WindowManager) mActivity.getSystemService(Context.WINDOW_SERVICE);
        //            wm.removeView(loadingOverlayView);
        //            loadingOverlayView.invalidate();
        //            loadingOverlayView = null;
        //        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }

        if (loadingChannel != null) {
            loadingChannel.setMethodCallHandler(null);
            loadingChannel = null;
        }

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(
            @NonNull ActivityPluginBinding binding
    ) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    //iap
    private void initializePurchases(List<String> productList, Runnable callback) {
        android.util.Log.d("check_iap", "start initializePurchases");
        ArrayList<ProductDetailCustom> products = new ArrayList<>();
        for (String productId : productList) {
            products.add(new ProductDetailCustom(productId, IAPManager.typeSub));
            android.util.Log.d("check_iap", "productId: " + productId);
        }

        final boolean[] isCallbackCalled = {false};

        iapManager.initBilling(context, products, new BillingCallback() {
            @Override
            public void onBillingServiceDisconnected() {
                super.onBillingServiceDisconnected();
                if (!isCallbackCalled[0]) {
                    isCallbackCalled[0] = true;
                    callback.run();
                    android.util.Log.d("check_iap", "onBillingServiceDisconnected");
                }
            }

            @Override
            public void onBillingSetupFinished(int resultCode) {
                super.onBillingSetupFinished(resultCode);
                if (!isCallbackCalled[0]) {
                    isCallbackCalled[0] = true;
                    callback.run();
                    android.util.Log.d("check_iap", "onBillingSetupFinished");
                }
            }
        });
    }

    private void handleGetOriginalPrice(MethodCall call, MethodChannel.Result result) {
        String idSub = call.argument("idSub");
        int percentSale = call.argument("percentSale");
        String salePriceString = iapManager.getPriceSub(idSub);
        double salePrice = iapManager.getPriceWithoutCurrency(idSub, IAPManager.typeSub) / 1000000.0;
        String currencySymbol = salePriceString.replaceAll("[0-9,.]", "");
        boolean isSymbolAtStart = salePriceString.startsWith(currencySymbol);
        double originalPrice = salePrice * (100 / (100 - percentSale));

        SpannableString originalPriceString = new SpannableString(
                isSymbolAtStart ? currencySymbol + formatNumber((int) originalPrice) : formatNumber((int) originalPrice) + currencySymbol
        );
        android.util.Log.d("check_iap", "originalPriceString: " + originalPriceString + "originalPrice" + formatNumber((int) originalPrice) + "currencySymbol: " + currencySymbol);

        result.success(originalPriceString);
    }

    private void handleGetPricePerWeek(MethodCall call, MethodChannel.Result result) {
        int numberWeek = call.argument("numberWeek");
        String idSub = call.argument("idSub");
        String salePriceString = iapManager.getPriceSub(idSub);
        double salePrice = iapManager.getPriceWithoutCurrency(idSub, IAPManager.typeSub) / 1000000.0;
        String currencySymbol = salePriceString.replaceAll("[0-9,.]", "");
        boolean isSymbolAtStart = salePriceString.startsWith(currencySymbol);
        int amountPerWeek = (int) (salePrice / numberWeek);

        SpannableString amountPerWeekString = new SpannableString(
                isSymbolAtStart ? currencySymbol + formatNumber(amountPerWeek) : formatNumber(amountPerWeek) + currencySymbol
        );

        result.success(amountPerWeekString);
    }

    private String formatNumber(int number) {
        String numberString = String.valueOf(number);
        StringBuilder stringBuilder = new StringBuilder();
        int length = numberString.length();

        for (int i = 0; i < length; i++) {
            stringBuilder.append(numberString.charAt(i));
            if ((length - i - 1) > 0 && (length - i - 1) % 3 == 0) {
                stringBuilder.append('.');
            }
        }

        return stringBuilder.toString();
    }
}
