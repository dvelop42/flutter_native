import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Configuration for an ad queue.
@immutable
class QueueConfig {
  /// Maximum number of ads to keep in the queue.
  final int maxSize;

  /// Minimum number of ads before triggering auto-refill.
  final int minSize;

  /// Whether to automatically refill the queue.
  final bool autoRefill;

  /// Time to live for cached ads before they expire.
  final Duration ttl;

  /// Priority level for this placement (higher = more important).
  final int priority;

  const QueueConfig({
    this.maxSize = 3,
    this.minSize = 1,
    this.autoRefill = true,
    this.ttl = const Duration(hours: 1),
    this.priority = 0,
  });

  /// Creates a high-priority configuration.
  factory QueueConfig.highPriority() {
    return const QueueConfig(
      maxSize: 5,
      minSize: 2,
      autoRefill: true,
      ttl: Duration(hours: 2),
      priority: 10,
    );
  }

  /// Creates a low-priority configuration.
  factory QueueConfig.lowPriority() {
    return const QueueConfig(
      maxSize: 2,
      minSize: 0,
      autoRefill: false,
      ttl: Duration(minutes: 30),
      priority: -10,
    );
  }
}

/// Represents a cached interstitial ad.
class CachedInterstitialAd {
  /// Unique identifier for this ad instance.
  final String id;

  /// The ad unit ID this ad belongs to.
  final String adUnitId;

  /// When this ad was loaded.
  final DateTime loadTime;

  /// When this ad expires.
  final DateTime expiryTime;

  /// Whether this ad is still valid.
  bool get isValid => DateTime.now().isBefore(expiryTime);

  /// How long until this ad expires.
  Duration get timeToExpiry => expiryTime.difference(DateTime.now());

  CachedInterstitialAd({
    required this.id,
    required this.adUnitId,
    required this.loadTime,
    required this.expiryTime,
  });
}

/// Manages multiple queues of interstitial ads.
class InterstitialQueueManager {
  /// Maps ad unit IDs to their respective ad queues.
  final Map<String, Queue<CachedInterstitialAd>> _adQueues = {};

  /// Configuration for each ad unit.
  final Map<String, QueueConfig> _queueConfigs = {};

  /// Callbacks for queue events.
  Function(String adUnitId)? onQueueEmpty;
  Function(String adUnitId)? onQueueLow;
  Function(String adUnitId, String adId)? onAdExpired;

  /// Timer for periodic cleanup of expired ads.
  Timer? _cleanupTimer;

  /// Whether the manager is active.
  bool _isActive = false;

  /// Load attempt tracking for retry logic.
  final Map<String, int> _loadAttempts = {};

  /// Backoff delays for retry logic.
  final Map<String, Duration> _backoffDelays = {};

  /// Navigation pattern tracking for smart preloading.
  final List<String> _navigationHistory = [];
  final int _maxHistorySize = 20;

  /// Predictive preloading patterns.
  final Map<String, List<String>> _navigationPatterns = {};

  InterstitialQueueManager() {
    _startCleanupTimer();
  }

  /// Initializes a queue for the given ad unit.
  void initializeQueue(String adUnitId, {QueueConfig? config}) {
    config ??= const QueueConfig();
    _queueConfigs[adUnitId] = config;
    _adQueues[adUnitId] = Queue<CachedInterstitialAd>();
    _loadAttempts[adUnitId] = 0;
    _backoffDelays[adUnitId] = Duration.zero;
  }

