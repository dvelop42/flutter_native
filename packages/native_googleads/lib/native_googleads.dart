import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'native_googleads_platform_interface.dart';
import 'src/ad_config.dart';
import 'src/interstitial_config.dart';

export 'src/ad_config.dart';
export 'src/banner_ad_widget.dart';
export 'src/native_ad_widget.dart';
export 'src/native_ad_style.dart';
export 'src/interstitial_config.dart';

/// Callback for ad lifecycle events.
///
/// [adType] - The type of ad ('interstitial' or 'rewarded').
typedef AdCallback = void Function(String adType);

/// Callback for ad error events.
///
/// [adType] - The type of ad ('interstitial' or 'rewarded').
/// [error] - The error message describing what went wrong.
typedef AdErrorCallback = void Function(String adType, String error);

/// Callback for rewarded ad completion.
///
/// [type] - The type of reward (e.g., 'coins', 'points').
/// [amount] - The amount of reward earned.
typedef RewardCallback = void Function(String type, int amount);

/// Main class for interacting with Google Mobile Ads.
///
/// This plugin provides native implementations for displaying
/// interstitial and rewarded ads in Flutter applications.
///
/// Example:
/// ```dart
/// final ads = NativeGoogleads.instance;
/// await ads.initialize(appId: 'your-app-id');
/// await ads.preloadInterstitialAd(adUnitId: 'your-ad-unit-id');
/// await ads.showInterstitialAd(adUnitId: 'your-ad-unit-id');
/// ```
class NativeGoogleads {
  static final NativeGoogleads _instance = NativeGoogleads._();

  /// Singleton instance of [NativeGoogleads].
  ///
  /// Use this to access all ad functionality.
  static NativeGoogleads get instance => _instance;

  final MethodChannel _channel = const MethodChannel('native_googleads');

  /// Provides access to the underlying method channel for advanced use cases.
  ///
  /// Use this for calling platform-specific methods that are not exposed
  /// through the main API, such as iOS-specific timeout configuration.
  MethodChannel get methodChannel => _channel;

  // Production ID validation options
  bool _disallowTestIdsInRelease = true;
  bool _strictTestIdPolicy = false;
  bool? _forceReleaseModeForTesting; // used only in tests

  AdCallback? _onAdDismissed;
  AdCallback? _onAdShowed;
  AdErrorCallback? _onAdFailedToShow;
  RewardCallback? _onUserEarnedReward;
  
  // Enhanced callbacks
  AdCallback? _onAdClicked;
  AdCallback? _onAdImpression;
  AdCallback? _onAdLoadStarted;
  
  // Frequency capping
  FrequencyCap? _frequencyCap;
  final Map<String, List<int>> _impressionTimestamps = {};
  
  // Load time tracking
  final Map<String, InterstitialLoadMetrics> _loadMetrics = {};
  final Map<String, List<int>> _loadDurations = {};

  NativeGoogleads._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  /// Clear all cached metrics and timestamps (for testing purposes).
  @visibleForTesting
  void clearTestState() {
    _loadMetrics.clear();
    _loadDurations.clear();
    _impressionTimestamps.clear();
    _frequencyCap = null;
  }

  /// Configure validation policy for using Google's test ad unit IDs in release.
  ///
  /// [disallowTestIdsInRelease] when true (default), will warn in release builds
  /// if a Google test ad unit ID is used. When false, the check is disabled.
  ///
  /// [strict] when true, will throw an error in release builds if a Google
  /// test ad unit ID is used. When false (default), only warns.
  void setAdIdValidationPolicy({
    bool? disallowTestIdsInRelease,
    bool? strict,
  }) {
    if (disallowTestIdsInRelease != null) {
      _disallowTestIdsInRelease = disallowTestIdsInRelease;
    }
    if (strict != null) {
      _strictTestIdPolicy = strict;
    }
  }

  /// INTERNAL – test-only override for release-mode detection in validation.
  @visibleForTesting
  void debugSetForceReleaseModeForValidation(bool? isRelease) {
    _forceReleaseModeForTesting = isRelease;
  }

