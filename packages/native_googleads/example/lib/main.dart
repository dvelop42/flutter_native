import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_googleads/native_googleads.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Ads Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Native Google Ads'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            icon: Icons.ad_units,
            title: 'Banner',
            subtitle: 'Standard banner ads',
            onTap: () => _navigate(context, const BannerPage()),
          ),
          _buildCard(
            icon: Icons.view_carousel,
            title: 'Native',
            subtitle: 'Custom native ads',
            onTap: () => _navigate(context, const NativePage()),
          ),
          _buildCard(
            icon: Icons.photo_library,
            title: 'Gallery',
            subtitle: 'Full screen gallery with ads',
            onTap: () => _navigate(context, const GalleryPage()),
          ),
          _buildCard(
            icon: Icons.fullscreen,
            title: 'Interstitial',
            subtitle: 'Full screen ads',
            onTap: () => _navigate(context, const InterstitialPage()),
          ),
          _buildCard(
            icon: Icons.card_giftcard,
            title: 'Rewarded',
            subtitle: 'Earn rewards',
            onTap: () => _navigate(context, const RewardedPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

// Banner Ad Page
class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final _ads = NativeGoogleads.instance;
  String? _bannerId;
  BannerAdSize _size = BannerAdSize.banner;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);
  }

  Future<void> _loadBanner() async {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidBanner
        : AdTestIds.iosBanner;

    _bannerId = await _ads.loadBannerAd(adUnitId: adUnitId, size: _size);

    if (_bannerId != null) {
      await _ads.showBannerAd(_bannerId!);
      setState(() => _isLoaded = true);
    }
  }

  @override
  void dispose() {
    if (_bannerId != null) _ads.disposeBannerAd(_bannerId!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Ads')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButton<BannerAdSize>(
                  value: _size,
                  isExpanded: true,
                  items: BannerAdSize.values.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size.name),
                    );
                  }).toList(),
                  onChanged: (size) {
                    if (size != null) setState(() => _size = size);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadBanner,
                  child: Text(_isLoaded ? 'Reload' : 'Load Banner'),
                ),
              ],
            ),
          ),
          if (_isLoaded && _bannerId != null)
            BannerAdWidget(
              adUnitId: Platform.isAndroid
                  ? AdTestIds.androidBanner
                  : AdTestIds.iosBanner,
              preloadedBannerId: _bannerId,
              size: _size,
            ),
        ],
      ),
    );
  }
}