  /// Adds an ad to the queue for the specified ad unit.
  bool enqueueAd(String adUnitId, String adId, {Duration? customTtl}) {
    if (!_adQueues.containsKey(adUnitId)) {
      debugPrint('Warning: Queue not initialized for ad unit: $adUnitId');
      return false;
    }

    final config = _queueConfigs[adUnitId]!;
    final queue = _adQueues[adUnitId]!;

    // Check if queue is at max capacity
    if (queue.length >= config.maxSize) {
      // Remove the oldest ad if at capacity
      final oldAd = queue.removeFirst();
      onAdExpired?.call(adUnitId, oldAd.id);
    }

    final now = DateTime.now();
    final ttl = customTtl ?? config.ttl;
    final cachedAd = CachedInterstitialAd(
      id: adId,
      adUnitId: adUnitId,
      loadTime: now,
      expiryTime: now.add(ttl),
    );

    queue.add(cachedAd);

    // Reset retry attempts on successful load
    _loadAttempts[adUnitId] = 0;
    _backoffDelays[adUnitId] = Duration.zero;

    debugPrint('Ad $adId added to queue for $adUnitId. Queue size: ${queue.length}');
    return true;
  }

  /// Retrieves the next ad from the queue (FIFO).
  CachedInterstitialAd? dequeueAd(String adUnitId) {
    final queue = _adQueues[adUnitId];
    if (queue == null || queue.isEmpty) {
      onQueueEmpty?.call(adUnitId);
      return null;
    }

    // Remove expired ads first
    _removeExpiredAds(adUnitId);

    if (queue.isEmpty) {
      onQueueEmpty?.call(adUnitId);
      return null;
    }

    final ad = queue.removeFirst();

    // Check if queue is getting low
    final config = _queueConfigs[adUnitId]!;
    if (queue.length <= config.minSize) {
      onQueueLow?.call(adUnitId);
    }

    debugPrint('Ad ${ad.id} dequeued from $adUnitId. Queue size: ${queue.length}');
    return ad;
  }

  /// Gets the number of ads in the queue for a specific ad unit.
  int getQueueSize(String adUnitId) {
    _removeExpiredAds(adUnitId);
    return _adQueues[adUnitId]?.length ?? 0;
  }

  /// Gets the queue status for all ad units.
  Map<String, int> getQueueStatus() {
    final status = <String, int>{};
    for (final adUnitId in _adQueues.keys) {
      status[adUnitId] = getQueueSize(adUnitId);
    }
    return status;
  }

  /// Checks if any queue needs refilling.
  List<String> getQueuesNeedingRefill() {
    final needsRefill = <String>[];
    
    for (final entry in _queueConfigs.entries) {
      final adUnitId = entry.key;
      final config = entry.value;
      
      if (!config.autoRefill) continue;
      
      final currentSize = getQueueSize(adUnitId);
      if (currentSize <= config.minSize) {
        needsRefill.add(adUnitId);
      }
    }

    // Sort by priority
    needsRefill.sort((a, b) {
      final priorityA = _queueConfigs[a]?.priority ?? 0;
      final priorityB = _queueConfigs[b]?.priority ?? 0;
      return priorityB.compareTo(priorityA);
    });

    return needsRefill;
  }

  /// Clears the cache for a specific ad unit or all if null.
  void clearCache(String? adUnitId) {
    if (adUnitId != null) {
      final queue = _adQueues[adUnitId];
      if (queue != null) {
        for (final ad in queue) {
          onAdExpired?.call(adUnitId, ad.id);
        }
        queue.clear();
      }
    } else {
      for (final entry in _adQueues.entries) {
        for (final ad in entry.value) {
          onAdExpired?.call(entry.key, ad.id);
        }
        entry.value.clear();
      }
    }
  }

  /// Records navigation for pattern learning.
  void recordNavigation(String placement) {
    _navigationHistory.add(placement);
    
    // Keep history size limited
    if (_navigationHistory.length > _maxHistorySize) {
      _navigationHistory.removeAt(0);
    }

    // Learn patterns (simple bigram model)
    if (_navigationHistory.length >= 2) {
      final previous = _navigationHistory[_navigationHistory.length - 2];
      if (!_navigationPatterns.containsKey(previous)) {
        _navigationPatterns[previous] = [];
      }
      _navigationPatterns[previous]!.add(placement);
    }
  }

