import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/set_row.dart';
import '../widgets/rest_timer_banner.dart';
import '../services/prefs_service.dart';
import '../utils/weight_unit.dart';

// ── Data model ─────────────────────────────────────────────
class WorkoutExercise {
  WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required List<SetRowData> sets,
    this.notes = '',
  }) : sets = List<SetRowData>.from(sets);

  final String id;
  final String name;
  final String muscle;
  final String equipment;
  List<SetRowData> sets;
  String notes;

  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'muscle':    muscle,
    'equipment': equipment,
    'sets':      sets.map((s) => s.toJson()).toList(),
    'notes':     notes,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> j) => WorkoutExercise(
    id:        j['id']        as String,
    name:      j['name']      as String,
    muscle:    j['muscle']    as String,
    equipment: j['equipment'] as String,
    notes:     (j['notes'] as String?) ?? '',
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
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  final String routineName;
  final List<WorkoutExercise> exercises;
  final int elapsedSecs;
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
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  factory CompletedWorkout.fromJson(Map<String, dynamic> j) => CompletedWorkout(
    routineName: j['routineName'] as String,
    exercises: (j['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    elapsedSecs: j['elapsedSecs'] as int,
    completedAt: DateTime.fromMillisecondsSinceEpoch(j['completedAt'] as int),
  );
}

List<WorkoutExercise> _defaultExercises() => [
  WorkoutExercise(
    id: 'bench', name: 'Bench Press', muscle: 'Chest', equipment: 'Barbell',
    sets: [
      const SetRowData(index:0, type:SetType.warmup, weight:60, reps:10),
      const SetRowData(index:1, type:SetType.normal, weight:80, reps:8,  prev:(weight:80, reps:8)),
      const SetRowData(index:2, type:SetType.normal, weight:80, reps:8,  prev:(weight:80, reps:8)),
      const SetRowData(index:3, type:SetType.normal, weight:80, reps:6,  prev:(weight:77.5, reps:7)),
    ],
  ),
  WorkoutExercise(
    id: 'incline', name: 'Incline DB Press', muscle: 'Chest', equipment: 'Dumbbell',
    sets: [
      const SetRowData(index:0, type:SetType.normal, weight:30, reps:10, prev:(weight:27.5, reps:10)),
      const SetRowData(index:1, type:SetType.normal, weight:30, reps:10, prev:(weight:27.5, reps:10)),
      const SetRowData(index:2, type:SetType.normal, weight:30, reps:8,  prev:(weight:27.5, reps:8)),
    ],
  ),
  WorkoutExercise(
    id: 'ohp', name: 'Overhead Press', muscle: 'Shoulders', equipment: 'Barbell',
    sets: [
      const SetRowData(index:0, type:SetType.normal, weight:50, reps:8, prev:(weight:50, reps:8)),
      const SetRowData(index:1, type:SetType.normal, weight:50, reps:8, prev:(weight:50, reps:8)),
      const SetRowData(index:2, type:SetType.normal, weight:50, reps:6, prev:(weight:47.5, reps:7)),
    ],
  ),
];

List<WorkoutExercise> routineExercises(String routineId) {
  switch (routineId) {
    case 'push-a':
      return [
        WorkoutExercise(id:'bench',   name:'Bench Press',      muscle:'Chest',     equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.warmup,weight:60,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:80,reps:8, prev:(weight:80,reps:8)),
                const SetRowData(index:2,type:SetType.normal,weight:80,reps:8, prev:(weight:80,reps:8)),
                const SetRowData(index:3,type:SetType.normal,weight:80,reps:6, prev:(weight:77.5,reps:7))]),
        WorkoutExercise(id:'incline', name:'Incline DB Press', muscle:'Chest',     equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:30,reps:10,prev:(weight:27.5,reps:10)),
                const SetRowData(index:1,type:SetType.normal,weight:30,reps:10,prev:(weight:27.5,reps:10)),
                const SetRowData(index:2,type:SetType.normal,weight:30,reps:8, prev:(weight:27.5,reps:8))]),
        WorkoutExercise(id:'cable-fly',name:'Cable Fly',       muscle:'Chest',     equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:15,reps:12),
                const SetRowData(index:1,type:SetType.normal,weight:15,reps:12),
                const SetRowData(index:2,type:SetType.normal,weight:15,reps:10)]),
        WorkoutExercise(id:'ohp',     name:'Overhead Press',  muscle:'Shoulders', equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:50,reps:8, prev:(weight:50,reps:8)),
                const SetRowData(index:1,type:SetType.normal,weight:50,reps:8, prev:(weight:50,reps:8)),
                const SetRowData(index:2,type:SetType.normal,weight:50,reps:6, prev:(weight:47.5,reps:7))]),
        WorkoutExercise(id:'lat-raise',name:'Lateral Raise',  muscle:'Shoulders', equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:12,reps:15),
                const SetRowData(index:1,type:SetType.normal,weight:12,reps:15),
                const SetRowData(index:2,type:SetType.normal,weight:12,reps:12)]),
        WorkoutExercise(id:'tri-push', name:'Tricep Pushdown', muscle:'Triceps',   equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:20,reps:12),
                const SetRowData(index:1,type:SetType.normal,weight:20,reps:12),
                const SetRowData(index:2,type:SetType.normal,weight:20,reps:10)]),
      ];
    case 'pull-a':
      return [
        WorkoutExercise(id:'barbell-row',name:'Barbell Row',     muscle:'Back',    equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.warmup,weight:60,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:80,reps:8,prev:(weight:77.5,reps:8)),
                const SetRowData(index:2,type:SetType.normal,weight:80,reps:8,prev:(weight:77.5,reps:8)),
                const SetRowData(index:3,type:SetType.normal,weight:80,reps:6,prev:(weight:77.5,reps:6))]),
        WorkoutExercise(id:'lat-pull',  name:'Lat Pulldown',     muscle:'Back',    equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:60,reps:10,prev:(weight:57.5,reps:10)),
                const SetRowData(index:1,type:SetType.normal,weight:60,reps:10,prev:(weight:57.5,reps:10)),
                const SetRowData(index:2,type:SetType.normal,weight:60,reps:8, prev:(weight:57.5,reps:8))]),
        WorkoutExercise(id:'cable-row', name:'Seated Cable Row', muscle:'Back',    equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:55,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:55,reps:10),
                const SetRowData(index:2,type:SetType.normal,weight:55,reps:8)]),
        WorkoutExercise(id:'face-pull', name:'Face Pull',        muscle:'Rear Delt',equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:25,reps:15),
                const SetRowData(index:1,type:SetType.normal,weight:25,reps:15),
                const SetRowData(index:2,type:SetType.normal,weight:25,reps:12)]),
        WorkoutExercise(id:'hammer-curl',name:'Hammer Curl',     muscle:'Biceps',  equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:18,reps:10,prev:(weight:16,reps:10)),
                const SetRowData(index:1,type:SetType.normal,weight:18,reps:10,prev:(weight:16,reps:10)),
                const SetRowData(index:2,type:SetType.normal,weight:18,reps:8, prev:(weight:16,reps:8))]),
      ];
    case 'legs-a':
      return [
        WorkoutExercise(id:'squat',   name:'Squat',              muscle:'Quads',   equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.warmup,weight:60,reps:8),
                const SetRowData(index:1,type:SetType.normal,weight:100,reps:5,prev:(weight:97.5,reps:5)),
                const SetRowData(index:2,type:SetType.normal,weight:100,reps:5,prev:(weight:97.5,reps:5)),
                const SetRowData(index:3,type:SetType.normal,weight:100,reps:5,prev:(weight:97.5,reps:5))]),
        WorkoutExercise(id:'rdl',     name:'Romanian Deadlift',  muscle:'Hamstrings',equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:80,reps:8,prev:(weight:77.5,reps:8)),
                const SetRowData(index:1,type:SetType.normal,weight:80,reps:8,prev:(weight:77.5,reps:8)),
                const SetRowData(index:2,type:SetType.normal,weight:80,reps:6,prev:(weight:77.5,reps:6))]),
        WorkoutExercise(id:'leg-press',name:'Leg Press',         muscle:'Quads',   equipment:'Machine',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:140,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:140,reps:10),
                const SetRowData(index:2,type:SetType.normal,weight:140,reps:8)]),
        WorkoutExercise(id:'leg-curl', name:'Leg Curl',          muscle:'Hamstrings',equipment:'Machine',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:45,reps:12),
                const SetRowData(index:1,type:SetType.normal,weight:45,reps:12),
                const SetRowData(index:2,type:SetType.normal,weight:45,reps:10)]),
        WorkoutExercise(id:'calf-raise',name:'Standing Calf Raise',muscle:'Calves',equipment:'Machine',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:60,reps:15),
                const SetRowData(index:1,type:SetType.normal,weight:60,reps:15),
                const SetRowData(index:2,type:SetType.normal,weight:60,reps:12)]),
        WorkoutExercise(id:'lunge',   name:'Walking Lunge',      muscle:'Glutes',  equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:20,reps:12),
                const SetRowData(index:1,type:SetType.normal,weight:20,reps:12)]),
      ];
    case 'push-b':
      return [
        WorkoutExercise(id:'ohp-b',   name:'Overhead Press',    muscle:'Shoulders',equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.warmup,weight:40,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:55,reps:5,prev:(weight:52.5,reps:5)),
                const SetRowData(index:2,type:SetType.normal,weight:55,reps:5,prev:(weight:52.5,reps:5)),
                const SetRowData(index:3,type:SetType.normal,weight:55,reps:4,prev:(weight:52.5,reps:5))]),
        WorkoutExercise(id:'arnold',  name:'Arnold Press',      muscle:'Shoulders',equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:22,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:22,reps:10),
                const SetRowData(index:2,type:SetType.normal,weight:22,reps:8)]),
        WorkoutExercise(id:'cable-lat',name:'Cable Lateral Raise',muscle:'Shoulders',equipment:'Cable',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:8,reps:15),
                const SetRowData(index:1,type:SetType.normal,weight:8,reps:15),
                const SetRowData(index:2,type:SetType.normal,weight:8,reps:12)]),
        WorkoutExercise(id:'pec-fly', name:'Pec Deck Fly',      muscle:'Chest',    equipment:'Machine',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:50,reps:12),
                const SetRowData(index:1,type:SetType.normal,weight:50,reps:12),
                const SetRowData(index:2,type:SetType.normal,weight:50,reps:10)]),
        WorkoutExercise(id:'skullcrusher',name:'Skullcrusher',  muscle:'Triceps',  equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:30,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:30,reps:10),
                const SetRowData(index:2,type:SetType.normal,weight:30,reps:8)]),
      ];
    case 'pull-b':
      return [
        WorkoutExercise(id:'deadlift',name:'Deadlift',           muscle:'Back',    equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.warmup,weight:80,reps:5),
                const SetRowData(index:1,type:SetType.normal,weight:130,reps:5,prev:(weight:127.5,reps:5)),
                const SetRowData(index:2,type:SetType.normal,weight:130,reps:3,prev:(weight:127.5,reps:5))]),
        WorkoutExercise(id:'pullup',  name:'Pull-Up',            muscle:'Back',    equipment:'Bodyweight',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:0,reps:8,prev:(weight:0,reps:8)),
                const SetRowData(index:1,type:SetType.normal,weight:0,reps:8,prev:(weight:0,reps:7)),
                const SetRowData(index:2,type:SetType.normal,weight:0,reps:6,prev:(weight:0,reps:6))]),
        WorkoutExercise(id:'db-row',  name:'DB Row',             muscle:'Back',    equipment:'Dumbbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:35,reps:10,prev:(weight:32.5,reps:10)),
                const SetRowData(index:1,type:SetType.normal,weight:35,reps:10,prev:(weight:32.5,reps:10)),
                const SetRowData(index:2,type:SetType.normal,weight:35,reps:8, prev:(weight:32.5,reps:8))]),
        WorkoutExercise(id:'bb-curl', name:'Barbell Curl',       muscle:'Biceps',  equipment:'Barbell',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:35,reps:10),
                const SetRowData(index:1,type:SetType.normal,weight:35,reps:10),
                const SetRowData(index:2,type:SetType.normal,weight:35,reps:8)]),
        WorkoutExercise(id:'rev-fly', name:'Reverse Pec Fly',    muscle:'Rear Delt',equipment:'Machine',
          sets:[const SetRowData(index:0,type:SetType.normal,weight:30,reps:15),
                const SetRowData(index:1,type:SetType.normal,weight:30,reps:15),
                const SetRowData(index:2,type:SetType.normal,weight:30,reps:12)]),
      ];
    default:
      return _defaultExercises();
  }
}

