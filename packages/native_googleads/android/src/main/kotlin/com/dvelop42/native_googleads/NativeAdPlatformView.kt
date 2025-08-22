package com.dvelop42.native_googleads

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugin.platform.PlatformView

class NativeAdPlatformView(
    private val context: Context,
    private val nativeAds: Map<String, NativeAd>,
    creationParams: Map<String?, Any?>?
) : PlatformView {
    private val container: FrameLayout = FrameLayout(context)
    private var nativeAdView: NativeAdView? = null

    init {
        val nativeAdId = creationParams?.get("nativeAdId") as? String
        if (nativeAdId != null) {
            val nativeAd = nativeAds[nativeAdId]
            nativeAd?.let { ad ->
                setupNativeAdView(ad)
            }
        }
    }

    private fun setupNativeAdView(nativeAd: NativeAd) {
        // Create a simple native ad layout programmatically
        nativeAdView = NativeAdView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(16, 16, 16, 16)
        }

        // Create a simple layout for the native ad
        val contentLayout = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setBackgroundColor(0xFFFFFFFF.toInt())
            setPadding(16, 16, 16, 16)
        }

        // Add headline
        val headlineView = TextView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            textSize = 18f
            setTextColor(0xFF000000.toInt())
            setPadding(0, 0, 0, 8)
        }
        
        // Add body
        val bodyView = TextView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = 60
            }
            textSize = 14f
            setTextColor(0xFF666666.toInt())
        }

        // Add call to action button
        val ctaView = Button(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = 120
            }
        }

        contentLayout.addView(headlineView)
        contentLayout.addView(bodyView)
        contentLayout.addView(ctaView)

        nativeAdView?.apply {
            headlineView = headlineView
            bodyView = bodyView
            callToActionView = ctaView
            
            // Set the native ad data
            headlineView.text = nativeAd.headline
            bodyView.text = nativeAd.body
            ctaView.text = nativeAd.callToAction

            // Associate the native ad with the view
            setNativeAd(nativeAd)
            
            addView(contentLayout)
        }

        container.addView(nativeAdView)
    }

    override fun getView(): View = container

    override fun dispose() {
        nativeAdView?.destroy()
    }
}