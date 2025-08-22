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
                if (_selectedSize == BannerAdSize.leaderboard && MediaQuery.of(context).size.width < 728)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Leaderboard is too wide for this screen. Will use adaptive size instead.',
                            style: TextStyle(fontSize: 12, color: Colors.orange[900]),
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
                      Icon(Icons.info_outline, color: Colors.amber[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Banner loads successfully but displays as placeholder',
                          style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(8.0),
                  child: BannerAdWidget(
                    key: ValueKey(_selectedSize),
                    adUnitId: adUnitId,
                    size: _selectedSize,
                    onAdLoaded: () {
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed: $error'),
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
        return screenWidth < 728 ? 'Leaderboard (728x90) ⚠️' : 'Leaderboard (728x90)';
      case BannerAdSize.adaptive:
        return 'Adaptive';
    }
  }
}

// Native Ad Page
class NativeAdPage extends StatefulWidget {
  const NativeAdPage({super.key});

  @override
  State<NativeAdPage> createState() => _NativeAdPageState();
}

class _NativeAdPageState extends State<NativeAdPage> {
  bool _isAdLoaded = false;

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
          itemCount: 12, // 총 아이템 수
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            // 인덱스 5에 광고 표시
            if (index == 5) {
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
                      debugPrint('Native ad loaded');
                      setState(() {
                        _isAdLoaded = true;
                      });
                    },
                    onAdFailedToLoad: (error) {
                      debugPrint('Native ad failed to load: $error');
                      setState(() {
                        _isAdLoaded = false;
                      });
                    },
                  ),
                ),
              );
            }
            
            // 일반 콘텐츠 표시
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '콘텐츠 아이템 ${index + 1}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '여기에 콘텐츠 내용이 표시됩니다. 이 부분은 실제 앱 콘텐츠로 대체될 수 있습니다.',
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

  Future<void> _loadInterstitialAd() async {
    setState(() {
      _status = 'Loading ad...';
    });

    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidInterstitial
        : AdTestIds.iosInterstitial;

    final success = await _ads.loadInterstitialAd(adUnitId: adUnitId);
    
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

    final success = await _ads.showInterstitialAd();
    if (!success) {
      _showSnackBar('Failed to show interstitial ad');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $_status',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            onPressed: _loadInterstitialAd,
                            icon: const Icon(Icons.download),
                            label: const Text('Load Ad'),
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

  Future<void> _loadRewardedAd() async {
    setState(() {
      _status = 'Loading ad...';
    });

    final adUnitId = Platform.isAndroid
        ? AdTestIds.androidRewarded
        : AdTestIds.iosRewarded;

    final success = await _ads.loadRewardedAd(adUnitId: adUnitId);
    
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

    final success = await _ads.showRewardedAd();
    if (!success) {
      _showSnackBar('Failed to show rewarded ad');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Rewards: $_rewardAmount',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $_status',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            onPressed: _loadRewardedAd,
                            icon: const Icon(Icons.download),
                            label: const Text('Load Ad'),
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