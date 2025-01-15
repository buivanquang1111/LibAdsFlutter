package com.amazic.ad.ads;
import android.content.Context;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.StandardMessageCodec;

public class AdsPlatformViewFactory extends PlatformViewFactory {
    private final Context context;
    public AdsPlatformViewFactory(Context context) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new AdsPlatformView(context, id, args);
    }
}

