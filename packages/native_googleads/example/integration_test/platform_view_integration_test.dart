import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_googleads/native_googleads.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
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

  setUpAll(() async {
    // Initialize the ads SDK once for all tests
    await NativeGoogleads.instance.initialize(appId: testAppId);
  });

  group('Platform View Creation and Disposal', () {
    testWidgets('Banner ad platform view creates and disposes correctly',
        (WidgetTester tester) async {
      bool adLoaded = false;
      bool adFailed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
              onAdLoaded: () => adLoaded = true,
              onAdFailedToLoad: (_) => adFailed = true,
            ),
          ),
        ),
      );

      // Wait for the ad to potentially load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the widget is present
      expect(find.byType(BannerAdWidget), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget is disposed
      expect(find.byType(BannerAdWidget), findsNothing);
    });

    testWidgets('Native ad platform view creates and disposes correctly',
        (WidgetTester tester) async {
      bool adLoaded = false;
      bool adFailed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: NativeAdWidget(
                adUnitId: testNativeAdUnitId,
                height: 300,
                onAdLoaded: () => adLoaded = true,
                onAdFailedToLoad: (_) => adFailed = true,
              ),
            ),
          ),
        ),
      );

      // Wait for the ad to potentially load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the widget is present
      expect(find.byType(NativeAdWidget), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget is disposed
      expect(find.byType(NativeAdWidget), findsNothing);
    });
  });

  group('Multiple Concurrent Platform Views', () {
    testWidgets('Multiple banner ads can coexist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  key: const Key('banner1'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                const SizedBox(height: 10),
                BannerAdWidget(
                  key: const Key('banner2'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.largeBanner,
                ),
                const SizedBox(height: 10),
                BannerAdWidget(
                  key: const Key('banner3'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.mediumRectangle,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify all three banner widgets are present
      expect(find.byType(BannerAdWidget), findsNWidgets(3));
      expect(find.byKey(const Key('banner1')), findsOneWidget);
      expect(find.byKey(const Key('banner2')), findsOneWidget);
      expect(find.byKey(const Key('banner3')), findsOneWidget);
    });

    testWidgets('Mixed ad types can coexist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                BannerAdWidget(
                  key: const Key('banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: NativeAdWidget(
                    key: const Key('native'),
                    adUnitId: testNativeAdUnitId,
                    height: 300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify both ad types are present
      expect(find.byType(BannerAdWidget), findsOneWidget);
      expect(find.byType(NativeAdWidget), findsOneWidget);
    });
  });

  group('Platform View Visibility Changes', () {
    testWidgets('Ad visibility can be toggled',
        (WidgetTester tester) async {
      bool showAd = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => showAd = !showAd),
                      child: const Text('Toggle Ad'),
                    ),
                    if (showAd)
                      BannerAdWidget(
                        adUnitId: testBannerAdUnitId,
                        size: BannerAdSize.banner,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Initially, ad should be visible
      expect(find.byType(BannerAdWidget), findsOneWidget);

      // Toggle visibility off
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(BannerAdWidget), findsNothing);

      // Toggle visibility on
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('Ad can be scrolled in and out of view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                Container(height: 800, color: Colors.blue),
                BannerAdWidget(
                  key: const Key('scrollable_banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                Container(height: 800, color: Colors.red),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, ad should not be visible (scrolled out of view)
      expect(find.byKey(const Key('scrollable_banner')), findsOneWidget);

      // Scroll to make the ad visible
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Ad should still exist in the widget tree
      expect(find.byKey(const Key('scrollable_banner')), findsOneWidget);

      // Scroll back
      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pumpAndSettle();

      // Ad should still exist
      expect(find.byKey(const Key('scrollable_banner')), findsOneWidget);
    });
  });

  group('Performance Benchmarks', () {
    testWidgets('Banner ad creation performance',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));
      stopwatch.stop();

      // Log performance metrics
      debugPrint('Banner ad creation took: ${stopwatch.elapsedMilliseconds}ms');
      
      // Ensure creation doesn't take too long (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
    });

    testWidgets('Multiple ads creation performance',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BannerAdWidget(
                    key: Key('banner_$index'),
                    adUnitId: testBannerAdUnitId,
                    size: BannerAdSize.banner,
                  ),
                );
              }),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 10));
      stopwatch.stop();

      // Log performance metrics
      debugPrint('5 banner ads creation took: ${stopwatch.elapsedMilliseconds}ms');
      
      // Ensure multiple ads don't take too long
      expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // 15 seconds max
    });
  });

  group('Memory Management', () {
    testWidgets('Ads are properly disposed when removed from tree',
        (WidgetTester tester) async {
      // Create initial ad
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              key: const Key('disposable_banner'),
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('disposable_banner')), findsOneWidget);

      // Replace with empty widget (should trigger disposal)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('disposable_banner')), findsNothing);

      // Create new ad with same key (should work if previous was disposed)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              key: const Key('disposable_banner'),
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.largeBanner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('disposable_banner')), findsOneWidget);
    });

    testWidgets('Rapid ad creation and disposal stress test',
        (WidgetTester tester) async {
      // Rapidly create and dispose ads
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerAdWidget(
                key: Key('stress_banner_$i'),
                adUnitId: testBannerAdUnitId,
                size: BannerAdSize.banner,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        // Dispose
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
      }

      // Final check - should be able to create a new ad
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              key: const Key('final_banner'),
              adUnitId: testBannerAdUnitId,
              size: BannerAdSize.banner,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('final_banner')), findsOneWidget);
    });
  });

  group('Dynamic Size Changes', () {
    testWidgets('Banner ad size can be changed dynamically',
        (WidgetTester tester) async {
      BannerAdSize currentSize = BannerAdSize.banner;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentSize = currentSize == BannerAdSize.banner
                              ? BannerAdSize.largeBanner
                              : BannerAdSize.banner;
                        });
                      },
                      child: const Text('Change Size'),
                    ),
                    BannerAdWidget(
                      key: ValueKey(currentSize),
                      adUnitId: testBannerAdUnitId,
                      size: currentSize,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Initially should have banner size
      expect(find.byType(BannerAdWidget), findsOneWidget);

      // Change size
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should still have one banner (with new size)
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('Native ad height can be adjusted dynamically',
        (WidgetTester tester) async {
      double adHeight = 200.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          adHeight = adHeight == 200.0 ? 400.0 : 200.0;
                        });
                      },
                      child: const Text('Change Height'),
                    ),
                    SizedBox(
                      height: adHeight,
                      child: NativeAdWidget(
                        key: ValueKey(adHeight),
                        adUnitId: testNativeAdUnitId,
                        height: adHeight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Initially should have native ad with 200 height
      expect(find.byType(NativeAdWidget), findsOneWidget);

      // Change height
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should still have one native ad (with new height)
      expect(find.byType(NativeAdWidget), findsOneWidget);
    });
  });

  group('Error Handling', () {
    testWidgets('Invalid ad unit ID handling',
        (WidgetTester tester) async {
      bool errorOccurred = false;
      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              adUnitId: 'invalid-ad-unit-id',
              size: BannerAdSize.banner,
              onAdFailedToLoad: (error) {
                errorOccurred = true;
                errorMessage = error;
              },
            ),
          ),
        ),
      );

      // Wait for potential error
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Widget should still be present even if ad fails
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('Network error recovery',
        (WidgetTester tester) async {
      bool errorOccurred = false;
      bool adLoaded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  key: const Key('network_test_banner'),
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                  onAdLoaded: () => adLoaded = true,
                  onAdFailedToLoad: (_) => errorOccurred = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Widget should be present regardless of network status
      expect(find.byKey(const Key('network_test_banner')), findsOneWidget);
    });
  });

  group('Preloaded Ads', () {
    testWidgets('Preloaded banner ad can be displayed',
        (WidgetTester tester) async {
      final ads = NativeGoogleads.instance;
      
      // Preload a banner ad
      final bannerId = await ads.loadBannerAd(
        adUnitId: testBannerAdUnitId,
        size: BannerAdSize.banner,
      );

      if (bannerId != null) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerAdWidget(
                adUnitId: testBannerAdUnitId,
                size: BannerAdSize.banner,
                preloadedBannerId: bannerId,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(BannerAdWidget), findsOneWidget);
      }
    });

    testWidgets('Preloaded native ad can be displayed',
        (WidgetTester tester) async {
      final ads = NativeGoogleads.instance;
      
      // Preload a native ad
      final nativeId = await ads.loadNativeAd(
        adUnitId: testNativeAdUnitId,
      );

      if (nativeId != null) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 300,
                child: NativeAdWidget(
                  adUnitId: testNativeAdUnitId,
                  height: 300,
                  preloadedNativeAdId: nativeId,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(NativeAdWidget), findsOneWidget);
      }
    });
  });

  // Platform-specific tests
  group('Platform Specific Behavior', () {
    testWidgets('Platform view renders correctly on ${Platform.operatingSystem}',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(
                  adUnitId: testBannerAdUnitId,
                  size: BannerAdSize.banner,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: NativeAdWidget(
                    adUnitId: testNativeAdUnitId,
                    height: 300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Both widgets should be present
      expect(find.byType(BannerAdWidget), findsOneWidget);
      expect(find.byType(NativeAdWidget), findsOneWidget);

      // Platform-specific checks
      if (Platform.isAndroid) {
        // Android-specific verifications
        debugPrint('Running on Android platform');
      } else if (Platform.isIOS) {
        // iOS-specific verifications
        debugPrint('Running on iOS platform');
      }
    });
  });
}