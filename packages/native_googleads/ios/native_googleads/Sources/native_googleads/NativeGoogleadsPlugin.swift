import Flutter
import UIKit
import GoogleMobileAds

public class NativeGoogleadsPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var bannerAds: [String: GADBannerView] = [:]
    private var nativeAds: [String: GADNativeAd] = [:]
    private var adLoaders: [String: GADAdLoader] = [:]
    private var pendingResults: [String: FlutterResult] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_googleads", binaryMessenger: registrar.messenger())
        let instance = NativeGoogleadsPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "initialize":
            var appId: String? = nil
            if let args = call.arguments as? [String: Any] {
                appId = args["appId"] as? String
            }
            initializeAdMob(appId: appId, result: result)
            
        case "loadInterstitialAd":
            if let args = call.arguments as? [String: Any],
               let adUnitId = args["adUnitId"] as? String {
                loadInterstitialAd(adUnitId: adUnitId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Ad unit ID is required",
                                    details: nil))
            }
            
        case "showInterstitialAd":
            showInterstitialAd(result: result)
            
        case "loadRewardedAd":
            if let args = call.arguments as? [String: Any],
               let adUnitId = args["adUnitId"] as? String {
                loadRewardedAd(adUnitId: adUnitId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Ad unit ID is required",
                                    details: nil))
            }
            
        case "showRewardedAd":
            showRewardedAd(result: result)
            
        case "loadBannerAd":
            if let args = call.arguments as? [String: Any],
               let adUnitId = args["adUnitId"] as? String,
               let size = args["size"] as? Int {
                loadBannerAd(adUnitId: adUnitId, sizeIndex: size, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Ad unit ID and size are required",
                                    details: nil))
            }
            
        case "showBannerAd":
            if let args = call.arguments as? [String: Any],
               let bannerId = args["bannerId"] as? String {
                showBannerAd(bannerId: bannerId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Banner ID is required",
                                    details: nil))
            }
            
        case "hideBannerAd":
            if let args = call.arguments as? [String: Any],
               let bannerId = args["bannerId"] as? String {
                hideBannerAd(bannerId: bannerId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Banner ID is required",
                                    details: nil))
            }
            
        case "disposeBannerAd":
            if let args = call.arguments as? [String: Any],
               let bannerId = args["bannerId"] as? String {
                disposeBannerAd(bannerId: bannerId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Banner ID is required",
                                    details: nil))
            }
            
        case "loadNativeAd":
            if let args = call.arguments as? [String: Any],
               let adUnitId = args["adUnitId"] as? String {
                loadNativeAd(adUnitId: adUnitId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Ad unit ID is required",
                                    details: nil))
            }
            
        case "showNativeAd":
            if let args = call.arguments as? [String: Any],
               let nativeAdId = args["nativeAdId"] as? String {
                showNativeAd(nativeAdId: nativeAdId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Native ad ID is required",
                                    details: nil))
            }
            
        case "disposeNativeAd":
            if let args = call.arguments as? [String: Any],
               let nativeAdId = args["nativeAdId"] as? String {
                disposeNativeAd(nativeAdId: nativeAdId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                    message: "Native ad ID is required",
                                    details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeAdMob(appId: String?, result: @escaping FlutterResult) {
        // Note: In production, the App ID should be set in Info.plist
        // This parameter is for flexibility during development/testing
        
        GADMobileAds.sharedInstance().start { status in
            var statusMap: [String: Any] = [:]
            statusMap["isReady"] = true
            
            var adapterStatusMap: [String: [String: Any]] = [:]
            for (className, adapterStatus) in status.adapterStatusesByClassName {
                var adapterInfo: [String: Any] = [:]
                adapterInfo["isReady"] = adapterStatus.state == .ready
                adapterInfo["description"] = adapterStatus.description
                adapterInfo["latency"] = adapterStatus.latency
                adapterStatusMap[className] = adapterInfo
            }
            
            statusMap["adapterStatus"] = adapterStatusMap
            statusMap["appId"] = appId ?? "Not specified"
            result(statusMap)
        }
    }
    
    private func loadInterstitialAd(adUnitId: String, result: @escaping FlutterResult) {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: adUnitId,
                               request: request) { [weak self] ad, error in
            if let error = error {
                self?.interstitialAd = nil
                let nsError = error as NSError
                result(FlutterError(code: "AD_LOAD_ERROR",
                                    message: error.localizedDescription,
                                    details: nsError.code))
                return
            }
            
            self?.interstitialAd = ad
            self?.setupInterstitialCallbacks()
            result(true)
        }
    }
    
    private func setupInterstitialCallbacks() {
        interstitialAd?.fullScreenContentDelegate = self
    }
    
    private func showInterstitialAd(result: @escaping FlutterResult) {
        guard let ad = interstitialAd else {
            result(FlutterError(code: "AD_NOT_READY",
                                message: "Interstitial ad is not loaded",
                                details: nil))
            return
        }
        
        if let rootViewController = getRootViewController() {
            ad.present(fromRootViewController: rootViewController)
            result(true)
        } else {
            result(FlutterError(code: "NO_ROOT_VIEW",
                                message: "Unable to find root view controller",
                                details: nil))
        }
    }
    
    private func loadRewardedAd(adUnitId: String, result: @escaping FlutterResult) {
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: adUnitId,
                           request: request) { [weak self] ad, error in
            if let error = error {
                self?.rewardedAd = nil
                let nsError = error as NSError
                result(FlutterError(code: "AD_LOAD_ERROR",
                                    message: error.localizedDescription,
                                    details: nsError.code))
                return
            }
            
            self?.rewardedAd = ad
            self?.setupRewardedCallbacks()
            result(true)
        }
    }
    
    private func setupRewardedCallbacks() {
        rewardedAd?.fullScreenContentDelegate = self
    }
    
    private func showRewardedAd(result: @escaping FlutterResult) {
        guard let ad = rewardedAd else {
            result(FlutterError(code: "AD_NOT_READY",
                                message: "Rewarded ad is not loaded",
                                details: nil))
            return
        }
        
        if let rootViewController = getRootViewController() {
            ad.present(fromRootViewController: rootViewController) { [weak self] in
                let reward = ad.adReward
                let rewardData: [String: Any] = [
                    "type": reward.type,
                    "amount": reward.amount
                ]
                self?.channel?.invokeMethod("onUserEarnedReward", arguments: rewardData)
            }
            result(true)
        } else {
            result(FlutterError(code: "NO_ROOT_VIEW",
                                message: "Unable to find root view controller",
                                details: nil))
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        // For iOS 15+ use the new API
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.rootViewController
        } else {
            // Fallback for older iOS versions
            return UIApplication.shared.windows.first?.rootViewController
        }
    }
}

