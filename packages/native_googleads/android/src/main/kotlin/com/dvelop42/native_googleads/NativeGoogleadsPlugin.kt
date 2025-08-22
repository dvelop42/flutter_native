package com.dvelop42.native_googleads

import android.content.Context
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.initialization.InitializationStatus
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.OnUserEarnedRewardListener
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.app.Activity
import android.view.ViewGroup
import android.widget.FrameLayout
import java.util.UUID

class NativeGoogleadsPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private val bannerAds = mutableMapOf<String, AdView>()
    private val nativeAds = mutableMapOf<String, NativeAd>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_googleads")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        
        // Register platform view factories
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "native_googleads/banner",
            BannerAdViewFactory(bannerAds)
        )
        
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "native_googleads/native",
            NativeAdViewFactory(nativeAds)
        )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initialize" -> {
                val appId = call.argument<String>("appId")
                initializeAdMob(appId, result)
            }
            "loadInterstitialAd" -> {
                val adUnitId = call.argument<String>("adUnitId")
                if (adUnitId != null) {
                    loadInterstitialAd(adUnitId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Ad unit ID is required", null)
                }
            }
            "showInterstitialAd" -> {
                showInterstitialAd(result)
            }
            "loadRewardedAd" -> {
                val adUnitId = call.argument<String>("adUnitId")
                if (adUnitId != null) {
                    loadRewardedAd(adUnitId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Ad unit ID is required", null)
                }
            }
            "showRewardedAd" -> {
                showRewardedAd(result)
            }
            "loadBannerAd" -> {
                val adUnitId = call.argument<String>("adUnitId")
                val size = call.argument<Int>("size")
                if (adUnitId != null && size != null) {
                    loadBannerAd(adUnitId, size, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Ad unit ID and size are required", null)
                }
            }
            "showBannerAd" -> {
                val bannerId = call.argument<String>("bannerId")
                if (bannerId != null) {
                    showBannerAd(bannerId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Banner ID is required", null)
                }
            }
            "hideBannerAd" -> {
                val bannerId = call.argument<String>("bannerId")
                if (bannerId != null) {
                    hideBannerAd(bannerId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Banner ID is required", null)
                }
            }
            "disposeBannerAd" -> {
                val bannerId = call.argument<String>("bannerId")
                if (bannerId != null) {
                    disposeBannerAd(bannerId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Banner ID is required", null)
                }
            }
            "loadNativeAd" -> {
                val adUnitId = call.argument<String>("adUnitId")
                if (adUnitId != null) {
                    loadNativeAd(adUnitId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Ad unit ID is required", null)
                }
            }
            "showNativeAd" -> {
                val nativeAdId = call.argument<String>("nativeAdId")
                if (nativeAdId != null) {
                    showNativeAd(nativeAdId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Native ad ID is required", null)
                }
            }
            "disposeNativeAd" -> {
                val nativeAdId = call.argument<String>("nativeAdId")
                if (nativeAdId != null) {
                    disposeNativeAd(nativeAdId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Native ad ID is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initializeAdMob(appId: String?, result: Result) {
        // If appId is provided, we can set it programmatically using MobileAds configuration
        // Note: In production, the App ID should be set in AndroidManifest.xml
        // This is for flexibility during development/testing
        android.util.Log.d("NativeGoogleads", "Initializing AdMob with appId: $appId")
        
        MobileAds.initialize(context) { initializationStatus ->
            android.util.Log.d("NativeGoogleads", "AdMob initialized successfully")
            val statusMap = HashMap<String, Any>()
            statusMap["isReady"] = true
            
            val adapterStatusMap = HashMap<String, HashMap<String, Any>>()
            for ((className, status) in initializationStatus.adapterStatusMap) {
                val adapterInfo = HashMap<String, Any>()
                adapterInfo["isReady"] = status.initializationState.ordinal == 1
                adapterInfo["description"] = status.description
                adapterInfo["latency"] = status.latency
                adapterStatusMap[className] = adapterInfo
            }
            
            statusMap["adapterStatus"] = adapterStatusMap
            statusMap["appId"] = appId ?: "Not specified"
            result.success(statusMap)
        }
    }

    private fun loadInterstitialAd(adUnitId: String, result: Result) {
        val adRequest = AdRequest.Builder().build()

        InterstitialAd.load(
            context,
            adUnitId,
            adRequest,
            object : InterstitialAdLoadCallback() {
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    interstitialAd = null
                    result.error("AD_LOAD_ERROR", adError.message, adError.code)
                }

                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialAd = ad
                    setupInterstitialCallbacks()
                    result.success(true)
                }
            }
        )
    }

    private fun setupInterstitialCallbacks() {
        interstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                interstitialAd = null
                channel.invokeMethod("onAdDismissed", mapOf("type" to "interstitial"))
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                interstitialAd = null
                channel.invokeMethod("onAdFailedToShow", mapOf(
                    "type" to "interstitial",
                    "error" to adError.message
                ))
            }

            override fun onAdShowedFullScreenContent() {
                channel.invokeMethod("onAdShowed", mapOf("type" to "interstitial"))
            }
        }
    }

    private fun showInterstitialAd(result: Result) {
        val ad = interstitialAd
        val currentActivity = activity
        
        if (ad != null && currentActivity != null) {
            ad.show(currentActivity)
            result.success(true)
        } else {
            result.error("AD_NOT_READY", "Interstitial ad is not loaded or activity is not available", null)
        }
    }

    private fun loadRewardedAd(adUnitId: String, result: Result) {
        val adRequest = AdRequest.Builder().build()

        RewardedAd.load(
            context,
            adUnitId,
            adRequest,
            object : RewardedAdLoadCallback() {
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    rewardedAd = null
                    result.error("AD_LOAD_ERROR", adError.message, adError.code)
                }

                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    setupRewardedCallbacks()
                    result.success(true)
                }
            }
        )
    }

    private fun setupRewardedCallbacks() {
        rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                rewardedAd = null
                channel.invokeMethod("onAdDismissed", mapOf("type" to "rewarded"))
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedAd = null
                channel.invokeMethod("onAdFailedToShow", mapOf(
                    "type" to "rewarded",
                    "error" to adError.message
                ))
            }

            override fun onAdShowedFullScreenContent() {
                channel.invokeMethod("onAdShowed", mapOf("type" to "rewarded"))
            }
        }
    }

    private fun showRewardedAd(result: Result) {
        val ad = rewardedAd
        val currentActivity = activity
        
        if (ad != null && currentActivity != null) {
            ad.show(currentActivity) { rewardItem ->
                val rewardData = mapOf(
                    "type" to rewardItem.type,
                    "amount" to rewardItem.amount
                )
                channel.invokeMethod("onUserEarnedReward", rewardData)
            }
            result.success(true)
        } else {
            result.error("AD_NOT_READY", "Rewarded ad is not loaded or activity is not available", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
    
    private fun loadBannerAd(adUnitId: String, sizeIndex: Int, result: Result) {
        val bannerId = UUID.randomUUID().toString()
        android.util.Log.d("NativeGoogleads", "Loading banner ad with ID: $bannerId, adUnitId: $adUnitId, size: $sizeIndex")
        
        val adView = AdView(context)
        adView.adUnitId = adUnitId
        
        val adSize = when (sizeIndex) {
            0 -> AdSize.BANNER
            1 -> AdSize.LARGE_BANNER
            2 -> AdSize.MEDIUM_RECTANGLE
            3 -> AdSize.FULL_BANNER
            4 -> AdSize.LEADERBOARD
            5 -> AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, AdSize.FULL_WIDTH)
            else -> AdSize.BANNER
        }
        
        adView.setAdSize(adSize)
        
        adView.adListener = object : AdListener() {
            override fun onAdLoaded() {
                android.util.Log.d("NativeGoogleads", "Banner ad loaded successfully: $bannerId")
                bannerAds[bannerId] = adView
                result.success(bannerId)
            }
            
            override fun onAdFailedToLoad(adError: LoadAdError) {
                android.util.Log.e("NativeGoogleads", "Banner ad failed to load: ${adError.message}, code: ${adError.code}, domain: ${adError.domain}")
                android.util.Log.e("NativeGoogleads", "Banner ad error details: ${adError.toString()}")
                result.error("AD_LOAD_ERROR", adError.message, adError.code)
            }
        }
        
        val adRequest = AdRequest.Builder().build()
        adView.loadAd(adRequest)
    }
    
    private fun showBannerAd(bannerId: String, result: Result) {
        val adView = bannerAds[bannerId]
        if (adView != null) {
            // Banner ads need to be displayed through platform views
            // For now, we'll just mark it as shown
            // In a complete implementation, this would be handled by a platform view factory
            result.success(true)
        } else {
            result.error("BANNER_NOT_FOUND", "Banner with ID $bannerId not found", null)
        }
    }
    
    private fun hideBannerAd(bannerId: String, result: Result) {
        val adView = bannerAds[bannerId]
        if (adView != null) {
            val currentActivity = activity
            if (currentActivity != null) {
                currentActivity.runOnUiThread {
                    val parent = adView.parent as? ViewGroup
                    parent?.removeView(adView)
                }
                result.success(true)
            } else {
                result.error("NO_ACTIVITY", "Activity is not available", null)
            }
        } else {
            result.error("BANNER_NOT_FOUND", "Banner with ID $bannerId not found", null)
        }
    }
    
    private fun disposeBannerAd(bannerId: String, result: Result) {
        val adView = bannerAds[bannerId]
        if (adView != null) {
            val currentActivity = activity
            if (currentActivity != null) {
                currentActivity.runOnUiThread {
                    val parent = adView.parent as? ViewGroup
                    parent?.removeView(adView)
                    adView.destroy()
                }
            } else {
                adView.destroy()
            }
            bannerAds.remove(bannerId)
            result.success(true)
        } else {
            result.error("BANNER_NOT_FOUND", "Banner with ID $bannerId not found", null)
        }
    }
    
    private fun loadNativeAd(adUnitId: String, result: Result) {
        val nativeAdId = UUID.randomUUID().toString()
        android.util.Log.d("NativeGoogleads", "Loading native ad with ID: $nativeAdId, adUnitId: $adUnitId")
        
        val adLoader = com.google.android.gms.ads.AdLoader.Builder(context, adUnitId)
            .forNativeAd { ad ->
                android.util.Log.d("NativeGoogleads", "Native ad loaded successfully: $nativeAdId")
                nativeAds[nativeAdId] = ad
                result.success(nativeAdId)
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    android.util.Log.e("NativeGoogleads", "Native ad failed to load: ${adError.message}, code: ${adError.code}, domain: ${adError.domain}")
                    android.util.Log.e("NativeGoogleads", "Native ad error details: ${adError.toString()}")
                    result.error("AD_LOAD_ERROR", adError.message, adError.code)
                }
            })
            .withNativeAdOptions(
                NativeAdOptions.Builder()
                    .setRequestMultipleImages(true)
                    .build()
            )
            .build()
        
        val adRequest = AdRequest.Builder().build()
        adLoader.loadAd(adRequest)
    }
    
    private fun showNativeAd(nativeAdId: String, result: Result) {
        val nativeAd = nativeAds[nativeAdId]
        if (nativeAd != null) {
            result.success(true)
        } else {
            result.error("NATIVE_AD_NOT_FOUND", "Native ad with ID $nativeAdId not found", null)
        }
    }
    
    private fun disposeNativeAd(nativeAdId: String, result: Result) {
        val nativeAd = nativeAds[nativeAdId]
        if (nativeAd != null) {
            nativeAd.destroy()
            nativeAds.remove(nativeAdId)
            result.success(true)
        } else {
            result.error("NATIVE_AD_NOT_FOUND", "Native ad with ID $nativeAdId not found", null)
        }
    }
    
    // Platform View Factory for Banner Ads
    inner class BannerAdViewFactory(
        private val bannerAds: Map<String, AdView>
    ) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            val creationParams = args as? Map<String?, Any?>
            return BannerAdPlatformView(context, bannerAds, creationParams)
        }
    }
    
    // Platform View Factory for Native Ads
    inner class NativeAdViewFactory(
        private val nativeAds: Map<String, NativeAd>
    ) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            val creationParams = args as? Map<String?, Any?>
            return NativeAdPlatformView(context, nativeAds, creationParams)
        }
    }
}