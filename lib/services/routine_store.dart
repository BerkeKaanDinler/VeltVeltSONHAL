import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/routine.dart';
import 'prefs_service.dart';

class RoutineStore {
  RoutineStore._();

  static final routines = ValueNotifier<List<Routine>>([]);

  static Future<void> init() async {
    final json = PrefsService.routines;
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        routines.value = list
            .map((e) => Routine.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        routines.value = [];
      }
    }
  }

  static Future<void> _persist() async {
    final json = jsonEncode(routines.value.map((r) => r.toJson()).toList());
    await PrefsService.saveRoutines(json);
  }

  static Future<void> add(Routine r) async {
    routines.value = [...routines.value, r];
    await _persist();
  }

  static Future<void> addAll(List<Routine> list) async {
    routines.value = [...routines.value, ...list];
    await _persist();
  }

  static Future<void> update(Routine r) async {
    routines.value = [
      for (final e in routines.value)
        if (e.id == r.id) r else e,
    ];
    await _persist();
  }

  static Future<void> delete(String id) async {
    routines.value = routines.value.where((r) => r.id != id).toList();
    await _persist();
  }

  static Future<void> markDone(String id) async {
    routines.value = [
      for (final r in routines.value)
        if (r.id == id) r.copyWith(lastDone: DateTime.now()) else r,
    ];
    await _persist();
  }

  static bool containsId(String id) =>
      routines.value.any((r) => r.id == id);
}
