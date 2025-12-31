// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pakcraft/main.dart';
import 'package:pakcraft/splashscreen.dart';
import 'package:pakcraft/screens/welcome_screen.dart';

// Ensure MyApp is defined in main.dart like below:
// class MyApp extends StatelessWidget { ... }

void main() {
  testWidgets('PakCraft app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PakCraftApp());

    // Verify that the splash screen is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Wait for the splash screen to navigate (2 seconds).
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we have navigated to the welcome screen.
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
