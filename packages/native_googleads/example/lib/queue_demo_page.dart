import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_googleads/native_googleads.dart';

/// Demo page for advanced interstitial queue management features.
class QueueDemoPage extends StatefulWidget {
  const QueueDemoPage({super.key});

  @override
  State<QueueDemoPage> createState() => _QueueDemoPageState();
}

class _QueueDemoPageState extends State<QueueDemoPage> {
  final _ads = NativeGoogleads.instance;
  Map<String, int> _queueStatus = {};
  bool _isLoading = false;
  final List<String> _logs = [];
  
  // Multiple ad units for different placements
  late final Map<String, String> _adUnits;
  late final Map<String, QueueConfig> _queueConfigs;
  
  @override
  void initState() {
    super.initState();
    
    // Setup ad units
    _adUnits = {
      'home': Platform.isAndroid
          ? AdTestIds.androidInterstitial
          : AdTestIds.iosInterstitial,
      'game': Platform.isAndroid
          ? AdTestIds.androidInterstitial
          : AdTestIds.iosInterstitial,
      'results': Platform.isAndroid
          ? AdTestIds.androidInterstitial
          : AdTestIds.iosInterstitial,
    };
    
    // Setup queue configurations
    _queueConfigs = {
      'home': QueueConfig.highPriority(),
      'game': const QueueConfig(
        maxSize: 4,
        minSize: 2,
        autoRefill: true,
        ttl: Duration(minutes: 45),
        priority: 5,
      ),
      'results': QueueConfig.lowPriority(),
    };
    
    _initialize();
  }
  
  Future<void> _initialize() async {
    final appId = Platform.isAndroid
        ? AdTestIds.androidAppId
        : AdTestIds.iosAppId;
    await _ads.initialize(appId: appId);
    
    // Initialize queues
    for (final entry in _adUnits.entries) {
      _ads.initializeInterstitialQueue(
        entry.value,
        config: _queueConfigs[entry.key],
      );
      _log('Initialized queue for ${entry.key}');
    }
    
    _updateQueueStatus();
  }
  
  void _log(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toIso8601String().split('T')[1].split('.')[0]}: $message');
      if (_logs.length > 20) {
        _logs.removeLast();
      }
    });
  }
  
  void _updateQueueStatus() {
    setState(() {
      _queueStatus = _ads.getInterstitialQueueStatus();
    });
  }
  
  Future<void> _preloadMultiple() async {
    setState(() => _isLoading = true);
    _log('Preloading multiple ads...');
    
    final results = await _ads.preloadMultipleInterstitials(
      _adUnits.values.toList(),
      configs: {
        _adUnits['home']!: InterstitialConfig.content(),
        _adUnits['game']!: InterstitialConfig.gaming(),
      },
      queueConfigs: _queueConfigs.map((k, v) => MapEntry(_adUnits[k]!, v)),
    );
    
    for (final entry in results.entries) {
      final placement = _adUnits.entries.firstWhere((e) => e.value == entry.key).key;
      _log('${placement}: ${entry.value ? "✓ Loaded" : "✗ Failed"}');
    }
    
    setState(() => _isLoading = false);
    _updateQueueStatus();
  }
  
  Future<void> _preloadWithRetry(String placement) async {
    setState(() => _isLoading = true);
    _log('Preloading $placement with retry...');
    
    final success = await _ads.preloadInterstitialWithRetry(
      adUnitId: _adUnits[placement]!,
      config: placement == 'game' 
          ? InterstitialConfig.gaming() 
          : InterstitialConfig.content(),
      maxRetries: 3,
    );
    
    _log('$placement: ${success ? "✓ Success" : "✗ All retries failed"}');
    
    setState(() => _isLoading = false);
    _updateQueueStatus();
  }
  
  Future<void> _showAd(String placement) async {
    final adUnitId = _adUnits[placement]!;
    
    // Record navigation for predictive preloading
    _ads.recordNavigation(placement);
    _log('Navigated to $placement');
    
    // Check if we can show (frequency cap)
    final canShow = await _ads.canShowInterstitial(adUnitId);
    if (!canShow) {
      _log('❌ Frequency cap reached for $placement');
      return;
    }
    
    // Show the ad
    final shown = await _ads.showInterstitialAd(
      adUnitId: adUnitId,
      useQueue: true,
    );
    
    if (shown) {
      _log('✓ Showed ad for $placement');
    } else {
      _log('✗ No ad available for $placement');
    }
    
    _updateQueueStatus();
    
    // Check predictions
    final predictions = _ads.getPredictedPlacements();
    if (predictions.isNotEmpty) {
      _log('Predictions: ${predictions.join(", ")}');
    }
  }
  
  void _clearCache(String? placement) {
    if (placement != null) {
      _ads.clearInterstitialCache(_adUnits[placement]);
      _log('Cleared cache for $placement');
    } else {
      _ads.clearInterstitialCache(null);
      _log('Cleared all caches');
    }
    _updateQueueStatus();
  }
  
  Widget _buildQueueCard(String placement) {
    final adUnitId = _adUnits[placement]!;
    final queueSize = _queueStatus[adUnitId] ?? 0;
    final config = _queueConfigs[placement]!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  placement.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    'Priority: ${config.priority}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: config.priority > 5
                      ? Colors.orange
                      : config.priority > 0
                          ? Colors.blue
                          : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: config.maxSize > 0 ? queueSize / config.maxSize : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                queueSize >= config.minSize ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Queue: $queueSize/${config.maxSize}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Min: ${config.minSize}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (config.autoRefill)
                  const Chip(
                    label: Text('Auto', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green,
                  ),
                const SizedBox(width: 4),
                Chip(
                  label: Text(
                    'TTL: ${config.ttl.inMinutes}m',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _preloadWithRetry(placement),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Load'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: queueSize > 0 ? () => _showAd(placement) : null,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Show'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _clearCache(placement),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear cache',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management Demo'),
        actions: [
          IconButton(
            onPressed: _updateQueueStatus,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _preloadMultiple,
                        icon: const Icon(Icons.download),
                        label: const Text('Preload All'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _clearCache(null),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const LinearProgressIndicator(),
              ],
            ),
          ),
          
          // Queue status cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Ad Queues',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._adUnits.keys.map(_buildQueueCard),
                
                const SizedBox(height: 20),
                const Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Logs
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _logs[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: _logs[index].contains('✓')
                              ? Colors.green[700]
                              : _logs[index].contains('✗') || _logs[index].contains('❌')
                                  ? Colors.red[700]
                                  : Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                
                // Info section
                const SizedBox(height: 20),
                Card(
                  color: Colors.blue[50],
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features Demonstrated:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Multiple ad queue management'),
                        Text('• Priority-based loading'),
                        Text('• Auto-refill when queue is low'),
                        Text('• TTL (Time To Live) for cached ads'),
                        Text('• Retry mechanism with exponential backoff'),
                        Text('• Predictive preloading based on navigation'),
                        Text('• Frequency capping'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}