extension NativeGoogleadsPlugin: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Find the banner ID for this view
        for (bannerId, view) in bannerAds where view == bannerView {
            if let result = pendingResults[bannerId] {
                result(bannerId)
                pendingResults.removeValue(forKey: bannerId)
            }
            return
        }
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        // Find the banner ID for this view
        for (bannerId, view) in bannerAds where view == bannerView {
            if let result = pendingResults[bannerId] {
                let nsError = error as NSError
                result(FlutterError(code: "AD_LOAD_ERROR",
                                    message: error.localizedDescription,
                                    details: nsError.code))
                pendingResults.removeValue(forKey: bannerId)
                bannerAds.removeValue(forKey: bannerId)
            }
            return
        }
    }
}

extension NativeGoogleadsPlugin: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        // Find the native ad ID for this loader
        for (nativeAdId, loader) in adLoaders where loader == adLoader {
            nativeAds[nativeAdId] = nativeAd
            if let result = pendingResults[nativeAdId] {
                result(nativeAdId)
                pendingResults.removeValue(forKey: nativeAdId)
            }
            adLoaders.removeValue(forKey: nativeAdId)
            return
        }
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        // Find the native ad ID for this loader
        for (nativeAdId, loader) in adLoaders where loader == adLoader {
            if let result = pendingResults[nativeAdId] {
                let nsError = error as NSError
                result(FlutterError(code: "AD_LOAD_ERROR",
                                    message: error.localizedDescription,
                                    details: nsError.code))
                pendingResults.removeValue(forKey: nativeAdId)
            }
            adLoaders.removeValue(forKey: nativeAdId)
            return
        }
    }
}

extension NativeGoogleadsPlugin: GADFullScreenContentDelegate {
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Called when the ad is about to dismiss
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        let type = ad is GADInterstitialAd ? "interstitial" : "rewarded"
        
        if ad is GADInterstitialAd {
            interstitialAd = nil
        } else if ad is GADRewardedAd {
            rewardedAd = nil
        }
        
        channel?.invokeMethod("onAdDismissed", arguments: ["type": type])
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        let type = ad is GADInterstitialAd ? "interstitial" : "rewarded"
        
        if ad is GADInterstitialAd {
            interstitialAd = nil
        } else if ad is GADRewardedAd {
            rewardedAd = nil
        }
        
