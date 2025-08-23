# Native Google Ads Example

Concise example app for the Native Google Ads Flutter plugin. It demonstrates the core, non-redundant flows only:

- Banner Ads: render with selectable sizes and simple success/fail handling
- Native Ads: adjustable height with optional preload toggle (preload → render)
- Interstitial Ads: preload → show with callbacks and readiness updates
- Rewarded Ads: preload → show with callbacks and reward tracking

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio or Xcode
- (Optional) AdMob account for production

### Setup
1) Install deps
```bash
flutter pub get
```
2) Android test App ID is set in `android/app/src/main/AndroidManifest.xml`.
3) iOS test App ID is set in `ios/Runner/Info.plist`.
   If needed, run:
```bash
cd ios && pod install && cd ..
```

### Run
```bash
flutter run            # Android
flutter run --release  # iOS (ads in release)
```

## Code Structure
```
lib/
└── main.dart
```

## Basics

Initialization
```dart
final ads = NativeGoogleads.instance;
await ads.initialize(appId: Platform.isAndroid
    ? AdTestIds.androidAppId
    : AdTestIds.iosAppId);
```

Interstitial/Rewarded flow (preload → show)
```dart
final interstitialId = Platform.isAndroid
    ? AdTestIds.androidInterstitial
    : AdTestIds.iosInterstitial;
await ads.preloadInterstitialAd(adUnitId: interstitialId);
final ok = await ads.showInterstitialAd(adUnitId: interstitialId);
```

Callbacks
```dart
ads.setAdCallbacks(
  onAdDismissed: (type) {},
  onAdShowed: (type) {},
  onAdFailedToShow: (type, error) {},
  onUserEarnedReward: (t, a) {},
);
```

## Test IDs

Android
- App ID: `ca-app-pub-3940256099942544~3347511713`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

iOS
- App ID: `ca-app-pub-3940256099942544~1458002511`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

Notes
- Banner/Native use test units inside the example code.
- Banner/Native gracefully hide/skip on failure to keep UI clean.
- Native page includes a "Use preloaded" toggle and a preload button that calls `loadNativeAd(...)`, then renders via `preloadedNativeAdId`.
### Ads not loading
- Check internet connection
- Verify App IDs are correct
- Check console logs for error messages

### iOS specific issues
- Run in release mode: `flutter run --release`
- Ensure pods are updated: `cd ios && pod update`
- Check Info.plist configuration

### Android specific issues
- Verify minimum SDK is 24
- Check AndroidManifest.xml configuration
- Run `flutter clean` and rebuild

## Production Setup

To use in production:

1. Replace test App IDs with your production App IDs
2. Replace test ad unit IDs with your production ad unit IDs
3. Remove or conditionally compile test code
4. Test thoroughly on real devices

## Additional Resources

- [AdMob Documentation](https://developers.google.com/admob)
- [Flutter Documentation](https://flutter.dev/docs)
- [Plugin Documentation](https://github.com/dvelop42/flutter_native/tree/main/packages/native_googleads)

## License

MIT - See LICENSE file for details
 
---

Notes:
- When using `BannerAdWidget` in the example, do not call `showBannerAd`/`hideBannerAd`; the PlatformView attaches the banner inside the widget.
- On iOS, the programmatic `showBannerAd` API attaches banners to the root view controller, not inside a widget tree.
