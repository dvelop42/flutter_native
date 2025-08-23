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
          // Simplified: removed preloaded and timeout demo entries
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
                const Text('Size', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (final size in [
                      BannerAdSize.adaptive,
                      BannerAdSize.banner,
                      BannerAdSize.mediumRectangle,
                    ])
                      ChoiceChip(
                        label: Text(_sizeLabel(size)),
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
          if (_showAd && _bannerVisible)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: BannerAdWidget(
                key: ValueKey(_selectedSize),
                adUnitId: adUnitId,
                size: _selectedSize,
                onAdLoaded: () => setState(() => _bannerVisible = true),
                onAdFailedToLoad: (_) => setState(() => _bannerVisible = false),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _sizeLabel(BannerAdSize size) {
    switch (size) {
      case BannerAdSize.banner:
        return 'Banner';
      case BannerAdSize.largeBanner:
        return 'Large';
      case BannerAdSize.mediumRectangle:
        return 'Medium';
      case BannerAdSize.fullBanner:
        return 'Full';
      case BannerAdSize.leaderboard:
        return 'Leader';
      case BannerAdSize.adaptive:
        return 'Adaptive';
    }
  }
}

// (Removed: Preloaded Banner Page)

// Native Ad Page
class NativeAdPage extends StatefulWidget {
  const NativeAdPage({super.key});

  @override
  State<NativeAdPage> createState() => _NativeAdPageState();
}

class _NativeAdPageState extends State<NativeAdPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  bool _showNativeSlot = true; // hide slot on failure
  double _adHeight = 300.0; // Default height
  bool _showAd = false;
  bool _usePreload = false;
  String? _preloadedNativeId;
  String _preloadStatus = 'Idle';

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
      body: Column(
        children: [
          // Height Control Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Height', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Height: '),
                    Expanded(
                      child: Slider(
                        value: _adHeight,
                        min: 100,
                        max: 500,
                        divisions: 40,
                        label: '${_adHeight.round()} dp',
                        onChanged: (value) {
                          setState(() {
                            _adHeight = value;
                            // Reset ad to apply new height
                            if (_showAd) {
                              _showAd = false;
                            }
                          });
                        },
                      ),
                    ),
                    Text('${_adHeight.round()} dp'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final h in [150.0, 250.0, 350.0, 450.0])
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _adHeight = h;
                          _showAd = false;
                        }),
                        child: Text(h.toInt().toString()),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: _usePreload,
                      onChanged: (v) => setState(() {
                        _usePreload = v;
                        _preloadedNativeId = null;
                        _preloadStatus = 'Idle';
                        _showAd = false;
                      }),
                    ),
                    const Text('Use preloaded native ad'),
                    const Spacer(),
                    if (_usePreload)
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _preloadStatus = 'Loading...');
                          final id = await _ads.loadNativeAd(
                            adUnitId: adUnitId,
                          );
                          if (!mounted) return;
                          setState(() {
                            _preloadedNativeId = id;
                            _preloadStatus =
                                id != null ? 'Ready' : 'Failed';
                          });
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Preload'),
                      ),
                  ],
                ),
                if (_usePreload)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Preload status: $_preloadStatus',
                        style: const TextStyle(fontSize: 12)),
                  ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAd = !_showAd;
                        _showNativeSlot = true;
                      });
                    },
                    icon: Icon(
                      _showAd ? Icons.visibility_off : Icons.visibility,
                    ),
                    label: Text(_showAd ? 'Hide Native Ad' : 'Show Native Ad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showAd ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Native Ad Display Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == 2 && _showNativeSlot && _showAd) {
                    return SizedBox(
                      height: _adHeight,
                      child: NativeAdWidget(
                        key: ValueKey('native_ad_$_adHeight'),
                        adUnitId: adUnitId,
                        preloadedNativeAdId:
                            _usePreload ? _preloadedNativeId : null,
                        height: _adHeight,
                        backgroundColor: Colors.white,
                        onAdLoaded: () {
                          if (!mounted) return;
                          setState(() => _showNativeSlot = true);
                        },
                        onAdFailedToLoad: (_) {
                          if (!mounted) return;
                          setState(() => _showNativeSlot = false);
                        },
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
                            'Item ${index + 1}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Content ${index + 1}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// (Removed: Preloaded Native Page)

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
                      Text('Status: $_status'),
                      const SizedBox(height: 8),
                      Text(_isAdReady ? 'Ready' : 'Not ready'),
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
                      const Text('Rewarded Ad',
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Rewards: $_rewardAmount'),
                      const SizedBox(height: 8),
                      Text('Status: $_status'),
                      const SizedBox(height: 8),
                      Text(_isAdReady ? 'Ready' : 'Not ready'),
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
