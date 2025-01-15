package com.amazic.ad.ads;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import io.flutter.plugin.platform.PlatformView;

import java.util.Map;

public class AdsPlatformView implements PlatformView {
    private final AdView adView;
//    private final MethodChannel channel;

    public AdsPlatformView(Context context, int id, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        String adUnitId = (String) params.get("adUnitId");

        adView = new AdView(context);
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId(adUnitId);

        adView.setAdListener(new AdListener() {
            @Override
            public void onAdClicked() {
                super.onAdClicked();
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);
            }

            @Override
            public void onAdImpression() {
                super.onAdImpression();
            }

            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
//                channel.invokeMethod("onAdLoaded", null);
            }
        });

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);
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


