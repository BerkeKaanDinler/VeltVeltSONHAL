import 'package:flutter/material.dart';
import '../screens/active_workout_screen.dart' show WorkoutExercise;

class Routine {
  Routine({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.exercises,
    this.lastDone,
  });

  final String id;
  final String name;
  final int colorValue;
  final List<WorkoutExercise> exercises;
  final DateTime? lastDone;

  Color get color => Color(colorValue);

  String get lastDoneLabel {
    if (lastDone == null) return 'Never';
    final diff = DateTime.now().difference(lastDone!);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  Routine copyWith({
    String? id,
    String? name,
    int? colorValue,
    List<WorkoutExercise>? exercises,
    DateTime? lastDone,
  }) =>
      Routine(
        id:         id         ?? this.id,
        name:       name       ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        exercises:  exercises  ?? this.exercises,
        lastDone:   lastDone   ?? this.lastDone,
      );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'colorValue': colorValue,
    'exercises':  exercises.map((e) => e.toJson()).toList(),
    if (lastDone != null) 'lastDone': lastDone!.millisecondsSinceEpoch,
  };

  factory Routine.fromJson(Map<String, dynamic> j) => Routine(
    id:         j['id']         as String,
    name:       j['name']       as String,
    colorValue: j['colorValue'] as int,
    exercises: (j['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastDone: j['lastDone'] != null
        ? DateTime.fromMillisecondsSinceEpoch(j['lastDone'] as int)
        : null,
  );
}
