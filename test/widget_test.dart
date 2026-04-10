// This is a basic Flutter widget test for SpendSense.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/main.dart';

void main() {
  testWidgets('SpendSense app launches without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpendSenseApp());

    // Verify that the app bar title is present
    // Note: The app bar title is not visible in the dashboard screen because
    // the dashboard screen doesn't have an AppBar (it uses a custom header).
    // Instead, we can check for the presence of a key widget like "Hello, Aman".
    expect(find.text('Hello, Aman'), findsOneWidget);
    
    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}