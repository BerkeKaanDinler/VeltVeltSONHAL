import '../utils/weight_unit.dart';
import '../widgets/set_row.dart' show SetRowData;

class WorkoutExercise {
  WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required List<SetRowData> sets,
    this.notes = '',
    this.supersetId,
  }) : sets = List<SetRowData>.from(sets);

  final String id;
  final String name;
  final String muscle;
  final String equipment;
  List<SetRowData> sets;
  String notes;
  /// Exercises sharing the same supersetId form a superset (A1/A2/...).
  String? supersetId;

  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'muscle':    muscle,
    'equipment': equipment,
    'sets':      sets.map((s) => s.toJson()).toList(),
    'notes':     notes,
    if (supersetId != null) 'supersetId': supersetId,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> j) => WorkoutExercise(
    id:        j['id']        as String,
    name:      j['name']      as String,
    muscle:    j['muscle']    as String,
    equipment: j['equipment'] as String,
    notes:     (j['notes'] as String?) ?? '',
    supersetId: j['supersetId'] as String?,
    sets: (j['sets'] as List)
        .map((s) => SetRowData.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class CompletedWorkout {
  CompletedWorkout({
    required this.routineName,
    required this.exercises,
    required this.elapsedSecs,
    this.avgRestSecs = 0,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  final String routineName;
  final List<WorkoutExercise> exercises;
  final int elapsedSecs;
  final int avgRestSecs;
  final DateTime completedAt;

  int get totalSets => exercises.fold(0, (a, e) => a + e.sets.length);
  int get doneSets  => exercises.fold(0, (a, e) => a + e.sets.where((s) => s.isDone).length);
  double get totalVolume => exercises.fold(0.0, (a, e) =>
      a + e.sets.where((s) => s.isDone).fold(0.0, (b, s) => b + s.weight * s.reps));

  String get durationLabel {
    final m = elapsedSecs ~/ 60;
    return '$m min';
  }

  String get relativeDate {
    final now = DateTime.now();
    final diff = now.difference(completedAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${diff.inDays ~/ 7} week${diff.inDays ~/ 7 > 1 ? 's' : ''} ago';
  }

  String get volumeLabel => WeightUnit.formatVolume(totalVolume);

  Map<String, dynamic> toJson() => {
    'routineName': routineName,
    'exercises':   exercises.map((e) => e.toJson()).toList(),
    'elapsedSecs': elapsedSecs,
    'avgRestSecs': avgRestSecs,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  factory CompletedWorkout.fromJson(Map<String, dynamic> j) => CompletedWorkout(
    routineName: j['routineName'] as String,
    exercises: (j['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    elapsedSecs: j['elapsedSecs'] as int,
    avgRestSecs: (j['avgRestSecs'] as int?) ?? 0,
    completedAt: DateTime.fromMillisecondsSinceEpoch(j['completedAt'] as int),
  );
}