        channel?.invokeMethod("onAdFailedToShow", arguments: [
            "type": type,
            "error": error.localizedDescription
        ])
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Called when the ad is about to be presented
        let type = ad is GADInterstitialAd ? "interstitial" : "rewarded"
        channel?.invokeMethod("onAdShowed", arguments: ["type": type])
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        // Called when an impression is recorded
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        // Called when a click is recorded
    }
    
    private func loadBannerAd(adUnitId: String, sizeIndex: Int, result: @escaping FlutterResult) {
        let bannerId = UUID().uuidString
        let bannerView = GADBannerView()
        bannerView.adUnitID = adUnitId
        
        let adSize: GADAdSize
        switch sizeIndex {
        case 0:
            adSize = GADAdSizeBanner
        case 1:
            adSize = GADAdSizeLargeBanner
        case 2:
            adSize = GADAdSizeMediumRectangle
        case 3:
            adSize = GADAdSizeFullBanner
        case 4:
            adSize = GADAdSizeLeaderboard
        case 5:
            if let rootViewController = getRootViewController() {
                adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(
                    rootViewController.view.frame.size.width
                )
            } else {
                adSize = GADAdSizeBanner
            }
        default:
            adSize = GADAdSizeBanner
        }
        
        bannerView.adSize = adSize
        bannerView.rootViewController = getRootViewController()
        bannerView.delegate = self
        
        // Store the banner and result for later use
        bannerAds[bannerId] = bannerView
        pendingResults[bannerId] = result
        
        let request = GADRequest()
        bannerView.load(request)
    }
    
    private func showBannerAd(bannerId: String, result: @escaping FlutterResult) {
        guard let bannerView = bannerAds[bannerId] else {
            result(FlutterError(code: "BANNER_NOT_FOUND",
                                message: "Banner with ID \(bannerId) not found",
                                details: nil))
            return
        }
        
        if let rootViewController = getRootViewController() {
            bannerView.removeFromSuperview()
            rootViewController.view.addSubview(bannerView)
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bannerView.bottomAnchor.constraint(equalTo: rootViewController.view.safeAreaLayoutGuide.bottomAnchor),
                bannerView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor)
            ])
            
            result(true)
        } else {
            result(FlutterError(code: "NO_ROOT_VIEW",
                                message: "Unable to find root view controller",
                                details: nil))
        }
    }
    
    private func hideBannerAd(bannerId: String, result: @escaping FlutterResult) {
        guard let bannerView = bannerAds[bannerId] else {
            result(FlutterError(code: "BANNER_NOT_FOUND",
                                message: "Banner with ID \(bannerId) not found",
                                details: nil))
            return
        }
        
        bannerView.removeFromSuperview()
        result(true)
    }
    
    private func disposeBannerAd(bannerId: String, result: @escaping FlutterResult) {
        guard let bannerView = bannerAds[bannerId] else {
            result(FlutterError(code: "BANNER_NOT_FOUND",
                                message: "Banner with ID \(bannerId) not found",
                                details: nil))
            return
        }
        
        bannerView.removeFromSuperview()
        bannerAds.removeValue(forKey: bannerId)
        result(true)
    }
    
    private func loadNativeAd(adUnitId: String, result: @escaping FlutterResult) {
        let nativeAdId = UUID().uuidString
        
        let adLoader = GADAdLoader(
            adUnitID: adUnitId,
            rootViewController: getRootViewController(),
            adTypes: [.native],
            options: nil
        )
        
        adLoader.delegate = self
        
        // Store the loader and result for later use
        adLoaders[nativeAdId] = adLoader
        pendingResults[nativeAdId] = result
        
        let request = GADRequest()
        adLoader.load(request)
    }
    
    private func showNativeAd(nativeAdId: String, result: @escaping FlutterResult) {
        guard let _ = nativeAds[nativeAdId] else {
            result(FlutterError(code: "NATIVE_AD_NOT_FOUND",
                                message: "Native ad with ID \(nativeAdId) not found",
                                details: nil))
            return
        }
        
        // Native ads in iOS are typically shown through custom views
        // For this plugin, we just verify the ad exists
        result(true)
    }
    
    private func disposeNativeAd(nativeAdId: String, result: @escaping FlutterResult) {
        guard nativeAds[nativeAdId] != nil else {
            result(FlutterError(code: "NATIVE_AD_NOT_FOUND",
                                message: "Native ad with ID \(nativeAdId) not found",
                                details: nil))
            return
        }
        
        nativeAds.removeValue(forKey: nativeAdId)
        result(true)
    }
}