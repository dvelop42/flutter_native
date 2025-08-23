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
    private var fullScreenView: FullScreenNativeAdView? = null
    private val style: Map<String, Any?>? = creationParams?.get("style") as? Map<String, Any?>?
    private val template: Int? = creationParams?.get("template") as? Int?
    private val isFullScreen: Boolean = creationParams?.get("isFullScreen") as? Boolean ?: false

    init {
        try {
            val nativeAdId = creationParams?.get("nativeAdId") as? String
            if (nativeAdId != null) {
                val nativeAd = nativeAds[nativeAdId]
                nativeAd?.let { ad ->
                    if (isFullScreen) {
                        setupFullScreenNativeAdView(ad)
                    } else {
                        setupNativeAdView(ad)
                    }
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
    
    private fun setupFullScreenNativeAdView(nativeAd: NativeAd) {
        fullScreenView = FullScreenNativeAdView(context, nativeAd, style).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        container.addView(fullScreenView)
    }

    private fun setupNativeAdView(nativeAd: NativeAd) {
        // Create a simple native ad layout programmatically
        nativeAdView = NativeAdView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            
            // Apply padding from style if available
            val padding = style?.get("padding") as? Map<String, Any?>
            if (padding != null) {
                val top = (padding["top"] as? Double)?.toInt() ?: 16
                val right = (padding["right"] as? Double)?.toInt() ?: 16
                val bottom = (padding["bottom"] as? Double)?.toInt() ?: 16
                val left = (padding["left"] as? Double)?.toInt() ?: 16
                setPadding(left, top, right, bottom)
            } else {
                setPadding(16, 16, 16, 16)
            }
        }

        // Use LinearLayout for better layout control
        val contentLayout = android.widget.LinearLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            orientation = android.widget.LinearLayout.VERTICAL
            
            // Apply background color from style if available
            val bgColor = style?.get("backgroundColor") as? Long
            setBackgroundColor(bgColor?.toInt() ?: 0xFFFFFFFF.toInt())
            
            // Apply corner radius if available
            val cornerRadius = style?.get("cornerRadius") as? Double
            if (cornerRadius != null && cornerRadius > 0) {
                val drawable = android.graphics.drawable.GradientDrawable()
                drawable.setColor(bgColor?.toInt() ?: 0xFFFFFFFF.toInt())
                drawable.cornerRadius = cornerRadius.toFloat()
                background = drawable
            }
            
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
            
            // Apply headline text style from style if available
            val headlineStyle = style?.get("headlineTextStyle") as? Map<String, Any?>
            textSize = (headlineStyle?.get("fontSize") as? Double)?.toFloat() ?: 18f
            val textColor = (headlineStyle?.get("color") as? Long)?.toInt()
            setTextColor(textColor ?: 0xFF000000.toInt())
        }
        
        // Add body
        val bodyView = TextView(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 12
            }
            
            // Apply body text style from style if available
            val bodyStyle = style?.get("bodyTextStyle") as? Map<String, Any?>
            textSize = (bodyStyle?.get("fontSize") as? Double)?.toFloat() ?: 14f
            val textColor = (bodyStyle?.get("color") as? Long)?.toInt()
            setTextColor(textColor ?: 0xFF666666.toInt())
        }

        // Add call to action button
        val ctaView = Button(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            
            // Apply call to action style from style if available
            val ctaStyle = style?.get("callToActionStyle") as? Map<String, Any?>
            if (ctaStyle != null) {
                val bgColor = (ctaStyle["backgroundColor"] as? Long)?.toInt()
                if (bgColor != null) {
                    setBackgroundColor(bgColor)
                }
                val textColor = (ctaStyle["textColor"] as? Long)?.toInt()
                if (textColor != null) {
                    setTextColor(textColor)
                }
                val textStyleMap = ctaStyle["textStyle"] as? Map<String, Any?>
                if (textStyleMap != null) {
                    val fontSize = (textStyleMap["fontSize"] as? Double)?.toFloat()
                    if (fontSize != null) {
                        textSize = fontSize
                    }
                }
            }
        }

        // Add media view if the ad has media content
        val mediaStyle = style?.get("mediaStyle") as? Map<String, Any?>
        if (nativeAd.mediaContent != null && nativeAd.mediaContent!!.hasVideoContent()) {
            val mediaView = MediaView(context).apply {
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = 12
                    
                    // Apply aspect ratio if specified
                    val aspectRatio = mediaStyle?.get("aspectRatio") as? Double
                    if (aspectRatio != null && aspectRatio > 0) {
                        // Set height based on aspect ratio
                        height = (container.width / aspectRatio).toInt()
                    }
                }
                
                // Set media content
                mediaContent = nativeAd.mediaContent
            }
            contentLayout.addView(mediaView)
            nativeAdView?.mediaView = mediaView
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
            fullScreenView?.destroy()
            fullScreenView = null
        } catch (e: Exception) {
            android.util.Log.e("NativeAdPlatformView", "Error disposing native ad view", e)
        }
    }
}