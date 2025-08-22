package com.dvelop42.native_googleads

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.google.android.gms.ads.AdView
import io.flutter.plugin.platform.PlatformView

class BannerAdPlatformView(
    context: Context,
    private val bannerAds: Map<String, AdView>,
    creationParams: Map<String?, Any?>?
) : PlatformView {
    private val container: FrameLayout = FrameLayout(context)
    private var adView: AdView? = null

    init {
        val bannerId = creationParams?.get("bannerId") as? String
        if (bannerId != null) {
            adView = bannerAds[bannerId]
            adView?.let { ad ->
                // Remove from any existing parent
                (ad.parent as? FrameLayout)?.removeView(ad)
                // Add to our container
                container.addView(ad)
            }
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        // Don't dispose the ad here, let the main plugin handle it
    }
}