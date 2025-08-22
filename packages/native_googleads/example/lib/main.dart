import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_googleads/native_googleads.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Google Ads Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Shared small UI helpers (kept in this file for the example)
class StatusChip extends StatelessWidget {
  final bool ready;
  const StatusChip({super.key, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ready ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ready ? 'Ready' : 'Not Ready',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

// (MiniActionButtons removed; not needed after multi-preload example removal)


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Native Google Ads Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('Banner Ads'),
              subtitle: const Text('Display banner ads in your app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BannerAdPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Preloaded Fullscreen Ads'),
              subtitle: const Text('Preload interstitial & rewarded, then show'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreloadedFullscreenAdsPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.downloading),
              title: const Text('Preloaded Banner'),
              subtitle: const Text('Load first, then render via widget'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreloadedBannerPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.view_carousel),
              title: const Text('Native Ads'),
              subtitle: const Text('Display native ads that match your app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NativeAdPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.downloading),
              title: const Text('Preloaded Native'),
              subtitle: const Text('Load first, then render via widget'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreloadedNativePage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fullscreen),
              title: const Text('Interstitial Ads'),
              subtitle: const Text('Full-screen ads at natural transitions'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InterstitialAdPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Rewarded Ads'),
              subtitle: const Text('Reward users for watching video ads'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RewardedAdPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Banner Ad Page
class BannerAdPage extends StatefulWidget {
  const BannerAdPage({super.key});

  @override
  State<BannerAdPage> createState() => _BannerAdPageState();
}

class _BannerAdPageState extends State<BannerAdPage> {
  BannerAdSize _selectedSize = BannerAdSize.adaptive;
  bool _showAd = false;
  bool _bannerVisible = true; // hide slot on failure

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;

    await NativeGoogleads.instance.initialize(appId: appId);
  }

  @override
  Widget build(BuildContext context) {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidBanner
        : AdTestIds.iosBanner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Banner Size:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (final size in BannerAdSize.values)
                      ChoiceChip(
                        label: Text(_getSizeName(size)),
                        selected: _selectedSize == size,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSize = size;
                              _showAd = false;
                            });
                          }
                        },
                      ),
                  ],
                ),
                if (_selectedSize == BannerAdSize.leaderboard &&
                    MediaQuery.of(context).size.width < 728)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Leaderboard is too wide for this screen. Will use adaptive size instead.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showAd = !_showAd;
                      });
                    },
                    child: Text(_showAd ? 'Hide Banner' : 'Show Banner'),
                  ),
                ),
              ],
            ),
          ),
          if (_showAd)
            Column(
              children: [
                Container(
                  color: Colors.amber[50],
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Banner loads successfully but displays as placeholder',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_bannerVisible)
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8.0),
                    child: BannerAdWidget(
                      key: ValueKey(_selectedSize),
                      adUnitId: adUnitId,
                      size: _selectedSize,
                      onAdLoaded: () {
                        setState(() => _bannerVisible = true);
                        debugPrint('Banner ad loaded');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Banner ad loaded successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      onAdFailedToLoad: (error) {
                        debugPrint('Banner ad failed to load: $error');
                        setState(() => _bannerVisible = false); // gracefully hide slot
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Banner unavailable, slot hidden'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          const Spacer(),
        ],
      ),
    );
  }

  String _getSizeName(BannerAdSize size) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (size) {
      case BannerAdSize.banner:
        return 'Banner (320x50)';
      case BannerAdSize.largeBanner:
        return 'Large (320x100)';
      case BannerAdSize.mediumRectangle:
        return 'Medium (300x250)';
      case BannerAdSize.fullBanner:
        return screenWidth < 468 ? 'Full (468x60) ⚠️' : 'Full (468x60)';
      case BannerAdSize.leaderboard:
        return screenWidth < 728
            ? 'Leaderboard (728x90) ⚠️'
            : 'Leaderboard (728x90)';
      case BannerAdSize.adaptive:
        return 'Adaptive';
    }
  }
}

// Preloaded Banner Page
class PreloadedBannerPage extends StatefulWidget {
  const PreloadedBannerPage({super.key});

  @override
  State<PreloadedBannerPage> createState() => _PreloadedBannerPageState();
}

