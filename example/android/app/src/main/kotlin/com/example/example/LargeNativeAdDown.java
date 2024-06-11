package com.example.example;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory;
import java.util.Map;

public class LargeNativeAdDown implements NativeAdFactory {

  private final LayoutInflater layoutInflater;

  LargeNativeAdDown(LayoutInflater layoutInflater) {
    this.layoutInflater = layoutInflater;
  }

  @Override
  public NativeAdView createNativeAd(
    NativeAd nativeAd,
    Map<String, Object> customOptions
  ) {
    final NativeAdView adView = (NativeAdView) layoutInflater.inflate(
      R.layout.large_native_ad_down,
      null
    );

    // Set the media view.
    adView.setMediaView(adView.findViewById(R.id.ad_media));

    // Set other ad assets.
    adView.setHeadlineView(adView.findViewById(R.id.ad_headline));
    adView.setBodyView(adView.findViewById(R.id.ad_body));
    adView.setCallToActionView(adView.findViewById(R.id.ad_call_to_action));
    adView.setIconView(adView.findViewById(R.id.ad_app_icon));
    //        adView.setAdvertiserView(adView.findViewById(R.id.ad_advertise));

    // The headline and mediaContent are guaranteed to be in every NativeAd.
    ((TextView) adView.getHeadlineView()).setText(nativeAd.getHeadline());
    adView.getMediaView().setMediaContent(nativeAd.getMediaContent());

    // These assets aren't guaranteed to be in every NativeAd, so it's important to
    // check before trying to display them.
    if (nativeAd.getBody() == null) {
      adView.getBodyView().setVisibility(View.INVISIBLE);
    } else {
      adView.getBodyView().setVisibility(View.VISIBLE);
      ((TextView) adView.getBodyView()).setText(nativeAd.getBody());
    }

    if (nativeAd.getCallToAction() == null) {
      adView.getCallToActionView().setVisibility(View.INVISIBLE);
    } else {
      adView.getCallToActionView().setVisibility(View.VISIBLE);
      ((Button) adView.getCallToActionView()).setText(
          nativeAd.getCallToAction()
        );
    }

    if (nativeAd.getIcon() == null) {
      adView.getIconView().setVisibility(View.GONE);
    } else {
      // attributionViewSmall.setVisibility(View.VISIBLE);
      // adView.getAttributionViewLarge().setVisibility(View.VISIBLE);
      ((ImageView) adView.getIconView()).setImageDrawable(
          nativeAd.getIcon().getDrawable()
        );
      adView.getIconView().setVisibility(View.VISIBLE);
    }
    //        if (nativeAd.getAdvertiser() == null) {
    //            adView.getAdvertiserView().setVisibility(View.INVISIBLE);
    //        } else {
    //            adView.getAdvertiserView().setVisibility(View.VISIBLE);
    //            ((TextView) adView.getAdvertiserView()).setText(nativeAd.getAdvertiser());
    //        }

    // This method tells the Google Mobile Ads SDK that you have finished populating
    // your
    // native ad view with this native ad.
    adView.setNativeAd(nativeAd);

    return adView;
  }
}