  /// Gets the platform version string.
  ///
  /// Returns the platform name and version (e.g., 'Android 13' or 'iOS 16.0').
  Future<String?> getPlatformVersion() {
    return NativeGoogleadsPlatform.instance.getPlatformVersion();
  }

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// [appId] - Optional App ID. If not provided, the SDK will use the
  /// App ID configured in the platform-specific configuration files.
  ///
  /// Returns a map containing initialization status and adapter information.
  /// Returns null if initialization fails.
  ///
  /// Example:
  /// ```dart
  /// final result = await ads.initialize(appId: 'ca-app-pub-xxxxx');
  /// if (result?['isReady'] == true) {
  ///   print('AdMob initialized successfully');
  /// }
  /// ```
  Future<Map<String, dynamic>?> initialize({String? appId}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initialize',
        {'appId': appId},
      );
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error initializing AdMob: $e');
      return null;
    }
  }

  /// Initializes the Google Mobile Ads SDK with a configuration object.
  ///
  /// [config] - Configuration object containing App ID, test mode settings,
  /// and test device IDs.
  ///
  /// Returns a map containing initialization status and adapter information.
  /// Returns null if initialization fails.
  ///
  /// Example:
  /// ```dart
  /// final config = AdConfig.test();
  /// final result = await ads.initializeWithConfig(config);
  /// ```
  Future<Map<String, dynamic>?> initializeWithConfig(AdConfig config) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initialize',
        {
          'appId': config.appId,
          'testMode': config.testMode,
          'testDeviceIds': config.testDeviceIds,
        },
      );
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error initializing AdMob: $e');
      return null;
    }
  }

  // No Dart-side caching; handled by platform implementations
  
  /// Sets the frequency cap for interstitial ads.
  /// 
  /// [maxImpressions] - Maximum number of impressions allowed.
  /// [perHours] - Time period in hours for the impression limit.
  /// 
  /// Example:
  /// ```dart
  /// await ads.setInterstitialFrequencyCap(
  ///   maxImpressions: 3,
  ///   perHours: 1,
  /// );
  /// ```
  Future<void> setInterstitialFrequencyCap({
    required int maxImpressions,
    required int perHours,
  }) async {
    _frequencyCap = FrequencyCap(
      maxImpressions: maxImpressions,
      perHours: perHours,
    );
    
    // Load existing timestamps from SharedPreferences
    await _loadImpressionTimestamps();
  }
  
  /// Checks if an interstitial ad can be shown without exceeding frequency cap.
  /// 
  /// Returns true if the ad can be shown, false if frequency cap is reached.
  Future<bool> canShowInterstitial(String adUnitId) async {
    if (_frequencyCap == null) return true;
    
    // Get timestamps for this ad unit
    final timestamps = _impressionTimestamps[adUnitId] ?? [];
    
    // Clean up old timestamps
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - (_frequencyCap!.perHours * 3600 * 1000);
    final validTimestamps = timestamps.where((t) => t > cutoff).toList();
    
    // Update cached timestamps
    _impressionTimestamps[adUnitId] = validTimestamps;
    
    return !_frequencyCap!.isCapReached(validTimestamps);
  }
  
  /// Gets the last load time for a specific ad unit.
  /// 
  /// Returns the load duration in milliseconds, or null if not available.
  int? getLastLoadTime(String adUnitId) {
    final metrics = _loadMetrics[adUnitId];
    return metrics?.loadDurationMs;
  }
  
  /// Gets the average load time across all interstitial ads.
  /// 
  /// Returns the average duration in milliseconds, or null if no data.
  double? getAverageLoadTime() {
    if (_loadDurations.isEmpty) return null;
    
    final allDurations = _loadDurations.values
        .expand((list) => list)
        .toList();
    
    if (allDurations.isEmpty) return null;
    
    final sum = allDurations.reduce((a, b) => a + b);
    return sum / allDurations.length;
  }
  
  /// Loads impression timestamps from SharedPreferences.
  Future<void> _loadImpressionTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('ad_impressions_'));
    
    for (final key in keys) {
      final adUnitId = key.replaceFirst('ad_impressions_', '');
      final timestamps = prefs.getStringList(key) ?? [];
      _impressionTimestamps[adUnitId] = timestamps
          .map((s) => int.tryParse(s) ?? 0)
          .where((t) => t > 0)
          .toList();
    }
  }
  
  /// Saves impression timestamps to SharedPreferences.
  Future<void> _saveImpressionTimestamps(String adUnitId) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamps = _impressionTimestamps[adUnitId] ?? [];
    final stringList = timestamps.map((t) => t.toString()).toList();
    await prefs.setStringList('ad_impressions_$adUnitId', stringList);
  }
  
  /// Records an ad impression for frequency capping.
  Future<void> _recordImpression(String adUnitId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (!_impressionTimestamps.containsKey(adUnitId)) {
      _impressionTimestamps[adUnitId] = [];
    }
    
    _impressionTimestamps[adUnitId]!.add(now);
    await _saveImpressionTimestamps(adUnitId);
    
    // Clean up old timestamps
    if (_frequencyCap != null) {
      final cutoff = now - (_frequencyCap!.perHours * 3600 * 1000);
      _impressionTimestamps[adUnitId] = 
          _impressionTimestamps[adUnitId]!.where((t) => t > cutoff).toList();
    }
  }

  /// Preloads an interstitial ad for the given ad unit ID.
  ///
  /// [adUnitId] - The ad unit ID for the interstitial ad.
  /// [requestConfig] - Optional configuration for the ad request.
  /// [config] - Optional interstitial configuration.
  ///
  /// Returns true if the ad loads successfully, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await ads.preloadInterstitialAd(
  ///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
  ///   config: InterstitialConfig.gaming(),
  /// );
  /// ```
  Future<bool> preloadInterstitialAd({
    required String adUnitId,
    AdRequestConfig? requestConfig,
    InterstitialConfig? config,
  }) async {
    _validateAdUnitId(adUnitId);
    
    // Track load start time
    final loadStartTime = DateTime.now();
    _loadMetrics[adUnitId] = InterstitialLoadMetrics(
      adUnitId: adUnitId,
      loadStartTime: loadStartTime,
    );
    
    // Notify load started callback
    _onAdLoadStarted?.call('interstitial');
    
    try {
      final params = <String, dynamic>{
        'adUnitId': adUnitId,
      };

      if (requestConfig != null) {
        params.addAll(requestConfig.toMap());
      }
      
      if (config != null) {
        params.addAll(config.toMap());
      }

      final result = await _channel.invokeMethod<bool>(
        'preloadInterstitialAd',
        params,
      );
      
      // Track load completion
      final loadEndTime = DateTime.now();
      final metrics = _loadMetrics[adUnitId]!.copyWith(
        loadEndTime: loadEndTime,
        success: result ?? false,
      );
      _loadMetrics[adUnitId] = metrics;
      
      // Store duration for averaging
      if (metrics.loadDurationMs != null) {
        if (!_loadDurations.containsKey(adUnitId)) {
          _loadDurations[adUnitId] = [];
        }
        _loadDurations[adUnitId]!.add(metrics.loadDurationMs!);
        
        // Keep only last 10 durations per ad unit
        if (_loadDurations[adUnitId]!.length > 10) {
          _loadDurations[adUnitId]!.removeAt(0);
        }
      }
      
      return result ?? false;
    } catch (e) {
      // Track load failure
      final loadEndTime = DateTime.now();
      final metrics = _loadMetrics[adUnitId]!.copyWith(
        loadEndTime: loadEndTime,
        success: false,
        errorMessage: e.toString(),
      );
      _loadMetrics[adUnitId] = metrics;
      
      debugPrint('Error loading interstitial ad: $e');
      return false;
    }
  }

  /// Returns whether an interstitial ad is ready for the given ad unit ID.
  Future<bool> isInterstitialReady(String adUnitId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isInterstitialReady',
        {'adUnitId': adUnitId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking interstitial readiness: $e');
      return false;
    }
  }

  /// Shows a preloaded interstitial ad for the given ad unit ID.
  ///
  /// Returns true if the ad is shown successfully, false if no ad is loaded,
  /// frequency cap is reached, or showing fails.
  ///
  /// Make sure to preload an ad first using [preloadInterstitialAd].
  Future<bool> showInterstitialAd({required String adUnitId}) async {
    // Check frequency cap
    if (!await canShowInterstitial(adUnitId)) {
      debugPrint('Frequency cap reached for ad unit: $adUnitId');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'showInterstitialAd',
        {'adUnitId': adUnitId},
      );
      
      if (result == true) {
        // Record impression for frequency capping
        await _recordImpression(adUnitId);
        
        // Trigger impression callback
        _onAdImpression?.call('interstitial');
      }
      
      return result ?? false;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  /// Preloads a rewarded ad for the given ad unit ID.
  ///
  /// [adUnitId] - The ad unit ID for the rewarded ad.
  /// [requestConfig] - Optional configuration for the ad request.
  ///
  /// Returns true if the ad loads successfully, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await ads.preloadRewardedAd(
  ///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
  /// );
  /// ```
  Future<bool> preloadRewardedAd({
    required String adUnitId,
    AdRequestConfig? requestConfig,
  }) async {
    _validateAdUnitId(adUnitId);
    try {
      final params = <String, dynamic>{
        'adUnitId': adUnitId,
      };

      if (requestConfig != null) {
        params.addAll(requestConfig.toMap());
      }

      final result = await _channel.invokeMethod<bool>(
        'preloadRewardedAd',
        params,
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      return false;
    }
  }

  /// Returns whether a rewarded ad is ready for the given ad unit ID.
  Future<bool> isRewardedReady(String adUnitId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isRewardedReady',
        {'adUnitId': adUnitId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking rewarded readiness: $e');
      return false;
    }
  }

  /// Shows a preloaded rewarded ad for the given ad unit ID.
  ///
  /// Returns true if the ad is shown successfully, false if no ad is loaded
  /// or if showing fails.
  ///
  /// When the user completes watching the ad, the [onUserEarnedReward]
  /// callback will be triggered.
  ///
  /// Make sure to preload an ad first using [preloadRewardedAd].
  Future<bool> showRewardedAd({required String adUnitId}) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'showRewardedAd',
        {'adUnitId': adUnitId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    }
  }

  /// Loads a banner ad.
  ///
  /// [adUnitId] - The ad unit ID for the banner ad.
  /// [size] - The size of the banner ad.
  /// [requestConfig] - Optional configuration for the ad request.
  ///
  /// Returns a unique banner ID if successful, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final bannerId = await ads.loadBannerAd(
  ///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
  ///   size: BannerAdSize.adaptive,
  /// );
  /// ```
  Future<String?> loadBannerAd({
    required String adUnitId,
    required BannerAdSize size,
    AdRequestConfig? requestConfig,
  }) async {
    _validateAdUnitId(adUnitId);
    try {
      debugPrint('Loading banner ad: adUnitId=$adUnitId, size=${size.name}');
      final params = <String, dynamic>{
        'adUnitId': adUnitId,
        'size': size.index,
      };

      if (requestConfig != null) {
        params.addAll(requestConfig.toMap());
      }

      final result = await _channel.invokeMethod<String>(
        'loadBannerAd',
        params,
      );
      debugPrint('Banner ad loaded with ID: $result');
      return result;
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      return null;
    }
  }

  /// Shows a previously loaded banner ad.
  ///
  /// [bannerId] - The unique ID of the banner ad to show.
  ///
  /// Returns true if the banner is shown successfully, false otherwise.
  Future<bool> showBannerAd(String bannerId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'showBannerAd',
        {'bannerId': bannerId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error showing banner ad: $e');
      return false;
    }
  }

  /// Hides a banner ad.
  ///
  /// [bannerId] - The unique ID of the banner ad to hide.
  ///
  /// Returns true if the banner is hidden successfully, false otherwise.
  Future<bool> hideBannerAd(String bannerId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'hideBannerAd',
        {'bannerId': bannerId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error hiding banner ad: $e');
      return false;
    }
  }

  /// Disposes a banner ad and releases its resources.
  ///
  /// [bannerId] - The unique ID of the banner ad to dispose.
  ///
  /// Returns true if the banner is disposed successfully, false otherwise.
  Future<bool> disposeBannerAd(String bannerId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'disposeBannerAd',
        {'bannerId': bannerId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error disposing banner ad: $e');
      return false;
    }
  }

  /// Loads a native ad.
  ///
  /// [adUnitId] - The ad unit ID for the native ad.
  /// [requestConfig] - Optional configuration for the ad request.
  /// [mediaAspectRatio] - Optional media aspect ratio preference for the native ad.
  ///
  /// Returns a unique native ad ID if successful, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final nativeAdId = await ads.loadNativeAd(
  ///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
  ///   mediaAspectRatio: NativeAdMediaAspectRatio.landscape,
  /// );
  /// ```
  Future<String?> loadNativeAd({
    required String adUnitId,
    AdRequestConfig? requestConfig,
    NativeAdMediaAspectRatio? mediaAspectRatio,
  }) async {
    _validateAdUnitId(adUnitId);
    try {
      debugPrint('Loading native ad: adUnitId=$adUnitId');
      final params = <String, dynamic>{
        'adUnitId': adUnitId,
      };

      if (requestConfig != null) {
        params.addAll(requestConfig.toMap());
      }

      if (mediaAspectRatio != null) {
        params['mediaAspectRatio'] = mediaAspectRatio.index;
      }

      final result = await _channel.invokeMethod<String>(
        'loadNativeAd',
        params,
      );
      debugPrint('Native ad loaded with ID: $result');
      return result;
    } catch (e) {
      debugPrint('Error loading native ad: $e');
      return null;
    }
  }

  /// Shows a previously loaded native ad.
  ///
  /// [nativeAdId] - The unique ID of the native ad to show.
  ///
  /// Returns true if the native ad is shown successfully, false otherwise.
  Future<bool> showNativeAd(String nativeAdId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'showNativeAd',
        {'nativeAdId': nativeAdId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error showing native ad: $e');
      return false;
    }
  }

  /// Disposes a native ad and releases its resources.
  ///
  /// [nativeAdId] - The unique ID of the native ad to dispose.
  ///
  /// Returns true if the native ad is disposed successfully, false otherwise.
  Future<bool> disposeNativeAd(String nativeAdId) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'disposeNativeAd',
        {'nativeAdId': nativeAdId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error disposing native ad: $e');
      return false;
    }
  }

  /// Validates an ad unit ID format.
  ///
  /// Throws ArgumentError if the ID is empty.
  /// Prints a warning if the ID doesn't match expected AdMob format.
  void _validateAdUnitId(String adUnitId) {
    if (adUnitId.isEmpty) {
      throw ArgumentError('Ad unit ID cannot be empty');
    }

    // Check for valid AdMob format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
    // or test IDs which have different formats
    final testIds = [
      AdTestIds.androidAppId,
      AdTestIds.iosAppId,
      AdTestIds.androidBanner,
      AdTestIds.iosBanner,
      AdTestIds.androidInterstitial,
      AdTestIds.iosInterstitial,
      AdTestIds.androidRewarded,
      AdTestIds.iosRewarded,
      AdTestIds.androidNativeAdvanced,
      AdTestIds.iosNativeAdvanced,
    ];

    final inTestIds = testIds.contains(adUnitId);

    // Enforce production safety: block or warn on test IDs in release builds
    final bool isReleaseMode = _forceReleaseModeForTesting ?? kReleaseMode;
    if (isReleaseMode && _disallowTestIdsInRelease && inTestIds) {
      final msg =
          'Using Google test ad unit ID "$adUnitId" in release build. Configure production IDs.';
      if (_strictTestIdPolicy) {
        throw ArgumentError(msg);
      } else {
        debugPrint('Warning: $msg');
      }
    }

    if (!inTestIds) {
      // Validate production ID format
      final regex = RegExp(r'^ca-app-pub-\d{16}/\d{10}$');
      if (!regex.hasMatch(adUnitId)) {
        debugPrint(
            'Warning: Ad unit ID "$adUnitId" may be invalid. Expected format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY');
      }
    }
  }

  /// Sets callbacks for ad lifecycle events.
  ///
  /// [onAdDismissed] - Called when an ad is dismissed.
  /// [onAdShowed] - Called when an ad is shown.
  /// [onAdFailedToShow] - Called when an ad fails to show.
  /// [onUserEarnedReward] - Called when a user earns a reward from a rewarded ad.
  /// [onAdClicked] - Called when an ad is clicked.
  /// [onAdImpression] - Called when an ad impression is recorded.
  /// [onAdLoadStarted] - Called when ad loading starts.
  ///
  /// Example:
  /// ```dart
  /// ads.setAdCallbacks(
  ///   onAdDismissed: (adType) => print('Ad dismissed: $adType'),
  ///   onAdClicked: (adType) => print('Ad clicked: $adType'),
  ///   onAdImpression: (adType) => analytics.track('ad_impression'),
  ///   onUserEarnedReward: (type, amount) => grantReward(amount),
  /// );
  /// ```
  void setAdCallbacks({
    AdCallback? onAdDismissed,
    AdCallback? onAdShowed,
    AdErrorCallback? onAdFailedToShow,
    RewardCallback? onUserEarnedReward,
    AdCallback? onAdClicked,
    AdCallback? onAdImpression,
    AdCallback? onAdLoadStarted,
  }) {
    _onAdDismissed = onAdDismissed;
    _onAdShowed = onAdShowed;
    _onAdFailedToShow = onAdFailedToShow;
    _onUserEarnedReward = onUserEarnedReward;
    _onAdClicked = onAdClicked;
    _onAdImpression = onAdImpression;
    _onAdLoadStarted = onAdLoadStarted;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAdDismissed':
        final type = call.arguments['type'] as String;
        _onAdDismissed?.call(type);
        break;
      case 'onAdShowed':
        final type = call.arguments['type'] as String;
        _onAdShowed?.call(type);
        break;
      case 'onAdFailedToShow':
        final type = call.arguments['type'] as String;
        final error = call.arguments['error'] as String;
        _onAdFailedToShow?.call(type, error);
        break;
      case 'onUserEarnedReward':
        final type = call.arguments['type'] as String;
        final dynamic rawAmount = call.arguments['amount'];
        // iOS sends NSDecimalNumber which arrives as double; Android sends int.
        final int amount = rawAmount is num
            ? rawAmount.toInt()
            : int.tryParse(rawAmount.toString()) ?? 0;
        _onUserEarnedReward?.call(type, amount);
        break;
      case 'onAdClicked':
        final type = call.arguments['type'] as String;
        _onAdClicked?.call(type);
        break;
      case 'onAdImpression':
        final type = call.arguments['type'] as String;
        _onAdImpression?.call(type);
        break;
    }
  }

  // No expiration logic needed on Dart side
}

