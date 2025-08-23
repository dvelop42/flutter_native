import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_googleads/native_googleads.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test app IDs (using test IDs from AdTestIds)
  final testAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544' // Android test app ID
      : 'ca-app-pub-3940256099942544'; // iOS test app ID

  final testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Android test banner
      : 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner

  final testNativeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110' // Android native advanced
      : 'ca-app-pub-3940256099942544/3986624511'; // iOS native advanced

  final testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android test interstitial
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS test interstitial

  final testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android test rewarded
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS test rewarded

  setUpAll(() async {
    // Initialize the ads SDK once for all tests
    await NativeGoogleads.instance.initialize(appId: testAppId);
  });

  group('App Lifecycle Management', () {
    testWidgets('Ads survive app pause and resume',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  key: const Key('lifecycle_banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: NativeAdWidget(
                    key: const Key('lifecycle_native'),
                    adUnitId: testNativeAdUnitId,
                    height: 300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify ads are present
      expect(find.byKey(const Key('lifecycle_banner')), findsOneWidget);
      expect(find.byKey(const Key('lifecycle_native')), findsOneWidget);

      // Simulate app going to background
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // Simulate app coming back to foreground
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify ads are still present after resume
      expect(find.byKey(const Key('lifecycle_banner')), findsOneWidget);
      expect(find.byKey(const Key('lifecycle_native')), findsOneWidget);
    });

    testWidgets('Ads handle app inactive state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              key: const Key('inactive_test_banner'),
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify ad is present
      expect(find.byKey(const Key('inactive_test_banner')), findsOneWidget);

      // Simulate app going inactive (e.g., receiving a phone call on iOS)
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      // Simulate app becoming active again
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify ad is still present
      expect(find.byKey(const Key('inactive_test_banner')), findsOneWidget);
    });

    testWidgets('Fullscreen ads handle lifecycle changes',
        (WidgetTester tester) async {
      final ads = NativeGoogleads.instance;
      bool interstitialReady = false;
      bool rewardedReady = false;

      // Set up callbacks
      ads.setAdCallbacks(
        onAdDismissed: (type) {
          debugPrint('Ad dismissed: $type');
        },
        onAdShowed: (type) {
          debugPrint('Ad showed: $type');
        },
        onAdFailedToShow: (type, error) {
          debugPrint('Ad failed to show: $type - $error');
        },
        onUserEarnedReward: (type, amount) {
          debugPrint('User earned reward: $amount $type');
        },
      );

      // Preload ads
      interstitialReady = await ads.preloadInterstitialAd(
        adUnitId: testInterstitialAdUnitId,
      );
      rewardedReady = await ads.preloadRewardedAd(
        adUnitId: testRewardedAdUnitId,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Interstitial Ready: $interstitialReady'),
                Text('Rewarded Ready: $rewardedReady'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate lifecycle changes
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Check if ads are still ready
      if (interstitialReady) {
        final stillReady = await ads.isInterstitialReady(testInterstitialAdUnitId);
        debugPrint('Interstitial still ready after lifecycle: $stillReady');
      }

      if (rewardedReady) {
        final stillReady = await ads.isRewardedReady(testRewardedAdUnitId);
        debugPrint('Rewarded still ready after lifecycle: $stillReady');
      }
    });

    testWidgets('Memory cleanup on app detached state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BannerAdWidget(
                    key: Key('detach_banner_$index'),
                    adUnitId: testBannerAdUnitId,
                    size: BannerAdSize.banner,
                  ),
                );
              }),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify all ads are present
      expect(find.byType(BannerAdWidget), findsNWidgets(3));

      // Simulate app detached (being terminated)
      binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pump();

      // Note: In real scenarios, the app would be terminated here
      // For testing, we'll verify that the ads handle this gracefully
      // by resuming and checking if everything still works

      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    });
  });

  group('State Preservation', () {
    testWidgets('Ad state is preserved during navigation',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  key: const Key('nav_banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                ElevatedButton(
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Second Page')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify ad is present
      expect(find.byKey(const Key('nav_banner')), findsOneWidget);

      // Navigate to second page
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify we're on second page
      expect(find.text('Second Page'), findsOneWidget);
      expect(find.byKey(const Key('nav_banner')), findsNothing);

      // Navigate back
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();

      // Verify ad is back (state preserved or recreated)
      expect(find.byKey(const Key('nav_banner')), findsOneWidget);
    });

    testWidgets('Preloaded ads survive navigation',
        (WidgetTester tester) async {
      final ads = NativeGoogleads.instance;
      final navigatorKey = GlobalKey<NavigatorState>();

      // Preload a banner
      final bannerId = await ads.loadBannerAd(
        adUnitId: testBannerAdUnitId,
        size: BannerAdSize.banner,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Column(
              children: [
                if (bannerId != null)
                  BannerAdWidget(
                    key: const Key('preloaded_nav_banner'),
                    adUnitId: testBannerAdUnitId,
                    size: BannerAdSize.banner,
                    preloadedBannerId: bannerId,
                  ),
                ElevatedButton(
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: Column(
                            children: [
                              const Text('Second Page'),
                              if (bannerId != null)
                                BannerAdWidget(
                                  key: const Key('preloaded_nav_banner_page2'),
                                  adUnitId: testBannerAdUnitId,
                                  size: BannerAdSize.banner,
                                  preloadedBannerId: bannerId,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Navigate with Preloaded Ad'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (bannerId != null) {
        // Verify ad is present on first page
        expect(find.byKey(const Key('preloaded_nav_banner')), findsOneWidget);

        // Navigate to second page
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Verify preloaded ad can be shown on second page
        expect(find.byKey(const Key('preloaded_nav_banner_page2')), findsOneWidget);
      }
    });
  });

  group('Configuration Changes', () {
    testWidgets('Ads handle theme changes',
        (WidgetTester tester) async {
      ThemeMode currentTheme = ThemeMode.light;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: currentTheme,
              home: Scaffold(
                body: Column(
                  children: [
                    BannerAdWidget(
                      key: const Key('theme_banner'),
                      adUnitId: testBannerAdUnitId,
                      size: BannerAdSize.banner,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentTheme = currentTheme == ThemeMode.light
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        });
                      },
                      child: const Text('Toggle Theme'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify ad is present
      expect(find.byKey(const Key('theme_banner')), findsOneWidget);

      // Toggle theme
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify ad is still present after theme change
      expect(find.byKey(const Key('theme_banner')), findsOneWidget);

      // Toggle theme again
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify ad is still present
      expect(find.byKey(const Key('theme_banner')), findsOneWidget);
    });

    testWidgets('Ads handle locale changes',
        (WidgetTester tester) async {
      Locale currentLocale = const Locale('en', 'US');

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              locale: currentLocale,
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('es', 'ES'),
              ],
              home: Scaffold(
                body: Column(
                  children: [
                    BannerAdWidget(
                      key: const Key('locale_banner'),
                      adUnitId: testBannerAdUnitId,
                      size: BannerAdSize.banner,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentLocale = currentLocale.languageCode == 'en'
                              ? const Locale('es', 'ES')
                              : const Locale('en', 'US');
                        });
                      },
                      child: const Text('Toggle Locale'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify ad is present
      expect(find.byKey(const Key('locale_banner')), findsOneWidget);

      // Toggle locale
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify ad is still present after locale change
      expect(find.byKey(const Key('locale_banner')), findsOneWidget);
    });
  });

  group('Edge Cases', () {
    testWidgets('Rapid lifecycle changes stress test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              key: const Key('stress_lifecycle_banner'),
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Rapid lifecycle changes
      for (int i = 0; i < 5; i++) {
        binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump(const Duration(milliseconds: 100));
        
        binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump(const Duration(milliseconds: 100));
        
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Verify ad is still present and functional
      expect(find.byKey(const Key('stress_lifecycle_banner')), findsOneWidget);
    });

    testWidgets('Ad behavior when app is minimized and restored',
        (WidgetTester tester) async {
      bool adLoaded = false;
      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  key: const Key('minimize_test_banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                  onAdLoaded: () => adLoaded = true,
                  onAdFailedToLoad: (error) => errorMessage = error,
                ),
                const SizedBox(height: 20),
                Text('Ad Loaded: $adLoaded'),
                if (errorMessage != null) Text('Error: $errorMessage'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simulate minimizing app
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 1));

      // Simulate restoring app
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify ad is still present
      expect(find.byKey(const Key('minimize_test_banner')), findsOneWidget);
    });
  });
}