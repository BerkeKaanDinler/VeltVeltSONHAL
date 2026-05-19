import 'package:health/health.dart';
import 'prefs_service.dart';
import '../models/workout.dart' show CompletedWorkout;

abstract final class HealthService {
  static final _health = Health();

  // Types we write to HealthKit
  static const _writeTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
  ];

  static bool _configured = false;

  // ── One-time configure ──────────────────────────────────────
  static Future<void> configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  // ── Request write permission, returns true if granted ───────
  static Future<bool> requestPermission() async {
    await configure();
    return _health.requestAuthorization(
      _writeTypes,
      permissions: List.filled(
        _writeTypes.length, HealthDataAccess.WRITE),
    );
  }

  // ── Log a completed workout — fire-and-forget safe ──────────
  // Returns true if all writes succeeded.
  static Future<bool> logWorkout(CompletedWorkout workout) async {
    try {
      await configure();
      final granted = await requestPermission();
      if (!granted) return false;

      final start = workout.completedAt.subtract(
        Duration(seconds: workout.elapsedSecs));
      final end   = workout.completedAt;

      // Calorie estimate: MET 4.5 × bodyweight × hours
      // Strength training MET = 4.5 (ACSM guidelines)
      const double met = 4.5;
      final double weightKg = PrefsService.bodyweightKg ?? 75.0;
      final double hours = workout.elapsedSecs / 3600.0;
      final double kcal = (met * weightKg * hours).clamp(1.0, double.infinity);

      // 1. Write workout session (HKWorkout)
      final workoutOk = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: start,
        end: end,
        totalEnergyBurned: kcal.round(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      // 2. Write active energy burned
      final energyOk = await _health.writeHealthData(
        value: kcal,
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: start,
        endTime: end,
        unit: HealthDataUnit.KILOCALORIE,
      );

      // 3. Write exercise time (minutes)
      final mins = (workout.elapsedSecs / 60.0).roundToDouble();
      final timeOk = await _health.writeHealthData(
        value: mins,
        type: HealthDataType.EXERCISE_TIME,
        startTime: start,
        endTime: end,
        unit: HealthDataUnit.MINUTE,
      );

      return workoutOk && energyOk && timeOk;
    } catch (_) {
      // HealthKit unavailable (simulator, non-iOS, permission denied)
      return false;
    }
  }
}
