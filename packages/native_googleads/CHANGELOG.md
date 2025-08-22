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
- Example: renamed UI actions to “Preload” for interstitial/rewarded; removed Multi-Preload Manager demo.

### Tests
- Unit tests for validation policy behavior (warn-only, strict, and disabled modes).
