// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:native_googleads_example/main.dart';

void main() {
  testWidgets('Verify app builds and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is shown
    expect(find.text('Native Google Ads Demo'), findsOneWidget);
    
    // Verify that ad type cards are present
    expect(find.text('Banner Ads'), findsOneWidget);
    expect(find.text('Native Ads'), findsOneWidget);
    expect(find.text('Interstitial Ads'), findsOneWidget);
    expect(find.text('Rewarded Ads'), findsOneWidget);
  });
}
