# Native Google Ads

[![pub package](https://img.shields.io/pub/v/native_googleads.svg)](https://pub.dev/packages/native_googleads)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue)](https://flutter.dev)

A Flutter plugin for integrating Google Mobile Ads (AdMob) using native platform implementations. This plugin provides a simple and efficient way to display banner, native, interstitial, and rewarded ads in your Flutter applications.

## Features

- ✅ **Native Implementation** - Direct integration with Google Mobile Ads SDK
- ✅ **iOS & Android Support** - Full support for both platforms
- ✅ **Banner Ads** - Display banner ads in various sizes including adaptive
- ✅ **Native Ads** - Fully customizable native ads with templates and styling options
- ✅ **Interstitial Ads** - Full-screen ads at natural transition points
- ✅ **Rewarded Ads** - Reward users for watching video ads
- ✅ **Platform Views** - Native ad rendering using platform-specific views
- ✅ **Comprehensive Callbacks** - Full lifecycle event handling
- ✅ **Swift Package Manager** - Modern iOS dependency management
- ✅ **Kotlin Support** - Modern Android implementation

## Platform Support

| Platform | Minimum Version | Architecture |
|----------|----------------|--------------|
| Android  | API 24 (7.0)   | Kotlin       |
| iOS      | 13.0           | Swift        |

## Installation

Add `native_googleads` to your `pubspec.yaml`:

```yaml
dependencies:
  native_googleads: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android Setup

#### 1. Update `android/app/build.gradle`

Ensure your minimum SDK version is at least 24:

```gradle
android {
    defaultConfig {
        minSdkVersion 24
        // ... other configurations
    }
}
```

#### 2. Add AdMob App ID to AndroidManifest.xml

Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add your AdMob App ID here -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

> **Note**: Use test App ID `ca-app-pub-3940256099942544~3347511713` for development

### iOS Setup

#### 1. Update iOS Deployment Target (or Swift Package Manager)

In your `ios/Podfile`, ensure the platform version is at least 13.0:

```ruby
platform :ios, '13.0'
```

#### 2. Add AdMob App ID to Info.plist

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>

<!-- For iOS 14+ App Tracking Transparency -->
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>

<!-- Required SKAdNetwork identifiers -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add other SKAdNetwork identifiers as needed -->
</array>
```

> **Note**: Use test App ID `ca-app-pub-3940256099942544~1458002511` for development

#### 3. Update iOS Pods

```bash
cd ios
pod install
```

## Usage

### Basic Usage

```dart
import 'package:native_googleads/native_googleads.dart';

// Get the singleton instance
final ads = NativeGoogleads.instance;

// Initialize with App ID (use platform test App ID during development)
await ads.initialize(appId: 'your-app-id');

// Load and show a banner ad (programmatic API)
final bannerId = await ads.loadBannerAd(
  adUnitId: 'your-banner-ad-unit-id',
  size: BannerAdSize.adaptive,
);
if (bannerId != null) {
  await ads.showBannerAd(bannerId);
}

// Load and show a native ad (programmatic API)
final nativeAdId = await ads.loadNativeAd(
  adUnitId: 'your-native-ad-unit-id',
);
if (nativeAdId != null) {
  await ads.showNativeAd(nativeAdId);
}

// Preload and show interstitial ad
await ads.preloadInterstitialAd(
  adUnitId: 'your-interstitial-ad-unit-id',
);
await ads.showInterstitialAd(adUnitId: 'your-interstitial-ad-unit-id');

// Preload and show rewarded ad
await ads.preloadRewardedAd(
  adUnitId: 'your-rewarded-ad-unit-id',
);
await ads.showRewardedAd(adUnitId: 'your-rewarded-ad-unit-id');
```

## Caching

This plugin preloads and caches full-screen ads at the platform level per `adUnitId`.

- Preload: call `preloadInterstitialAd(adUnitId)` or `preloadRewardedAd(adUnitId)` ahead of time.
- Check: use `isInterstitialReady(adUnitId)` or `isRewardedReady(adUnitId)` before showing.
- Show: call `showInterstitialAd(adUnitId: ...)` or `showRewardedAd(adUnitId: ...)`.
- Auto-preload: after an ad is dismissed or fails to show, the native layer auto-preloads the next ad for the same `adUnitId` to keep a warm cache.

Best practices:
- Preload during app start or at natural pauses (e.g., level start).
- Always check readiness for smoother UX; if not ready, delay or show alternative UI.
- Use one `adUnitId` per placement; the cache holds one ready ad per type per `adUnitId`.

### Preload → Check → Show (with auto-preload)

```dart
import 'dart:io';
import 'package:native_googleads/native_googleads.dart';

final ads = NativeGoogleads.instance;
late final String interstitialId;

Future<void> initAds() async {
  interstitialId = Platform.isAndroid
      ? AdTestIds.androidInterstitial
      : AdTestIds.iosInterstitial;

  // 1) Initialize and preload early
  await ads.initialize(appId: Platform.isAndroid
      ? AdTestIds.androidAppId
      : AdTestIds.iosAppId);

  await ads.preloadInterstitialAd(adUnitId: interstitialId);

  // Optional: listen for lifecycle to reflect auto-preload
  ads.setAdCallbacks(
    onAdDismissed: (type) async {
      if (type == 'interstitial') {
        await Future.delayed(const Duration(milliseconds: 200));
        final ready = await ads.isInterstitialReady(interstitialId);
        // Update UI state accordingly
      }
    },
  );
}

Future<void> maybeShowInterstitial() async {
  // 2) Check readiness before showing
  final ready = await ads.isInterstitialReady(interstitialId);
  if (!ready) {
    await ads.preloadInterstitialAd(adUnitId: interstitialId);
    return;
  }

  // 3) Show when ready
  await ads.showInterstitialAd(adUnitId: interstitialId);
}
```

Use the same pattern for rewarded ads with `preloadRewardedAd`, `isRewardedReady`, and `showRewardedAd(adUnitId: ...)`.

### Using Test Ads

For development, always use test ad unit IDs:

```dart
import 'dart:io';

// Use test IDs during development
final testAdUnitId = Platform.isAndroid
    ? AdTestIds.androidInterstitial  // Test interstitial for Android
    : AdTestIds.iosInterstitial;      // Test interstitial for iOS

await ads.preloadInterstitialAd(adUnitId: testAdUnitId);
```

Available test IDs:
- `AdTestIds.androidInterstitial` / `AdTestIds.iosInterstitial`
- `AdTestIds.androidRewarded` / `AdTestIds.iosRewarded`
- `AdTestIds.androidBanner` / `AdTestIds.iosBanner`
- `AdTestIds.androidNativeAdvanced` / `AdTestIds.iosNativeAdvanced`

### Setting Up Callbacks

```dart
ads.setAdCallbacks(
  onAdDismissed: (adType) {
    print('Ad dismissed: $adType');
    // Handle ad dismissal
  },
  onAdShowed: (adType) {
    print('Ad showed: $adType');
    // Handle ad display
  },
  onAdFailedToShow: (adType, error) {
    print('Ad failed: $adType, error: $error');
    // Handle ad failure
  },
  onUserEarnedReward: (type, amount) {
    print('Reward earned: $amount $type');
    // Grant reward to user
  },
);
```

### Working with Banner Ads

Banner ads can be displayed in various sizes:

```dart
// Available banner sizes
BannerAdSize.banner           // 320x50
BannerAdSize.largeBanner       // 320x100
BannerAdSize.mediumRectangle   // 300x250
BannerAdSize.fullBanner        // 468x60
BannerAdSize.leaderboard       // 728x90
BannerAdSize.adaptive          // Adaptive size based on device width

// Load a banner ad (programmatic API)
final bannerId = await ads.loadBannerAd(
  adUnitId: Platform.isAndroid 
    ? AdTestIds.androidBanner 
    : AdTestIds.iosBanner,
  size: BannerAdSize.adaptive,
);

// Show the banner (programmatic API)
if (bannerId != null) {
  await ads.showBannerAd(bannerId);
}

// Hide the banner (keeps it loaded)
await ads.hideBannerAd(bannerId);

// Dispose when no longer needed
await ads.disposeBannerAd(bannerId);
```

You can also use the `BannerAdWidget` for easier integration:

```dart
BannerAdWidget(
  adUnitId: AdTestIds.androidBanner,
  size: BannerAdSize.adaptive,
  onAdLoaded: () => print('Banner loaded'),
  onAdFailedToLoad: (error) => print('Banner failed: $error'),
)
```

Note:
- When using `BannerAdWidget`, do not call `showBannerAd`/`hideBannerAd` — the PlatformView handles attaching/detaching the banner.
- On iOS, the programmatic `showBannerAd` attaches the banner to the root view controller, not inside a widget tree.
- If you preloaded via `loadBannerAd(...)`, you can render that ad by passing `preloadedBannerId` to the widget: `BannerAdWidget(preloadedBannerId: bannerId, ...)`.

### Working with Native Ads

Native ads allow you to customize the ad appearance to match your app:

```dart
// Load a native ad (programmatic API)
final nativeAdId = await ads.loadNativeAd(
  adUnitId: Platform.isAndroid 
    ? AdTestIds.androidNativeAdvanced 
    : AdTestIds.iosNativeAdvanced,
);

// Show the native ad (programmatic API)
if (nativeAdId != null) {
  await ads.showNativeAd(nativeAdId);
}

// Dispose when no longer needed
await ads.disposeNativeAd(nativeAdId);
```

Use the `NativeAdWidget` for easier integration:

```dart
NativeAdWidget(
  adUnitId: AdTestIds.androidNativeAdvanced,
  height: 300,
  backgroundColor: Colors.white,
  onAdLoaded: () => print('Native ad loaded'),
  onAdFailedToLoad: (error) => print('Native ad failed: $error'),
)
```

#### Customizing Native Ads (New in 0.0.3)

Customize the appearance of native ads with `NativeAdStyle`:

```dart
NativeAdWidget(
  adUnitId: AdTestIds.androidNativeAdvanced,
  height: 350,
  style: NativeAdStyle(
    // Typography customization
    headlineStyle: NativeAdTextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      textColor: Colors.black87,
    ),
    bodyStyle: NativeAdTextStyle(
      fontSize: 14,
      textColor: Colors.black54,
    ),
    
    // Layout customization
    backgroundColor: Colors.white,
    mainBackgroundColor: Colors.grey[50],
    cornerRadius: 12,
    padding: EdgeInsets.all(16),
    
    // Media customization
    mediaStyle: NativeAdMediaStyle(
      aspectRatio: 16 / 9,
      cornerRadius: 8,
    ),
    
    // Call-to-action button customization
    callToActionStyle: NativeAdButtonStyle(
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      cornerRadius: 6,
    ),
  ),
  onAdLoaded: () => print('Styled native ad loaded'),
)
```

#### Using Native Ad Templates (New in 0.0.3)

Choose from predefined templates for consistent native ad layouts:

```dart
NativeAdWidget(
  adUnitId: AdTestIds.androidNativeAdvanced,
  template: NativeAdTemplate.medium,  // small, medium, banner, or large
  height: 320,
  onAdLoaded: () => print('Template native ad loaded'),
)
```

#### Full-Screen Native Ads (New in 0.0.3)

Display native ads in full-screen mode for immersive experiences:

```dart
NativeAdWidget(
  adUnitId: AdTestIds.androidNativeAdvanced,
  isFullScreen: true,
  style: NativeAdStyle(
    backgroundColor: Colors.black,
    headlineStyle: NativeAdTextStyle(
      fontSize: 24,
      textColor: Colors.white,
    ),
    // ... other style properties
  ),
  onAdLoaded: () => print('Full-screen native ad loaded'),
)
```

Note:
- If you preloaded via `loadNativeAd(...)`, you can render that ad by passing `preloadedNativeAdId` to the widget: `NativeAdWidget(preloadedNativeAdId: nativeId, ...)`.

<!-- Advanced request configuration is currently not supported at the native layer. -->

## Complete Example

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_googleads/native_googleads.dart';

class AdExample extends StatefulWidget {
  @override
  _AdExampleState createState() => _AdExampleState();
}

class _AdExampleState extends State<AdExample> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  int _rewardAmount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    // Set up callbacks
    _ads.setAdCallbacks(
      onAdDismissed: (adType) {
        setState(() {
          if (adType == 'interstitial') _interstitialReady = false;
          if (adType == 'rewarded') _rewardedReady = false;
        });
      },
      onUserEarnedReward: (type, amount) {
        setState(() {
          _rewardAmount += amount;
        });
      },
    );

    // Initialize with test App ID for development
    await _ads.initialize(appId: Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId);
  }

  Future<void> _preloadInterstitialAd() async {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;

    final success = await _ads.preloadInterstitialAd(adUnitId: adUnitId);
    setState(() => _interstitialReady = success);
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialReady) {
      await _ads.showInterstitialAd(adUnitId: Platform.isAndroid
          ? AdTestIds.androidInterstitial
          : AdTestIds.iosInterstitial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Native Google Ads Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rewards: $_rewardAmount'),
            ElevatedButton(
              onPressed: _preloadInterstitialAd,
              child: Text('Preload Interstitial'),
            ),
            ElevatedButton(
              onPressed: _interstitialReady ? _showInterstitialAd : null,
              child: Text('Show Interstitial'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### NativeGoogleads

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `initialize` | Initialize the ads SDK | `appId: String?` | `Future<Map<String, dynamic>?>` |
| `loadBannerAd` | Load a banner ad | `adUnitId: String`, `size: BannerAdSize` | `Future<String?>` |
| `showBannerAd` | Show loaded banner | `bannerId: String` | `Future<bool>` |
| `hideBannerAd` | Hide loaded banner | `bannerId: String` | `Future<bool>` |
| `disposeBannerAd` | Dispose banner ad | `bannerId: String` | `Future<bool>` |
| `loadNativeAd` | Load a native ad | `adUnitId: String` | `Future<String?>` |
| `showNativeAd` | Show loaded native ad | `nativeAdId: String` | `Future<bool>` |
| `disposeNativeAd` | Dispose native ad | `nativeAdId: String` | `Future<bool>` |
| `preloadInterstitialAd` | Preload an interstitial | `adUnitId: String` | `Future<bool>` |
| `isInterstitialReady` | Check if interstitial ready | `adUnitId: String` | `Future<bool>` |
| `showInterstitialAd` | Show preloaded interstitial | `adUnitId: String` | `Future<bool>` |
| `preloadRewardedAd` | Preload a rewarded ad | `adUnitId: String` | `Future<bool>` |
| `isRewardedReady` | Check if rewarded is ready | `adUnitId: String` | `Future<bool>` |
| `showRewardedAd` | Show preloaded rewarded ad | `adUnitId: String` | `Future<bool>` |
| `setAdCallbacks` | Set ad event callbacks | Various callbacks | `void` |


### BannerAdSize

Enum for banner ad sizes:

| Size | Description | Dimensions | Notes |
|------|-------------|------------|-------|
| `banner` | Standard banner | 320x50 | Works on all devices |
| `largeBanner` | Large banner | 320x100 | Works on all devices |
| `mediumRectangle` | Medium rectangle | 300x250 | Works on most devices |
| `fullBanner` | Full banner | 468x60 | Requires tablet or landscape |
| `leaderboard` | Leaderboard | 728x90 | Requires tablet or large screen |
| `adaptive` | Adaptive banner | Width based on device | Recommended for best fit |

**Note**: The widget automatically validates banner sizes and will use a smaller size if the requested size doesn't fit the screen width. For example:
- Leaderboard (728px) on phones → uses Adaptive size
- Full Banner (468px) on small phones → uses Banner size

## Testing

The plugin includes test ad unit IDs from Google. Always use test ads during development:

```dart
// Use test ad unit IDs
final testInterstitial = Platform.isAndroid
    ? AdTestIds.androidInterstitial
    : AdTestIds.iosInterstitial;
```

### Production ID Validation

To help prevent accidental use of Google test ad unit IDs in release:

- Default: warns in release if a test ad unit ID is used.
- Strict mode: throws an error in release when a test ad unit ID is used.
- Disable: you can disable the check if needed.

```dart
// Warn-only (default)
NativeGoogleads.instance.setAdIdValidationPolicy(
  disallowTestIdsInRelease: true,
  strict: false,
);

// Strict: throw in release when using test IDs
NativeGoogleads.instance.setAdIdValidationPolicy(strict: true);

// Disable check
NativeGoogleads.instance.setAdIdValidationPolicy(
  disallowTestIdsInRelease: false,
);
```

## Troubleshooting

### Common Issues

1. **Ads not loading**
   - Ensure you have a valid AdMob account
   - Verify your App ID and Ad Unit IDs are correct
   - Check internet connectivity
   - For iOS, ensure App Tracking Transparency is handled

2. **Build errors on Android**
   - Verify minimum SDK is 24 or higher
   - Run `flutter clean` and rebuild

3. **Build errors on iOS**
   - Ensure deployment target is iOS 13.0+
   - Run `pod install` in the ios directory
   - Clean build folder in Xcode

4. **Test ads not showing**
   - Use test App IDs and ad unit IDs
   - Check console logs for error messages
   - Ensure proper initialization

## Migration Guide

If you're migrating from another ads plugin:

1. Remove the old plugin from `pubspec.yaml`
2. Follow the platform setup instructions above
3. Replace initialization and ad loading code
4. Update ad unit IDs and callbacks
5. Test thoroughly with test ads first

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/dvelop42/flutter_native/issues).

## Acknowledgments

- Google Mobile Ads SDK team
- Flutter community
- All contributors

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## iOS-Specific Features

### Timeout Mechanism for Pending Ad Results

On iOS, the plugin includes an automatic timeout mechanism to prevent memory leaks from pending ad results that may never complete. This feature helps manage edge cases where ad loading fails without proper callbacks.

#### Default Behavior
- **Default timeout**: 30 seconds
- **Automatic cleanup**: Removes stale pending results after timeout
- **Periodic cleanup**: Runs every 60 seconds to clean up very old results
- **Logging**: Detailed logs in Xcode console for debugging

#### Configuration

You can configure the timeout duration programmatically:

```dart
// Access the method channel for iOS-specific features
final ads = NativeGoogleads.instance;

// Set custom timeout (iOS only)
if (Platform.isIOS) {
  await ads.methodChannel.invokeMethod('setAdLoadTimeout', {
    'timeout': 15.0, // Set to 15 seconds
  });
}
```

#### Diagnostic Information

Get diagnostic information about pending results and ad state:

```dart
if (Platform.isIOS) {
  final diagnosticInfo = await ads.methodChannel.invokeMethod('getDiagnosticInfo');
  print('Pending results: ${diagnosticInfo['pendingResultsCount']}');
  print('Active timers: ${diagnosticInfo['pendingTimersCount']}');
  print('Current timeout: ${diagnosticInfo['currentTimeout']}s');
}
```

#### Testing the Timeout Mechanism

The example app includes a dedicated test page for the timeout mechanism:

1. Navigate to "Timeout Mechanism Test" in the example app (iOS only)
2. Set a short timeout (e.g., 5 seconds)
3. Trigger a timeout test with invalid ad unit ID
4. Check diagnostic info to verify cleanup

#### Implementation Details

- Each pending ad result gets a timeout timer
- When timeout occurs, the result receives an `AD_LOAD_TIMEOUT` error
- All associated resources are automatically cleaned up
- Periodic cleanup removes results older than 2x timeout duration
- All timers are properly invalidated on plugin deallocation

This mechanism ensures your iOS app maintains optimal memory usage even in edge cases where ad loading encounters unexpected issues.

---

Made with ❤️ by [Your Name]
