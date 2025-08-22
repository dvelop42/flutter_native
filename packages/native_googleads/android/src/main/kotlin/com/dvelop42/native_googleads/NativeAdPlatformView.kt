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
        try {
            val nativeAdId = creationParams?.get("nativeAdId") as? String
            if (nativeAdId != null) {
                val nativeAd = nativeAds[nativeAdId]
                nativeAd?.let { ad ->
                    setupNativeAdView(ad)
                } ?: run {
                    android.util.Log.e("NativeAdPlatformView", "Native ad not found for ID: $nativeAdId")
                }
            } else {
                android.util.Log.e("NativeAdPlatformView", "Native ad ID is null in creation params")
            }
        } catch (e: Exception) {
            android.util.Log.e("NativeAdPlatformView", "Error initializing native ad view", e)
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

        // Use LinearLayout for better layout control
        val contentLayout = android.widget.LinearLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            orientation = android.widget.LinearLayout.VERTICAL
            setBackgroundColor(0xFFFFFFFF.toInt())
            setPadding(16, 16, 16, 16)
        }

        // Add headline
        val headlineView = TextView(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 8
            }
            textSize = 18f
            setTextColor(0xFF000000.toInt())
        }
        
        // Add body
        val bodyView = TextView(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 12
            }
            textSize = 14f
            setTextColor(0xFF666666.toInt())
        }

        // Add call to action button
        val ctaView = Button(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        contentLayout.addView(headlineView)
        contentLayout.addView(bodyView)
        contentLayout.addView(ctaView)

        nativeAdView?.apply {
            this.headlineView = headlineView
            this.bodyView = bodyView
            this.callToActionView = ctaView
            
            // Set the native ad data
            (this.headlineView as? TextView)?.text = nativeAd.headline
            (this.bodyView as? TextView)?.text = nativeAd.body
            (this.callToActionView as? Button)?.text = nativeAd.callToAction

            // Associate the native ad with the view
            setNativeAd(nativeAd)
            
            addView(contentLayout)
        }

        container.addView(nativeAdView)
    }

    override fun getView(): View = container

    override fun dispose() {
        try {
            nativeAdView?.destroy()
            nativeAdView = null
        } catch (e: Exception) {
            android.util.Log.e("NativeAdPlatformView", "Error disposing native ad view", e)
        }
    }
}