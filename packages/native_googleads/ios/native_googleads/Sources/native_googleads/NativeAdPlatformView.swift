import Flutter
import UIKit
import GoogleMobileAds

class NativeAdPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var plugin: NativeGoogleadsPlugin?
    
    init(plugin: NativeGoogleadsPlugin) {
        self.plugin = plugin
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeAdPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            plugin: plugin
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeAdPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private weak var plugin: NativeGoogleadsPlugin?
    private var nativeAdView: GADNativeAdView?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        plugin: NativeGoogleadsPlugin?
    ) {
        _view = UIView()
        self.plugin = plugin
        super.init()
        
        // Get the native ad ID from arguments
        if let params = args as? [String: Any],
           let nativeAdId = params["nativeAdId"] as? String {
            // Get the native ad from the plugin
            if let nativeAd = plugin?.getNativeAd(for: nativeAdId) {
                setupNativeAdView(nativeAd: nativeAd)
            }
        }
    }
    
    private func setupNativeAdView(nativeAd: GADNativeAd) {
        // Create a simple native ad view
        nativeAdView = GADNativeAdView(frame: _view.bounds)
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let nativeAdView = nativeAdView else { return }
        
        // Create UI elements
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Headline
        let headlineLabel = UILabel()
        headlineLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        headlineLabel.textColor = .black
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Body
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textColor = .darkGray
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Call to action button
        let ctaButton = UIButton(type: .system)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 4
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ad attribution label
        let adLabel = UILabel()
        adLabel.text = "Ad"
        adLabel.font = .systemFont(ofSize: 11)
        adLabel.textColor = .white
        adLabel.backgroundColor = .systemOrange
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 3
        adLabel.clipsToBounds = true
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(headlineLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(ctaButton)
        contentView.addSubview(adLabel)
        nativeAdView.addSubview(contentView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
            
            adLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            adLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            adLabel.widthAnchor.constraint(equalToConstant: 25),
            adLabel.heightAnchor.constraint(equalToConstant: 15),
            
            headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            headlineLabel.leadingAnchor.constraint(equalTo: adLabel.trailingAnchor, constant: 8),
            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 12),
            ctaButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            ctaButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Assign native ad assets to views
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.callToActionView = ctaButton
        
        // Populate the views with native ad data
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body
        if let cta = nativeAd.callToAction {
            ctaButton.setTitle(cta, for: .normal)
        }
        
        // Associate the native ad with the view
        nativeAdView.nativeAd = nativeAd
        
        // Add the native ad view to the main view
        _view.addSubview(nativeAdView)
        
        NSLayoutConstraint.activate([
            nativeAdView.topAnchor.constraint(equalTo: _view.topAnchor),
            nativeAdView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])
    }
    
    func view() -> UIView {
        return _view
    }
}