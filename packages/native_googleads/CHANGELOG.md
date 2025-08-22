# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-12-22

### Added
- Banner ad support with multiple size options
  - Standard banner (320x50)
  - Large banner (320x100)
  - Medium rectangle (300x250)
  - Full banner (468x60)
  - Leaderboard (728x90)
  - Adaptive banner (width based on device)
- Native ad support for customizable ads
- BannerAdWidget for easy banner integration
- NativeAdWidget for easy native ad integration
- New methods: loadBannerAd, showBannerAd, hideBannerAd, disposeBannerAd
- New methods: loadNativeAd, showNativeAd, disposeNativeAd
- Test ad unit IDs for banner and native ads
- Comprehensive tests for new ad types

### Fixed
- Missing native platform implementations for banner ads
- Missing native platform implementations for native ads

## [1.0.0] - 2024-12-22

### Added
- Initial release of Native Google Ads Flutter plugin
- Full support for Android (Kotlin) and iOS (Swift)
- Interstitial ad support with complete lifecycle callbacks
- Rewarded ad support with reward callbacks
- Flexible initialization with App ID passed from Dart
- Test mode configuration for development
- Comprehensive ad callbacks for all events
- AdConfig class for easy configuration management
- AdRequestConfig for customizing ad requests
- Built-in test ad unit IDs for development
- Swift Package Manager support for iOS
- Modern Kotlin implementation for Android
- Complete example application
- Comprehensive documentation and setup guides

### Platform Requirements
- Android: API 24+ (Android 7.0+)
- iOS: 13.0+
- Flutter: 3.0.0+
- Dart: 2.17.0+

## [0.2.0-beta] - 2024-12-20

### Added
- Beta implementation of core ad functionality
- Basic interstitial ad support
- Basic rewarded ad support

## [0.1.0-alpha] - 2024-12-15

### Added
- Initial alpha release
- Project structure setup
- Basic plugin architecture