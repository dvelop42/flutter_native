# Native Google Ads

[![pub package](https://img.shields.io/pub/v/native_googleads.svg)](https://pub.dev/packages/native_googleads)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue)](https://flutter.dev)

A Flutter plugin for integrating Google Mobile Ads (AdMob) using native platform implementations. This plugin provides a simple and efficient way to display banner, native, interstitial, and rewarded ads in your Flutter applications.

## Features

- ✅ **Native Implementation** - Direct integration with Google Mobile Ads SDK
- ✅ **iOS & Android Support** - Full support for both platforms
- ✅ **Banner Ads** - Display banner ads in various sizes including adaptive
- ✅ **Native Ads** - Customizable ads that match your app's design
- ✅ **Interstitial Ads** - Full-screen ads at natural transition points
- ✅ **Rewarded Ads** - Reward users for watching video ads
- ✅ **Flexible Configuration** - Pass App IDs and configurations from Dart
- ✅ **Test Mode** - Easy switching between test and production ads
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
  native_googleads: ^1.0.0
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

#### 1. Update iOS Deployment Target

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

// Initialize with App ID
await ads.initialize(appId: 'your-app-id');

// Or initialize with configuration
final config = AdConfig.production(
  appId: 'your-app-id',
  testDeviceIds: {'device-id-1', 'device-id-2'},
);
await ads.initializeWithConfig(config);

// Load and show banner ad
final bannerId = await ads.loadBannerAd(
  adUnitId: 'your-banner-ad-unit-id',
  size: BannerAdSize.adaptive,
);
if (bannerId != null) {
  await ads.showBannerAd(bannerId);
}

// Load and show native ad
final nativeAdId = await ads.loadNativeAd(
  adUnitId: 'your-native-ad-unit-id',
);
if (nativeAdId != null) {
  await ads.showNativeAd(nativeAdId);
}

// Load and show interstitial ad
await ads.loadInterstitialAd(
  adUnitId: 'your-interstitial-ad-unit-id',
);
await ads.showInterstitialAd();

// Load and show rewarded ad
await ads.loadRewardedAd(
  adUnitId: 'your-rewarded-ad-unit-id',
);
await ads.showRewardedAd();
```

### Using Test Ads

For development, always use test ad unit IDs:

```dart
import 'dart:io';

// Use test IDs during development
final testAdUnitId = Platform.isAndroid
    ? AdTestIds.androidInterstitial  // Test interstitial for Android
    : AdTestIds.iosInterstitial;      // Test interstitial for iOS

await ads.loadInterstitialAd(adUnitId: testAdUnitId);
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

// Load a banner ad
final bannerId = await ads.loadBannerAd(
  adUnitId: Platform.isAndroid 
    ? AdTestIds.androidBanner 
    : AdTestIds.iosBanner,
  size: BannerAdSize.adaptive,
);

// Show the banner
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

### Working with Native Ads

Native ads allow you to customize the ad appearance to match your app:

```dart
// Load a native ad
final nativeAdId = await ads.loadNativeAd(
  adUnitId: Platform.isAndroid 
    ? AdTestIds.androidNativeAdvanced 
    : AdTestIds.iosNativeAdvanced,
);

// Show the native ad
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

### Advanced Configuration

```dart
// Create custom ad request configuration
final requestConfig = AdRequestConfig(
  keywords: ['games', 'sports'],
  contentUrl: 'https://example.com',
  nonPersonalizedAds: true,
);

// Load ad with custom configuration
await ads.loadInterstitialAd(
  adUnitId: 'your-ad-unit-id',
  requestConfig: requestConfig,
);
```

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

    // Initialize with test mode for development
    final config = AdConfig.test();
    await _ads.initializeWithConfig(config);
  }

  Future<void> _loadInterstitialAd() async {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;

    final success = await _ads.loadInterstitialAd(adUnitId: adUnitId);
    setState(() => _interstitialReady = success);
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialReady) {
      await _ads.showInterstitialAd();
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
              onPressed: _loadInterstitialAd,
              child: Text('Load Interstitial'),
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
| `initializeWithConfig` | Initialize with configuration | `config: AdConfig` | `Future<Map<String, dynamic>?>` |
| `loadBannerAd` | Load a banner ad | `adUnitId: String`, `size: BannerAdSize`, `requestConfig: AdRequestConfig?` | `Future<String?>` |
| `showBannerAd` | Show loaded banner | `bannerId: String` | `Future<bool>` |
| `hideBannerAd` | Hide loaded banner | `bannerId: String` | `Future<bool>` |
| `disposeBannerAd` | Dispose banner ad | `bannerId: String` | `Future<bool>` |
| `loadNativeAd` | Load a native ad | `adUnitId: String`, `requestConfig: AdRequestConfig?` | `Future<String?>` |
| `showNativeAd` | Show loaded native ad | `nativeAdId: String` | `Future<bool>` |
| `disposeNativeAd` | Dispose native ad | `nativeAdId: String` | `Future<bool>` |
| `loadInterstitialAd` | Load an interstitial ad | `adUnitId: String`, `requestConfig: AdRequestConfig?` | `Future<bool>` |
| `showInterstitialAd` | Show loaded interstitial | None | `Future<bool>` |
| `loadRewardedAd` | Load a rewarded ad | `adUnitId: String`, `requestConfig: AdRequestConfig?` | `Future<bool>` |
| `showRewardedAd` | Show loaded rewarded ad | None | `Future<bool>` |
| `setAdCallbacks` | Set ad event callbacks | Various callbacks | `void` |

### AdConfig

Configuration class for initializing ads:

```dart
AdConfig({
  String? appId,
  Map<String, String> testDeviceIds,
  bool testMode,
})
```

### AdRequestConfig

Configuration for ad requests:

```dart
AdRequestConfig({
  List<String>? keywords,
  String? contentUrl,
  List<String>? testDevices,
  bool? nonPersonalizedAds,
})
```

### BannerAdSize

Enum for banner ad sizes:

| Size | Description | Dimensions |
|------|-------------|------------|
| `banner` | Standard banner | 320x50 |
| `largeBanner` | Large banner | 320x100 |
| `mediumRectangle` | Medium rectangle | 300x250 |
| `fullBanner` | Full banner | 468x60 |
| `leaderboard` | Leaderboard | 728x90 |
| `adaptive` | Adaptive banner | Width based on device |

## Testing

The plugin includes test ad unit IDs from Google. Always use test ads during development:

```dart
// Test mode configuration
final config = AdConfig.test();
await NativeGoogleads.instance.initializeWithConfig(config);

// Use test ad unit IDs
final testInterstitial = Platform.isAndroid
    ? AdTestIds.androidInterstitial
    : AdTestIds.iosInterstitial;
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

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/yourusername/native_googleads/issues).

## Acknowledgments

- Google Mobile Ads SDK team
- Flutter community
- All contributors

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

Made with ❤️ by [Your Name]