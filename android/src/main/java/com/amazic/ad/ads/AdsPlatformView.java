package com.amazic.ad.ads;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import java.util.Map;

public class AdsPlatformView implements PlatformView {
    private final AdView adView;
    private final MethodChannel methodChannel;

    public AdsPlatformView(Context context, int id, Object args, MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
        Map<String, Object> params = (Map<String, Object>) args;
        String adUnitId = (String) params.get("adUnitId");

        Map<String, Integer> adSizeMap = (Map<String, Integer>) params.get("adSize");
        int width = adSizeMap.get("width");
        int height = adSizeMap.get("height");
        AdSize adSize = new AdSize(width, height);
        Log.d("check_test_ad", "adSize. " + adSize);

        adView = new AdView(context);
        adView.setAdSize(adSize);
        adView.setAdUnitId(adUnitId);
        methodChannel.invokeMethod("onRequestAds", null);
        adView.setAdListener(new AdListener() {
            @Override
            public void onAdClicked() {
                super.onAdClicked();
                methodChannel.invokeMethod("onAdClicked", null);
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
                methodChannel.invokeMethod("onAdLoaded", null);
            }

            @Override
            public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);
                methodChannel.invokeMethod("onAdFailedToLoad", null);
            }

            @Override
            public void onAdImpression() {
                super.onAdImpression();
                methodChannel.invokeMethod("onAdImpression", null);
            }

            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                methodChannel.invokeMethod("onAdLoaded", null);
                detectTestAd(adView);
            }
        });

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);
    }

    private boolean detectTestAd(ViewGroup viewGroup) {
        for (int i = 0; i < viewGroup.getChildCount(); i++) {
            View viewChild = viewGroup.getChildAt(i);
            if (viewChild instanceof ViewGroup) {
                Log.d("check_test_ad", "detectTestAd: 2.TextView");
                detectTestAd((ViewGroup) viewChild);
            }
            if (viewChild instanceof TextView) {
                Log.d("check_test_ad", "detectTestAd: 1.TextView");
                methodChannel.invokeMethod("coreTechnologyTestAd",null);
                return true;
            }
        }
        return false;
    }

    @Override
    public View getView() {
        return adView;
    }

    @Override
    public void dispose() {
        if (adView != null) {
            adView.destroy();
        }
    }
}


