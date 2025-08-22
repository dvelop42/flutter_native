// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Scrollable; // for scrollUntilVisible

import 'package:native_googleads_example/main.dart';

void main() {
  testWidgets('Verify app builds and shows home page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is shown
    expect(find.text('Native Google Ads Demo'), findsOneWidget);

    // Verify that ad type cards are present (scroll if needed)
    expect(find.text('Banner Ads'), findsOneWidget);
    expect(find.text('Native Ads'), findsOneWidget);
    expect(find.text('Interstitial Ads'), findsOneWidget);

    // The list may require scrolling for the last item after adding new entries
    final rewardedFinder = find.text('Rewarded Ads');
    if (rewardedFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        rewardedFinder,
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }
    expect(rewardedFinder, findsOneWidget);
  });
}
