import 'package:flutter/material.dart';
import '../native_googleads.dart';

/// A widget that displays a banner ad.
/// 
/// This widget creates a platform view to display native banner ads.
/// 
/// Example:
/// ```dart
/// BannerAdWidget(
///   adUnitId: 'ca-app-pub-xxxxx/xxxxx',
///   size: BannerAdSize.adaptive,
///   onAdLoaded: () => print('Banner loaded'),
///   onAdFailedToLoad: (error) => print('Banner failed: $error'),
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  /// The ad unit ID for the banner ad.
  final String adUnitId;
  
  /// The size of the banner ad.
  final BannerAdSize size;
  
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
  
  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.size = BannerAdSize.adaptive,
    this.requestConfig,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  String? _bannerId;
  bool _isLoaded = false;
  bool _isShowing = false;
  double _height = 50.0; // Default banner height

  @override
  void initState() {
    super.initState();
    debugPrint('BannerAdWidget: initState called for adUnitId: ${widget.adUnitId}');
    _setAdHeight();
    _loadAd();
  }

  void _setAdHeight() {
    // Set height based on ad size
    switch (widget.size) {
      case BannerAdSize.banner:
        _height = 50.0;
        break;
      case BannerAdSize.largeBanner:
        _height = 100.0;
        break;
      case BannerAdSize.mediumRectangle:
        _height = 250.0;
        break;
      case BannerAdSize.fullBanner:
        _height = 60.0;
        break;
      case BannerAdSize.leaderboard:
        _height = 90.0;
        break;
      case BannerAdSize.adaptive:
        _height = 60.0; // Will be adjusted by native code
        break;
    }
  }

  Future<void> _loadAd() async {
    debugPrint('BannerAdWidget: Starting to load ad');
    final bannerId = await _ads.loadBannerAd(
      adUnitId: widget.adUnitId,
      size: widget.size,
      requestConfig: widget.requestConfig,
    );
    
    if (bannerId != null && mounted) {
      debugPrint('BannerAdWidget: Ad loaded successfully with ID: $bannerId');
      setState(() {
        _bannerId = bannerId;
        _isLoaded = true;
      });
      widget.onAdLoaded?.call();
      // Automatically show the banner once loaded
      _showAd();
    } else {
      debugPrint('BannerAdWidget: Failed to load ad');
      widget.onAdFailedToLoad?.call('Failed to load banner ad');
    }
  }
  
  Future<void> _showAd() async {
    if (_bannerId != null && !_isShowing) {
      final success = await _ads.showBannerAd(_bannerId!);
      if (success && mounted) {
        setState(() {
          _isShowing = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_bannerId != null) {
      if (_isShowing) {
        _ads.hideBannerAd(_bannerId!);
      }
      _ads.disposeBannerAd(_bannerId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerId == null) {
      return SizedBox(
        height: _height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Banner ads are shown natively as overlays
    // This widget just reserves space for them
    return Container(
      height: _height,
      color: Colors.transparent,
      child: Center(
        child: Text(
          _isShowing ? 'Banner Ad Space' : 'Loading Banner Ad...',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}