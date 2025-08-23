import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_googleads/native_googleads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeGoogleads', () {
    final NativeGoogleads ads = NativeGoogleads.instance;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return 'Test Platform 1.0';
            case 'initialize':
              return {
                'isReady': true,
                'appId': methodCall.arguments['appId'] ?? 'test-app-id',
                'adapterStatus': {},
              };
            case 'preloadInterstitialAd':
              return true;
            case 'isInterstitialReady':
              return true;
            case 'showInterstitialAd':
              return true;
            case 'preloadRewardedAd':
              return true;
            case 'isRewardedReady':
              return true;
            case 'showRewardedAd':
              return true;
            case 'loadBannerAd':
              return 'banner-id-123';
            case 'showBannerAd':
              return true;
            case 'hideBannerAd':
              return true;
            case 'disposeBannerAd':
              return true;
            case 'loadNativeAd':
              return 'native-id-456';
            case 'showNativeAd':
              return true;
            case 'disposeNativeAd':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        null,
      );
    });

    test('getPlatformVersion', () async {
      final version = await ads.getPlatformVersion();
      expect(version, 'Test Platform 1.0');
      expect(log, [
        isMethodCall('getPlatformVersion', arguments: null),
      ]);
    });

    test('initialize with app ID', () async {
      final result = await ads.initialize(appId: 'test-app-123');

      expect(result, isNotNull);
      expect(result!['isReady'], true);
      expect(result['appId'], 'test-app-123');
      expect(log, [
        isMethodCall('initialize', arguments: {'appId': 'test-app-123'}),
      ]);
    });

    test('initialize without app ID', () async {
      final result = await ads.initialize();

      expect(result, isNotNull);
      expect(result!['isReady'], true);
      expect(result['appId'], 'test-app-id');
      expect(log, [
        isMethodCall('initialize', arguments: {'appId': null}),
      ]);
    });

    test('initializeWithConfig using test config', () async {
      final config = AdConfig.test();
      final result = await ads.initializeWithConfig(config);

      expect(result, isNotNull);
      expect(result!['isReady'], true);
      expect(log, [
        isMethodCall('initialize', arguments: {
          'appId': null,
          'testMode': true,
          'testDeviceIds': {},
        }),
      ]);
    });

    test('initializeWithConfig using production config', () async {
      final config = AdConfig.production(
        appId: 'prod-app-123',
        testDeviceIds: {'device1': 'device1', 'device2': 'device2'},
      );
      final result = await ads.initializeWithConfig(config);

      expect(result, isNotNull);
      expect(result!['isReady'], true);
      expect(log, [
        isMethodCall('initialize', arguments: {
          'appId': 'prod-app-123',
          'testMode': false,
          'testDeviceIds': {'device1': 'device1', 'device2': 'device2'},
        }),
      ]);
    });

    test('preloadInterstitialAd', () async {
      final result = await ads.preloadInterstitialAd(
        adUnitId: 'test-interstitial-123',
      );

      expect(result, true);
      expect(log, [
        isMethodCall('preloadInterstitialAd', arguments: {
          'adUnitId': 'test-interstitial-123',
        }),
      ]);
    });

    test('preloadInterstitialAd with request config', () async {
      const requestConfig = AdRequestConfig(
        keywords: ['test', 'ads'],
        contentUrl: 'https://example.com',
        nonPersonalizedAds: true,
      );

      final result = await ads.preloadInterstitialAd(
        adUnitId: 'test-interstitial-123',
        requestConfig: requestConfig,
      );

      expect(result, true);
      expect(log, [
        isMethodCall('preloadInterstitialAd', arguments: {
          'adUnitId': 'test-interstitial-123',
          'keywords': ['test', 'ads'],
          'contentUrl': 'https://example.com',
          'nonPersonalizedAds': true,
        }),
      ]);
    });

    test('showInterstitialAd', () async {
      final result =
          await ads.showInterstitialAd(adUnitId: 'test-interstitial-123');

      expect(result, true);
      expect(log, [
        isMethodCall('showInterstitialAd', arguments: {
          'adUnitId': 'test-interstitial-123',
        }),
      ]);
    });

    test('preloadRewardedAd', () async {
      final result = await ads.preloadRewardedAd(
        adUnitId: 'test-rewarded-123',
      );

      expect(result, true);
      expect(log, [
        isMethodCall('preloadRewardedAd', arguments: {
          'adUnitId': 'test-rewarded-123',
        }),
      ]);
    });

    test('preloadRewardedAd with request config', () async {
      const requestConfig = AdRequestConfig(
        keywords: ['games', 'rewards'],
        testDevices: ['test-device-1'],
      );

      final result = await ads.preloadRewardedAd(
        adUnitId: 'test-rewarded-123',
        requestConfig: requestConfig,
      );

      expect(result, true);
      expect(log, [
        isMethodCall('preloadRewardedAd', arguments: {
          'adUnitId': 'test-rewarded-123',
          'keywords': ['games', 'rewards'],
          'testDevices': ['test-device-1'],
        }),
      ]);
    });

    test('showRewardedAd', () async {
      final result = await ads.showRewardedAd(adUnitId: 'test-rewarded-123');

      expect(result, true);
      expect(log, [
        isMethodCall('showRewardedAd', arguments: {
          'adUnitId': 'test-rewarded-123',
        }),
      ]);
    });

    group('Banner Ads', () {
      test('loadBannerAd', () async {
        final bannerId = await ads.loadBannerAd(
          adUnitId: 'test-banner-123',
          size: BannerAdSize.banner,
        );

        expect(bannerId, 'banner-id-123');
        expect(log, [
          isMethodCall('loadBannerAd', arguments: {
            'adUnitId': 'test-banner-123',
            'size': BannerAdSize.banner.index,
          }),
        ]);
      });

      test('loadBannerAd with adaptive size', () async {
        final bannerId = await ads.loadBannerAd(
          adUnitId: 'test-banner-adaptive',
          size: BannerAdSize.adaptive,
        );

        expect(bannerId, 'banner-id-123');
        expect(log, [
          isMethodCall('loadBannerAd', arguments: {
            'adUnitId': 'test-banner-adaptive',
            'size': BannerAdSize.adaptive.index,
          }),
        ]);
      });

      test('loadBannerAd with request config', () async {
        const requestConfig = AdRequestConfig(
          keywords: ['news', 'sports'],
          contentUrl: 'https://example.com/content',
          nonPersonalizedAds: true,
        );

        final bannerId = await ads.loadBannerAd(
          adUnitId: 'test-banner-123',
          size: BannerAdSize.mediumRectangle,
          requestConfig: requestConfig,
        );

        expect(bannerId, 'banner-id-123');
        expect(log, [
          isMethodCall('loadBannerAd', arguments: {
            'adUnitId': 'test-banner-123',
            'size': BannerAdSize.mediumRectangle.index,
            'keywords': ['news', 'sports'],
            'contentUrl': 'https://example.com/content',
            'nonPersonalizedAds': true,
          }),
        ]);
      });

      test('showBannerAd', () async {
        final result = await ads.showBannerAd('banner-id-123');

        expect(result, true);
        expect(log, [
          isMethodCall('showBannerAd', arguments: {
            'bannerId': 'banner-id-123',
          }),
        ]);
      });

      test('hideBannerAd', () async {
        final result = await ads.hideBannerAd('banner-id-123');

        expect(result, true);
        expect(log, [
          isMethodCall('hideBannerAd', arguments: {
            'bannerId': 'banner-id-123',
          }),
        ]);
      });

      test('disposeBannerAd', () async {
        final result = await ads.disposeBannerAd('banner-id-123');

        expect(result, true);
        expect(log, [
          isMethodCall('disposeBannerAd', arguments: {
            'bannerId': 'banner-id-123',
          }),
        ]);
      });
    });

    group('Native Ads', () {
      test('loadNativeAd', () async {
        final nativeAdId = await ads.loadNativeAd(
          adUnitId: 'test-native-123',
        );

        expect(nativeAdId, 'native-id-456');
        expect(log, [
          isMethodCall('loadNativeAd', arguments: {
            'adUnitId': 'test-native-123',
          }),
        ]);
      });

      test('loadNativeAd with request config', () async {
        const requestConfig = AdRequestConfig(
          keywords: ['technology', 'gadgets'],
          testDevices: ['test-device-1', 'test-device-2'],
        );

        final nativeAdId = await ads.loadNativeAd(
          adUnitId: 'test-native-123',
          requestConfig: requestConfig,
        );

        expect(nativeAdId, 'native-id-456');
        expect(log, [
          isMethodCall('loadNativeAd', arguments: {
            'adUnitId': 'test-native-123',
            'keywords': ['technology', 'gadgets'],
            'testDevices': ['test-device-1', 'test-device-2'],
          }),
        ]);
      });

      test('showNativeAd', () async {
        final result = await ads.showNativeAd('native-id-456');

        expect(result, true);
        expect(log, [
          isMethodCall('showNativeAd', arguments: {
            'nativeAdId': 'native-id-456',
          }),
        ]);
      });

      test('disposeNativeAd', () async {
        final result = await ads.disposeNativeAd('native-id-456');

        expect(result, true);
        expect(log, [
          isMethodCall('disposeNativeAd', arguments: {
            'nativeAdId': 'native-id-456',
          }),
        ]);
      });
    });

    test('setAdCallbacks', () {
      String? dismissedAdType;
      String? showedAdType;
      String? failedAdType;
      String? failedError;
      String? rewardType;
      int? rewardAmount;

      ads.setAdCallbacks(
        onAdDismissed: (adType) => dismissedAdType = adType,
        onAdShowed: (adType) => showedAdType = adType,
        onAdFailedToShow: (adType, error) {
          failedAdType = adType;
          failedError = error;
        },
        onUserEarnedReward: (type, amount) {
          rewardType = type;
          rewardAmount = amount;
        },
      );

      // Simulate callbacks from native
      const channel = MethodChannel('native_googleads');

      // Test onAdDismissed
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('onAdDismissed', {'type': 'interstitial'}),
        ),
        (_) {},
      );
      expect(dismissedAdType, 'interstitial');

      // Test onAdShowed
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('onAdShowed', {'type': 'rewarded'}),
        ),
        (_) {},
      );
      expect(showedAdType, 'rewarded');

      // Test onAdFailedToShow
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('onAdFailedToShow', {
            'type': 'interstitial',
            'error': 'Network error',
          }),
        ),
        (_) {},
      );
      expect(failedAdType, 'interstitial');
      expect(failedError, 'Network error');

      // Test onUserEarnedReward
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('onUserEarnedReward', {
            'type': 'coins',
            'amount': 100,
          }),
        ),
        (_) {},
      );
      expect(rewardType, 'coins');
      expect(rewardAmount, 100);
    });
  });

  group('AdConfig', () {
    test('test configuration', () {
      final config = AdConfig.test();

      expect(config.testMode, true);
      expect(config.appId, null);
      expect(config.testDeviceIds, {});
    });

    test('production configuration', () {
      final config = AdConfig.production(
        appId: 'prod-app-id',
        testDeviceIds: {'device1': 'device1', 'device2': 'device2'},
      );

      expect(config.testMode, false);
      expect(config.appId, 'prod-app-id');
      expect(
          config.testDeviceIds, {'device1': 'device1', 'device2': 'device2'});
    });

    test('custom configuration', () {
      const config = AdConfig(
        appId: 'custom-app-id',
        testDeviceIds: {'custom-device': 'custom-device'},
        testMode: true,
      );

      expect(config.testMode, true);
      expect(config.appId, 'custom-app-id');
      expect(config.testDeviceIds, {'custom-device': 'custom-device'});
    });
  });

  group('AdRequestConfig', () {
    test('toMap with all parameters', () {
      const config = AdRequestConfig(
        keywords: ['games', 'sports'],
        contentUrl: 'https://example.com',
        testDevices: ['device1', 'device2'],
        nonPersonalizedAds: true,
      );

      final map = config.toMap();

      expect(map['keywords'], ['games', 'sports']);
      expect(map['contentUrl'], 'https://example.com');
      expect(map['testDevices'], ['device1', 'device2']);
      expect(map['nonPersonalizedAds'], true);
    });

    test('toMap with partial parameters', () {
      const config = AdRequestConfig(
        keywords: ['news'],
        nonPersonalizedAds: false,
      );

      final map = config.toMap();

      expect(map['keywords'], ['news']);
      expect(map.containsKey('contentUrl'), false);
      expect(map.containsKey('testDevices'), false);
      expect(map['nonPersonalizedAds'], false);
    });

    test('toMap with no parameters', () {
      const config = AdRequestConfig();

      final map = config.toMap();

      expect(map.isEmpty, true);
    });
  });

  group('BannerAdSize', () {
    test('BannerAdSize enum values', () {
      expect(BannerAdSize.banner.index, 0);
      expect(BannerAdSize.largeBanner.index, 1);
      expect(BannerAdSize.mediumRectangle.index, 2);
      expect(BannerAdSize.fullBanner.index, 3);
      expect(BannerAdSize.leaderboard.index, 4);
      expect(BannerAdSize.adaptive.index, 5);
    });

    test('BannerAdSize enum contains all expected values', () {
      expect(BannerAdSize.values.length, 6);
      expect(BannerAdSize.values, contains(BannerAdSize.banner));
      expect(BannerAdSize.values, contains(BannerAdSize.largeBanner));
      expect(BannerAdSize.values, contains(BannerAdSize.mediumRectangle));
      expect(BannerAdSize.values, contains(BannerAdSize.fullBanner));
      expect(BannerAdSize.values, contains(BannerAdSize.leaderboard));
      expect(BannerAdSize.values, contains(BannerAdSize.adaptive));
    });
  });

  group('AdTestIds', () {
    test('Android test IDs', () {
      expect(AdTestIds.androidAppId, 'ca-app-pub-3940256099942544~3347511713');
      expect(AdTestIds.androidInterstitial,
          'ca-app-pub-3940256099942544/1033173712');
      expect(
          AdTestIds.androidRewarded, 'ca-app-pub-3940256099942544/5224354917');
      expect(AdTestIds.androidBanner, 'ca-app-pub-3940256099942544/2435281174');
      expect(AdTestIds.androidNativeAdvanced,
          'ca-app-pub-3940256099942544/3986624511');
    });

    test('iOS test IDs', () {
      expect(AdTestIds.iosAppId, 'ca-app-pub-3940256099942544~1458002511');
      expect(
          AdTestIds.iosInterstitial, 'ca-app-pub-3940256099942544/4411468910');
      expect(AdTestIds.iosRewarded, 'ca-app-pub-3940256099942544/1712485313');
      expect(AdTestIds.iosBanner, 'ca-app-pub-3940256099942544/2435281174');
      expect(AdTestIds.iosNativeAdvanced,
          'ca-app-pub-3940256099942544/3986624511');
    });
  });

  group('Additional NativeGoogleads Tests', () {
    final NativeGoogleads ads = NativeGoogleads.instance;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'initialize':
              return {
                'isReady': true,
                'appId': 'test-app-id',
                'adapterStatus': {}
              };
            case 'loadBannerAd':
              return 'banner-id-123';
            case 'disposeBannerAd':
              return true;
            default:
              return null;
          }
        },
      );
    });

    test('validates ad unit ID for empty string', () {
      // Empty ad unit ID should throw ArgumentError
      expect(
        () => ads.loadBannerAd(
          adUnitId: '',
          size: BannerAdSize.banner,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ads.loadNativeAd(adUnitId: ''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ads.preloadRewardedAd(adUnitId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles multiple banner ads simultaneously', () async {
      final result = await ads.initialize();
      expect(result?['isReady'], true);

      // Load multiple banners
      final banner1 = await ads.loadBannerAd(
        adUnitId: 'test-banner-1',
        size: BannerAdSize.banner,
      );
      final banner2 = await ads.loadBannerAd(
        adUnitId: 'test-banner-2',
        size: BannerAdSize.largeBanner,
      );

      expect(banner1, isNotNull);
      expect(banner2, isNotNull);

      // Dispose in different order
      await ads.disposeBannerAd(banner2!);
      await ads.disposeBannerAd(banner1!);
    });

    test('handles null returns from platform gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        (MethodCall methodCall) async {
          // Return null for all methods
          return null;
        },
      );

      // Should handle null and return appropriate defaults
      final result = await ads.initialize();
      expect(result, null);

      final loaded = await ads.preloadInterstitialAd(
        adUnitId: 'test-ad-unit',
      );
      expect(loaded, false);

      final bannerId = await ads.loadBannerAd(
        adUnitId: 'test-banner',
        size: BannerAdSize.banner,
      );
      expect(bannerId, isNull);
    });
  });

  group('Production/test ID validation policy', () {
    final NativeGoogleads ads = NativeGoogleads.instance;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      // Force release mode for validation path
      ads.debugSetForceReleaseModeForValidation(true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'preloadInterstitialAd':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      ads.debugSetForceReleaseModeForValidation(null);
      ads.setAdIdValidationPolicy(
        disallowTestIdsInRelease: true,
        strict: false,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_googleads'),
        null,
      );
    });

    test('warn-only policy allows test IDs in release (no throw)', () async {
      // default policy: disallow true + strict false => warn only
      final ok = await ads.preloadInterstitialAd(
        adUnitId: AdTestIds.androidInterstitial,
      );
      expect(ok, true);
      expect(log, [
        isMethodCall('preloadInterstitialAd', arguments: {
          'adUnitId': AdTestIds.androidInterstitial,
        }),
      ]);
    });

    test('strict policy throws on test IDs in release', () async {
      ads.setAdIdValidationPolicy(strict: true);
      expect(
        () => ads.preloadInterstitialAd(
          adUnitId: AdTestIds.androidInterstitial,
        ),
        throwsA(isA<ArgumentError>()),
      );
      // No platform call should be made
      expect(log, isEmpty);
    });

    test('allowTestIdsInRelease disables the check', () async {
      ads.setAdIdValidationPolicy(
          disallowTestIdsInRelease: false, strict: true);
      final ok = await ads.preloadInterstitialAd(
        adUnitId: AdTestIds.androidInterstitial,
      );
      expect(ok, true);
      expect(log, isNotEmpty);
    });
  });
}
