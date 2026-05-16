import 'package:flutter/material.dart';
import 'services/prefs_service.dart';
import 'services/routine_store.dart';
import 'services/workout_history_store.dart';
import 'services/nutrition_store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.init();
  await RoutineStore.init();
  await WorkoutHistoryStore.init();
  await NutritionStore.init();
  runApp(const VeltRoot());
}
