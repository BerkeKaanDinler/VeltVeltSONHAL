import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/notification_service.dart';
import 'services/prefs_service.dart';
import 'services/routine_store.dart';
import 'services/workout_history_store.dart';
import 'services/nutrition_store.dart';
import 'app.dart';

void main() async {
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
  runApp(const VeltRoot());
}
