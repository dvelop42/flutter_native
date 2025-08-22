# Debugging Banner and Native Ads

## What Was Fixed

### iOS Issues Fixed:
1. **Delegate Retention**: Fixed delegate classes being deallocated immediately
2. **GADBannerViewDelegate**: Plugin now properly conforms to GADBannerViewDelegate
3. **GADNativeAdLoaderDelegate**: Plugin now properly conforms to GADNativeAdLoaderDelegate
4. **Result Handling**: Added proper result storage and callback handling

### Android Issues Fixed:
1. **Enhanced Logging**: Added detailed logging for all ad loading operations
2. **Error Details**: Added more comprehensive error logging

### Test IDs Updated:
- **Banner Test ID**: `ca-app-pub-3940256099942544/2435281174`
- **Native Test ID**: `ca-app-pub-3940256099942544/3986624511`

## How to Debug

### 1. Check Console Logs

Run your app with `flutter run` and look for these log messages:

#### Expected Flow for Banner Ads:
```
BannerAdWidget: initState called for adUnitId: ca-app-pub-3940256099942544/2435281174
BannerAdWidget: Starting to load ad
Loading banner ad: adUnitId=ca-app-pub-3940256099942544/2435281174, size=adaptive
[Android] NativeGoogleads: Loading banner ad with ID: xxx, adUnitId: xxx, size: 5
[Android] NativeGoogleads: Banner ad loaded successfully: xxx
[iOS] Banner ad loaded with ID: xxx
BannerAdWidget: Ad loaded successfully with ID: xxx
```

#### Expected Flow for Native Ads:
```
NativeAdWidget: initState called for adUnitId: ca-app-pub-3940256099942544/3986624511
NativeAdWidget: Starting to load ad
Loading native ad: adUnitId=ca-app-pub-3940256099942544/3986624511
[Android] NativeGoogleads: Loading native ad with ID: xxx, adUnitId: xxx
[Android] NativeGoogleads: Native ad loaded successfully: xxx
[iOS] Native ad loaded with ID: xxx
NativeAdWidget: Ad loaded successfully with ID: xxx
```

### 2. Common Error Messages and Solutions

#### Error: "No ad config" or Error Code 3
- **Cause**: Invalid ad unit ID or test mode not properly configured
- **Solution**: Ensure you're using the correct test ad unit IDs

#### Error: "Network Error" or Error Code 0
- **Cause**: No internet connection
- **Solution**: Check device internet connection

#### Error: "Invalid Request" or Error Code 1
- **Cause**: AdMob SDK not properly initialized
- **Solution**: Make sure `initialize()` is called before loading ads

### 3. Platform-Specific Checks

#### Android:
- Check `adb logcat | grep NativeGoogleads` for detailed logs
- Verify Google Play Services is installed and updated
- Check AndroidManifest.xml has the correct App ID

#### iOS:
- Check Xcode console for detailed logs
- Verify Info.plist has GADApplicationIdentifier
- Check that App Tracking Transparency is handled (iOS 14+)

### 4. Current Implementation Status

✅ **Working**:
- Interstitial ads
- Rewarded ads
- Banner ad loading (returns valid ID)
- Native ad loading (returns valid ID)

⚠️ **Limitations**:
- Banner and native ads load successfully but display as placeholders
- Full display requires platform view factory implementation (advanced feature)

### 5. Testing Steps

1. **Initialize the SDK**:
```dart
await NativeGoogleads.instance.initialize();
```

2. **Check the console for initialization success**

3. **Try loading a banner ad**:
```dart
final bannerId = await NativeGoogleads.instance.loadBannerAd(
  adUnitId: AdTestIds.androidBanner, // or iosBanner
  size: BannerAdSize.banner,
);
print('Banner ID: $bannerId'); // Should print a UUID
```

4. **Try loading a native ad**:
```dart
final nativeId = await NativeGoogleads.instance.loadNativeAd(
  adUnitId: AdTestIds.androidNativeAdvanced, // or iosNativeAdvanced
);
print('Native ID: $nativeId'); // Should print a UUID
```

### 6. If Ads Still Don't Load

1. **Check AdMob Account**: Ensure your AdMob account is active
2. **Check Bundle ID/Package Name**: Must match AdMob app settings
3. **Check Test Device**: Add your device as a test device if testing with real ad units
4. **Check Region**: Some regions may have limited ad inventory
5. **Wait Time**: First ad load can take 30-60 seconds

## Next Steps for Full Implementation

To display actual banner and native ads (not just placeholders), you need:

1. **Android**: Create a `PlatformViewFactory` and register it
2. **iOS**: Create a `FlutterPlatformViewFactory` and register it
3. **Flutter**: Update widgets to use registered platform views

This is an advanced feature that requires additional native code implementation.