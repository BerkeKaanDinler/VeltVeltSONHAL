import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'prefs_service.dart';

class FoodEntry {
  FoodEntry({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    DateTime? loggedAt,
  }) : loggedAt = loggedAt ?? DateTime.now();

  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
    'name':     name,
    'calories': calories,
    'protein':  protein,
    'carbs':    carbs,
    'fat':      fat,
    'loggedAt': loggedAt.millisecondsSinceEpoch,
  };

  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(
    name:     j['name']     as String,
    calories: j['calories'] as int,
    protein:  (j['protein'] as num).toDouble(),
    carbs:    (j['carbs']   as num).toDouble(),
    fat:      (j['fat']     as num).toDouble(),
    loggedAt: DateTime.fromMillisecondsSinceEpoch(j['loggedAt'] as int),
  );
}

class NutritionTargets {
  const NutritionTargets({
    this.calories = 2400,
    this.protein  = 180,
    this.carbs    = 240,
    this.fat      = 75,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein':  protein,
    'carbs':    carbs,
    'fat':      fat,
  };

  factory NutritionTargets.fromJson(Map<String, dynamic> j) => NutritionTargets(
    calories: j['calories'] as int? ?? 2400,
    protein:  j['protein']  as int? ?? 180,
    carbs:    j['carbs']    as int? ?? 240,
    fat:      j['fat']      as int? ?? 75,
  );
}

class NutritionStore {
  NutritionStore._();

  // Today's entries
  static final entries  = ValueNotifier<List<FoodEntry>>([]);
  static final targets  = ValueNotifier<NutritionTargets>(const NutritionTargets());

  static Future<void> init() async {
    // Load targets
    final tJson = PrefsService.nutritionTargets;
    if (tJson != null) {
      try {
        targets.value = NutritionTargets.fromJson(
            jsonDecode(tJson) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Load today's log
    _loadToday();
  }

  static void _loadToday() {
    final key = _todayKey();
    final raw = PrefsService.nutritionDay(key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        entries.value = list
            .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        entries.value = [];
      }
    } else {
      entries.value = [];
    }
  }

  static Future<void> addEntry(FoodEntry e) async {
    entries.value = [...entries.value, e];
    await _persistToday();
  }

  static Future<void> removeEntry(int index) async {
    final list = [...entries.value];
    if (index < list.length) list.removeAt(index);
    entries.value = list;
    await _persistToday();
  }

  static Future<void> updateTargets(NutritionTargets t) async {
    targets.value = t;
    await PrefsService.saveNutritionTargets(jsonEncode(t.toJson()));
  }

  static Future<void> _persistToday() async {
    final json = jsonEncode(entries.value.map((e) => e.toJson()).toList());
    await PrefsService.saveNutritionDay(_todayKey(), json);
  }

  // Computed totals
  static int get totalCalories =>
      entries.value.fold(0, (s, e) => s + e.calories);
  static double get totalProtein =>
      entries.value.fold(0.0, (s, e) => s + e.protein);
  static double get totalCarbs =>
      entries.value.fold(0.0, (s, e) => s + e.carbs);
  static double get totalFat =>
      entries.value.fold(0.0, (s, e) => s + e.fat);

  // Calories for each day of the current week (Mon=0 .. Sun=6)
  // Returns list of 7 ints, today's value is live from entries
  static List<int> get weeklyCaloriesByDow {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Compute Mon of this week
    final mondayOffset = now.weekday - 1;
    final monday = today.subtract(Duration(days: mondayOffset));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      // Today's data is live in memory
      if (day.year == today.year &&
          day.month == today.month &&
          day.day == today.day) {
        return totalCalories;
      }
      final key = 'nutr_${day.year}_${day.month}_${day.day}';
      final raw = PrefsService.nutritionDay(key);
      if (raw == null) return 0;
      try {
        final list = jsonDecode(raw) as List;
        return list.fold<int>(0, (s, e) {
          final entry = FoodEntry.fromJson(e as Map<String, dynamic>);
          return s + entry.calories;
        });
      } catch (_) {
        return 0;
      }
    });
  }

  static String _todayKey() {
    final now = DateTime.now();
    return 'nutr_${now.year}_${now.month}_${now.day}';
  }
}