// ══════════════════════════════════════════════════════════
//  ACTIVE WORKOUT SCREEN
// ══════════════════════════════════════════════════════════
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.routineName,
    required this.onFinish,
    this.exercises,
    this.initialElapsedSecs = 0,
  });

  final String routineName;
  final void Function(CompletedWorkout) onFinish;
  final List<WorkoutExercise>? exercises;
  final int initialElapsedSecs;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late List<WorkoutExercise> _exercises;
  int _currentExIdx = 0;
  int? _restSeconds;
  int _elapsedSecs = 0;
  bool _showMenu = false;
  Timer? _elapsedTimer;
  int? _restKey; // increments to force RestTimerBanner rebuild on new rest

  @override
  void initState() {
    super.initState();
    _elapsedSecs = widget.initialElapsedSecs;
    _exercises = widget.exercises ?? _defaultExercises();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSecs++);
    });
  }

  void _saveToPrefs() {
    final data = jsonEncode({
      'routineName': widget.routineName,
      'exercises':   _exercises.map((e) => e.toJson()).toList(),
      'elapsedSecs': _elapsedSecs,
    });
    PrefsService.saveActiveWorkout(data);
  }

  void _finishWorkout() {
    _elapsedTimer?.cancel();
    PrefsService.clearActiveWorkout();
    widget.onFinish(CompletedWorkout(
      routineName: widget.routineName,
      exercises: _exercises,
      elapsedSecs: _elapsedSecs,
    ));
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String get _elapsed {
    final m = (_elapsedSecs ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _totalSets => _exercises.fold(0, (a, e) => a + e.sets.length);
  int get _doneSets  => _exercises.fold(0, (a, e) => a + e.sets.where((s) => s.isDone).length);

  void _handleSetComplete(int exIdx, int setIdx, bool done) {
    setState(() {
      final ex = _exercises[exIdx];
      final old = ex.sets[setIdx];
      ex.sets[setIdx] = SetRowData(
        index: old.index,
        type: old.type,
        weight: old.weight,
        reps: old.reps,
        prev: old.prev,
        isDone: done,
      );

      if (done) {
        _restSeconds = PrefsService.restSecs;
        _restKey = (_restKey ?? 0) + 1;
        final allDone = ex.sets.every((s) => s.isDone);
        if (allDone && exIdx < _exercises.length - 1) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _currentExIdx = exIdx + 1);
          });
        }
      } else {
        _restSeconds = null;
      }
    });
    _saveToPrefs();
  }

  void _updateWeight(int exIdx, int setIdx, double weight) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index, type: old.type,
        weight: weight, reps: old.reps, prev: old.prev, isDone: old.isDone,
      );
    });
  }

  void _updateReps(int exIdx, int setIdx, int reps) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index, type: old.type,
        weight: old.weight, reps: reps, prev: old.prev, isDone: old.isDone,
      );
    });
  }

  void _addExercise(WorkoutExercise ex) {
    setState(() {
      _exercises.add(ex);
      _currentExIdx = _exercises.length - 1;
    });
    _saveToPrefs();
  }

  void _removeExercise(int idx) {
    if (_exercises.length <= 1) return;
    setState(() {
      _exercises.removeAt(idx);
      if (_currentExIdx >= _exercises.length) {
        _currentExIdx = _exercises.length - 1;
      }
    });
    _saveToPrefs();
  }

  void _updateNotes(int exIdx, String notes) {
    setState(() => _exercises[exIdx].notes = notes);
    _saveToPrefs();
  }

  void _showExercisePicker() {
    setState(() => _showMenu = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePickerSheet(
        onSelect: (ex) {
          Navigator.of(context).pop();
          _addExercise(ex);
        },
      ),
    );
  }

  void _addSet(int exIdx) {
    setState(() {
      final ex = _exercises[exIdx];
      final last = ex.sets.isNotEmpty ? ex.sets.last : null;
      ex.sets = [
        ...ex.sets,
        SetRowData(
          index: ex.sets.length,
          type: SetType.normal,
          weight: last?.weight ?? 0,
          reps: last?.reps ?? 0,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final currentEx = _exercises[_currentExIdx];
    final upNext = _exercises.skip(_currentExIdx + 1).toList();

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar
                _TopBar(
                  routineName: widget.routineName,
                  elapsed: _elapsed,
                  doneSets: _doneSets,
                  totalSets: _totalSets,
                  onMenu: () => setState(() => _showMenu = !_showMenu),
                  c: c,
                ),

                // Rest timer
                if (_restSeconds != null)
                  RestTimerBanner(
                    key: ValueKey(_restKey),
                    initialSeconds: _restSeconds!,
                    onSkip: () => setState(() => _restSeconds = null),
                    onAdd: () => setState(() => _restSeconds = (_restSeconds ?? 0) + 15),
                  ),

                Expanded(
                  child: Column(
                    children: [
                      // Progress bar
                      SizedBox(
                        height: 3,
                        child: LinearProgressIndicator(
                          value: _totalSets > 0 ? _doneSets / _totalSets : 0,
                          backgroundColor: c.divider,
                          valueColor: AlwaysStoppedAnimation(c.accentIron),
                          minHeight: 3,
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current exercise card
                              _ExerciseCard(
                                exercise: currentEx,
                                onSetComplete: (setIdx, done) =>
                                    _handleSetComplete(_currentExIdx, setIdx, done),
                                onAddSet: () => _addSet(_currentExIdx),
                                onWeightChanged: (setIdx, w) =>
                                    _updateWeight(_currentExIdx, setIdx, w),
                                onRepsChanged: (setIdx, r) =>
                                    _updateReps(_currentExIdx, setIdx, r),
                                onNotesChanged: (notes) =>
                                    _updateNotes(_currentExIdx, notes),
                                onRemove: _exercises.length > 1
                                    ? () => _removeExercise(_currentExIdx)
                                    : null,
                                c: c,
                              ),

                              // Exercise nav chips
                              if (_exercises.length > 1)
                                _ExerciseNavChips(
                                  exercises: _exercises,
                                  currentIdx: _currentExIdx,
                                  onSelect: (i) =>
                                      setState(() => _currentExIdx = i),
                                  c: c,
                                ),

                              // Up next
                              if (upNext.isNotEmpty)
                                _UpNextSection(upNext: upNext.take(2).toList(), c: c),

                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky bottom
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    border: Border(top: BorderSide(color: c.divider)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PrimaryButton(
                      label: 'Finish Workout',
                      onPressed: _finishWorkout,
                    ),
                  ),
                ),
              ],
            ),

            // Menu overlay
            if (_showMenu)
              _MenuOverlay(
                onDismiss: () => setState(() => _showMenu = false),
                onCancel: _finishWorkout,
                onAddExercise: _showExercisePicker,
                c: c,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.routineName,
    required this.elapsed,
    required this.doneSets,
    required this.totalSets,
    required this.onMenu,
    required this.c,
  });
  final String routineName;
  final String elapsed;
  final int doneSets;
  final int totalSets;
  final VoidCallback onMenu;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineName,
                  style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 15,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 1),
                Text(
                  '$doneSets / $totalSets sets',
                  style: AppTypography.caption(c.textTertiary).copyWith(
                    fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              elapsed,
              style: AppTypography.displayM(c.accentIron).copyWith(
                fontSize: 15,
                fontFeatures: [const FontFeature.tabularFigures()],
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onMenu,
            child: SizedBox(
              width: 36, height: 36,
              child: Center(
                child: Text(
                  '⋯',
                  style: TextStyle(fontSize: 20, color: c.textTertiary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise Card ──────────────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onSetComplete,
    required this.onAddSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onNotesChanged,
    required this.c,
    this.onRemove,
  });

  final WorkoutExercise exercise;
  final void Function(int setIdx, bool done) onSetComplete;
  final VoidCallback onAddSet;
  final void Function(int setIdx, double weight) onWeightChanged;
  final void Function(int setIdx, int reps) onRepsChanged;
  final void Function(String notes) onNotesChanged;
  final VoidCallback? onRemove;
  final AppColors c;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late final TextEditingController _notesCtrl;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.exercise.notes);
    _showNotes = widget.exercise.notes.isNotEmpty;
  }

  @override
  void didUpdateWidget(_ExerciseCard old) {
    super.didUpdateWidget(old);
    if (old.exercise.id != widget.exercise.id) {
      _notesCtrl.text = widget.exercise.notes;
      _showNotes = widget.exercise.notes.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final exercise = widget.exercise;
    final firstActiveIdx = exercise.sets.indexWhere((s) => !s.isDone);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(left: BorderSide(color: c.accentIron, width: 3)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 18, letterSpacing: -0.2),
                      ),
                    ),
                    // Notes toggle
                    GestureDetector(
                      onTap: () => setState(() => _showNotes = !_showNotes),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Icon(
                          _showNotes
                              ? Icons.sticky_note_2_rounded
                              : Icons.sticky_note_2_outlined,
                          size: 18,
                          color: _showNotes ? c.accentIron : c.textTertiary,
                        ),
                      ),
                    ),
                    // Remove exercise
                    if (widget.onRemove != null)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: c.surfaceElevated,
                              title: Text('Remove ${exercise.name}?',
                                  style: AppTypography.titleM(c.textPrimary)),
                              content: Text('Remove this exercise from the workout.',
                                  style: AppTypography.bodyS(c.textSecondary)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel',
                                      style: AppTypography.bodyM(c.textSecondary)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    widget.onRemove!();
                                  },
                                  child: Text('Remove',
                                      style: AppTypography.bodyM(c.errorRose)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: c.textTertiary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${exercise.muscle} · ${exercise.equipment}',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 11),
                    ),
                    if (exercise.sets.isNotEmpty && exercise.sets.first.prev != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Last: ${exercise.sets.first.prev!.weight} ${PrefsService.unit} × ${exercise.sets.first.prev!.reps}',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontWeight: FontWeight.w600, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                // Notes field
                if (_showNotes) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesCtrl,
                    onChanged: widget.onNotesChanged,
                    maxLines: 2,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Add notes (form cues, tempo, RPE…)',
                      hintStyle: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 11, fontStyle: FontStyle.italic),
                      filled: true,
                      fillColor: c.surfaceHigh,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Column header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.divider.withValues(alpha: 0.13))),
            ),
            child: Row(
              children: const ['Set', 'Prev', 'Weight', 'Reps', ''].map((h) =>
                Expanded(
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),

          // Set rows
          ...List.generate(exercise.sets.length, (j) {
            final set = exercise.sets[j];
            final isActive = j == firstActiveIdx;
            return SetRow(
              key: ValueKey('${exercise.id}_$j'),
              data: set,
              isActive: isActive,
              onComplete: (done) => widget.onSetComplete(j, done),
              onWeightChanged: (w) => widget.onWeightChanged(j, w),
              onRepsChanged: (r) => widget.onRepsChanged(j, r),
            );
          }),

          // Add set
          GestureDetector(
            onTap: widget.onAddSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.divider),
                ),
              ),
              child: Text(
                '+ Add Set',
                textAlign: TextAlign.center,
                style: AppTypography.bodyS(c.textTertiary).copyWith(
                  fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise Nav Chips ─────────────────────────────────────
class _ExerciseNavChips extends StatelessWidget {
  const _ExerciseNavChips({
    required this.exercises,
    required this.currentIdx,
    required this.onSelect,
    required this.c,
  });
  final List<WorkoutExercise> exercises;
  final int currentIdx;
  final void Function(int) onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 0),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, i) {
          final ex = exercises[i];
          final allDone = ex.sets.every((s) => s.isDone);
          final isCurrent = i == currentIdx;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? c.accentIron
                    : allDone
                        ? c.successLime.withValues(alpha: 0.13)
                        : c.surfaceHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${allDone ? '✓ ' : ''}${ex.name.split(' ').first}',
                style: AppTypography.bodyS(
                  isCurrent ? Colors.white
                      : allDone ? c.successLime : c.textSecondary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Up Next Section ────────────────────────────────────────
class _UpNextSection extends StatelessWidget {
  const _UpNextSection({required this.upNext, required this.c});
  final List<WorkoutExercise> upNext;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'Up Next'),
          const SizedBox(height: AppSpacing.xs),
          ...upNext.map((ex) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ex.name,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
                  ),
                  Text(
                    '${ex.sets.length} sets',
                    style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ── Menu Overlay ───────────────────────────────────────────
class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.onDismiss,
    required this.onCancel,
    required this.onAddExercise,
    required this.c,
  });
  final VoidCallback onDismiss;
  final VoidCallback onCancel;
  final VoidCallback onAddExercise;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Add Exercise',    color: c.textPrimary, onTap: onAddExercise),
      (label: 'Add Note',        color: c.textPrimary, onTap: onDismiss),
      (label: 'Cancel Workout',  color: c.errorRose,   onTap: onCancel),
    ];

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.53),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 60, AppSpacing.md, 0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (i) {
                    final item = items[i];
                    return GestureDetector(
                      onTap: item.onTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          border: i < items.length - 1
                              ? Border(bottom: BorderSide(color: c.divider))
                              : null,
                        ),
                        child: Text(
                          item.label,
                          style: AppTypography.bodyM(item.color).copyWith(
                            fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WORKOUT SUMMARY SCREEN
// ══════════════════════════════════════════════════════════
class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({
    super.key,
    required this.workout,
    required this.newPRs,
    required this.onDone,
  });
  final CompletedWorkout workout;
  final List<({String exercise, double weight, int reps})> newPRs;
  final VoidCallback onDone;

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _statsCtrl;
  late AnimationController _prCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _statsFade;
  late Animation<double> _prFade;
  late Animation<Offset> _prSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _statsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _prCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
    _prFade = CurvedAnimation(parent: _prCtrl, curve: Curves.easeOut);
    _prSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _prCtrl, curve: Curves.easeOutCubic));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _statsCtrl.forward();
    });
    if (widget.newPRs.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _prCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _statsCtrl.dispose();
    _prCtrl.dispose();
    super.dispose();
  }

  String _motivationalLine() {
    final sets = widget.workout.doneSets;
    final mins = widget.workout.elapsedSecs ~/ 60;
    final prs = widget.newPRs.length;
    if (prs >= 3) return 'Legendary session. History was made today.';
    if (prs >= 1) return 'New personal record. You\'re getting stronger.';
    if (sets >= 20) return 'Massive volume. Your muscles noticed.';
    if (mins >= 75) return 'Long haul. Mental strength ✓';
    if (mins <= 35) return 'Short & intense. Quality over quantity.';
    return 'Another day, another session done.';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final w = widget.workout;
    final hasPRs = widget.newPRs.isNotEmpty;

    return Scaffold(
      backgroundColor: c.surface,
      body: Stack(
        children: [
          // Background gradient
          Positioned(
            top: 0, left: 0, right: 0, height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    c.accentIron.withValues(alpha: 0.12),
                    c.accentIron.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.xl,
                      AppSpacing.md, 0),
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: SlideTransition(
                        position: _heroSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.successLime.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: c.successLime.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                    size: 12, color: c.successLime),
                                  const SizedBox(width: 5),
                                  Text(
                                    'WORKOUT COMPLETE',
                                    style: AppTypography.caption(c.successLime)
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          letterSpacing: 0.8,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              w.routineName,
                              style: AppTypography.displayL(c.textPrimary).copyWith(
                                fontSize: 32,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _motivationalLine(),
                              style: AppTypography.bodyS(c.textSecondary).copyWith(
                                fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Stats strip
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.xl,
                      AppSpacing.md, 0),
                    child: FadeTransition(
                      opacity: _statsFade,
                      child: Row(
                        children: [
                          _SummaryStat(
                            value: '${w.elapsedSecs ~/ 60}',
                            unit: 'min',
                            label: 'Duration',
                            c: c,
                          ),
                          _SummaryStat(
                            value: w.totalVolume >= 1000
                                ? '${(w.totalVolume / 1000).toStringAsFixed(1)}k'
                                : w.totalVolume.toStringAsFixed(0),
                            unit: PrefsService.unit,
                            label: 'Volume',
                            c: c,
                          ),
                          _SummaryStat(
                            value: '${w.doneSets}',
                            unit: '',
                            label: 'Sets Done',
                            c: c,
                          ),
                          if (hasPRs)
                            _SummaryStat(
                              value: '${widget.newPRs.length}',
                              unit: '',
                              label: 'New PR${widget.newPRs.length > 1 ? 's' : ''}',
                              c: c,
                              highlight: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // New PRs
                if (hasPRs)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.xl,
                        AppSpacing.md, 0),
                      child: FadeTransition(
                        opacity: _prFade,
                        child: SlideTransition(
                          position: _prSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(label: 'Personal Records'),
                              const SizedBox(height: AppSpacing.xs),
                              ...widget.newPRs.take(4).map((pr) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        c.accentIronSoft,
                                        c.accentIron.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: c.accentIron.withValues(alpha: 0.35)),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: c.accentIron,
                                        ),
                                        child: const Center(
                                          child: Text('🏆',
                                            style: TextStyle(fontSize: 17)),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pr.exercise,
                                              style: AppTypography.titleM(
                                                c.textPrimary).copyWith(
                                                  fontSize: 13,
                                                  letterSpacing: -0.1),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              'New best: ${WeightUnit.format(pr.weight)} × ${pr.reps} reps',
                                              style: AppTypography.bodyS(
                                                c.textSecondary).copyWith(
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'NEW PR',
                                        style: AppTypography.caption(c.accentIron)
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                              letterSpacing: 0.7,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Exercise breakdown
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xl,
                    AppSpacing.md, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SectionHeader(label: 'Exercise Breakdown'),
                      const SizedBox(height: AppSpacing.xs),
                      ...w.exercises.map((ex) {
                        final done = ex.sets.where((s) => s.isDone).toList();
                        if (done.isEmpty) return const SizedBox.shrink();
                        final bestWeight = done
                            .map((s) => s.weight)
                            .reduce((a, b) => a > b ? a : b);
                        final totalReps = done.fold(0, (a, s) => a + s.reps);
                        final isNewPR = widget.newPRs
                            .any((pr) => pr.exercise == ex.name);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: BoxDecoration(
                              color: c.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isNewPR
                                    ? c.accentIron.withValues(alpha: 0.3)
                                    : c.divider.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            ex.name,
                                            style: AppTypography.titleM(
                                              c.textPrimary).copyWith(
                                                fontSize: 14,
                                                letterSpacing: -0.1),
                                          ),
                                          if (isNewPR) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: c.accentIron
                                                    .withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'PR',
                                                style: AppTypography.caption(
                                                  c.accentIron).copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 9,
                                                    letterSpacing: 0.5),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${done.length} set${done.length > 1 ? 's' : ''} · $totalReps total reps',
                                        style: AppTypography.bodyS(c.textTertiary)
                                            .copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      WeightUnit.format(bestWeight),
                                      style: AppTypography.displayM(c.accentIron)
                                          .copyWith(
                                            fontSize: 15,
                                            letterSpacing: -0.2,
                                            fontFeatures: [
                                              const FontFeature.tabularFigures()],
                                          ),
                                    ),
                                    Text(
                                      'top set',
                                      style: AppTypography.caption(c.textTertiary)
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Done button
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                MediaQuery.of(context).padding.bottom + AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    c.surface.withValues(alpha: 0),
                    c.surface,
                    c.surface,
                  ],
                ),
              ),
              child: PrimaryButton(
                label: 'Back to Home',
                onPressed: widget.onDone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.unit,
    required this.label,
    required this.c,
    this.highlight = false,
  });
  final String value;
  final String unit;
  final String label;
  final AppColors c;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: highlight
              ? c.accentIron.withValues(alpha: 0.08)
              : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: highlight
                ? c.accentIron.withValues(alpha: 0.3)
                : c.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.displayM(
                    highlight ? c.accentIron : c.textPrimary,
                  ).copyWith(
                    fontSize: 22,
                    letterSpacing: -0.6,
                    height: 1,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(
                      fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTypography.caption(
                highlight ? c.accentIron : c.textTertiary,
              ).copyWith(fontSize: 8, letterSpacing: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  EXERCISE PICKER SHEET
// ══════════════════════════════════════════════════════════
const kExerciseCatalogue = [
  // ── Chest ──────────────────────────────────────────
  (id:'bench',        name:'Bench Press',              muscle:'Chest',      equipment:'Barbell'),
  (id:'incline-bb',   name:'Incline Bench Press',      muscle:'Chest',      equipment:'Barbell'),
  (id:'incline',      name:'Incline DB Press',         muscle:'Chest',      equipment:'Dumbbell'),
  (id:'decline',      name:'Decline Press',            muscle:'Chest',      equipment:'Barbell'),
  (id:'db-fly',       name:'Dumbbell Fly',             muscle:'Chest',      equipment:'Dumbbell'),
  (id:'cable-fly',    name:'Cable Fly',                muscle:'Chest',      equipment:'Cable'),
  (id:'pec-deck',     name:'Pec Deck Machine',         muscle:'Chest',      equipment:'Machine'),
  (id:'dips',         name:'Dips',                     muscle:'Chest',      equipment:'Bodyweight'),
  (id:'pushup',       name:'Push-Up',                  muscle:'Chest',      equipment:'Bodyweight'),
  (id:'landmine-pp',  name:'Landmine Press',           muscle:'Chest',      equipment:'Barbell'),
  // ── Back ───────────────────────────────────────────
  (id:'deadlift',     name:'Deadlift',                 muscle:'Back',       equipment:'Barbell'),
  (id:'row',          name:'Barbell Row',              muscle:'Back',       equipment:'Barbell'),
  (id:'db-row',       name:'Dumbbell Row',             muscle:'Back',       equipment:'Dumbbell'),
  (id:'tbar-row',     name:'T-Bar Row',                muscle:'Back',       equipment:'Barbell'),
  (id:'pullup',       name:'Pull-Up',                  muscle:'Back',       equipment:'Bodyweight'),
  (id:'chinup',       name:'Chin-Up',                  muscle:'Back',       equipment:'Bodyweight'),
  (id:'lat-pull',     name:'Lat Pulldown',             muscle:'Back',       equipment:'Cable'),
  (id:'cable-row',    name:'Seated Cable Row',         muscle:'Back',       equipment:'Cable'),
  (id:'straight-arm', name:'Straight-Arm Pulldown',    muscle:'Back',       equipment:'Cable'),
  (id:'shrug',        name:'Barbell Shrug',            muscle:'Traps',      equipment:'Barbell'),
  (id:'face-pull',    name:'Face Pull',                muscle:'Rear Delt',  equipment:'Cable'),
  (id:'rev-fly',      name:'Reverse Fly',              muscle:'Rear Delt',  equipment:'Dumbbell'),
  // ── Shoulders ──────────────────────────────────────
  (id:'ohp',          name:'Overhead Press',           muscle:'Shoulders',  equipment:'Barbell'),
  (id:'db-ohp',       name:'DB Shoulder Press',        muscle:'Shoulders',  equipment:'Dumbbell'),
  (id:'arnold',       name:'Arnold Press',             muscle:'Shoulders',  equipment:'Dumbbell'),
  (id:'lat-raise',    name:'Lateral Raise',            muscle:'Shoulders',  equipment:'Dumbbell'),
  (id:'cable-lat',    name:'Cable Lateral Raise',      muscle:'Shoulders',  equipment:'Cable'),
  (id:'front-raise',  name:'Front Raise',              muscle:'Shoulders',  equipment:'Dumbbell'),
  (id:'upright-row',  name:'Upright Row',              muscle:'Shoulders',  equipment:'Barbell'),
  // ── Biceps ─────────────────────────────────────────
  (id:'bb-curl',      name:'Barbell Curl',             muscle:'Biceps',     equipment:'Barbell'),
  (id:'db-curl',      name:'Dumbbell Curl',            muscle:'Biceps',     equipment:'Dumbbell'),
  (id:'hammer',       name:'Hammer Curl',              muscle:'Biceps',     equipment:'Dumbbell'),
  (id:'preacher',     name:'Preacher Curl',            muscle:'Biceps',     equipment:'Barbell'),
  (id:'incline-curl', name:'Incline DB Curl',          muscle:'Biceps',     equipment:'Dumbbell'),
  (id:'cable-curl',   name:'Cable Curl',               muscle:'Biceps',     equipment:'Cable'),
  (id:'conc-curl',    name:'Concentration Curl',       muscle:'Biceps',     equipment:'Dumbbell'),
  // ── Triceps ────────────────────────────────────────
  (id:'tri-push',     name:'Tricep Pushdown',          muscle:'Triceps',    equipment:'Cable'),
  (id:'skull',        name:'Skullcrusher',             muscle:'Triceps',    equipment:'Barbell'),
  (id:'tri-dips',     name:'Tricep Dips',              muscle:'Triceps',    equipment:'Bodyweight'),
  (id:'cg-bench',     name:'Close-Grip Bench Press',   muscle:'Triceps',    equipment:'Barbell'),
  (id:'oh-tri-ext',   name:'Overhead Tricep Extension',muscle:'Triceps',    equipment:'Cable'),
  (id:'kickback',     name:'Tricep Kickback',          muscle:'Triceps',    equipment:'Dumbbell'),
  // ── Quads ──────────────────────────────────────────
  (id:'squat',        name:'Squat',                    muscle:'Quads',      equipment:'Barbell'),
  (id:'front-squat',  name:'Front Squat',              muscle:'Quads',      equipment:'Barbell'),
  (id:'hack-squat',   name:'Hack Squat',               muscle:'Quads',      equipment:'Machine'),
  (id:'leg-press',    name:'Leg Press',                muscle:'Quads',      equipment:'Machine'),
  (id:'leg-ext',      name:'Leg Extension',            muscle:'Quads',      equipment:'Machine'),
  (id:'bulgarian',    name:'Bulgarian Split Squat',    muscle:'Quads',      equipment:'Dumbbell'),
  (id:'goblet',       name:'Goblet Squat',             muscle:'Quads',      equipment:'Dumbbell'),
  // ── Hamstrings ─────────────────────────────────────
  (id:'rdl',          name:'Romanian Deadlift',        muscle:'Hamstrings', equipment:'Barbell'),
  (id:'sdl',          name:'Stiff-Leg Deadlift',       muscle:'Hamstrings', equipment:'Barbell'),
  (id:'leg-curl',     name:'Leg Curl',                 muscle:'Hamstrings', equipment:'Machine'),
  (id:'db-rdl',       name:'DB Romanian Deadlift',     muscle:'Hamstrings', equipment:'Dumbbell'),
  (id:'nordic',       name:'Nordic Curl',              muscle:'Hamstrings', equipment:'Bodyweight'),
  // ── Glutes ─────────────────────────────────────────
  (id:'hip-thrust',   name:'Hip Thrust',               muscle:'Glutes',     equipment:'Barbell'),
  (id:'lunge',        name:'Walking Lunge',            muscle:'Glutes',     equipment:'Dumbbell'),
  (id:'sumo-dl',      name:'Sumo Deadlift',            muscle:'Glutes',     equipment:'Barbell'),
  (id:'step-up',      name:'Step-Up',                  muscle:'Glutes',     equipment:'Dumbbell'),
  (id:'cable-kickback',name:'Cable Glute Kickback',    muscle:'Glutes',     equipment:'Cable'),
  (id:'glute-bridge', name:'Glute Bridge',             muscle:'Glutes',     equipment:'Bodyweight'),
  // ── Calves ─────────────────────────────────────────
  (id:'calf',         name:'Standing Calf Raise',      muscle:'Calves',     equipment:'Machine'),
  (id:'seated-calf',  name:'Seated Calf Raise',        muscle:'Calves',     equipment:'Machine'),
  (id:'donkey-calf',  name:'Donkey Calf Raise',        muscle:'Calves',     equipment:'Machine'),
  (id:'single-calf',  name:'Single-Leg Calf Raise',    muscle:'Calves',     equipment:'Bodyweight'),
  // ── Core ───────────────────────────────────────────
  (id:'plank',        name:'Plank',                    muscle:'Core',       equipment:'Bodyweight'),
  (id:'side-plank',   name:'Side Plank',               muscle:'Core',       equipment:'Bodyweight'),
  (id:'crunch',       name:'Crunch',                   muscle:'Core',       equipment:'Bodyweight'),
  (id:'leg-raise',    name:'Leg Raise',                muscle:'Core',       equipment:'Bodyweight'),
  (id:'ab-wheel',     name:'Ab Wheel Rollout',         muscle:'Core',       equipment:'Other'),
  (id:'cable-crunch', name:'Cable Crunch',             muscle:'Core',       equipment:'Cable'),
  (id:'russian-twist',name:'Russian Twist',            muscle:'Core',       equipment:'Bodyweight'),
  (id:'hollow-hold',  name:'Hollow Hold',              muscle:'Core',       equipment:'Bodyweight'),
  (id:'hanging-raise',name:'Hanging Leg Raise',        muscle:'Core',       equipment:'Bodyweight'),
  // ── Cardio / Other ─────────────────────────────────
  (id:'treadmill',    name:'Treadmill',                muscle:'Cardio',     equipment:'Machine'),
  (id:'rowing',       name:'Rowing Machine',           muscle:'Cardio',     equipment:'Machine'),
  (id:'bike',         name:'Stationary Bike',          muscle:'Cardio',     equipment:'Machine'),
  (id:'jump-rope',    name:'Jump Rope',                muscle:'Cardio',     equipment:'Other'),
  (id:'battle-rope',  name:'Battle Ropes',             muscle:'Cardio',     equipment:'Other'),
];

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key, required this.onSelect});
  final void Function(WorkoutExercise) onSelect;

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  String _query  = '';
  String _muscle = 'All';

  static const _muscleFilters = [
    'All', 'Chest', 'Back', 'Shoulders', 'Biceps',
    'Triceps', 'Quads', 'Hamstrings', 'Glutes',
    'Calves', 'Core', 'Cardio',
  ];

  List<({String id, String name, String muscle, String equipment})> get _filtered {
    var list = kExerciseCatalogue.toList();
    if (_muscle != 'All') {
      list = list.where((e) => e.muscle == _muscle).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.muscle.toLowerCase().contains(q) ||
          e.equipment.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  WorkoutExercise _buildExercise(
      ({String id, String name, String muscle, String equipment}) e) =>
      WorkoutExercise(
        id: '${e.id}-${DateTime.now().millisecondsSinceEpoch}',
        name: e.name, muscle: e.muscle, equipment: e.equipment,
        sets: [
          const SetRowData(index: 0, type: SetType.normal, weight: 0, reps: 0),
          const SetRowData(index: 1, type: SetType.normal, weight: 0, reps: 0),
          const SetRowData(index: 2, type: SetType.normal, weight: 0, reps: 0),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).extension<AppColors>()!;
    final filtered = _filtered;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          // Header + search
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 14, AppSpacing.md, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Add Exercise',
                      style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 18, letterSpacing: -0.2),
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length} exercises',
                      style: AppTypography.caption(c.textTertiary).copyWith(
                          fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: TextField(
                    autofocus: false,
                    style: AppTypography.bodyM(c.textPrimary).copyWith(
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by name or muscle…',
                      hintStyle: AppTypography.bodyM(c.textTertiary).copyWith(
                          fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: c.textTertiary, size: 18),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ],
            ),
          ),
          // Muscle filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _muscleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final m      = _muscleFilters[i];
                final active = _muscle == m;
                return GestureDetector(
                  onTap: () => setState(() => _muscle = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? c.accentIron
                          : c.surfaceHigh,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      m,
                      style: AppTypography.bodyS(
                        active ? Colors.white : c.textSecondary,
                      ).copyWith(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No exercises found',
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final ex = filtered[i];
                      return GestureDetector(
                        onTap: () => widget.onSelect(_buildExercise(ex)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 11),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: c.divider.withValues(alpha: 0.25)),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Muscle color dot
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _muscleColor(ex.muscle, c),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: AppTypography.bodyM(
                                              c.textPrimary)
                                          .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${ex.muscle} · ${ex.equipment}',
                                      style: AppTypography.bodyS(
                                              c.textTertiary)
                                          .copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.add_circle_outline_rounded,
                                  color: c.accentIron, size: 22),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static Color _muscleColor(String muscle, AppColors c) {
    return switch (muscle) {
      'Chest'      => const Color(0xFFEF4444),
      'Back'       => const Color(0xFF3B82F6),
      'Shoulders'  => const Color(0xFF8B5CF6),
      'Biceps'     => const Color(0xFFF59E0B),
      'Triceps'    => const Color(0xFFEC4899),
      'Quads'      => const Color(0xFF10B981),
      'Hamstrings' => const Color(0xFF06B6D4),
      'Glutes'     => const Color(0xFFD97706),
      'Calves'     => const Color(0xFF84CC16),
      'Traps'      => const Color(0xFF6366F1),
      'Rear Delt'  => const Color(0xFFA78BFA),
      'Core'       => c.accentIron,
      'Cardio'     => const Color(0xFF22C55E),
      _            => c.textTertiary,
    };
  }
}
