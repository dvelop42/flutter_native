import Flutter
import UIKit
import GoogleMobileAds

class BannerAdPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return BannerAdPlatformView(
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

class BannerAdPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private weak var plugin: NativeGoogleadsPlugin?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        plugin: NativeGoogleadsPlugin?
    ) {
        _view = UIView()
        self.plugin = plugin
        super.init()
        
        // Get the banner ID from arguments
        if let params = args as? [String: Any],
           let bannerId = params["bannerId"] as? String {
            // Get the banner ad view from the plugin
            if let bannerView = plugin?.getBannerView(for: bannerId) {
                bannerView.removeFromSuperview()
                _view.addSubview(bannerView)
                
                // Setup constraints
                bannerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    bannerView.topAnchor.constraint(equalTo: _view.topAnchor),
                    bannerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                    bannerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                    bannerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
                ])
            }
        }
    }
    
    func view() -> UIView {
        return _view
    }
}