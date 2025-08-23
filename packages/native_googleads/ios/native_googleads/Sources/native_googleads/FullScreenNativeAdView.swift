import UIKit
import GoogleMobileAds

class FullScreenNativeAdView: UIView {
    private var nativeAdView: GADNativeAdView?
    private var nativeAd: GADNativeAd
    private var style: [String: Any]?
    private var gradientLayer: CAGradientLayer?
    
    init(frame: CGRect, nativeAd: GADNativeAd, style: [String: Any]? = nil) {
        self.nativeAd = nativeAd
        self.style = style
        super.init(frame: frame)
        setupFullScreenView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFullScreenView() {
        // Create native ad view that fills the entire screen
        nativeAdView = GADNativeAdView(frame: bounds)
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let nativeAdView = nativeAdView else { return }
        
        // Main container with black background for full screen effect
        let mainContainer = UIView()
        mainContainer.backgroundColor = .black
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Media view for full screen media content
        let mediaView = GADMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFit
        mainContainer.addSubview(mediaView)
        nativeAdView.mediaView = mediaView
        
        // Gradient overlay for text readability
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer?.locations = [0, 0.3, 0.7, 1]
        gradientLayer?.frame = bounds
        
        let gradientView = UIView()
        if let gradientLayer = gradientLayer {
            gradientView.layer.addSublayer(gradientLayer)
        }
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(gradientView)
        
        // Top section with ad attribution
        let topSection = UIStackView()
        topSection.axis = .horizontal
        topSection.alignment = .center
        topSection.spacing = 12
        topSection.translatesAutoresizingMaskIntoConstraints = false
        
        // Ad attribution label
        let adLabel = UILabel()
        adLabel.text = "AD"
        adLabel.font = .systemFont(ofSize: 11, weight: .bold)
        adLabel.textColor = .black
        adLabel.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0, alpha: 1.0) // Gold color
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 3
        adLabel.clipsToBounds = true
        
        // Add padding to ad label
        let paddedAdLabel = UIView()
        paddedAdLabel.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0, alpha: 1.0)
        paddedAdLabel.layer.cornerRadius = 3
        paddedAdLabel.clipsToBounds = true
        paddedAdLabel.addSubview(adLabel)
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adLabel.topAnchor.constraint(equalTo: paddedAdLabel.topAnchor, constant: 2),
            adLabel.bottomAnchor.constraint(equalTo: paddedAdLabel.bottomAnchor, constant: -2),
            adLabel.leadingAnchor.constraint(equalTo: paddedAdLabel.leadingAnchor, constant: 6),
            adLabel.trailingAnchor.constraint(equalTo: paddedAdLabel.trailingAnchor, constant: -6)
        ])
        
        topSection.addArrangedSubview(paddedAdLabel)
        
        // Advertiser/Store info if available
        if let advertiser = nativeAd.advertiser ?? nativeAd.store {
            let advertiserLabel = UILabel()
            advertiserLabel.text = advertiser
            advertiserLabel.font = .systemFont(ofSize: 14)
            advertiserLabel.textColor = .white
            topSection.addArrangedSubview(advertiserLabel)
            nativeAdView.advertiserView = advertiserLabel
        }
        
        topSection.addArrangedSubview(UIView()) // Spacer
        
        mainContainer.addSubview(topSection)
        
        // Bottom section with headline, body, and CTA
        let bottomSection = UIStackView()
        bottomSection.axis = .vertical
        bottomSection.alignment = .leading
        bottomSection.spacing = 12
        bottomSection.translatesAutoresizingMaskIntoConstraints = false
        
        // Headline
        let headlineLabel = UILabel()
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = .systemFont(ofSize: 24, weight: .bold)
        headlineLabel.textColor = .white
        headlineLabel.numberOfLines = 2
        bottomSection.addArrangedSubview(headlineLabel)
        nativeAdView.headlineView = headlineLabel
        
        // Body text
        if let body = nativeAd.body {
            let bodyLabel = UILabel()
            bodyLabel.text = body
            bodyLabel.font = .systemFont(ofSize: 16)
            bodyLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
            bodyLabel.numberOfLines = 3
            bottomSection.addArrangedSubview(bodyLabel)
            nativeAdView.bodyView = bodyLabel
        }
        
        // Call to action button
        if let cta = nativeAd.callToAction {
            let ctaButton = UIButton(type: .system)
            ctaButton.setTitle(cta, for: .normal)
            ctaButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            ctaButton.backgroundColor = UIColor(red: 0.1, green: 0.46, blue: 0.82, alpha: 1.0) // Blue
            ctaButton.setTitleColor(.white, for: .normal)
            ctaButton.layer.cornerRadius = 8
            ctaButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
            bottomSection.addArrangedSubview(ctaButton)
            nativeAdView.callToActionView = ctaButton
        }
        
        mainContainer.addSubview(bottomSection)
        
        // Add main container to native ad view
        nativeAdView.addSubview(mainContainer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Main container fills the entire view
            mainContainer.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
            
            // Media view fills the entire container
            mediaView.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            
            // Gradient overlay
            gradientView.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            
            // Top section
            topSection.topAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.topAnchor, constant: 20),
            topSection.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 20),
            topSection.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -20),
            
            // Bottom section
            bottomSection.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 20),
            bottomSection.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -20),
            bottomSection.bottomAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Associate the native ad with the view
        nativeAdView.nativeAd = nativeAd
        
        // Add native ad view to this view
        addSubview(nativeAdView)
        
        NSLayoutConstraint.activate([
            nativeAdView.topAnchor.constraint(equalTo: topAnchor),
            nativeAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient layer frame safely
        gradientLayer?.frame = bounds
    }
}