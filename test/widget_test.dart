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
  testWidgets('Onboarding smoke test - welcome visible', (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    expect(find.textContaining('VELT adapts'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Onboarding step 0 to step 1 shows goal picker', (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What are you building toward?'), findsOneWidget);
  });

  testWidgets('Onboarding goal selection marks selected choice',
      (tester) async {
    await initPrefs();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build Muscle'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
  });

  testWidgets('Home screen visible after completed onboarding', (tester) async {
    await initPrefsOnboarded();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Start Workout'), findsOneWidget);
  });

  testWidgets('Bottom nav and home content visible after onboarding',
      (tester) async {
    await initPrefsOnboarded();
    await tester.pumpWidget(const VeltRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Train'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
