import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'config/env.dart';
import 'services/notification_service.dart';
import 'services/prefs_service.dart';
import 'services/routine_store.dart';
import 'services/workout_history_store.dart';
import 'services/nutrition_store.dart';
import 'services/auth_service.dart';
import 'services/pro_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone must be configured before NotificationService.init()
  tz.initializeTimeZones();
  final tzInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

  await NotificationService.init();
  await PrefsService.init();
  await RoutineStore.init();
  await WorkoutHistoryStore.init();
  await NutritionStore.init();

  // Cloud + payments init — all guarded by env flags so the app still
  // launches in fully-offline mode if secrets are not configured.
  await AuthService.init();
  await ProService.init();

  if (Env.sentryEnabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
        options.tracesSampleRate = 0.2;
        options.profilesSampleRate = 0.1;
        options.attachScreenshot = false;
        options.sendDefaultPii = false;
      },
      appRunner: () => runApp(const VeltRoot()),
    );
  } else {
    runApp(const VeltRoot());
  }
}
