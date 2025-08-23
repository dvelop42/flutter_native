# Changelog

All notable changes to this project are documented in this file.

The format follows Keep a Changelog and this project adheres to Semantic Versioning.

## [0.0.1] - 2025-08-22

### Added
- Initial release of the `native_googleads` Flutter plugin.
- Android and iOS implementations using native SDKs (Kotlin/Swift).
- Interstitial and rewarded ads with lifecycle callbacks.
- Banner and native ads with platform views.
- Helper widgets: `BannerAdWidget` and `NativeAdWidget`.
- Configuration via `AdConfig` and `AdRequestConfig`.
- Built-in Google test ad unit IDs and example app.
## [0.0.3] - 2025-08-23

### Added
- **Native ad customization support**: New `NativeAdStyle` class for customizing native ad appearance
  - Typography controls (headline, body, advertiser, price, store, call-to-action)
  - Color schemes (background, text colors)
  - Layout controls (padding, corner radius)
  - Media styling (aspect ratio, corner radius)
  - Button styling (background color, text color, corner radius)
- **Full-screen native ads**: New `isFullScreen` parameter for immersive ad experiences
- **Native ad templates**: Added `NativeAdTemplate` enum (small, medium, banner, large templates)
- **iOS timeout mechanism**: Added 30-second timeout for pending ad results to prevent indefinite waits
- Integration tests for platform views and ad lifecycle management

### Changed
- Improved native ad widget initialization with better creation params caching
- Enhanced error handling with timeout support in `NativeAdWidget`
- Updated example app to demonstrate new customization features

### Fixed
- iOS ad loading reliability with timeout mechanism for pending results

## [0.0.2] - 2025-08-22

### Added
- Preloaded rendering support for widgets:
  - `BannerAdWidget(preloadedBannerId: ...)`
  - `NativeAdWidget(preloadedNativeAdId: ...)`
- Production/test ID validation policy in Dart:
  - Warn or throw on Google test IDs in release; configurable via `setAdIdValidationPolicy`.
- New example pages: Preloaded Banner, Preloaded Native, and Preloaded Fullscreen Ads; UI overflow fixes and graceful failure handling.

### Changed
- README and example docs updated to remove unimplemented features and reflect current APIs.
- Example: renamed UI actions to "Preload" for interstitial/rewarded; removed Multi-Preload Manager demo.

### Tests
- Unit tests for validation policy behavior (warn-only, strict, and disabled modes).
