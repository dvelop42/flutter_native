import 'package:flutter/foundation.dart';

/// Configuration options for interstitial ads.
///
/// Provides advanced control over interstitial ad behavior including
/// presentation options, timing controls, and platform-specific features.
@immutable
class InterstitialConfig {
  /// Whether to show the ad in immersive mode (Android only).
  /// 
  /// When enabled, the ad will hide system UI elements like
  /// the status bar and navigation bar.
  final bool? immersiveMode;

  /// Whether to disable the back button during ad display (Android only).
  /// 
  /// When true, pressing the back button will not dismiss the ad.
  final bool? disableBackButton;

  /// Minimum time that must pass between showing ads.
  /// 
  /// This is enforced in addition to frequency capping.
  /// If an ad is requested before this duration has passed,
  /// it will not be shown.
  final Duration? minTimeBetweenAds;

  /// Maximum number of times to retry loading an ad on failure.
  /// 
  /// Defaults to 3 if not specified.
  final int? maxRetries;

  /// Delay before the close button appears on the ad.
  /// 
  /// Some ad formats support delaying the close button
  /// to ensure minimum viewing time.
  final Duration? closeButtonDelay;

  /// Whether to mute video ads by default.
  /// 
  /// Applies only to video interstitial ads.
  final bool? muteByDefault;

  const InterstitialConfig({
    this.immersiveMode,
    this.disableBackButton,
    this.minTimeBetweenAds,
    this.maxRetries,
    this.closeButtonDelay,
    this.muteByDefault,
  });

  /// Creates a configuration optimized for gaming apps.
  factory InterstitialConfig.gaming() {
    return const InterstitialConfig(
      immersiveMode: true,
      disableBackButton: true,
      minTimeBetweenAds: Duration(minutes: 3),
      muteByDefault: false,
    );
  }

  /// Creates a configuration optimized for content apps.
  factory InterstitialConfig.content() {
    return const InterstitialConfig(
      immersiveMode: false,
      disableBackButton: false,
      minTimeBetweenAds: Duration(minutes: 5),
      muteByDefault: true,
    );
  }

  /// Converts this configuration to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    
    if (immersiveMode != null) {
      map['immersiveMode'] = immersiveMode;
    }
    if (disableBackButton != null) {
      map['disableBackButton'] = disableBackButton;
    }
    if (minTimeBetweenAds != null) {
      map['minTimeBetweenAds'] = minTimeBetweenAds!.inMilliseconds;
    }
    if (maxRetries != null) {
      map['maxRetries'] = maxRetries;
    }
    if (closeButtonDelay != null) {
      map['closeButtonDelay'] = closeButtonDelay!.inSeconds;
    }
    if (muteByDefault != null) {
      map['muteByDefault'] = muteByDefault;
    }
    
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterstitialConfig &&
          runtimeType == other.runtimeType &&
          immersiveMode == other.immersiveMode &&
          disableBackButton == other.disableBackButton &&
          minTimeBetweenAds == other.minTimeBetweenAds &&
          maxRetries == other.maxRetries &&
          closeButtonDelay == other.closeButtonDelay &&
          muteByDefault == other.muteByDefault;

  @override
  int get hashCode =>
      immersiveMode.hashCode ^
      disableBackButton.hashCode ^
      minTimeBetweenAds.hashCode ^
      maxRetries.hashCode ^
      closeButtonDelay.hashCode ^
      muteByDefault.hashCode;
}

/// Frequency cap configuration for interstitial ads.
@immutable
class FrequencyCap {
  /// Maximum number of impressions allowed.
  final int maxImpressions;

  /// Time period in hours for the impression limit.
  final int perHours;

  const FrequencyCap({
    required this.maxImpressions,
    required this.perHours,
  }) : assert(maxImpressions > 0, 'maxImpressions must be greater than 0'),
       assert(perHours > 0, 'perHours must be greater than 0');

  /// Checks if showing an ad would exceed the frequency cap.
  /// 
  /// [impressionTimestamps] should be a list of millisecondsSinceEpoch
  /// when ads were shown.
  bool isCapReached(List<int> impressionTimestamps) {
    if (impressionTimestamps.isEmpty) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoffTime = now - (perHours * 3600 * 1000);
    
    // Count impressions within the time window
    final recentImpressions = impressionTimestamps
        .where((timestamp) => timestamp > cutoffTime)
        .length;
    
    return recentImpressions >= maxImpressions;
  }

  Map<String, dynamic> toMap() {
    return {
      'maxImpressions': maxImpressions,
      'perHours': perHours,
    };
  }
}

/// Load time metrics for interstitial ads.
class InterstitialLoadMetrics {
  final String adUnitId;
  final DateTime loadStartTime;
  final DateTime? loadEndTime;
  final bool success;
  final String? errorMessage;

  InterstitialLoadMetrics({
    required this.adUnitId,
    required this.loadStartTime,
    this.loadEndTime,
    this.success = false,
    this.errorMessage,
  });

  /// Gets the load duration in milliseconds.
  /// Returns null if loading is not complete.
  int? get loadDurationMs {
    if (loadEndTime == null) return null;
    return loadEndTime!.difference(loadStartTime).inMilliseconds;
  }

  /// Creates a copy with updated values.
  InterstitialLoadMetrics copyWith({
    DateTime? loadEndTime,
    bool? success,
    String? errorMessage,
  }) {
    return InterstitialLoadMetrics(
      adUnitId: adUnitId,
      loadStartTime: loadStartTime,
      loadEndTime: loadEndTime ?? this.loadEndTime,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}