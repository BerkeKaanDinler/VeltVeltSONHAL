abstract final class AppConstants {
  // ── Rest timer ────────────────────────────────────────────
  static const int restTimerDefaultSecs = 90;
  static const int restTimerAddSecs     = 15;
  static const int restTimerUrgentSecs  = 10;

  // ── Workout limits ────────────────────────────────────────
  static const int maxSetsPerExercise   = 20;
  static const int maxExercisesPerRoutine = 20;

  // ── Nutrition ─────────────────────────────────────────────
  static const int defaultCalorieGoal   = 2000;
  static const int defaultProteinGoal   = 150;
  static const int defaultCarbsGoal     = 200;
  static const int defaultFatGoal       = 65;

  // ── Progress / History ────────────────────────────────────
  static const int weeklyVolumeChartBars = 8;
  static const int prListMaxDisplay      = 8;
  static const int bodyweightHistoryDays = 90;

  // ── Animations ───────────────────────────────────────────
  static const Duration animPrimary    = Duration(milliseconds: 200);
  static const Duration animChart      = Duration(milliseconds: 500);
  static const Duration animTransition = Duration(milliseconds: 300);

  // ── 1RM (Epley formula: weight × (1 + reps / 30)) ────────
  static double epley1RM(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }
}
