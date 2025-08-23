package com.dvelop42.native_googleads

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

class FullScreenNativeAdView(
    context: Context,
    private val nativeAd: NativeAd,
    private val style: Map<String, Any?>? = null
) : FrameLayout(context) {
    
    private var nativeAdView: NativeAdView? = null
    
    init {
        setupFullScreenView()
    }
    
    private fun setupFullScreenView() {
        // Create native ad view that fills the entire screen
        nativeAdView = NativeAdView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
        }
        
        // Main container with black background for full screen effect
        val mainContainer = FrameLayout(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.BLACK)
        }
        
        // Media view for full screen media content
        val mediaView = MediaView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
        }
        mainContainer.addView(mediaView)
        nativeAdView?.mediaView = mediaView
        
        // Gradient overlay for text readability
        val gradientOverlay = View(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
            val gradient = android.graphics.drawable.GradientDrawable(
                android.graphics.drawable.GradientDrawable.Orientation.BOTTOM_TOP,
                intArrayOf(
                    Color.parseColor("#CC000000"),
                    Color.TRANSPARENT,
                    Color.TRANSPARENT,
                    Color.parseColor("#CC000000")
                )
            )
            background = gradient
        }
        mainContainer.addView(gradientOverlay)
        
        // Top section with ad attribution
        val topSection = LinearLayout(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.TOP
                topMargin = 40
            }
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(24, 16, 24, 16)
        }
        
        // Ad attribution label
        val adLabel = TextView(context).apply {
            text = "Ad"
            setTextColor(Color.BLACK)
            setBackgroundColor(Color.parseColor("#FFD700"))
            setPadding(12, 4, 12, 4)
            textSize = 11f
            gravity = Gravity.CENTER
        }
        topSection.addView(adLabel)
        
        // Advertiser/Store info if available
        if (nativeAd.advertiser != null || nativeAd.store != null) {
            val advertiserView = TextView(context).apply {
                text = nativeAd.advertiser ?: nativeAd.store
                setTextColor(Color.WHITE)
                textSize = 14f
                setPadding(16, 0, 0, 0)
            }
            topSection.addView(advertiserView)
            nativeAdView?.advertiserView = advertiserView
        }
        
        mainContainer.addView(topSection)
        
        // Bottom section with headline, body, and CTA
        val bottomSection = LinearLayout(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.BOTTOM
                bottomMargin = 40
            }
            orientation = LinearLayout.VERTICAL
            setPadding(24, 24, 24, 24)
        }
        
        // Headline
        val headlineView = TextView(context).apply {
            text = nativeAd.headline
            setTextColor(Color.WHITE)
            textSize = 24f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 8)
        }
        bottomSection.addView(headlineView)
        nativeAdView?.headlineView = headlineView
        
        // Body text
        nativeAd.body?.let { body ->
            val bodyView = TextView(context).apply {
                text = body
                setTextColor(Color.parseColor("#E0E0E0"))
                textSize = 16f
                maxLines = 3
                setPadding(0, 0, 0, 16)
            }
            bottomSection.addView(bodyView)
            nativeAdView?.bodyView = bodyView
        }
        
        // Call to action button
        nativeAd.callToAction?.let { cta ->
            val ctaButton = Button(context).apply {
                text = cta
                setTextColor(Color.WHITE)
                setBackgroundColor(Color.parseColor("#1976D2"))
                setPadding(32, 16, 32, 16)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }
            bottomSection.addView(ctaButton)
            nativeAdView?.callToActionView = ctaButton
        }
        
        mainContainer.addView(bottomSection)
        
        // Set the native ad
        nativeAdView?.setNativeAd(nativeAd)
        
        // Add main container to native ad view
        nativeAdView?.addView(mainContainer)
        
        // Add native ad view to this FrameLayout
        addView(nativeAdView)
    }
    
    fun destroy() {
        nativeAdView?.destroy()
        nativeAdView = null
    }
}