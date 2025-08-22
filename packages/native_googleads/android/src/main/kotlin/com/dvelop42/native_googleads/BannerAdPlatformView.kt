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
        try {
            val bannerId = creationParams?.get("bannerId") as? String
            if (bannerId != null) {
                adView = bannerAds[bannerId]
                adView?.let { ad ->
                    // Remove from any existing parent
                    (ad.parent as? android.view.ViewGroup)?.removeView(ad)
                    // Add to our container
                    container.addView(ad)
                } ?: run {
                    android.util.Log.e("BannerAdPlatformView", "Banner ad not found for ID: $bannerId")
                }
            } else {
                android.util.Log.e("BannerAdPlatformView", "Banner ID is null in creation params")
            }
        } catch (e: Exception) {
            android.util.Log.e("BannerAdPlatformView", "Error initializing banner ad view", e)
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        // Remove the ad view from container before disposal
        adView?.let { ad ->
            container.removeView(ad)
        }
        // Note: The actual ad disposal is handled by the main plugin
        // when disposeBannerAd is called from Flutter
        adView = null
    }
}