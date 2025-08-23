import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_googleads/native_googleads.dart';

/// Test page for demonstrating and testing the timeout mechanism
/// for pending ad results (iOS only feature)
class TimeoutTestPage extends StatefulWidget {
  const TimeoutTestPage({super.key});

  @override
  State<TimeoutTestPage> createState() => _TimeoutTestPageState();
}

class _TimeoutTestPageState extends State<TimeoutTestPage> {
  final NativeGoogleads _ads = NativeGoogleads.instance;
  double _currentTimeout = 30.0;
  String _status = 'Ready to test';
  Map<String, dynamic>? _diagnosticInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    final appId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544'
        : 'ca-app-pub-3940256099942544';

    await _ads.initialize(appId: appId);
  }

  Future<void> _setAdTimeout(double seconds) async {
    if (Platform.isIOS) {
      try {
        // This will call the native iOS method to set timeout
        await _ads.methodChannel.invokeMethod('setAdLoadTimeout', {
          'timeout': seconds,
        });
        setState(() {
          _currentTimeout = seconds;
          _status = 'Timeout set to ${seconds.toInt()} seconds';
        });
      } catch (e) {
        setState(() {
          _status = 'Failed to set timeout: $e';
        });
      }
    } else {
      setState(() {
        _status = 'Timeout mechanism is iOS only';
      });
    }
  }

  Future<void> _getDiagnosticInfo() async {
    if (Platform.isIOS) {
      try {
        final info = await _ads.methodChannel.invokeMethod('getDiagnosticInfo');
        setState(() {
          _diagnosticInfo = Map<String, dynamic>.from(info as Map);
          _status = 'Diagnostic info retrieved';
        });
      } catch (e) {
        setState(() {
          _status = 'Failed to get diagnostic info: $e';
        });
      }
    } else {
      setState(() {
        _status = 'Diagnostic info is iOS only';
      });
    }
  }

  Future<void> _triggerTimeoutTest() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading ad with invalid ID to trigger timeout...';
    });

    try {
      // Use an invalid ad unit ID to simulate a timeout scenario
      const invalidAdUnitId = 'invalid-test-ad-unit-id-for-timeout';

      // Try to load a banner with invalid ID - should timeout
      final result = await _ads.loadBannerAd(
        adUnitId: invalidAdUnitId,
        size: BannerAdSize.banner,
      );

      setState(() {
        _isLoading = false;
        if (result != null) {
          _status = 'Unexpected: Ad loaded with ID: $result';
        } else {
          _status = 'Ad failed to load (as expected)';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error during test: $e';
      });
    }

    // Get diagnostic info after test
    await Future.delayed(const Duration(seconds: 2));
    await _getDiagnosticInfo();
  }

  Future<void> _triggerMultipleAds() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading multiple ads to test cleanup...';
    });

    // Load multiple ads with invalid IDs to test cleanup
    final futures = <Future>[];
    for (int i = 0; i < 5; i++) {
      futures.add(
        _ads
            .loadBannerAd(adUnitId: 'invalid-ad-$i', size: BannerAdSize.banner)
            .catchError((_) => null),
      );
    }

    await Future.wait(futures);

    setState(() {
      _isLoading = false;
      _status = 'Multiple ad load test completed';
    });

    // Get diagnostic info after test
    await Future.delayed(const Duration(seconds: 2));
    await _getDiagnosticInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeout Mechanism Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Platform indicator
          Card(
            color: Platform.isIOS ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Platform.isIOS ? Icons.check_circle : Icons.info,
                    color: Platform.isIOS ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Platform.isIOS
                          ? 'iOS Platform - Timeout mechanism available'
                          : 'Android Platform - Timeout mechanism not implemented',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _isLoading ? Colors.blue : Colors.black87,
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timeout configuration
          if (Platform.isIOS) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timeout Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Current timeout: ${_currentTimeout.toInt()} seconds'),
                    const SizedBox(height: 8),
                    Slider(
                      value: _currentTimeout,
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${_currentTimeout.toInt()}s',
                      onChanged: (value) {
                        setState(() {
                          _currentTimeout = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _setAdTimeout(5),
                          child: const Text('5s'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setAdTimeout(15),
                          child: const Text('15s'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setAdTimeout(30),
                          child: const Text('30s'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setAdTimeout(60),
                          child: const Text('60s'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _setAdTimeout(_currentTimeout),
                      icon: const Icon(Icons.timer),
                      label: const Text('Apply Timeout'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _triggerTimeoutTest,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Trigger Timeout Test'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Loads an ad with invalid ID to trigger timeout',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _triggerMultipleAds,
                      icon: const Icon(Icons.layers),
                      label: const Text('Test Multiple Ads'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Loads 5 ads with invalid IDs to test cleanup',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getDiagnosticInfo,
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Get Diagnostic Info'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Diagnostic info display
            if (_diagnosticInfo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnostic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDiagnosticRow(
                        'Pending Results',
                        _diagnosticInfo!['pendingResultsCount']?.toString() ??
                            '0',
                      ),
                      _buildDiagnosticRow(
                        'Pending Timers',
                        _diagnosticInfo!['pendingTimersCount']?.toString() ??
                            '0',
                      ),
                      _buildDiagnosticRow(
                        'Banner Ads',
                        _diagnosticInfo!['bannerAdsCount']?.toString() ?? '0',
                      ),
                      _buildDiagnosticRow(
                        'Native Ads',
                        _diagnosticInfo!['nativeAdsCount']?.toString() ?? '0',
                      ),
                      _buildDiagnosticRow(
                        'Interstitial Ads',
                        _diagnosticInfo!['interstitialAdsCount']?.toString() ??
                            '0',
                      ),
                      _buildDiagnosticRow(
                        'Rewarded Ads',
                        _diagnosticInfo!['rewardedAdsCount']?.toString() ?? '0',
                      ),
                      _buildDiagnosticRow(
                        'Current Timeout',
                        '${_diagnosticInfo!['currentTimeout']?.toString() ?? '30'}s',
                      ),
                      if (_diagnosticInfo!['pendingResultIds'] != null &&
                          (_diagnosticInfo!['pendingResultIds'] as List)
                              .isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Pending IDs:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...(_diagnosticInfo!['pendingResultIds'] as List).map(
                          (id) => Text(
                            '• $id',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],

          // Instructions
          const SizedBox(height: 16),
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Test',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Set a short timeout (e.g., 5 seconds)'),
                  Text('2. Trigger the timeout test'),
                  Text('3. Wait for the timeout to occur'),
                  Text('4. Check diagnostic info to see cleanup'),
                  SizedBox(height: 8),
                  Text(
                    'Note: Check Xcode console for detailed logs on iOS',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
