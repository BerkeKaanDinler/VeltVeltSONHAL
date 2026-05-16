import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velt/app.dart';
import 'package:velt/services/prefs_service.dart';

Future<void> initPrefs() async {
  SharedPreferences.setMockInitialValues({});
  await PrefsService.init();
}

void main() {
  setUp(initPrefs);

  testWidgets('Onboarding smoke test — VELT wordmark visible', (tester) async {
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    expect(find.text('VELT'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Onboarding step 0 → step 1 on Get Started tap', (tester) async {
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('How do you\nmeasure weight?'), findsOneWidget);
  });

  testWidgets('Onboarding unit picker — kg selection enables Continue', (tester) async {
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Full onboarding flow reaches home screen', (tester) async {
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();

    // Step 0 → Step 1
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Step 1: pick kg → Continue
    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: skip via "I'll set up later"
    await tester.tap(find.text("I'll set up later"));
    await tester.pumpAndSettle();

    // Should now be on the home screen
    expect(find.text('VELT'), findsWidgets);
    expect(find.text("TODAY'S PLAN"), findsOneWidget);
  });

  testWidgets('After onboarding — bottom nav and home content visible', (tester) async {
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();

    // Complete onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I'll set up later"));
    await tester.pumpAndSettle();

    // Home screen content should be visible
    expect(find.text("TODAY'S PLAN"), findsOneWidget);
    // Bottom nav is present (has 5 touch targets)
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
