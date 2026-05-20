import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/workout.dart' show CompletedWorkout, WorkoutExercise;
import '../widgets/set_row.dart' show SetRowData;
import 'prefs_service.dart';

class WorkoutHistoryStore {
  WorkoutHistoryStore._();

  static final history = ValueNotifier<List<CompletedWorkout>>([]);

  static Future<void> init() async {
    final json = PrefsService.workoutHistory;
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        history.value = list
            .map((e) => CompletedWorkout.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        history.value = [];
      }
    }
  }

  static Future<void> clearAll() async {
    history.value = [];
    await PrefsService.saveWorkoutHistory('[]');
  }

  static Future<void> add(CompletedWorkout w) async {
    history.value = [w, ...history.value];
    await _persist();
  }

  static Future<void> _persist() async {
    final json = jsonEncode(history.value.map((w) => w.toJson()).toList());
    await PrefsService.saveWorkoutHistory(json);
  }

  // ── Computed properties ────────────────────────────────────

  static int get currentStreak {
    if (history.value.isEmpty) return 0;
    final today = _day(DateTime.now());
    final days = history.value
        .map((w) => _day(w.completedAt))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final gap = today.difference(days.first).inDays;
    if (gap > 1) return 0;
    int streak = 0;
    var expected = days.first;
    for (final d in days) {
      if (d == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Last 7 days activity: index 0 = 6 days ago, index 6 = today
  static List<bool> get last7Days {
    final today = _day(DateTime.now());
    final days = history.value.map((w) => _day(w.completedAt)).toSet();
    return List.generate(7, (i) => days.contains(today.subtract(Duration(days: 6 - i))));
  }

  static double totalVolumeInPeriod(String period) {
    final now = DateTime.now();
    return history.value
        .where((w) => _inPeriod(w.completedAt, period, now))
        .fold(0.0, (s, w) => s + w.totalVolume);
  }

  static int workoutsInPeriod(String period) {
    final now = DateTime.now();
    return history.value.where((w) => _inPeriod(w.completedAt, period, now)).length;
  }

  // PR map: exercise name → (max weight, date label)
  static Map<String, ({double weight, String dateLabel})> get allTimePRs {
    final prs = <String, ({double weight, String dateLabel})>{};
    for (final w in history.value.reversed) {
      for (final ex in w.exercises) {
        for (final s in ex.sets) {
          if (!s.isDone || s.weight <= 0) continue;
          final existing = prs[ex.name];
          if (existing == null || s.weight > existing.weight) {
            prs[ex.name] = (weight: s.weight, dateLabel: w.relativeDate);
          }
        }
      }
    }
    return prs;
  }

  // Last time a given exercise was done — used for prev perf display
  static WorkoutExercise? previousExercise(String exerciseName) {
    for (final w in history.value) {
      for (final ex in w.exercises) {
        if (ex.name == exerciseName) return ex;
      }
    }
    return null;
  }

  /// Build a fresh template from a previously completed workout.
  /// Sets keep weight/reps as starting values, isDone is reset, and `prev`
  /// is populated from the historical performance so the user sees what
  /// they hit last time.
  static List<WorkoutExercise> templateFromCompleted(CompletedWorkout source) {
    return source.exercises.map((ex) {
      final newSets = ex.sets
          .asMap()
          .entries
          .map((entry) {
            final s = entry.value;
            return SetRowData(
              index: entry.key,
              type: s.type,
              // Reset isDone so user can re-log the session
              weight: s.weight,
              reps: s.reps,
              prev: (weight: s.weight, reps: s.reps),
              isDone: false,
              rpe: null,
            );
          })
          .toList();
      return WorkoutExercise(
        id: ex.id,
        name: ex.name,
        muscle: ex.muscle,
        equipment: ex.equipment,
        notes: ex.notes,
        supersetId: ex.supersetId,
        sets: newSets,
      );
    }).toList();
  }

  /// Returns up to [limit] distinct recent routine templates from history,
  /// keyed by routine name (most recent occurrence wins).
  static List<CompletedWorkout> recentTemplates({int limit = 5}) {
    final seen = <String>{};
    final result = <CompletedWorkout>[];
    for (final w in history.value) {
      if (seen.add(w.routineName)) {
        result.add(w);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  // Enrich exercises with previous performance data
  static List<WorkoutExercise> enrichWithPrev(List<WorkoutExercise> exercises) {
    return exercises.map((ex) {
      final prevEx = previousExercise(ex.name);
      if (prevEx == null) return ex;
      final doneSets = prevEx.sets.where((s) => s.isDone).toList();
      if (doneSets.isEmpty) return ex;
      final newSets = List.generate(ex.sets.length, (i) {
        final ps = i < doneSets.length ? doneSets[i] : doneSets.last;
        final old = ex.sets[i];
        return SetRowData(
          index: old.index,
          type: old.type,
          weight: old.weight > 0 ? old.weight : ps.weight,
          reps: old.reps > 0 ? old.reps : ps.reps,
          prev: (weight: ps.weight, reps: ps.reps),
        );
      });
      return WorkoutExercise(
        id: ex.id, name: ex.name,
        muscle: ex.muscle, equipment: ex.equipment,
        sets: newSets,
      );
    }).toList();
  }

  // Weekly volume for last N weeks (oldest first)
  static List<({String label, double volume})> weeklyVolumes({int weeks = 8}) {
    final now = DateTime.now();
    final result = <({String label, double volume})>[];
    for (int i = weeks - 1; i >= 0; i--) {
      final weekEnd   = _day(now).subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final vol = history.value.where((w) {
        final d = _day(w.completedAt);
        return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
      }).fold(0.0, (s, w) => s + w.totalVolume);
      result.add((label: _weekLabel(weekStart), volume: vol));
    }
    return result;
  }

  // Monthly volume for last N months (oldest first)
  static List<({String label, double volume})> monthlyVolumes({int months = 8}) {
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    final result = <({String label, double volume})>[];
    for (int i = months - 1; i >= 0; i--) {
      int m = now.month - i;
      int y = now.year;
      while (m <= 0) { m += 12; y--; }
      final vol = history.value.where((w) =>
          w.completedAt.year == y && w.completedAt.month == m)
          .fold(0.0, (s, w) => s + w.totalVolume);
      result.add((label: monthNames[m - 1], volume: vol));
    }
    return result;
  }

  // Yearly volume for last N years (oldest first)
  static List<({String label, double volume})> yearlyVolumes({int years = 8}) {
    final now = DateTime.now();
    final result = <({String label, double volume})>[];
    for (int i = years - 1; i >= 0; i--) {
      final y = now.year - i;
      final vol = history.value.where((w) => w.completedAt.year == y)
          .fold(0.0, (s, w) => s + w.totalVolume);
      result.add((label: '$y', volume: vol));
    }
    return result;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _inPeriod(DateTime d, String period, DateTime now) =>
      switch (period) {
        'week'  => now.difference(d).inDays <= 7,
        'month' => d.year == now.year && d.month == now.month,
        'year'  => d.year == now.year,
        _       => true,
      };

  static String _weekLabel(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }
}
