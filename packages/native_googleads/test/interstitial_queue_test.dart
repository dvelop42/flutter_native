import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_googleads/native_googleads.dart';
import 'package:native_googleads/src/interstitial_queue_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late InterstitialQueueManager queueManager;
  late NativeGoogleads ads;
  
  setUp(() {
    queueManager = InterstitialQueueManager();
    ads = NativeGoogleads.instance;
    const channel = MethodChannel('native_googleads');
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return {'isReady': true};
        case 'preloadInterstitialAd':
          return true;
        case 'isInterstitialReady':
          return true;
        case 'showInterstitialAd':
          return true;
        case 'clearInterstitialCache':
        case 'clearAllInterstitialCache':
        case 'disposeInterstitialFromQueue':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    queueManager.dispose();
    ads.clearTestState();
  });

  group('QueueConfig Tests', () {
    test('Default configuration has correct values', () {
      const config = QueueConfig();
      expect(config.maxSize, equals(3));
      expect(config.minSize, equals(1));
      expect(config.autoRefill, isTrue);
      expect(config.ttl, equals(const Duration(hours: 1)));
      expect(config.priority, equals(0));
    });

    test('High priority configuration has correct values', () {
      final config = QueueConfig.highPriority();
      expect(config.maxSize, equals(5));
      expect(config.minSize, equals(2));
      expect(config.autoRefill, isTrue);
      expect(config.ttl, equals(const Duration(hours: 2)));
      expect(config.priority, equals(10));
    });

    test('Low priority configuration has correct values', () {
      final config = QueueConfig.lowPriority();
      expect(config.maxSize, equals(2));
      expect(config.minSize, equals(0));
      expect(config.autoRefill, isFalse);
      expect(config.ttl, equals(const Duration(minutes: 30)));
      expect(config.priority, equals(-10));
    });
  });

  group('InterstitialQueueManager Tests', () {
    test('Initialize queue creates empty queue', () {
      const adUnitId = 'test-ad-unit';
      queueManager.initializeQueue(adUnitId);
      
      expect(queueManager.getQueueSize(adUnitId), equals(0));
      expect(queueManager.getQueueStatus()[adUnitId], equals(0));
    });

    test('Enqueue and dequeue ads FIFO order', () async {
      const adUnitId = 'test-ad-unit';
      queueManager.initializeQueue(adUnitId);
      
      // Add ads
      await queueManager.enqueueAd(adUnitId, 'ad1');
      await queueManager.enqueueAd(adUnitId, 'ad2');
      await queueManager.enqueueAd(adUnitId, 'ad3');
      
      expect(queueManager.getQueueSize(adUnitId), equals(3));
      
      // Remove ads (FIFO)
      final ad1 = await queueManager.dequeueAd(adUnitId);
      expect(ad1?.id, equals('ad1'));
      
      final ad2 = await queueManager.dequeueAd(adUnitId);
      expect(ad2?.id, equals('ad2'));
      
      expect(queueManager.getQueueSize(adUnitId), equals(1));
    });

    test('Queue respects max size limit', () async {
      const adUnitId = 'test-ad-unit';
      const config = QueueConfig(maxSize: 2);
      queueManager.initializeQueue(adUnitId, config: config);
      
      bool expiredCalled = false;
      String? expiredAdId;
      queueManager.onAdExpired = (unitId, adId) {
        expiredCalled = true;
        expiredAdId = adId;
      };
      
      await queueManager.enqueueAd(adUnitId, 'ad1');
      await queueManager.enqueueAd(adUnitId, 'ad2');
      await queueManager.enqueueAd(adUnitId, 'ad3'); // Should remove ad1
      
      expect(queueManager.getQueueSize(adUnitId), equals(2));
      expect(expiredCalled, isTrue);
      expect(expiredAdId, equals('ad1'));
    });

    test('Queue callbacks trigger correctly', () async {
      const adUnitId = 'test-ad-unit';
      const config = QueueConfig(minSize: 1);
      queueManager.initializeQueue(adUnitId, config: config);
      
      bool emptyCallbackTriggered = false;
      bool lowCallbackTriggered = false;
      
      queueManager.onQueueEmpty = (unitId) {
        emptyCallbackTriggered = true;
      };
      
      queueManager.onQueueLow = (unitId) {
        lowCallbackTriggered = true;
      };
      
      await queueManager.enqueueAd(adUnitId, 'ad1');
      await queueManager.enqueueAd(adUnitId, 'ad2');
      
      // Dequeue to trigger low callback
      await queueManager.dequeueAd(adUnitId);
      expect(lowCallbackTriggered, isTrue);
      
      // Dequeue to trigger empty callback
      await queueManager.dequeueAd(adUnitId);
      await queueManager.dequeueAd(adUnitId); // Try dequeue from empty
      expect(emptyCallbackTriggered, isTrue);
    });

    test('Get queues needing refill returns correct list', () async {
      queueManager.initializeQueue('high', 
        config: QueueConfig.highPriority());
      queueManager.initializeQueue('low', 
        config: QueueConfig.lowPriority());
      queueManager.initializeQueue('normal',
        config: const QueueConfig(minSize: 2, autoRefill: true));
      
      // Add ads
      await queueManager.enqueueAd('high', 'ad1'); // Below minSize (2)
      await queueManager.enqueueAd('normal', 'ad1'); // Below minSize (2)
      // 'low' has autoRefill=false, shouldn't appear
      
      final needsRefill = queueManager.getQueuesNeedingRefill();
      
      expect(needsRefill.length, equals(2));
      expect(needsRefill[0], equals('high')); // Higher priority
      expect(needsRefill[1], equals('normal'));
    });

    test('Clear cache removes all ads', () async {
      const adUnitId = 'test-ad-unit';
      queueManager.initializeQueue(adUnitId);
      
      await queueManager.enqueueAd(adUnitId, 'ad1');
      await queueManager.enqueueAd(adUnitId, 'ad2');
      
      expect(queueManager.getQueueSize(adUnitId), equals(2));
      
      queueManager.clearCache(adUnitId);
      
      expect(queueManager.getQueueSize(adUnitId), equals(0));
    });

    test('Navigation pattern learning works', () {
      queueManager.recordNavigation('home');
      queueManager.recordNavigation('game');
      queueManager.recordNavigation('store');
      queueManager.recordNavigation('game');
      queueManager.recordNavigation('results');
      
      // Should predict 'results' after 'game'
      queueManager.recordNavigation('game');
      final predictions = queueManager.predictNextPlacements();
      
      expect(predictions.contains('results'), isTrue);
    });

    test('Retry mechanism with exponential backoff', () {
      const adUnitId = 'test-ad-unit';
      queueManager.initializeQueue(adUnitId);
      
      // First attempt
      queueManager.incrementLoadAttempt(adUnitId);
      var delay = queueManager.getRetryDelay(adUnitId);
      expect(delay.inSeconds, equals(2)); // 2^1
      
      // Second attempt
      queueManager.incrementLoadAttempt(adUnitId);
      delay = queueManager.getRetryDelay(adUnitId);
      expect(delay.inSeconds, equals(4)); // 2^2
      
      // Third attempt
      queueManager.incrementLoadAttempt(adUnitId);
      delay = queueManager.getRetryDelay(adUnitId);
      expect(delay.inSeconds, equals(8)); // 2^3
      
      // Check retry limit
      expect(queueManager.isRetryLimitReached(adUnitId), isTrue);
    });

    test('Detailed queue info returns correct data', () async {
      const adUnitId = 'test-ad-unit';
      const config = QueueConfig(
        maxSize: 5,
        minSize: 2,
        priority: 10,
      );
      queueManager.initializeQueue(adUnitId, config: config);
      
      await queueManager.enqueueAd(adUnitId, 'ad1');
      await queueManager.enqueueAd(adUnitId, 'ad2');
      
      final info = queueManager.getDetailedQueueInfo(adUnitId);
      
      expect(info['adUnitId'], equals(adUnitId));
      expect(info['currentSize'], equals(2));
      expect(info['maxSize'], equals(5));
      expect(info['minSize'], equals(2));
      expect(info['priority'], equals(10));
      expect(info['autoRefill'], isTrue);
      expect((info['ads'] as List).length, equals(2));
    });
  });

  group('NativeGoogleads Queue Integration Tests', () {
    test('Initialize interstitial queue', () {
      const adUnitId = 'test-ad-unit';
      ads.initializeInterstitialQueue(adUnitId);
      
      final status = ads.getInterstitialQueueStatus();
      expect(status.containsKey(adUnitId), isTrue);
      expect(status[adUnitId], equals(0));
    });

    test('Preload multiple interstitials', () async {
      final adUnitIds = ['ad1', 'ad2', 'ad3'];
      
      final results = await ads.preloadMultipleInterstitials(
        adUnitIds,
        configs: {
          'ad1': InterstitialConfig.gaming(),
          'ad2': InterstitialConfig.content(),
        },
        queueConfigs: {
          'ad1': QueueConfig.highPriority(),
          'ad2': const QueueConfig(),
          'ad3': QueueConfig.lowPriority(),
        },
      );
      
      expect(results.length, equals(3));
      expect(results['ad1'], isTrue);
      expect(results['ad2'], isTrue);
      expect(results['ad3'], isTrue);
    });

    test('Get preloaded count', () {
      ads.initializeInterstitialQueue('ad1');
      ads.initializeInterstitialQueue('ad2');
      
      // Initially empty
      expect(ads.getPreloadedCount(null), equals(0));
      expect(ads.getPreloadedCount('ad1'), equals(0));
    });

    test('Clear interstitial cache', () async {
      const adUnitId = 'test-ad-unit';
      ads.initializeInterstitialQueue(adUnitId);
      
      await ads.clearInterstitialCache(adUnitId);
      
      final status = ads.getInterstitialQueueStatus();
      expect(status[adUnitId], equals(0));
    });

    test('Record navigation and get predictions', () {
      ads.recordNavigation('home');
      ads.recordNavigation('game');
      ads.recordNavigation('results');
      ads.recordNavigation('home');
      ads.recordNavigation('game');
      
      final predictions = ads.getPredictedPlacements(maxPredictions: 2);
      expect(predictions.length, lessThanOrEqualTo(2));
    });

    test('Preload with retry mechanism', () async {
      const adUnitId = 'test-ad-unit';
      
      final success = await ads.preloadInterstitialWithRetry(
        adUnitId: adUnitId,
        config: InterstitialConfig.gaming(),
        maxRetries: 3,
      );
      
      expect(success, isTrue);
    });

    test('Get detailed queue info', () {
      const adUnitId = 'test-ad-unit';
      ads.initializeInterstitialQueue(
        adUnitId,
        config: QueueConfig.highPriority(),
      );
      
      final info = ads.getDetailedQueueInfo(adUnitId);
      
      expect(info['adUnitId'], equals(adUnitId));
      expect(info['maxSize'], equals(5));
      expect(info['priority'], equals(10));
    });

    test('Set max cache size', () {
      // This is a simple setter test
      expect(() => ads.setMaxInterstitialCacheSize(10), returnsNormally);
    });
  });

  group('CachedInterstitialAd Tests', () {
    test('Ad validity check works correctly', () {
      final now = DateTime.now();
      final ad = CachedInterstitialAd(
        id: 'test-ad',
        adUnitId: 'test-unit',
        loadTime: now,
        expiryTime: now.add(const Duration(hours: 1)),
      );
      
      expect(ad.isValid, isTrue);
      expect(ad.timeToExpiry.inMinutes, greaterThan(55));
    });

    test('Expired ad is detected correctly', () {
      final now = DateTime.now();
      final ad = CachedInterstitialAd(
        id: 'test-ad',
        adUnitId: 'test-unit',
        loadTime: now.subtract(const Duration(hours: 2)),
        expiryTime: now.subtract(const Duration(hours: 1)),
      );
      
      expect(ad.isValid, isFalse);
    });
  });
}