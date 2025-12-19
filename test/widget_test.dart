import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_share/main.dart';
import 'package:flash_share/ui/screens/welcome_screen.dart';
import 'package:flash_share/ui/screens/home_screen.dart';

void main() {
  testWidgets('App flow from Welcome to Home Screen', (WidgetTester tester) async {
    // 1. Set a large screen size to prevent overflow errors during test rendering
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    // 2. Pump the app (No 'seenWelcome' parameter needed anymore)
    await tester.pumpWidget(const ProviderScope(child: FlashShareApp()));
    
    // Allow animations to settle (Welcome Screen entry)
    await tester.pumpAndSettle();

    // 3. Verify we start at the Welcome Screen
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);

    // 4. Interact: Tap the "GET STARTED" button
    await tester.tap(find.text('GET STARTED'));
    
    // Allow navigation animation to finish
    await tester.pumpAndSettle();

    // 5. Verify we are now on the Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('FlashShare'), findsOneWidget);
    expect(find.text('Universal File Transfer'), findsOneWidget);

    // 6. Verify Core Features are present
    expect(find.text('Send Files'), findsOneWidget);
    expect(find.text('Phone Clone'), findsOneWidget);
    expect(find.text('Share Apps'), findsOneWidget);
    expect(find.text('FlashCast'), findsOneWidget);

    // Clean up window size
    addTearDown(tester.view.resetPhysicalSize);
  });
}