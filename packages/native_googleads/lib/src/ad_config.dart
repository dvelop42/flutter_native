/// Configuration class for Google Mobile Ads initialization.
///
/// Use this class to configure how the ads SDK is initialized,
/// including test mode settings and test device IDs.
///
/// Example:
/// ```dart
/// // For testing
/// final config = AdConfig.test();
///
/// // For production
/// final config = AdConfig.production(
///   appId: 'ca-app-pub-xxxxx',
///   testDeviceIds: {'device-id-1', 'device-id-2'},
/// );
/// ```
class AdConfig {
  /// The AdMob App ID.
  ///
  /// If null, the SDK will use the App ID from platform configuration.
  final String? appId;

  /// Test device IDs for showing test ads on specific devices.
  ///
  /// Even in production, these devices will see test ads.
  final Map<String, String> testDeviceIds;

  /// Whether to use test mode.
  ///
  /// When true, test ads will be shown to all users.
  final bool testMode;

  const AdConfig({
    this.appId,
    this.testDeviceIds = const {},
    this.testMode = false,
  });

  /// Creates a test configuration with Google's test IDs.
  ///
  /// Use this during development to show test ads.
  ///
  /// Example:
  /// ```dart
  /// final config = AdConfig.test();
  /// await ads.initializeWithConfig(config);
  /// ```
  factory AdConfig.test() {
    return const AdConfig(
      testMode: true,
    );
  }

  /// Creates a production configuration with your App ID.
  ///
  /// [appId] - Your AdMob App ID.
  /// [testDeviceIds] - Optional test device IDs for showing test ads
  /// on specific devices even in production.
  ///
  /// Example:
  /// ```dart
  /// final config = AdConfig.production(
  ///   appId: 'ca-app-pub-xxxxx',
  ///   testDeviceIds: {'test-device-id'},
  /// );
  /// ```
  factory AdConfig.production({
    required String appId,
    Map<String, String> testDeviceIds = const {},
  }) {
    return AdConfig(
      appId: appId,
      testDeviceIds: testDeviceIds,
      testMode: false,
    );
  }
}

/// Configuration for ad requests.
///
/// Use this class to customize individual ad requests with
/// targeting information and preferences.
///
/// Example:
/// ```dart
/// final config = AdRequestConfig(
///   keywords: ['games', 'sports'],
///   nonPersonalizedAds: true,
/// );
/// await ads.preloadInterstitialAd(
///   adUnitId: 'ad-unit-id',
///   requestConfig: config,
/// );
/// ```
class AdRequestConfig {
  /// Keywords for ad targeting.
  ///
  /// Help improve ad relevance by providing keywords related to your content.
  final List<String>? keywords;

  /// URL of the content being displayed.
  ///
  /// Helps with ad targeting and brand safety.
  final String? contentUrl;

  /// Test device IDs for this specific request.
  ///
  /// Overrides global test device settings for this request.
  final List<String>? testDevices;

  /// Whether to request non-personalized ads.
  ///
  /// Set to true for users who have not consented to personalized ads.
  final bool? nonPersonalizedAds;

  const AdRequestConfig({
    this.keywords,
    this.contentUrl,
    this.testDevices,
    this.nonPersonalizedAds,
  });

  /// Converts this configuration to a map for platform channel communication.
  ///
  /// Returns a map containing only non-null values.
  Map<String, dynamic> toMap() {
    return {
      if (keywords != null) 'keywords': keywords,
      if (contentUrl != null) 'contentUrl': contentUrl,
      if (testDevices != null) 'testDevices': testDevices,
      if (nonPersonalizedAds != null) 'nonPersonalizedAds': nonPersonalizedAds,
    };
  }
}
