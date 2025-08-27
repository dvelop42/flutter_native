/// Custom error types for ad loading and queue management.
class AdLoadError implements Exception {
  final String message;
  final String adUnitId;
  final ErrorType type;
  final int? errorCode;
  
  AdLoadError({
    required this.message,
    required this.adUnitId,
    required this.type,
    this.errorCode,
  });
  
  @override
  String toString() => 'AdLoadError[$type]: $message (adUnit: $adUnitId, code: $errorCode)';
}

/// Types of errors that can occur during ad operations.
enum ErrorType {
  /// Network connectivity issues
  network,
  
  /// Invalid ad unit ID or configuration
  invalidConfiguration,
  
  /// Ad server returned no fill
  noFill,
  
  /// Timeout while loading ad
  timeout,
  
  /// Queue is full
  queueFull,
  
  /// Ad expired before showing
  expired,
  
  /// General loading error
  loadFailed,
  
  /// Platform-specific error
  platformError,
}

/// Recovery strategies for different error types.
class ErrorRecoveryStrategy {
  /// Get recovery strategy for specific error type.
  static RecoveryAction getStrategy(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return RecoveryAction(
          shouldRetry: true,
          retryDelay: const Duration(seconds: 5),
          maxRetries: 3,
          alternativeAction: AlternativeAction.waitForConnectivity,
        );
        
      case ErrorType.noFill:
        return RecoveryAction(
          shouldRetry: true,
          retryDelay: const Duration(minutes: 1),
          maxRetries: 2,
          alternativeAction: AlternativeAction.tryAlternativeAdUnit,
        );
        
      case ErrorType.timeout:
        return RecoveryAction(
          shouldRetry: true,
          retryDelay: const Duration(seconds: 2),
          maxRetries: 3,
          alternativeAction: AlternativeAction.increaseTimeout,
        );
        
      case ErrorType.queueFull:
        return RecoveryAction(
          shouldRetry: false,
          alternativeAction: AlternativeAction.clearOldestAds,
        );
        
      case ErrorType.expired:
        return RecoveryAction(
          shouldRetry: false,
          alternativeAction: AlternativeAction.removeAndReload,
        );
        
      case ErrorType.invalidConfiguration:
        return RecoveryAction(
          shouldRetry: false,
          alternativeAction: AlternativeAction.logAndSkip,
        );
        
      case ErrorType.loadFailed:
      case ErrorType.platformError:
      default:
        return RecoveryAction(
          shouldRetry: true,
          retryDelay: const Duration(seconds: 3),
          maxRetries: 2,
          alternativeAction: AlternativeAction.logAndContinue,
        );
    }
  }
}

/// Recovery action configuration.
class RecoveryAction {
  final bool shouldRetry;
  final Duration? retryDelay;
  final int? maxRetries;
  final AlternativeAction alternativeAction;
  
  RecoveryAction({
    required this.shouldRetry,
    this.retryDelay,
    this.maxRetries,
    required this.alternativeAction,
  });
}

/// Alternative actions when primary recovery fails.
enum AlternativeAction {
  /// Wait for network connectivity
  waitForConnectivity,
  
  /// Try loading from alternative ad unit
  tryAlternativeAdUnit,
  
  /// Increase timeout duration
  increaseTimeout,
  
  /// Clear oldest ads from queue
  clearOldestAds,
  
  /// Remove expired ad and reload
  removeAndReload,
  
  /// Log error and skip
  logAndSkip,
  
  /// Log error and continue
  logAndContinue,
}