import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../native_googleads.dart';

/// A widget that displays a native ad.
///
/// Native ads are customizable ads that match the look and feel of your app.
///
/// Example:
/// ```dart
/// NativeAdWidget(
///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
///   height: 300,
///   style: NativeAdStyle(
///     mediaStyle: NativeAdMediaStyle(aspectRatio: 16/9),
///   ),
///   onAdLoaded: () => print('Native ad loaded'),
///   onAdFailedToLoad: (error) => print('Native ad failed: $error'),
/// )
/// ```
class NativeAdWidget extends StatefulWidget {
  /// The ad unit ID for the native ad.
  final String adUnitId;

  /// The height of the native ad container.
  final double height;

  /// Optional request configuration.
  final AdRequestConfig? requestConfig;

  /// Called when the ad loads successfully.
  final VoidCallback? onAdLoaded;

  /// Called when the ad fails to load.
  final Function(String error)? onAdFailedToLoad;

  /// Called when the ad is clicked.
  final VoidCallback? onAdClicked;

  /// Called when the ad impression is recorded.
  final VoidCallback? onAdImpression;

  /// Background color for the ad container.
  final Color? backgroundColor;

  /// Custom template ID for native ads (optional).
  final String? templateId;

  /// Optional preloaded native ad ID returned by `loadNativeAd`.
  ///
  /// If provided, the widget will skip loading and render this preloaded ad.
  final String? preloadedNativeAdId;

  /// Native ad style configuration
  final NativeAdStyle? style;

  /// Native ad template type
  final NativeAdTemplate? template;

  /// Whether to show the ad in full screen mode
  final bool isFullScreen;

  const NativeAdWidget({
    super.key,
    required this.adUnitId,
    this.height = 250.0,
    this.requestConfig,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
    this.backgroundColor,
    this.templateId,
    this.preloadedNativeAdId,
    this.style,
    this.template,
    this.isFullScreen = false,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  String? _nativeAdId;
  bool _isLoaded = false;
  bool _isShowing = false;
  late final Map<String, dynamic> _creationParams;

  @override
  void initState() {
    super.initState();
    debugPrint(
        'NativeAdWidget: initState called for adUnitId: ${widget.adUnitId}');
    // Initialize creation params once
    _initializeCreationParams();

    if (widget.preloadedNativeAdId != null &&
        widget.preloadedNativeAdId!.isNotEmpty) {
      _nativeAdId = widget.preloadedNativeAdId;
      _isLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAd());
    } else {
      _loadAd();
    }
  }

  void _initializeCreationParams() {
    _creationParams = {
      'adUnitId': widget.adUnitId,
      'height': widget.height,
      if (widget.templateId != null) 'templateId': widget.templateId,
      if (widget.backgroundColor != null)
        'backgroundColor': widget.backgroundColor!.toARGB32(),
      if (widget.style != null) 'style': widget.style!.toMap(),
      if (widget.template != null) 'template': widget.template!.index,
      'isFullScreen': widget.isFullScreen,
    };
  }

  Future<void> _loadAd() async {
    debugPrint('NativeAdWidget: Starting to load ad');
    try {
      final nativeAdId = await _ads
          .loadNativeAd(
        adUnitId: widget.adUnitId,
        requestConfig: widget.requestConfig,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('NativeAdWidget: Ad loading timed out');
          widget.onAdFailedToLoad
              ?.call('Ad loading timed out after 30 seconds');
          return null;
        },
      );

      if (nativeAdId != null && mounted) {
        debugPrint(
            'NativeAdWidget: Ad loaded successfully with ID: $nativeAdId');
        setState(() {
          _nativeAdId = nativeAdId;
          _isLoaded = true;
        });
        widget.onAdLoaded?.call();
        // Automatically show the native ad once loaded
        _showAd();
      } else if (mounted) {
        debugPrint('NativeAdWidget: Failed to load ad');
        widget.onAdFailedToLoad?.call('Failed to load native ad');
      }
    } catch (e) {
      debugPrint('NativeAdWidget: Error loading ad: $e');
      if (mounted) {
        widget.onAdFailedToLoad?.call('Error loading ad: $e');
      }
    }
  }

  Future<void> _showAd() async {
    if (_nativeAdId != null && !_isShowing) {
      final success = await _ads.showNativeAd(_nativeAdId!);
      if (success && mounted) {
        setState(() {
          _isShowing = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up native ad resources
    if (_nativeAdId != null) {
      _ads.disposeNativeAd(_nativeAdId!);
      _nativeAdId = null;
    }
    // Reset state flags
    _isLoaded = false;
    _isShowing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAdId == null) {
      return Container(
        height: widget.height,
        color: widget.backgroundColor ?? Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Update nativeAdId in cached params
    final Map<String, dynamic> creationParams = {
      ..._creationParams,
      'nativeAdId': _nativeAdId,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        height: widget.height,
        color: widget.backgroundColor,
        child: AndroidView(
          viewType: 'native_googleads/native',
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (int id) {
            debugPrint('Native ad platform view created with id: $id');
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        height: widget.height,
        color: widget.backgroundColor,
        child: UiKitView(
          viewType: 'native_googleads/native',
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (int id) {
            debugPrint('Native ad platform view created with id: $id');
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
