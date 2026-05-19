import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velt/app.dart';
import 'package:velt/services/prefs_service.dart';

Future<void> initPrefs() async {
  SharedPreferences.setMockInitialValues({});
  await PrefsService.init();
}

Future<void> initPrefsOnboarded() async {
  SharedPreferences.setMockInitialValues({'onboarding_done': true});
  await PrefsService.init();
}

void main() {
  testWidgets('Onboarding smoke test — VELT wordmark visible', (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    expect(find.text('VELT'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Onboarding step 0 → step 1 shows goal picker', (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.textContaining("primary goal"), findsOneWidget);
  });

  testWidgets('Onboarding goal selection enables Continue', (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build Muscle'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Home screen visible after completed onboarding', (tester) async {
    await initPrefsOnboarded();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('VELT'), findsWidgets);
    // Stats section is above the fold and always built
    expect(find.text('Day Streak'), findsOneWidget);
  });

  testWidgets('Bottom nav and home content visible after onboarding', (tester) async {
    await initPrefsOnboarded();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Day Streak'), findsOneWidget);
    // Bottom nav tabs are gesture detectors
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
