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
    private var fullScreenView: FullScreenNativeAdView?
    private var style: [String: Any]?
    private var template: Int?
    private var isFullScreen: Bool = false
    
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
        if let params = args as? [String: Any] {
            if let nativeAdId = params["nativeAdId"] as? String {
                // Get style and template parameters
                style = params["style"] as? [String: Any]
                template = params["template"] as? Int
                isFullScreen = params["isFullScreen"] as? Bool ?? false
                
                // Get the native ad from the plugin
                if let nativeAd = plugin?.getNativeAd(for: nativeAdId) {
                    if isFullScreen {
                        setupFullScreenNativeAdView(nativeAd: nativeAd)
                    } else {
                        setupNativeAdView(nativeAd: nativeAd)
                    }
                }
            }
        }
    }
    
    private func setupFullScreenNativeAdView(nativeAd: GADNativeAd) {
        fullScreenView = FullScreenNativeAdView(
            frame: _view.bounds,
            nativeAd: nativeAd,
            style: style
        )
        fullScreenView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let fullScreenView = fullScreenView else { return }
        
        _view.addSubview(fullScreenView)
        
        NSLayoutConstraint.activate([
            fullScreenView.topAnchor.constraint(equalTo: _view.topAnchor),
            fullScreenView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            fullScreenView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            fullScreenView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])
    }
    
    private func setupNativeAdView(nativeAd: GADNativeAd) {
        // Create a simple native ad view
        nativeAdView = GADNativeAdView(frame: _view.bounds)
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let nativeAdView = nativeAdView else { return }
        
        // Create UI elements
        let contentView = UIView()
        
        // Apply background color from style if available
        if let bgColor = style?["backgroundColor"] as? Int {
            contentView.backgroundColor = UIColor(rgb: bgColor)
        } else {
            contentView.backgroundColor = .white
        }
        
        // Apply corner radius if available
        if let cornerRadius = style?["cornerRadius"] as? Double {
            contentView.layer.cornerRadius = CGFloat(cornerRadius)
            contentView.clipsToBounds = true
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Headline
        let headlineLabel = UILabel()
        
        // Apply headline style if available
        if let headlineStyle = style?["headlineTextStyle"] as? [String: Any] {
            let fontSize = (headlineStyle["fontSize"] as? Double) ?? 18
            let fontWeight = (headlineStyle["fontWeight"] as? Int) ?? 6
            headlineLabel.font = .systemFont(ofSize: CGFloat(fontSize), weight: getFontWeight(fontWeight))
            
            if let textColor = headlineStyle["color"] as? Int {
                headlineLabel.textColor = UIColor(rgb: textColor)
            } else {
                headlineLabel.textColor = .black
            }
        } else {
            headlineLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            headlineLabel.textColor = .black
        }
        
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Body
        let bodyLabel = UILabel()
        
        // Apply body style if available
        if let bodyStyle = style?["bodyTextStyle"] as? [String: Any] {
            let fontSize = (bodyStyle["fontSize"] as? Double) ?? 14
            bodyLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            
            if let textColor = bodyStyle["color"] as? Int {
                bodyLabel.textColor = UIColor(rgb: textColor)
            } else {
                bodyLabel.textColor = .darkGray
            }
        } else {
            bodyLabel.font = .systemFont(ofSize: 14)
            bodyLabel.textColor = .darkGray
        }
        
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Call to action button
        let ctaButton = UIButton(type: .system)
        
        // Apply call to action style if available
        if let ctaStyle = style?["callToActionStyle"] as? [String: Any] {
            if let bgColor = ctaStyle["backgroundColor"] as? Int {
                ctaButton.backgroundColor = UIColor(rgb: bgColor)
            } else {
                ctaButton.backgroundColor = .systemBlue
            }
            
            if let textColor = ctaStyle["textColor"] as? Int {
                ctaButton.setTitleColor(UIColor(rgb: textColor), for: .normal)
            } else {
                ctaButton.setTitleColor(.white, for: .normal)
            }
            
            if let textStyle = ctaStyle["textStyle"] as? [String: Any],
               let fontSize = textStyle["fontSize"] as? Double {
                ctaButton.titleLabel?.font = .systemFont(ofSize: CGFloat(fontSize), weight: .medium)
            } else {
                ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            }
            
            if let cornerRadius = ctaStyle["cornerRadius"] as? Double {
                ctaButton.layer.cornerRadius = CGFloat(cornerRadius)
            } else {
                ctaButton.layer.cornerRadius = 4
            }
        } else {
            ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            ctaButton.backgroundColor = .systemBlue
            ctaButton.setTitleColor(.white, for: .normal)
            ctaButton.layer.cornerRadius = 4
        }
        
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ad attribution label
        let adLabel = UILabel()
        
        // Apply attribution style if available
        if let attrStyle = style?["attributionStyle"] as? [String: Any] {
            adLabel.text = (attrStyle["text"] as? String) ?? "Ad"
            
            if let textStyle = attrStyle["textStyle"] as? [String: Any],
               let fontSize = textStyle["fontSize"] as? Double {
                adLabel.font = .systemFont(ofSize: CGFloat(fontSize))
            } else {
                adLabel.font = .systemFont(ofSize: 11)
            }
            
            if let textColor = (attrStyle["textStyle"] as? [String: Any])?["color"] as? Int {
                adLabel.textColor = UIColor(rgb: textColor)
            } else {
                adLabel.textColor = .white
            }
            
            if let bgColor = attrStyle["backgroundColor"] as? Int {
                adLabel.backgroundColor = UIColor(rgb: bgColor)
            } else {
                adLabel.backgroundColor = .systemOrange
            }
            
            if let cornerRadius = attrStyle["cornerRadius"] as? Double {
                adLabel.layer.cornerRadius = CGFloat(cornerRadius)
            } else {
                adLabel.layer.cornerRadius = 3
            }
        } else {
            adLabel.text = "Ad"
            adLabel.font = .systemFont(ofSize: 11)
            adLabel.textColor = .white
            adLabel.backgroundColor = .systemOrange
            adLabel.layer.cornerRadius = 3
        }
        
        adLabel.textAlignment = .center
        adLabel.clipsToBounds = true
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add media view if the ad has media content
        var mediaView: GADMediaView?
        let mediaStyle = style?["mediaStyle"] as? [String: Any]
        if nativeAd.mediaContent != nil {
            mediaView = GADMediaView()
            mediaView?.translatesAutoresizingMaskIntoConstraints = false
            
            // Apply corner radius if specified
            if let cornerRadius = mediaStyle?["cornerRadius"] as? Double {
                mediaView?.layer.cornerRadius = CGFloat(cornerRadius)
                mediaView?.clipsToBounds = true
            }
            
            contentView.addSubview(mediaView!)
            nativeAdView.mediaView = mediaView
        }
        
        // Add subviews
        contentView.addSubview(headlineLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(ctaButton)
        contentView.addSubview(adLabel)
        nativeAdView.addSubview(contentView)
        
        // Set up constraints
        var constraints = [
            contentView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
            
            adLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            adLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            adLabel.widthAnchor.constraint(equalToConstant: 25),
            adLabel.heightAnchor.constraint(equalToConstant: 15)
        ]
        
        // Add media view constraints if present
        if let mediaView = mediaView {
            constraints.append(contentsOf: [
                mediaView.topAnchor.constraint(equalTo: adLabel.bottomAnchor, constant: 8),
                mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
            ])
            
            // Apply aspect ratio constraint if specified
            let aspectRatio = mediaStyle?["aspectRatio"] as? Double ?? 1.77
            constraints.append(mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: CGFloat(1.0 / aspectRatio)))
            
            constraints.append(contentsOf: [
                headlineLabel.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
                headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
            ])
        } else {
            constraints.append(contentsOf: [
                headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                headlineLabel.leadingAnchor.constraint(equalTo: adLabel.trailingAnchor, constant: 8),
                headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
            ])
        }
        
        constraints.append(contentsOf: [
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 12),
            ctaButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            ctaButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate(constraints)
        
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
    
    // Helper function to convert font weight index to UIFont.Weight
    private func getFontWeight(_ index: Int) -> UIFont.Weight {
        switch index {
        case 0: return .ultraLight
        case 1: return .thin
        case 2: return .light
        case 3: return .regular
        case 4: return .medium
        case 5: return .semibold
        case 6: return .bold
        case 7: return .heavy
        case 8: return .black
        default: return .regular
        }
    }
}

// Extension to create UIColor from Int (ARGB)
extension UIColor {
    convenience init(rgb: Int) {
        let alpha = CGFloat((rgb >> 24) & 0xFF) / 255.0
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}