/// Enum for banner ad sizes.
enum BannerAdSize {
  banner, // 320x50
  largeBanner, // 320x100
  mediumRectangle, // 300x250
  fullBanner, // 468x60
  leaderboard, // 728x90
  adaptive, // Adaptive size based on width
}

/// Enum for native ad media aspect ratio preferences.
enum NativeAdMediaAspectRatio {
  /// Any aspect ratio (default)
  any,

  /// Landscape aspect ratio (16:9)
  landscape,

  /// Portrait aspect ratio (9:16)
  portrait,

  /// Square aspect ratio (1:1)
  square,
}

/// Contains Google's test ad unit IDs for development.
///
/// Always use test ads during development to avoid policy violations.
/// These IDs will show test ads that look like real ads but don't
/// generate actual revenue.
///
/// Example:
/// ```dart
/// final testInterstitial = Platform.isAndroid
///     ? AdTestIds.androidInterstitial
///     : AdTestIds.iosInterstitial;
/// ```
class AdTestIds {
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String androidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  static const String androidRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static const String androidBanner = 'ca-app-pub-3940256099942544/2435281174';
  static const String iosBanner = 'ca-app-pub-3940256099942544/2435281174';

  static const String androidNativeAdvanced =
      'ca-app-pub-3940256099942544/3986624511';
  static const String iosNativeAdvanced =
      'ca-app-pub-3940256099942544/3986624511';
}
