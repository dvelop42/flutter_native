# Native Google Ads Example

A complete example application demonstrating the Native Google Ads Flutter plugin.

## Features Demonstrated

- ✅ AdMob SDK initialization
- ✅ Interstitial ad loading and display
- ✅ Rewarded ad loading and display
- ✅ Ad callbacks handling
- ✅ Reward tracking
- ✅ Test ads integration

## Getting Started

### Prerequisites

1. Flutter SDK installed
2. Android Studio or Xcode (for platform-specific setup)
3. An AdMob account (optional for production)

### Setup Instructions

#### 1. Clone the repository

```bash
git clone https://github.com/dvelop42/native_googleads.git
cd native_googleads/example
```

#### 2. Install dependencies

```bash
flutter pub get
```

#### 3. Platform-specific setup

##### Android Setup

1. Open `android/app/src/main/AndroidManifest.xml`
2. The test App ID is already configured:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-3940256099942544~3347511713"/>
   ```
3. For production, replace with your actual App ID

##### iOS Setup

1. Open `ios/Runner/Info.plist`
2. The test App ID is already configured:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-3940256099942544~1458002511</string>
   ```
3. For production, replace with your actual App ID
4. Run `pod install` in the `ios` directory:
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Running the Example

```bash
# For Android
flutter run

# For iOS
flutter run --release
```

> **Note**: On iOS, ads may not show properly in debug mode. Use `--release` flag for testing.

## Example Code Structure

```
lib/
└── main.dart          # Main example application
```

### Key Components

#### Initialization

```dart
final NativeGoogleads _ads = NativeGoogleads.instance;

// Initialize with test App ID
final appId = Platform.isAndroid
    ? AdTestIds.androidAppId
    : AdTestIds.iosAppId;

await _ads.initialize(appId: appId);
```

#### Loading Ads

```dart
// Load interstitial ad
final adUnitId = Platform.isAndroid
    ? AdTestIds.androidInterstitial
    : AdTestIds.iosInterstitial;

await _ads.preloadInterstitialAd(adUnitId: adUnitId);

// Load rewarded ad
final rewardedAdUnitId = Platform.isAndroid
    ? AdTestIds.androidRewarded
    : AdTestIds.iosRewarded;

await _ads.preloadRewardedAd(adUnitId: rewardedAdUnitId);
```

#### Preloaded Fullscreen Ads (Demo Page)

The example includes a dedicated page to experience preloading behavior for interstitial and rewarded ads:

- Navigate to: Home → "Preloaded Fullscreen Ads"
- Actions per ad type:
  - Preload: loads and warms the cache
  - Check Ready: queries native cache state
  - Show: displays when ready
- After dismiss or failure, native code auto-preloads next; the UI reflects readiness after a short delay.

#### Preloaded Banner (Demo Page)

- Flow: tap Preload to call `loadBannerAd(...)`, then render via `BannerAdWidget(preloadedBannerId: ...)`.
- Notes:
  - Widget accepts a preloaded banner ID to skip internal loading.
  - On iOS, prefer the widget approach over programmatic `showBannerAd` to place the banner in the layout.

#### Preloaded Native (Demo Page)

- Flow: tap Preload to call `loadNativeAd(...)`, then render via `NativeAdWidget(preloadedNativeAdId: ...)`.
- Notes:
  - Widget accepts a preloaded native ad ID to skip internal loading.
  - On failure, the card is skipped to keep content flow natural.

#### Setting Up Callbacks

```dart
_ads.setAdCallbacks(
  onAdDismissed: (adType) {
    print('Ad dismissed: $adType');
    // Reset ad state
  },
  onAdShowed: (adType) {
    print('Ad showed: $adType');
  },
  onAdFailedToShow: (adType, error) {
    print('Ad failed: $adType, error: $error');
  },
  onUserEarnedReward: (type, amount) {
    print('Reward earned: $amount $type');
    // Grant reward to user
  },
);

### Preload → Check → Show (with auto-preload)

```dart
late final String interstitialId;

Future<void> initAds() async {
  // Initialize with test App ID for development
  await _ads.initialize(appId: Platform.isAndroid
      ? AdTestIds.androidAppId
      : AdTestIds.iosAppId);
  interstitialId = Platform.isAndroid
      ? AdTestIds.androidInterstitial
      : AdTestIds.iosInterstitial;
  await _ads.preloadInterstitialAd(adUnitId: interstitialId);

  _ads.setAdCallbacks(
    onAdDismissed: (type) async {
      if (type == 'interstitial') {
        // Native layer auto-preloads the next ad for this ID.
        await Future.delayed(const Duration(milliseconds: 200));
        final ready = await _ads.isInterstitialReady(interstitialId);
        // update UI state based on `ready`
      }
    },
  );
}

Future<void> onPlayPressed() async {
  final ready = await _ads.isInterstitialReady(interstitialId);
  if (!ready) {
    await _ads.preloadInterstitialAd(adUnitId: interstitialId);
    return; // Show later when ready
  }
  await _ads.showInterstitialAd(adUnitId: interstitialId);
}
```
```

## Test Ad Unit IDs

The example uses Google's test ad unit IDs:

### Android
- App ID: `ca-app-pub-3940256099942544~3347511713`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

### iOS
- App ID: `ca-app-pub-3940256099942544~1458002511`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

## UI Components

The example app includes:

1. **Status Display**: Shows initialization status
2. **Reward Counter**: Displays total rewards earned
3. **Interstitial Ad Card**: 
   - Load button
   - Show button (enabled when ad is ready)
   - Status indicator
4. **Rewarded Ad Card**:
   - Load button
   - Show button (enabled when ad is ready)
   - Status indicator
5. **Preloaded Fullscreen Ads**:
   - Combined page for Interstitial + Rewarded
   - Preload / Check Ready / Show controls
   - Shows auto-preload behavior after dismissal

### Handling Load Failures Gracefully

- Banner Ads: if loading fails, the banner slot is hidden automatically, avoiding awkward blank space.
- Native Ads: the demo skips the native ad insertion when load fails, letting content flow naturally.

## Troubleshooting

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