  /// Predicts likely next placements based on navigation history.
  List<String> predictNextPlacements({int maxPredictions = 3}) {
    if (_navigationHistory.isEmpty) return [];

    final currentPlacement = _navigationHistory.last;
    final predictions = <String, int>{};

    // Get patterns for current placement
    final patterns = _navigationPatterns[currentPlacement] ?? [];
    for (final next in patterns) {
      predictions[next] = (predictions[next] ?? 0) + 1;
    }

    // Sort by frequency and return top predictions
    final sorted = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(maxPredictions)
        .map((e) => e.key)
        .toList();
  }

  /// Calculates retry delay with exponential backoff.
  Duration getRetryDelay(String adUnitId) {
    final attempts = _loadAttempts[adUnitId] ?? 0;
    
    // Exponential backoff: 2^attempts seconds, max 5 minutes
    final delaySeconds = min(pow(2, attempts).toInt(), 300);
    final delay = Duration(seconds: delaySeconds);
    
    _backoffDelays[adUnitId] = delay;
    return delay;
  }

  /// Increments load attempts for retry tracking.
  void incrementLoadAttempt(String adUnitId) {
    _loadAttempts[adUnitId] = (_loadAttempts[adUnitId] ?? 0) + 1;
  }

  /// Gets the maximum retry count for an ad unit.
  int getMaxRetries(String adUnitId) {
    // Could be configured per queue, defaulting to 3
    return 3;
  }

  /// Checks if retry limit is reached.
  bool isRetryLimitReached(String adUnitId) {
    final attempts = _loadAttempts[adUnitId] ?? 0;
    return attempts >= getMaxRetries(adUnitId);
  }

  /// Removes expired ads from a queue.
  void _removeExpiredAds(String adUnitId) {
    final queue = _adQueues[adUnitId];
    if (queue == null) return;

    final expired = <CachedInterstitialAd>[];
    final valid = <CachedInterstitialAd>[];

    for (final ad in queue) {
      if (ad.isValid) {
        valid.add(ad);
      } else {
        expired.add(ad);
      }
    }

    if (expired.isNotEmpty) {
      queue.clear();
      queue.addAll(valid);
      
      for (final ad in expired) {
        onAdExpired?.call(adUnitId, ad.id);
        debugPrint('Expired ad ${ad.id} removed from queue $adUnitId');
      }
    }
  }

  /// Starts the cleanup timer for periodic maintenance.
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performCleanup(),
    );
    _isActive = true;
  }

  /// Performs periodic cleanup of expired ads.
  void _performCleanup() {
    for (final adUnitId in _adQueues.keys) {
      _removeExpiredAds(adUnitId);
    }
  }

  /// Gets detailed queue information for debugging.
  Map<String, dynamic> getDetailedQueueInfo(String adUnitId) {
    final queue = _adQueues[adUnitId];
    final config = _queueConfigs[adUnitId];
    
    if (queue == null || config == null) {
      return {'error': 'Queue not found for $adUnitId'};
    }

    _removeExpiredAds(adUnitId);

    return {
      'adUnitId': adUnitId,
      'currentSize': queue.length,
      'maxSize': config.maxSize,
      'minSize': config.minSize,
      'autoRefill': config.autoRefill,
      'priority': config.priority,
      'ttl': config.ttl.inMinutes,
      'ads': queue.map((ad) => {
        'id': ad.id,
        'loadTime': ad.loadTime.toIso8601String(),
        'expiryTime': ad.expiryTime.toIso8601String(),
        'isValid': ad.isValid,
        'timeToExpiry': ad.timeToExpiry.inSeconds,
      }).toList(),
      'loadAttempts': _loadAttempts[adUnitId] ?? 0,
      'backoffDelay': _backoffDelays[adUnitId]?.inSeconds ?? 0,
    };
  }

  /// Disposes the queue manager and cleans up resources.
  void dispose() {
    _cleanupTimer?.cancel();
    _isActive = false;
    clearCache(null);
    _adQueues.clear();
    _queueConfigs.clear();
    _loadAttempts.clear();
    _backoffDelays.clear();
    _navigationHistory.clear();
    _navigationPatterns.clear();
  }
}