class _PreloadedBannerPageState extends State<PreloadedBannerPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  String? _bannerId;
  BannerAdSize _size = BannerAdSize.adaptive;
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    await _ads.initialize(appId: Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId);
  }

  Future<void> _preload() async {
    setState(() => _status = 'Loading...');
    final id = await _ads.loadBannerAd(
      adUnitId: Platform.isAndroid ? AdTestIds.androidBanner : AdTestIds.iosBanner,
      size: _size,
    );
    setState(() {
      _bannerId = id;
      _status = id != null ? 'Ready' : 'Failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preloaded Banner'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('Size:'),
              const SizedBox(width: 8),
              DropdownButton<BannerAdSize>(
                value: _size,
                onChanged: (v) => setState(() => _size = v ?? _size),
                items: [
                  for (final s in BannerAdSize.values)
                    DropdownMenuItem(value: s, child: Text(s.name)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(onPressed: _preload, icon: const Icon(Icons.download), label: const Text('Preload')),
            ],
          ),
          const SizedBox(height: 12),
          Text('Status: $_status'),
          const SizedBox(height: 12),
          if (_bannerId != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: BannerAdWidget(
                adUnitId: Platform.isAndroid ? AdTestIds.androidBanner : AdTestIds.iosBanner,
                size: _size,
                preloadedBannerId: _bannerId,
                onAdFailedToLoad: (_) {
                  if (!mounted) return;
                  setState(() => _status = 'Failed to render');
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Native Ad Page
class NativeAdPage extends StatefulWidget {
  const NativeAdPage({super.key});

  @override
  State<NativeAdPage> createState() => _NativeAdPageState();
}

class _NativeAdPageState extends State<NativeAdPage> {
  bool _showNativeSlot = true; // hide slot on failure
  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;

    await NativeGoogleads.instance.initialize(appId: appId);
  }

  @override
  Widget build(BuildContext context) {
    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidNativeAdvanced
        : AdTestIds.iosNativeAdvanced;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          itemCount: 12,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 5 && _showNativeSlot) {
              return Card(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 300,
                    minHeight: 300,
                    maxHeight: 350,
                    maxWidth: 450,
                  ),
                  child: NativeAdWidget(
                    key: const ValueKey('native_ad'),
                    adUnitId: adUnitId,
                    backgroundColor: Colors.white,
                    onAdLoaded: () {
                      if (!mounted) return;
                      setState(() => _showNativeSlot = true);
                      debugPrint('Native ad loaded');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Native ad loaded successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onAdFailedToLoad: (error) {
                      debugPrint('Native ad failed to load: $error');
                      if (!mounted) return;
                      setState(() => _showNativeSlot = false); // gracefully skip the slot
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Native ad unavailable, skipping slot'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            // Normal Contents
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contents Item ${index + 1}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is where the content for item ${index + 1} will be displayed.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Preloaded Native Page
class PreloadedNativePage extends StatefulWidget {
  const PreloadedNativePage({super.key});

  @override
  State<PreloadedNativePage> createState() => _PreloadedNativePageState();
}

class _PreloadedNativePageState extends State<PreloadedNativePage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  String? _nativeId;
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    await _ads.initialize(appId: Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId);
  }

  Future<void> _preload() async {
    setState(() => _status = 'Loading...');
    final id = await _ads.loadNativeAd(
      adUnitId: Platform.isAndroid ? AdTestIds.androidNativeAdvanced : AdTestIds.iosNativeAdvanced,
    );
    setState(() {
      _nativeId = id;
      _status = id != null ? 'Ready' : 'Failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preloaded Native'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ElevatedButton.icon(onPressed: _preload, icon: const Icon(Icons.download), label: const Text('Preload')),
              const SizedBox(width: 12),
              Text('Status: $_status'),
            ],
          ),
          const SizedBox(height: 12),
          if (_nativeId != null)
            Card(
              elevation: 4,
              child: SizedBox(
                height: 300,
                child: NativeAdWidget(
                  adUnitId: Platform.isAndroid ? AdTestIds.androidNativeAdvanced : AdTestIds.iosNativeAdvanced,
                  preloadedNativeAdId: _nativeId,
                  backgroundColor: Colors.white,
                  onAdFailedToLoad: (_) {
                    if (!mounted) return;
                    setState(() => _status = 'Failed to render');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Interstitial Ad Page
class InterstitialAdPage extends StatefulWidget {
  const InterstitialAdPage({super.key});

  @override
  State<InterstitialAdPage> createState() => _InterstitialAdPageState();
}

class _InterstitialAdPageState extends State<InterstitialAdPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  bool _isAdReady = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    setState(() {
      _status = 'Initializing...';
    });

    _ads.setAdCallbacks(
      onAdDismissed: (adType) {
        if (adType == 'interstitial') {
          setState(() {
            _isAdReady = false;
            _status = 'Ad dismissed';
          });
          // Auto-preload runs natively; refresh readiness shortly after
          Future<void>(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            if (_interstitialAdUnitId != null) {
              final ready = await _ads.isInterstitialReady(
                _interstitialAdUnitId!,
              );
              if (!mounted) return;
              setState(() {
                _isAdReady = ready;
                if (ready) _status = 'Ready';
              });
            }
          });
        }
      },
      onAdShowed: (adType) {
        if (adType == 'interstitial') {
          setState(() {
            _status = 'Ad showing';
          });
        }
      },
      onAdFailedToShow: (adType, error) {
        if (adType == 'interstitial') {
          setState(() {
            _status = 'Failed to show: $error';
          });
          _showSnackBar('Failed to show ad: $error');
          // Try to reflect auto-preload status
          Future<void>(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            if (_interstitialAdUnitId != null) {
              final ready = await _ads.isInterstitialReady(
                _interstitialAdUnitId!,
              );
              if (!mounted) return;
              setState(() {
                _isAdReady = ready;
                if (ready) _status = 'Ready';
              });
            }
          });
        }
      },
    );

    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;

    final result = await _ads.initialize(appId: appId);

    if (result != null && result['isReady'] == true) {
      setState(() {
        _status = 'Initialized';
      });
    } else {
      setState(() {
        _status = 'Initialization failed';
      });
    }
  }

  String? _interstitialAdUnitId;

  Future<void> _preloadInterstitialAd() async {
    setState(() {
      _status = 'Loading ad...';
    });

    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;

    _interstitialAdUnitId = adUnitId;
    final success = await _ads.preloadInterstitialAd(adUnitId: adUnitId);

    setState(() {
      _isAdReady = success;
      _status = success ? 'Ad loaded' : 'Failed to load ad';
    });

    if (!success) {
      _showSnackBar('Failed to load interstitial ad');
    }
  }

  Future<void> _showInterstitialAd() async {
    if (!_isAdReady) {
      _showSnackBar('Interstitial ad is not ready');
      return;
    }

    final success = await _ads.showInterstitialAd(
      adUnitId: _interstitialAdUnitId!,
    );
    if (!success) {
      _showSnackBar('Failed to show interstitial ad');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fullscreen,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Interstitial Ad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $_status',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isAdReady ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isAdReady ? 'Ready' : 'Not Ready',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _preloadInterstitialAd,
                            icon: const Icon(Icons.download),
                            label: const Text('Preload'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isAdReady ? _showInterstitialAd : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Show Ad'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rewarded Ad Page
class RewardedAdPage extends StatefulWidget {
  const RewardedAdPage({super.key});

  @override
  State<RewardedAdPage> createState() => _RewardedAdPageState();
}

// Preloaded Fullscreen Ads Page (Interstitial + Rewarded)
class PreloadedFullscreenAdsPage extends StatefulWidget {
  const PreloadedFullscreenAdsPage({super.key});

  @override
  State<PreloadedFullscreenAdsPage> createState() => _PreloadedFullscreenAdsPageState();
}

class _PreloadedFullscreenAdsPageState extends State<PreloadedFullscreenAdsPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;

  String? _interstitialId;
  String? _rewardedId;

  bool _interstitialReady = false;
  bool _rewardedReady = false;
  String _interstitialStatus = 'Idle';
  String _rewardedStatus = 'Idle';
  int _rewardedEarned = 0;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    _ads.setAdCallbacks(
      onAdDismissed: (type) async {
        if (!mounted) return;
        if (type == 'interstitial') {
          setState(() {
            _interstitialReady = false;
            _interstitialStatus = 'Dismissed';
          });
          await Future.delayed(const Duration(milliseconds: 200));
          if (_interstitialId != null) {
            final ready = await _ads.isInterstitialReady(_interstitialId!);
            if (!mounted) return;
            setState(() {
              _interstitialReady = ready;
              if (ready) _interstitialStatus = 'Ready';
            });
          }
        } else if (type == 'rewarded') {
          setState(() {
            _rewardedReady = false;
            _rewardedStatus = 'Dismissed';
          });
          await Future.delayed(const Duration(milliseconds: 200));
          if (_rewardedId != null) {
            final ready = await _ads.isRewardedReady(_rewardedId!);
            if (!mounted) return;
            setState(() {
              _rewardedReady = ready;
              if (ready) _rewardedStatus = 'Ready';
            });
          }
        }
      },
      onAdShowed: (type) {
        if (!mounted) return;
        if (type == 'interstitial') {
          setState(() => _interstitialStatus = 'Showing');
        } else if (type == 'rewarded') {
          setState(() => _rewardedStatus = 'Showing');
        }
      },
      onAdFailedToShow: (type, error) async {
        if (!mounted) return;
        if (type == 'interstitial') {
          setState(() => _interstitialStatus = 'Failed: $error');
          await Future.delayed(const Duration(milliseconds: 200));
          if (_interstitialId != null) {
            final ready = await _ads.isInterstitialReady(_interstitialId!);
            if (!mounted) return;
            setState(() {
              _interstitialReady = ready;
              if (ready) _interstitialStatus = 'Ready';
            });
          }
        } else if (type == 'rewarded') {
          setState(() => _rewardedStatus = 'Failed: $error');
          await Future.delayed(const Duration(milliseconds: 200));
          if (_rewardedId != null) {
            final ready = await _ads.isRewardedReady(_rewardedId!);
            if (!mounted) return;
            setState(() {
              _rewardedReady = ready;
              if (ready) _rewardedStatus = 'Ready';
            });
          }
        }
      },
      onUserEarnedReward: (type, amount) {
        if (!mounted) return;
        setState(() {
          _rewardedEarned += amount;
        });
      },
    );

    // Initialize with test App ID and preload both
    await _ads.initialize(appId: Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId);

    _interstitialId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;
    _rewardedId = Platform.isAndroid
        ? AdTestIds.androidRewarded
        : AdTestIds.iosRewarded;

    await _preloadInterstitial();
    await _preloadRewarded();
  }

  Future<void> _preloadInterstitial() async {
    if (_interstitialId == null) return;
    setState(() => _interstitialStatus = 'Loading...');
    final ok = await _ads.preloadInterstitialAd(adUnitId: _interstitialId!);
    if (!mounted) return;
    setState(() {
      _interstitialReady = ok;
      _interstitialStatus = ok ? 'Ready' : 'Failed to load';
    });
  }

  Future<void> _showInterstitial() async {
    if (!_interstitialReady || _interstitialId == null) return;
    final ok = await _ads.showInterstitialAd(adUnitId: _interstitialId!);
    if (!ok && mounted) {
      setState(() => _interstitialStatus = 'Failed to show');
    }
  }

  Future<void> _checkInterstitialReady() async {
    if (_interstitialId == null) return;
    final ready = await _ads.isInterstitialReady(_interstitialId!);
    if (!mounted) return;
    setState(() {
      _interstitialReady = ready;
      if (ready) _interstitialStatus = 'Ready';
    });
  }

  Future<void> _preloadRewarded() async {
    if (_rewardedId == null) return;
    setState(() => _rewardedStatus = 'Loading...');
    final ok = await _ads.preloadRewardedAd(adUnitId: _rewardedId!);
    if (!mounted) return;
    setState(() {
      _rewardedReady = ok;
      _rewardedStatus = ok ? 'Ready' : 'Failed to load';
    });
  }

  Future<void> _showRewarded() async {
    if (!_rewardedReady || _rewardedId == null) return;
    final ok = await _ads.showRewardedAd(adUnitId: _rewardedId!);
    if (!ok && mounted) {
      setState(() => _rewardedStatus = 'Failed to show');
    }
  }

  Future<void> _checkRewardedReady() async {
    if (_rewardedId == null) return;
    final ready = await _ads.isRewardedReady(_rewardedId!);
    if (!mounted) return;
    setState(() {
      _rewardedReady = ready;
      if (ready) _rewardedStatus = 'Ready';
    });
  }

  List<Widget> _actionButtons({
    required VoidCallback onPreload,
    required VoidCallback onRefresh,
    required VoidCallback onShow,
    required bool canShow,
  }) {
    return [
      ElevatedButton.icon(
        onPressed: onPreload,
        icon: const Icon(Icons.download),
        label: const Text('Preload'),
      ),
      ElevatedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Ready'),
      ),
      ElevatedButton.icon(
        onPressed: canShow ? onShow : null,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Show'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preloaded Fullscreen Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fullscreen, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Interstitial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      StatusChip(ready: _interstitialReady),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Status: $_interstitialStatus'),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: _actionButtons(
                      onPreload: _preloadInterstitial,
                      onRefresh: _checkInterstitialReady,
                      onShow: _showInterstitial,
                      canShow: _interstitialReady,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Rewarded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      StatusChip(ready: _rewardedReady),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Status: $_rewardedStatus'),
                  const SizedBox(height: 4),
                  Text('Rewards earned: $_rewardedEarned'),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: _actionButtons(
                      onPreload: _preloadRewarded,
                      onRefresh: _checkRewardedReady,
                      onShow: _showRewarded,
                      canShow: _rewardedReady,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _RewardedAdPageState extends State<RewardedAdPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  bool _isAdReady = false;
  String _status = 'Not initialized';
  int _rewardAmount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    setState(() {
      _status = 'Initializing...';
    });

    _ads.setAdCallbacks(
      onAdDismissed: (adType) {
        if (adType == 'rewarded') {
          setState(() {
            _isAdReady = false;
            _status = 'Ad dismissed';
          });
          // Auto-preload runs natively; refresh readiness shortly after
          Future<void>(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            if (_rewardedAdUnitId != null) {
              final ready = await _ads.isRewardedReady(_rewardedAdUnitId!);
              if (!mounted) return;
              setState(() {
                _isAdReady = ready;
                if (ready) _status = 'Ready';
              });
            }
          });
        }
      },
      onAdShowed: (adType) {
        if (adType == 'rewarded') {
          setState(() {
            _status = 'Ad showing';
          });
        }
      },
      onAdFailedToShow: (adType, error) {
        if (adType == 'rewarded') {
          setState(() {
            _status = 'Failed to show: $error';
          });
          _showSnackBar('Failed to show ad: $error');
          // Try to reflect auto-preload status
          Future<void>(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            if (_rewardedAdUnitId != null) {
              final ready = await _ads.isRewardedReady(_rewardedAdUnitId!);
              if (!mounted) return;
              setState(() {
                _isAdReady = ready;
                if (ready) _status = 'Ready';
              });
            }
          });
        }
      },
      onUserEarnedReward: (type, amount) {
        setState(() {
          _rewardAmount += amount;
          _status = 'Reward earned!';
        });
        _showSnackBar('You earned $amount $type!');
      },
    );

    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;

    final result = await _ads.initialize(appId: appId);

    if (result != null && result['isReady'] == true) {
      setState(() {
        _status = 'Initialized';
      });
    } else {
      setState(() {
        _status = 'Initialization failed';
      });
    }
  }

  String? _rewardedAdUnitId;

  Future<void> _preloadRewardedAd() async {
    setState(() {
      _status = 'Loading ad...';
    });

    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidRewarded
        : AdTestIds.iosRewarded;

    _rewardedAdUnitId = adUnitId;
    final success = await _ads.preloadRewardedAd(adUnitId: adUnitId);

    setState(() {
      _isAdReady = success;
      _status = success ? 'Ad loaded' : 'Failed to load ad';
    });

    if (!success) {
      _showSnackBar('Failed to load rewarded ad');
    }
  }

  Future<void> _showRewardedAd() async {
    if (!_isAdReady) {
      _showSnackBar('Rewarded ad is not ready');
      return;
    }

    final success = await _ads.showRewardedAd(adUnitId: _rewardedAdUnitId!);
    if (!success) {
      _showSnackBar('Failed to show rewarded ad');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Rewarded Ad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Rewards: $_rewardAmount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $_status',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isAdReady ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isAdReady ? 'Ready' : 'Not Ready',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _preloadRewardedAd,
                            icon: const Icon(Icons.download),
                            label: const Text('Preload'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isAdReady ? _showRewardedAd : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Watch Ad'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
