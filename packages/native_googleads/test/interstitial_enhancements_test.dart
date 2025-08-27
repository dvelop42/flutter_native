import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_googleads/native_googleads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Interstitial Enhancements', () {
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
              return {'isReady': true, 'appId': 'test-app-id'};
            case 'preloadInterstitialAd':
              return true;
            case 'showInterstitialAd':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('native_googleads'), null);
    });

    group('InterstitialConfig', () {
      test('creates config with all options', () {
        const config = InterstitialConfig(
          immersiveMode: true,
          disableBackButton: true,
          minTimeBetweenAds: Duration(minutes: 5),
          maxRetries: 3,
          closeButtonDelay: Duration(seconds: 5),
          muteByDefault: true,
        );

        final map = config.toMap();
        expect(map['immersiveMode'], true);
        expect(map['disableBackButton'], true);
        expect(map['minTimeBetweenAds'], 5 * 60 * 1000); // 5 minutes in milliseconds
        expect(map['maxRetries'], 3);
        expect(map['closeButtonDelay'], 5); // 5 seconds
        expect(map['muteByDefault'], true);
      });

      test('creates gaming config with defaults', () {
        final config = InterstitialConfig.gaming();
        final map = config.toMap();
        
        expect(map['immersiveMode'], true);
        expect(map['disableBackButton'], true);
        expect(map['minTimeBetweenAds'], 3 * 60 * 1000); // 3 minutes
        expect(map['muteByDefault'], false);
      });

      test('creates content config with defaults', () {
        final config = InterstitialConfig.content();
        final map = config.toMap();
        
        expect(map['immersiveMode'], false);
        expect(map['disableBackButton'], false);
        expect(map['minTimeBetweenAds'], 5 * 60 * 1000); // 5 minutes
        expect(map['muteByDefault'], true);
      });
    });

    group('FrequencyCap', () {
      test('frequency cap correctly identifies when limit is reached', () {
        const cap = FrequencyCap(maxImpressions: 3, perHours: 1);
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // No impressions - should not be capped
        expect(cap.isCapReached([]), false);
        
        // 2 impressions - should not be capped
        expect(cap.isCapReached([now - 1000, now - 2000]), false);
        
        // 3 impressions within the hour - should be capped
        expect(cap.isCapReached([now - 1000, now - 2000, now - 3000]), true);
        
        // 3 impressions but one is old - should not be capped
        expect(cap.isCapReached([
          now - 1000,
          now - 2000,
          now - (2 * 3600 * 1000), // 2 hours ago
        ]), false);
      });

      test('frequency cap validates constructor parameters', () {
        expect(
          () => FrequencyCap(maxImpressions: 0, perHours: 1),
          throwsAssertionError,
        );
        
        expect(
          () => FrequencyCap(maxImpressions: 1, perHours: 0),
          throwsAssertionError,
        );
      });
    });

    group('Load Time Tracking', () {
      test('tracks load metrics correctly', () {
        final startTime = DateTime.now();
        final endTime = startTime.add(const Duration(milliseconds: 500));
        
        final metrics = InterstitialLoadMetrics(
          adUnitId: 'test-ad',
          loadStartTime: startTime,
          loadEndTime: endTime,
          success: true,
        );
        
        expect(metrics.loadDurationMs, 500);
        expect(metrics.success, true);
        expect(metrics.errorMessage, null);
      });

      test('handles failed load metrics', () {
        final metrics = InterstitialLoadMetrics(
          adUnitId: 'test-ad',
          loadStartTime: DateTime.now(),
          success: false,
          errorMessage: 'Network error',
        );
        
        expect(metrics.loadDurationMs, null); // No end time
        expect(metrics.success, false);
        expect(metrics.errorMessage, 'Network error');
      });
    });

    group('Enhanced Callbacks', () {
      test('preloadInterstitialAd with config passes parameters', () async {
        final config = InterstitialConfig.gaming();
        
        await ads.preloadInterstitialAd(
          adUnitId: 'test-interstitial',
          config: config,
        );
        
        expect(log.length, greaterThan(0));
        final call = log.last;
        expect(call.method, 'preloadInterstitialAd');
        expect(call.arguments['adUnitId'], 'test-interstitial');
        expect(call.arguments['immersiveMode'], true);
        expect(call.arguments['disableBackButton'], true);
      });

      test('setInterstitialFrequencyCap configures frequency capping', () async {
        await ads.setInterstitialFrequencyCap(
          maxImpressions: 5,
          perHours: 2,
        );
        
        // Frequency cap should be set internally
        // We can't directly test private fields, but we can verify 
        // that canShowInterstitial uses the cap
        final canShow = await ads.canShowInterstitial('test-ad');
        expect(canShow, true); // Should be true with no impressions
      });

      test('enhanced callbacks can be set', () {
        int? clickCount;
        int? impressionCount;
        int? loadStartCount;
        
        ads.setAdCallbacks(
          onAdClicked: (type) => clickCount = (clickCount ?? 0) + 1,
          onAdImpression: (type) => impressionCount = (impressionCount ?? 0) + 1,
          onAdLoadStarted: (type) => loadStartCount = (loadStartCount ?? 0) + 1,
        );
        
        // Simulate callbacks from native
        const channel = MethodChannel('native_googleads');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onAdClicked', {'type': 'interstitial'}),
          ),
          (_) {},
        );
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onAdImpression', {'type': 'interstitial'}),
          ),
          (_) {},
        );
        
        expect(clickCount, 1);
        expect(impressionCount, 1);
      });
    });

    group('Average Load Time', () {
      test('getAverageLoadTime returns null when no data', () {
        final avgTime = ads.getAverageLoadTime();
        expect(avgTime, null);
      });

      test('getLastLoadTime returns null when no data', () {
        final lastTime = ads.getLastLoadTime('unknown-ad');
        expect(lastTime, null);
      });
    });
  });
}