// Native Ad Page
class NativePage extends StatefulWidget {
  const NativePage({super.key});

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  final _ads = NativeGoogleads.instance;
  bool _showAd = false;
  bool _useCustomStyle = false;
  NativeAdMediaAspectRatio _aspectRatio = NativeAdMediaAspectRatio.landscape;
  double _height = 300;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);
  }

  @override
  Widget build(BuildContext context) {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidNativeAdvanced
        : AdTestIds.iosNativeAdvanced;

    return Scaffold(
      appBar: AppBar(title: const Text('Native Ads')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Custom Style'),
                    Switch(
                      value: _useCustomStyle,
                      onChanged: (v) => setState(() {
                        _useCustomStyle = v;
                        _showAd = false;
                      }),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('16:9'),
                      selected:
                          _aspectRatio == NativeAdMediaAspectRatio.landscape,
                      onSelected: (s) => setState(() {
                        _aspectRatio = NativeAdMediaAspectRatio.landscape;
                        _showAd = false;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('1:1'),
                      selected: _aspectRatio == NativeAdMediaAspectRatio.square,
                      onSelected: (s) => setState(() {
                        _aspectRatio = NativeAdMediaAspectRatio.square;
                        _showAd = false;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('9:16'),
                      selected:
                          _aspectRatio == NativeAdMediaAspectRatio.portrait,
                      onSelected: (s) => setState(() {
                        _aspectRatio = NativeAdMediaAspectRatio.portrait;
                        _showAd = false;
                      }),
                    ),
                  ],
                ),
                Slider(
                  value: _height,
                  min: 200,
                  max: 400,
                  divisions: 20,
                  label: '${_height.round()}',
                  onChanged: (v) => setState(() {
                    _height = v;
                    _showAd = false;
                  }),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _showAd = !_showAd),
                  child: Text(_showAd ? 'Hide' : 'Show Ad'),
                ),
              ],
            ),
          ),
          if (_showAd)
            SizedBox(
              height: _height,
              child: NativeAdWidget(
                adUnitId: adUnitId,
                height: _height,
                style: _useCustomStyle
                    ? NativeAdStyle(
                        mediaStyle: NativeAdMediaStyle(
                          aspectRatio: _getAspectRatioValue(),
                          cornerRadius: 8,
                        ),
                        headlineTextStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        cornerRadius: 12,
                        padding: const EdgeInsets.all(12),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  double _getAspectRatioValue() {
    switch (_aspectRatio) {
      case NativeAdMediaAspectRatio.landscape:
        return 16 / 9;
      case NativeAdMediaAspectRatio.portrait:
        return 9 / 16;
      case NativeAdMediaAspectRatio.square:
        return 1;
      default:
        return 16 / 9;
    }
  }
}

// Gallery with Full Screen Viewer
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final images = List.generate(20, (i) => 'Image ${i + 1}');

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FullScreenViewer(images: images, initialIndex: index),
                ),
              );
            },
            child: Container(
              color: Colors.grey.shade300,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Full Screen Image Viewer with Ads
class FullScreenViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late PageController _controller;
  late List<dynamic> _items;
  final Map<int, String> _preloadedAds = {};
  int _current = 0;
  final _ads = NativeGoogleads.instance;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _items = [];
    for (int i = 0; i < widget.images.length; i++) {
      _items.add(widget.images[i]);
      if ((i + 1) % 3 == 0 && i < widget.images.length - 1) {
        _items.add('ad');
      }
    }

    _current = widget.initialIndex + (widget.initialIndex ~/ 3);
    _controller = PageController(initialPage: _current);
    _initialize();
  }

  Future<void> _initialize() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);

    // Preload ads for nearby positions
    _preloadNearbyAds();
  }

  Future<void> _preloadNearbyAds() async {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidNativeAdvanced
        : AdTestIds.iosNativeAdvanced;

    // Preload ads within 2 positions of current
    for (int i = 0; i < _items.length; i++) {
      if (_items[i] == 'ad' && (i - _current).abs() <= 2) {
        if (!_preloadedAds.containsKey(i)) {
          final adId = await _ads.loadNativeAd(
            adUnitId: adUnitId,
            mediaAspectRatio: NativeAdMediaAspectRatio.landscape,
          );
          if (adId != null) {
            _preloadedAds[i] = adId;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Clean up preloaded ads
    for (final adId in _preloadedAds.values) {
      _ads.disposeNativeAd(adId);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidNativeAdvanced
        : AdTestIds.iosNativeAdvanced;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) {
              setState(() => _current = i);
              // Preload more ads as user navigates
              _preloadNearbyAds();
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              if (_items[index] == 'ad') {
                return NativeAdWidget(
                  key: ValueKey('fs_ad_$index'),
                  adUnitId: adUnitId,
                  height: MediaQuery.of(context).size.height,
                  isFullScreen: true,
                  preloadedNativeAdId: _preloadedAds[index],
                );
              }
              return Center(
                child: Container(
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Text(
                      _items[index],
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withAlpha(180), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      '${_current + 1} / ${_items.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Interstitial Ad Page
class InterstitialPage extends StatefulWidget {
  const InterstitialPage({super.key});

  @override
  State<InterstitialPage> createState() => _InterstitialPageState();
}

class _InterstitialPageState extends State<InterstitialPage> {
  final _ads = NativeGoogleads.instance;
  bool _ready = false;
  String _status = 'Init';
  int? _lastLoadTime;
  double? _avgLoadTime;
  int _impressions = 0;
  int _clicks = 0;
  bool _canShow = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Set frequency cap: max 3 impressions per hour
    await _ads.setInterstitialFrequencyCap(
      maxImpressions: 3,
      perHours: 1,
    );
    
    _ads.setAdCallbacks(
      onAdDismissed: (type) {
        if (type == 'interstitial') setState(() => _ready = false);
      },
      onAdLoadStarted: (type) {
        if (type == 'interstitial') {
          setState(() => _status = 'Loading started...');
        }
      },
      onAdImpression: (type) {
        if (type == 'interstitial') {
          setState(() => _impressions++);
        }
      },
      onAdClicked: (type) {
        if (type == 'interstitial') {
          setState(() => _clicks++);
        }
      },
    );

    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);
  }

  Future<void> _load() async {
    setState(() => _status = 'Loading...');
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;

    final success = await _ads.preloadInterstitialAd(
      adUnitId: adUnitId,
      config: InterstitialConfig.gaming(), // Use gaming optimized config
    );
    
    // Get load time metrics
    final loadTime = _ads.getLastLoadTime(adUnitId);
    final avgTime = _ads.getAverageLoadTime();
    
    setState(() {
      _ready = success;
      _status = success ? 'Ready' : 'Failed';
      _lastLoadTime = loadTime;
      _avgLoadTime = avgTime;
    });
  }

  Future<void> _show() async {
    if (!_ready) return;
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;
    
    // Check frequency cap
    _canShow = await _ads.canShowInterstitial(adUnitId);
    if (!_canShow) {
      setState(() => _status = 'Frequency cap reached!');
      return;
    }
    
    await _ads.showInterstitialAd(adUnitId: adUnitId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interstitial')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fullscreen, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Status: $_status', style: TextStyle(fontSize: 18)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Impressions', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('$_impressions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Clicks', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('$_clicks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_lastLoadTime != null)
                      Text('Last Load: ${_lastLoadTime}ms', style: TextStyle(fontSize: 12)),
                    if (_avgLoadTime != null)
                      Text('Avg Load: ${_avgLoadTime!.toStringAsFixed(1)}ms', style: TextStyle(fontSize: 12)),
                    if (!_canShow)
                      Chip(
                        label: Text('Frequency Cap Active', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _load, 
                  child: const Text('Preload'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _ready && _canShow ? _show : null,
                  child: const Text('Show'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Frequency Cap: Max 3 ads per hour',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Rewarded Ad Page
class RewardedPage extends StatefulWidget {
  const RewardedPage({super.key});

  @override
  State<RewardedPage> createState() => _RewardedPageState();
}

class _RewardedPageState extends State<RewardedPage> {
  final _ads = NativeGoogleads.instance;
  bool _ready = false;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _ads.setAdCallbacks(
      onAdDismissed: (type) {
        if (type == 'rewarded') setState(() => _ready = false);
      },
      onUserEarnedReward: (type, amount) {
        setState(() => _coins += amount);
      },
    );

    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);
  }

  Future<void> _load() async {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidRewarded
        : AdTestIds.iosRewarded;

    final success = await _ads.preloadRewardedAd(adUnitId: adUnitId);
    setState(() => _ready = success);
  }

  Future<void> _show() async {
    if (!_ready) return;
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidRewarded
        : AdTestIds.iosRewarded;
    await _ads.showRewardedAd(adUnitId: adUnitId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewarded')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Coins: $_coins', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _load, child: const Text('Load')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _ready ? _show : null,
                  child: const Text('Watch'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
