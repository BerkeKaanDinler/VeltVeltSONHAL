import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String get theme => _p.getString('theme') ?? 'warm';
  static Future<void> setTheme(String v) => _p.setString('theme', v);

  static String get unit => _p.getString('unit') ?? 'kg';
  static Future<void> setUnit(String v) => _p.setString('unit', v);

  static int get restSecs => _p.getInt('rest_secs') ?? 90;
  static Future<void> setRestSecs(int v) => _p.setInt('rest_secs', v);

  static String? get activeWorkout => _p.getString('active_workout');
  static Future<void> saveActiveWorkout(String jsonStr) =>
      _p.setString('active_workout', jsonStr);
  static Future<void> clearActiveWorkout() => _p.remove('active_workout');
  static Future<void> clearLastWorkout() => _p.remove('last_workout');
  static Future<void> clearBodyweightHistory() => _p.remove('bodyweight_history');

  static String? get lastWorkout => _p.getString('last_workout');
  static Future<void> saveLastWorkout(String jsonStr) =>
      _p.setString('last_workout', jsonStr);

  static String? get routines => _p.getString('routines');
  static Future<void> saveRoutines(String jsonStr) =>
      _p.setString('routines', jsonStr);

  static String? get workoutHistory => _p.getString('workout_history');
  static Future<void> saveWorkoutHistory(String jsonStr) =>
      _p.setString('workout_history', jsonStr);

  static bool get onboardingDone => _p.getBool('onboarding_done') ?? false;
  static Future<void> setOnboardingDone() => _p.setBool('onboarding_done', true);

  static String get experienceLevel => _p.getString('experience_level') ?? 'intermediate';
  static Future<void> setExperienceLevel(String v) => _p.setString('experience_level', v);

  static String? get nutritionTargets => _p.getString('nutrition_targets');
  static Future<void> saveNutritionTargets(String jsonStr) =>
      _p.setString('nutrition_targets', jsonStr);

  // User profile stats
  static double? get bodyweightKg {
    final v = _p.getDouble('bodyweight_kg');
    return v;
  }
  static Future<void> setBodyweightKg(double v) => _p.setDouble('bodyweight_kg', v);

  static double? get heightCm {
    final v = _p.getDouble('height_cm');
    return v;
  }
  static Future<void> setHeightCm(double v) => _p.setDouble('height_cm', v);

  static String get fitnessGoal => _p.getString('fitness_goal') ?? 'Build Muscle';
  static Future<void> setFitnessGoal(String v) => _p.setString('fitness_goal', v);

  static String get displayName => _p.getString('display_name') ?? 'Athlete';
  static Future<void> setDisplayName(String v) => _p.setString('display_name', v);

  static bool get showRpe => _p.getBool('show_rpe') ?? false;
  static Future<void> setShowRpe(bool v) => _p.setBool('show_rpe', v);

  static String? nutritionDay(String key) => _p.getString(key);
  static Future<void> saveNutritionDay(String key, String jsonStr) =>
      _p.setString(key, jsonStr);

  // Bodyweight history: list of {date: ms, kg: double}
  static String? get bodyweightHistory => _p.getString('bodyweight_history');
  static Future<void> saveBodyweightHistory(String jsonStr) =>
      _p.setString('bodyweight_history', jsonStr);

  // Generic per-key notes (exercise form notes, PR notes, etc.)
  static String? getNote(String key) => _p.getString('note_$key');
  static Future<void> setNote(String key, String value) =>
      _p.setString('note_$key', value);
  static Future<void> clearNote(String key) => _p.remove('note_$key');
}
