// ignore_for_file: dead_code, unused_element, unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/set_row.dart';
import '../widgets/rest_timer_banner.dart';
import '../widgets/velt_redesign_widgets.dart';
import '../widgets/plate_calculator.dart';
import '../data/exercise_library.dart';
import '../services/prefs_service.dart';
import '../services/workout_history_store.dart';
import '../utils/weight_unit.dart';
import '../models/workout.dart';
export '../models/workout.dart';

// ══════════════════════════════════════════════════════════
//  ACTIVE WORKOUT SCREEN
// ══════════════════════════════════════════════════════════
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.routineName,
    required this.onFinish,
    required this.onDiscard,
    this.exercises,
    this.initialElapsedSecs = 0,
  });

  final String routineName;
  final void Function(CompletedWorkout) onFinish;
  final VoidCallback onDiscard;
  final List<WorkoutExercise>? exercises;
  final int initialElapsedSecs;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late List<WorkoutExercise> _exercises;
  late String _workoutName;
  int? _restSeconds;
  int _elapsedSecs = 0;
  Timer? _elapsedTimer;
  int? _restKey;
  int _restCount = 0;
  int _totalRestSecs = 0;

  Timer? _autosaveTimer;
  final List<GlobalKey> _exerciseKeys = [];

  void _syncExerciseKeys() {
    while (_exerciseKeys.length < _exercises.length) {
      _exerciseKeys.add(GlobalKey());
    }
    while (_exerciseKeys.length > _exercises.length) {
      _exerciseKeys.removeLast();
    }
  }

  // PR celebration
  bool _prVisible = false;
  String _prExerciseName = '';
  double _prWeight = 0;
  int _prReps = 0;
  Timer? _prDismissTimer;

  @override
  void initState() {
    super.initState();
    _workoutName = widget.routineName;
    _elapsedSecs = widget.initialElapsedSecs;
    _exercises = widget.exercises ?? [];
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSecs++);
    });
    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveToPrefs();
    });
  }

  void _saveToPrefs() {
    final data = jsonEncode({
      'routineName': _workoutName,
      'exercises': _exercises.map((e) => e.toJson()).toList(),
      'elapsedSecs': _elapsedSecs,
    });
    PrefsService.saveActiveWorkout(data);
  }

  void _finishWorkout() {
    _elapsedTimer?.cancel();
    _autosaveTimer?.cancel();
    PrefsService.clearActiveWorkout();
    widget.onFinish(CompletedWorkout(
      routineName: _workoutName,
      exercises: _exercises,
      elapsedSecs: _elapsedSecs,
      avgRestSecs: _restCount > 0 ? _totalRestSecs ~/ _restCount : 0,
    ));
  }

  void _discardWorkout() {
    final c = Theme.of(context).extension<AppColors>()!;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Discard this workout?',
            style: AppTypography.titleM(c.textPrimary)),
        content: Text(
            'Your logged sets won\'t be saved. This can\'t be undone.',
            style: AppTypography.bodyS(c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Going',
                style: AppTypography.bodyM(c.textPrimary)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard',
                style: AppTypography.bodyM(c.errorRose)
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _elapsedTimer?.cancel();
        _autosaveTimer?.cancel();
        widget.onDiscard();
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _autosaveTimer?.cancel();
    _prDismissTimer?.cancel();
    super.dispose();
  }

  String get _elapsed {
    final h = (_elapsedSecs ~/ 3600).toString().padLeft(2, '0');
    final m = ((_elapsedSecs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSecs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  int get _totalSets => _exercises.fold(0, (a, e) => a + e.sets.length);
  int get _doneSets =>
      _exercises.fold(0, (a, e) => a + e.sets.where((s) => s.isDone).length);
  double get _liveVolume => _exercises.fold(
      0.0,
      (a, e) => a +
          e.sets
              .where((s) => s.isDone && s.weight > 0)
              .fold(0.0, (b, s) => b + s.weight * s.reps));
  bool get _allDone => _totalSets > 0 && _doneSets == _totalSets;

  void _handleSetComplete(int exIdx, int setIdx, bool done) {
    bool triggerPR = false;
    String prExName = '';
    double prW = 0;
    int prR = 0;

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
        rpe: old.rpe,
      );
      if (done) {
        _restSeconds = PrefsService.restSecs;
        _restKey = (_restKey ?? 0) + 1;
        _restCount++;
        _totalRestSecs += PrefsService.restSecs;

        if (old.weight > 0) {
          final prEntry = WorkoutHistoryStore.allTimePRs[ex.name];
          if (prEntry == null || old.weight > prEntry.weight) {
            triggerPR = true;
            prExName = ex.name;
            prW = old.weight;
            prR = old.reps;
          }
        }
      } else {
        _restSeconds = null;
      }
    });

    if (triggerPR) _showPRCelebration(prExName, prW, prR);
    _saveToPrefs();
  }

  void _showPRCelebration(String exerciseName, double weight, int reps) {
    HapticFeedback.heavyImpact();
    _prDismissTimer?.cancel();
    setState(() {
      _prVisible = true;
      _prExerciseName = exerciseName;
      _prWeight = weight;
      _prReps = reps;
    });
    _prDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _prVisible = false);
    });
  }

  void _updateWeight(int exIdx, int setIdx, double weight) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index,
        type: old.type,
        weight: weight,
        reps: old.reps,
        prev: old.prev,
        isDone: old.isDone,
        rpe: old.rpe,
      );
    });
    _saveToPrefs();
  }

  void _updateReps(int exIdx, int setIdx, int reps) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index,
        type: old.type,
        weight: old.weight,
        reps: reps,
        prev: old.prev,
        isDone: old.isDone,
        rpe: old.rpe,
      );
    });
    _saveToPrefs();
  }

  void _updateSetType(int exIdx, int setIdx, SetType type) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index,
        type: type,
        weight: old.weight,
        reps: old.reps,
        prev: old.prev,
        isDone: old.isDone,
        rpe: old.rpe,
      );
    });
    _saveToPrefs();
  }

  void _updateRpe(int exIdx, int setIdx, double? rpe) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index,
        type: old.type,
        weight: old.weight,
        reps: old.reps,
        prev: old.prev,
        isDone: old.isDone,
        rpe: rpe,
      );
    });
    _saveToPrefs();
  }

  void _removeSet(int exIdx, int setIdx) {
    final ex = _exercises[exIdx];
    if (ex.sets.length <= 1) return;
    final removed = ex.sets[setIdx];
    setState(() {
      final newSets = List<SetRowData>.from(ex.sets)..removeAt(setIdx);
      ex.sets = newSets
          .asMap()
          .entries
          .map((e) => SetRowData(
                index: e.key,
                type: e.value.type,
                weight: e.value.weight,
                reps: e.value.reps,
                prev: e.value.prev,
                isDone: e.value.isDone,
              ))
          .toList();
    });
    _saveToPrefs();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Set removed'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted) return;
            final ex2 = _exercises[exIdx];
            setState(() {
              final newSets = List<SetRowData>.from(ex2.sets)
                ..insert(setIdx.clamp(0, ex2.sets.length), removed);
              ex2.sets = newSets
                  .asMap()
                  .entries
                  .map((e) => SetRowData(
                        index: e.key,
                        type: e.value.type,
                        weight: e.value.weight,
                        reps: e.value.reps,
                        prev: e.value.prev,
                        isDone: e.value.isDone,
                      ))
                  .toList();
            });
            _saveToPrefs();
          },
        ),
      ),
    );
  }

  void _reorderSet(int exIdx, int oldIndex, int newIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final ex = _exercises[exIdx];
      final moved = ex.sets.removeAt(oldIndex);
      ex.sets.insert(newIndex, moved);
      ex.sets = ex.sets
          .asMap()
          .entries
          .map((e) => SetRowData(
                index: e.key,
                type: e.value.type,
                weight: e.value.weight,
                reps: e.value.reps,
                prev: e.value.prev,
                isDone: e.value.isDone,
              ))
          .toList();
    });
    _saveToPrefs();
  }

  void _addExercises(List<WorkoutExercise> list) {
    setState(() => _exercises.addAll(list));
    _saveToPrefs();
  }

  void _removeExercise(int idx) {
    if (_exercises.length <= 1) return;
    setState(() => _exercises.removeAt(idx));
    _saveToPrefs();
  }

  /// Toggle superset linkage between this exercise and the next one.
  /// If already in a superset, splits them apart.
  void _toggleSuperset(int idx) {
    if (idx >= _exercises.length - 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      final cur = _exercises[idx];
      final next = _exercises[idx + 1];
      if (cur.supersetId != null && cur.supersetId == next.supersetId) {
        // Break apart
        cur.supersetId = null;
        next.supersetId = null;
      } else {
        final id = 'ss_${DateTime.now().millisecondsSinceEpoch}';
        cur.supersetId = id;
        next.supersetId = id;
      }
    });
    _saveToPrefs();
  }

  /// Returns "A1", "A2"... letter+index for the given exercise based on supersets.
  String? _supersetLabel(int idx) {
    final ex = _exercises[idx];
    if (ex.supersetId == null) return null;
    // Find letter — A for first group, B for second, etc.
    final groupIds = <String>[];
    for (final e in _exercises) {
      if (e.supersetId != null && !groupIds.contains(e.supersetId)) {
        groupIds.add(e.supersetId!);
      }
    }
    final groupIdx = groupIds.indexOf(ex.supersetId!);
    if (groupIdx < 0) return null;
    final letter = String.fromCharCode(65 + groupIdx); // 65='A'
    // Position within group
    final inGroup = <int>[];
    for (int i = 0; i < _exercises.length; i++) {
      if (_exercises[i].supersetId == ex.supersetId) inGroup.add(i);
    }
    final pos = inGroup.indexOf(idx) + 1;
    return '$letter$pos';
  }

  void _swapExercise(int idx, VeltExercise newEx) {
    HapticFeedback.mediumImpact();
    setState(() {
      final old = _exercises[idx];
      _exercises[idx] = WorkoutExercise(
        id: newEx.id,
        name: newEx.name,
        muscle: newEx.muscle,
        equipment: newEx.equipment,
        notes: old.notes,
        // Keep the sets — preserve set count + weights + done state
        sets: old.sets,
      );
    });
    _saveToPrefs();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('Swapped to ${newEx.name}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _reorderExercise(int oldIndex, int newIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final ex = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, ex);
    });
    _saveToPrefs();
  }

  void _updateNotes(int exIdx, String notes) {
    setState(() => _exercises[exIdx].notes = notes);
    _saveToPrefs();
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePickerSheet(
        onAdd: (list) {
          Navigator.of(context).pop();
          _addExercises(list);
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
    _syncExerciseKeys();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discardWorkout();
      },
      child: VeltStaticScreen(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                  child: _ProActiveHeader(
                    initialName: _workoutName,
                    elapsed: _elapsed,
                    doneSets: _doneSets,
                    totalSets: _totalSets,
                    liveVolume: _liveVolume,
                    allDone: _allDone,
                    onNameChanged: (v) => setState(() => _workoutName = v),
                    onDiscard: _discardWorkout,
                    onFinish: _finishWorkout,
                  ),
                ),
                if (_restSeconds != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                    child: RestTimerBanner(
                      key: ValueKey(_restKey),
                      initialSeconds: _restSeconds!,
                      onSkip: () => setState(() => _restSeconds = null),
                      onAdd: () {},
                    ),
                  ),
                if (_exercises.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          final ex = _exercises[i];
                          final total = ex.sets.length;
                          final done =
                              ex.sets.where((s) => s.isDone).length;
                          final allDone =
                              total > 0 && done == total;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              final k = _exerciseKeys.length > i
                                  ? _exerciseKeys[i]
                                  : null;
                              final ctx = k?.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration:
                                      const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  alignment: 0,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: allDone
                                    ? c.successLime.withValues(alpha: .15)
                                    : c.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: allDone
                                      ? c.successLime.withValues(alpha: .5)
                                      : c.divider,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: allDone
                                          ? c.successLime
                                          : c.surfaceHigh,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: allDone
                                            ? (c.successLime
                                                        .computeLuminance() >
                                                    .55
                                                ? c.ink
                                                : Colors.white)
                                            : c.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 110),
                                    child: Text(
                                      ex.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: c.textPrimary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$done/$total',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: c.textTertiary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: _exercises.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Center(
                            child: VeltPanel(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const VeltLabel('No exercises yet'),
                                  const SizedBox(height: 14),
                                  VeltButton(
                                    label: 'Add exercise',
                                    onTap: _showExercisePicker,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 92),
                          itemCount: _exercises.length,
                          onReorder: _reorderExercise,
                          proxyDecorator: (child, index, animation) =>
                              Material(color: Colors.transparent, child: child),
                          itemBuilder: (context, i) => KeyedSubtree(
                            key: ValueKey(_exercises[i].id),
                            child: Container(
                              key: i < _exerciseKeys.length
                                  ? _exerciseKeys[i]
                                  : null,
                              child: _ExerciseCard(
                            exercise: _exercises[i],
                            onSetComplete: (setIdx, done) =>
                                _handleSetComplete(i, setIdx, done),
                            onAddSet: () => _addSet(i),
                            onWeightChanged: (setIdx, w) =>
                                _updateWeight(i, setIdx, w),
                            onRepsChanged: (setIdx, r) =>
                                _updateReps(i, setIdx, r),
                            onNotesChanged: (notes) => _updateNotes(i, notes),
                            onRemove: _exercises.length > 1
                                ? () => _removeExercise(i)
                                : null,
                            onRemoveSet: (setIdx) => _removeSet(i, setIdx),
                            onReorderSet: (old, newIdx) =>
                                _reorderSet(i, old, newIdx),
                            onTypeChanged: (setIdx, type) =>
                                _updateSetType(i, setIdx, type),
                            onRpeChanged: (setIdx, rpe) =>
                                _updateRpe(i, setIdx, rpe),
                            onSwap: (newEx) => _swapExercise(i, newEx),
                            onToggleSuperset: i < _exercises.length - 1
                                ? () => _toggleSuperset(i)
                                : null,
                            supersetLabel: _supersetLabel(i),
                            inSuperset:
                                _exercises[i].supersetId != null &&
                                    i < _exercises.length - 1 &&
                                    _exercises[i].supersetId ==
                                        _exercises[i + 1].supersetId,
                            c: c,
                          ),
                            ),
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border(top: BorderSide(color: c.divider)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: VeltButton(
                            label: '+ Add exercise',
                            secondary: true,
                            onTap: _showExercisePicker,
                          ),
                        ),
                        if (_allDone) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: VeltButton(
                              label: 'Finish workout',
                              onTap: _finishWorkout,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_prVisible)
              Positioned.fill(
                child: _PRCelebrationOverlay(
                  exerciseName: _prExerciseName,
                  weight: _prWeight,
                  reps: _prReps,
                  onDismiss: () {
                    _prDismissTimer?.cancel();
                    setState(() => _prVisible = false);
                  },
                  c: c,
                ),
              ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discardWorkout();
      },
      child: Scaffold(
        backgroundColor: c.surface,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar — editable name, HH:MM:SS timer, Finish button
                  _TopBar(
                    initialName: _workoutName,
                    elapsed: _elapsed,
                    onNameChanged: (v) => setState(() => _workoutName = v),
                    onFinish: _finishWorkout,
                    c: c,
                  ),

                  // Rest timer banner with circular ring
                  if (_restSeconds != null)
                    RestTimerBanner(
                      key: ValueKey(_restKey),
                      initialSeconds: _restSeconds!,
                      onSkip: () => setState(() => _restSeconds = null),
                      onAdd: () {},
                    ),

                  // Progress bar (2px, matches JSX)
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      value: _totalSets > 0 ? _doneSets / _totalSets : 0,
                      backgroundColor: c.divider,
                      valueColor: AlwaysStoppedAnimation(c.accentIron),
                      minHeight: 2,
                    ),
                  ),

                  // ALL exercises — long-press drag to reorder
                  Expanded(
                    child: _exercises.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fitness_center_outlined,
                                      size: 44,
                                      color: c.textTertiary
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No exercises yet',
                                    style: AppTypography.titleS(c.textPrimary)
                                        .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first movement to start logging.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyS(c.textTertiary)
                                        .copyWith(fontSize: 13, height: 1.45),
                                  ),
                                  const SizedBox(height: 24),
                                  PrimaryButton(
                                    label: 'Add Exercise',
                                    onPressed: _showExercisePicker,
                                    width: 200,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                                AppSpacing.md, AppSpacing.md, 100),
                            itemCount: _exercises.length,
                            onReorder: _reorderExercise,
                            proxyDecorator: (child, index, animation) =>
                                Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: child,
                            ),
                            itemBuilder: (context, i) => Padding(
                              key: ValueKey(_exercises[i].id),
                              padding: EdgeInsets.only(
                                  bottom: i < _exercises.length - 1 ? 16 : 0),
                              child: _ExerciseCard(
                                exercise: _exercises[i],
                                onSetComplete: (setIdx, done) =>
                                    _handleSetComplete(i, setIdx, done),
                                onAddSet: () => _addSet(i),
                                onWeightChanged: (setIdx, w) =>
                                    _updateWeight(i, setIdx, w),
                                onRepsChanged: (setIdx, r) =>
                                    _updateReps(i, setIdx, r),
                                onNotesChanged: (notes) =>
                                    _updateNotes(i, notes),
                                onRemove: _exercises.length > 1
                                    ? () => _removeExercise(i)
                                    : null,
                                onRemoveSet: (setIdx) => _removeSet(i, setIdx),
                                onReorderSet: (old, newIdx) =>
                                    _reorderSet(i, old, newIdx),
                                onTypeChanged: (setIdx, type) =>
                                    _updateSetType(i, setIdx, type),
                                c: c,
                              ),
                            ),
                          ),
                  ),

                  // Bottom: ghost "+ Add Exercise" button (matches JSX)
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 10, AppSpacing.md, 14),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border(top: BorderSide(color: c.divider)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: GhostButton(
                        label: '+ Add Exercise',
                        onPressed: _showExercisePicker,
                        height: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PR Celebration overlay — rendered above everything
            if (_prVisible)
              _PRCelebrationOverlay(
                exerciseName: _prExerciseName,
                weight: _prWeight,
                reps: _prReps,
                onDismiss: () {
                  _prDismissTimer?.cancel();
                  setState(() => _prVisible = false);
                },
                c: c,
              ),
          ],
        ),
      ),
    );
  }
}

// ── New, redesigned active workout header ──────────────────
class _ProActiveHeader extends StatefulWidget {
  const _ProActiveHeader({
    required this.initialName,
    required this.elapsed,
    required this.doneSets,
    required this.totalSets,
    required this.liveVolume,
    required this.allDone,
    required this.onNameChanged,
    required this.onDiscard,
    required this.onFinish,
  });

  final String initialName;
  final String elapsed;
  final int doneSets;
  final int totalSets;
  final double liveVolume;
  final bool allDone;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onDiscard;
  final VoidCallback onFinish;

  @override
  State<_ProActiveHeader> createState() => _ProActiveHeaderState();
}

class _ProActiveHeaderState extends State<_ProActiveHeader> {
  late final TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void didUpdateWidget(covariant _ProActiveHeader old) {
    super.didUpdateWidget(old);
    if (!_editing &&
        old.initialName != widget.initialName &&
        _controller.text != widget.initialName) {
      _controller.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final v = _controller.text.trim();
    widget.onNameChanged(v.isEmpty ? widget.initialName : v);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final progress =
        widget.totalSets > 0 ? widget.doneSets / widget.totalSets : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.surfaceElevated,
            Color.lerp(c.surfaceElevated, c.accentIron, .08)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: c.surface.computeLuminance() > .5 ? .06 : .25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: discard X · live dot+timer · finish CTA
          Row(
            children: [
              GestureDetector(
                onTap: widget.onDiscard,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.divider),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.close_rounded,
                      color: c.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _LiveTimerPill(elapsed: widget.elapsed, c: c)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onFinish,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: widget.allDone
                        ? c.successLime
                        : c.accentIron.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.allDone
                          ? c.successLime
                          : c.accentIron.withValues(alpha: .45),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.allDone
                            ? Icons.check_rounded
                            : Icons.flag_rounded,
                        size: 15,
                        color: widget.allDone
                            ? (c.successLime.computeLuminance() > .55
                                ? c.ink
                                : Colors.white)
                            : c.accentIron,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.allDone ? 'Finish' : 'Finish',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: widget.allDone
                              ? (c.successLime.computeLuminance() > .55
                                  ? c.ink
                                  : Colors.white)
                              : c.accentIron,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Workout name — big editable
          if (_editing)
            TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (_) => _commit(),
              onEditingComplete: _commit,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.textPrimary,
                fontSize: 24,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                hintText: 'Workout name',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textTertiary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _editing = true),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _controller.text.isEmpty
                          ? 'Workout name'
                          : _controller.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_outlined,
                      color: c.textTertiary, size: 14),
                ],
              ),
            ),
          const SizedBox(height: 14),
          // Stats strip
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  label: 'SETS',
                  value: '${widget.doneSets}/${widget.totalSets}',
                  c: c,
                ),
              ),
              Container(width: 1, height: 32, color: c.divider),
              Expanded(
                child: _StatBlock(
                  label: 'VOLUME',
                  value: _shortVolume(widget.liveVolume),
                  c: c,
                ),
              ),
              Container(width: 1, height: 32, color: c.divider),
              Expanded(
                child: _StatBlock(
                  label: 'COMPLETION',
                  value: '${(progress * 100).round()}%',
                  c: c,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: c.surfaceHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.allDone ? c.successLime : c.accentIron,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _shortVolume(double v) {
  if (v <= 0) return '0';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v.toStringAsFixed(0);
}

class _LiveTimerPill extends StatelessWidget {
  const _LiveTimerPill({required this.elapsed, required this.c});
  final String elapsed;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentIron,
              boxShadow: [
                BoxShadow(
                  color: c.accentIron.withValues(alpha: .6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            elapsed,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.c,
  });
  final String label;
  final String value;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            color: c.textPrimary,
            fontSize: 17,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: c.textTertiary,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Top Bar (stateful — editable name) ─────────────────────
class _TopBar extends StatefulWidget {
  const _TopBar({
    required this.initialName,
    required this.elapsed,
    required this.onNameChanged,
    required this.onFinish,
    required this.c,
  });
  final String initialName;
  final String elapsed;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onFinish;
  final AppColors c;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _done() {
    setState(() => _editing = false);
    final v = _ctrl.text.trim();
    widget.onNameChanged(v.isNotEmpty ? v : widget.initialName);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // Editable workout name
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    autofocus: true,
                    onSubmitted: (_) => _done(),
                    onEditingComplete: _done,
                    style: AppTypography.titleM(c.textPrimary)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: c.surfaceHigh,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        borderSide: BorderSide(color: c.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        borderSide: BorderSide(color: c.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        borderSide: BorderSide(color: c.divider),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: Text(
                      _ctrl.text,
                      style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Live session indicator + HH:MM:SS timer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accentIron,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.elapsed,
                style: AppTypography.displayM(c.accentIron).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [const FontFeature.tabularFigures()],
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          // Finish button — amber pill for clear affordance and tap target
          GestureDetector(
            onTap: widget.onFinish,
            child: Container(
              constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.accentIron.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                    color: c.accentIron.withValues(alpha: 0.40), width: 0.5),
              ),
              child: Center(
                child: Text(
                  'Finish',
                  style: AppTypography.bodyS(c.accentIron).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1),
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
    super.key,
    required this.exercise,
    required this.onSetComplete,
    required this.onAddSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onNotesChanged,
    required this.c,
    this.onRemove,
    this.onRemoveSet,
    this.onReorderSet,
    this.onTypeChanged,
    this.onSwap,
    this.onToggleSuperset,
    this.onRpeChanged,
    this.supersetLabel,
    this.inSuperset = false,
  });

  final WorkoutExercise exercise;
  final void Function(int setIdx, bool done) onSetComplete;
  final VoidCallback onAddSet;
  final void Function(int setIdx, double weight) onWeightChanged;
  final void Function(int setIdx, int reps) onRepsChanged;
  final void Function(String notes) onNotesChanged;
  final VoidCallback? onRemove;
  final void Function(int setIdx)? onRemoveSet;
  final void Function(int oldIdx, int newIdx)? onReorderSet;
  final void Function(int setIdx, SetType type)? onTypeChanged;
  final void Function(VeltExercise newExercise)? onSwap;
  final void Function(int setIdx, double? rpe)? onRpeChanged;
  final VoidCallback? onToggleSuperset;
  final String? supersetLabel;
  final bool inSuperset;
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
    final doneCount = exercise.sets.where((s) => s.isDone).length;
    final totalSets = exercise.sets.length;
    final allDone = doneCount == totalSets && totalSets > 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          border: Border.all(color: c.divider, width: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.supersetLabel != null) ...[
                        Container(
                          width: 28,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c.accentIron.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: c.accentIron.withValues(alpha: .45)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.supersetLabel!,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: c.accentIron,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textPrimary,
                            fontSize: 18,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Set progress badge
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: allDone
                              ? c.successLime.withValues(alpha: 0.12)
                              : c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '$doneCount / $totalSets',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: allDone ? c.successLime : c.textTertiary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      // Notes toggle
                      GestureDetector(
                        onTap: () => setState(() => _showNotes = !_showNotes),
                        child: SizedBox(
                          width: 36,
                          height: 44,
                          child: Icon(
                            _showNotes
                                ? Icons.sticky_note_2_rounded
                                : Icons.sticky_note_2_outlined,
                            size: 18,
                            color: _showNotes ? c.accentIron : c.textTertiary,
                          ),
                        ),
                      ),
                      // Plate calculator (only for barbell/dumbbell)
                      if (_supportsPlates(exercise.equipment))
                        GestureDetector(
                          onTap: () {
                            final lastWeight = exercise.sets
                                .map((s) => s.weight)
                                .where((w) => w > 0)
                                .lastOrNull;
                            showPlateCalculator(
                              context,
                              targetWeight: lastWeight ?? 60,
                            );
                          },
                          child: SizedBox(
                            width: 36,
                            height: 44,
                            child: Icon(
                              Icons.calculate_outlined,
                              size: 18,
                              color: c.textTertiary,
                            ),
                          ),
                        ),
                      // Info (form cues)
                      GestureDetector(
                        onTap: () => _showExerciseInfo(context, exercise),
                        child: SizedBox(
                          width: 32,
                          height: 44,
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                      // Swap exercise
                      if (widget.onSwap != null)
                        GestureDetector(
                          onTap: () => _showSwapSheet(
                              context, exercise, widget.onSwap!),
                          child: SizedBox(
                            width: 32,
                            height: 44,
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              size: 19,
                              color: c.textTertiary,
                            ),
                          ),
                        ),
                      // Superset link toggle
                      if (widget.onToggleSuperset != null)
                        GestureDetector(
                          onTap: widget.onToggleSuperset,
                          child: SizedBox(
                            width: 32,
                            height: 44,
                            child: Icon(
                              widget.inSuperset
                                  ? Icons.link_rounded
                                  : Icons.link_off_rounded,
                              size: 18,
                              color: widget.inSuperset
                                  ? c.accentIron
                                  : c.textTertiary,
                            ),
                          ),
                        ),
                      // Remove exercise button
                      if (widget.onRemove != null)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: c.surfaceElevated,
                                title: Text('Remove ${exercise.name}?',
                                    style: AppTypography.titleM(c.textPrimary)),
                                content: Text(
                                    'Remove this exercise from the workout.',
                                    style:
                                        AppTypography.bodyS(c.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel',
                                        style: AppTypography.bodyM(
                                            c.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      widget.onRemove!();
                                    },
                                    child: Text('Remove',
                                        style:
                                            AppTypography.bodyM(c.errorRose)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 36,
                            height: 44,
                            child: Icon(Icons.close_rounded,
                                size: 16, color: c.textTertiary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _ExPill(label: exercise.muscle, c: c),
                      const SizedBox(width: 4),
                      _ExPill(label: exercise.equipment, c: c),
                    ],
                  ),
                  // Notes field
                  if (_showNotes) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      onChanged: widget.onNotesChanged,
                      maxLines: 2,
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Add notes (form cues, tempo, RPE…)',
                        hintStyle: AppTypography.caption(c.textTertiary)
                            .copyWith(
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

            // Column header — matches SetRow grid: 32 | 1fr | 80 | 80 | 44
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 7),
              decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: c.divider.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text('SET',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: c.textTertiary,
                            letterSpacing: 1.4)),
                  ),
                  Expanded(
                    child: Text('LAST',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: c.textTertiary,
                            letterSpacing: 1.4)),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text('WEIGHT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: c.textTertiary,
                            letterSpacing: 1.4)),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text('REPS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: c.textTertiary,
                            letterSpacing: 1.4)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Set rows — swipe left to delete, long-press to reorder
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: widget.onReorderSet ?? (_, __) {},
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                elevation: 0,
                child: child,
              ),
              itemCount: exercise.sets.length,
              itemBuilder: (context, j) {
                final set = exercise.sets[j];
                final isActive = j == firstActiveIdx;
                final prEntry = WorkoutHistoryStore.allTimePRs[exercise.name];
                final canDelete = exercise.sets.length > 1;
                return Dismissible(
                  key: ValueKey('${exercise.id}_set_${j}_${set.type.index}'),
                  direction: canDelete
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    color: c.errorRose.withValues(alpha: 0.12),
                    child: Icon(Icons.delete_outline_rounded,
                        color: c.errorRose, size: 20),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.mediumImpact();
                    widget.onRemoveSet?.call(j);
                  },
                  child: SetRow(
                    key: ValueKey('row_${exercise.id}_$j'),
                    data: set,
                    isActive: isActive,
                    prWeight: prEntry?.weight,
                    onComplete: (done) => widget.onSetComplete(j, done),
                    onWeightChanged: (w) => widget.onWeightChanged(j, w),
                    onRepsChanged: (r) => widget.onRepsChanged(j, r),
                    onTypeChanged: (t) => widget.onTypeChanged?.call(j, t),
                    onRpeChanged: (rpe) => widget.onRpeChanged?.call(j, rpe),
                  ),
                );
              },
            ),

            // Add set — proper button with optional warmup shortcut
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.divider)),
                color: c.surfaceElevated,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onAddSet();
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: c.accentIron.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: c.accentIron.withValues(alpha: .4)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 18, color: c.accentIron),
                            const SizedBox(width: 6),
                            Text(
                              'Add Set',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: c.accentIron,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onAddSet();
                        // Mark new last set as warmup
                        Future.microtask(() {
                          final last = exercise.sets.length - 1;
                          widget.onTypeChanged?.call(last, SetType.warmup);
                        });
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.divider),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.whatshot_rounded,
                                size: 15, color: c.textSecondary),
                            const SizedBox(width: 5),
                            Text(
                              'Warmup',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: c.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline pill for muscle/equipment labels ─────────────────
bool _supportsPlates(String equipment) =>
    equipment.toLowerCase().contains('barbell') ||
    equipment.toLowerCase().contains('dumbbell');

void _showSwapSheet(
  BuildContext context,
  WorkoutExercise current,
  void Function(VeltExercise) onSwap,
) {
  final c = Theme.of(context).extension<AppColors>()!;
  HapticFeedback.selectionClick();
  // Filter to same muscle first, fallback to all
  final sameMuscle = kExerciseLibrary
      .where((e) =>
          e.muscle.toLowerCase() == current.muscle.toLowerCase() &&
          e.name != current.name)
      .toList();
  final others = kExerciseLibrary
      .where((e) =>
          e.muscle.toLowerCase() != current.muscle.toLowerCase() &&
          e.name != current.name)
      .toList();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Swap exercise',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Replace ${current.name}. Logged sets and weights are preserved.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                children: [
                  if (sameMuscle.isNotEmpty) ...[
                    Text('SAME MUSCLE (${current.muscle.toUpperCase()})',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: c.accentIron,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        )),
                    const SizedBox(height: 8),
                    for (final e in sameMuscle)
                      _SwapRow(
                          exercise: e,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onSwap(e);
                          },
                          c: c),
                  ],
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('OTHER MUSCLES',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: c.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        )),
                    const SizedBox(height: 8),
                    for (final e in others.take(30))
                      _SwapRow(
                          exercise: e,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onSwap(e);
                          },
                          c: c),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SwapRow extends StatelessWidget {
  const _SwapRow({
    required this.exercise,
    required this.onTap,
    required this.c,
  });
  final VeltExercise exercise;
  final VoidCallback onTap;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: c.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.1,
                          )),
                      const SizedBox(height: 2),
                      Text(
                          '${exercise.muscle} • ${exercise.equipment} • ${exercise.mechanic}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.swap_horiz_rounded,
                    color: c.accentIron, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showExerciseInfo(BuildContext context, WorkoutExercise we) {
  final c = Theme.of(context).extension<AppColors>()!;
  final lib = exerciseByName(we.name);
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, 16, AppSpacing.screenH, 24),
                children: [
                  Text(we.name,
                      style: AppTypography.displayM(c.textPrimary)
                          .copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    '${we.muscle} • ${we.equipment}',
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (lib == null)
                    Text(
                      'No detailed coaching tips for this exercise yet.',
                      style: AppTypography.bodyM(c.textTertiary),
                    )
                  else ...[
                    Text('HOW TO',
                        style: AppTypography.caption(c.textSecondary)
                            .copyWith(letterSpacing: 1.4)),
                    const SizedBox(height: 8),
                    for (int i = 0; i < lib.instructions.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color:
                                    c.accentIron.withValues(alpha: .14),
                                border: Border.all(
                                    color: c.accentIron
                                        .withValues(alpha: .35)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: c.accentIron,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lib.instructions[i],
                                style: AppTypography.bodyM(c.textPrimary)
                                    .copyWith(fontSize: 13.5, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (lib.tips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('COACH TIPS',
                          style: AppTypography.caption(c.warningAmber)
                              .copyWith(letterSpacing: 1.4)),
                      const SizedBox(height: 8),
                      for (final t in lib.tips)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: c.warningAmber,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(t,
                                    style: AppTypography.bodyM(c.textPrimary)
                                        .copyWith(
                                            fontSize: 13, height: 1.45)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExPill extends StatelessWidget {
  const _ExPill({required this.label, required this.c});
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: c.divider.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption(c.textSecondary)
            .copyWith(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WORKOUT SUMMARY SCREEN  (matches complete.jsx)
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
  late AnimationController _ringCtrl;
  late AnimationController _checkCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _ringAnim;
  late Animation<double> _checkAnim;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _ringCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _checkCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _showShareSheet(BuildContext context, AppColors c) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ShareSheet(workout: widget.workout, newPRs: widget.newPRs, c: c),
    );
  }

  String _setsSummary(WorkoutExercise ex) {
    final done = ex.sets.where((s) => s.isDone).toList();
    if (done.isEmpty) return '';
    final grouped = <double, int>{};
    for (final s in done) {
      grouped[s.weight] = (grouped[s.weight] ?? 0) + 1;
    }
    return grouped.entries
        .map((e) =>
            '${e.value} × ${e.key == 0 ? 'BW' : WeightUnit.format(e.key)}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final w = widget.workout;
    final hasPRs = widget.newPRs.isNotEmpty;
    final mins = w.elapsedSecs ~/ 60;
    final volStr = w.totalVolume >= 1000
        ? '${(w.totalVolume / 1000).toStringAsFixed(1)}k'
        : w.totalVolume.toStringAsFixed(0);

    final stats = [
      (label: 'Duration', value: '$mins', unit: 'min', accent: false),
      (label: 'Volume', value: volStr, unit: PrefsService.unit, accent: false),
      (label: 'Sets', value: '${w.doneSets}', unit: '', accent: false),
      if (hasPRs)
        (
          label: 'PRs',
          value: '${widget.newPRs.length}',
          unit: '',
          accent: true
        ),
    ];

    return _FreshWorkoutSummaryScreen(
      workout: w,
      newPRs: widget.newPRs,
      onDone: widget.onDone,
      onShare: () => _showShareSheet(context, c),
      setsSummary: _setsSummary,
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
                100,
              ),
              child: Column(
                children: [
                  // ── Animated check ring ─────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([_ringAnim, _checkAnim]),
                    builder: (_, __) => _CheckRingPainter.widget(
                      ringPct: _ringAnim.value,
                      checkPct: _checkAnim.value,
                      color: c.accentIron,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Title ───────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            'Workout Complete',
                            style: AppTypography.displayL(c.textPrimary)
                                .copyWith(
                                    fontSize: 26,
                                    letterSpacing: -0.8,
                                    height: 1.1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            w.routineName,
                            style: AppTypography.bodyS(c.textSecondary)
                                .copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Stats strip ─────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: Row(
                      children: stats.map((s) {
                        final isLast = s == stats.last;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: isLast ? 0 : 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
                            decoration: BoxDecoration(
                              color: s.accent
                                  ? c.accentIron.withValues(alpha: 0.08)
                                  : c.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: s.accent
                                    ? c.accentIron
                                    : c.divider.withValues(alpha: 0.5),
                                width: s.accent ? 1.0 : 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  s.value,
                                  style: AppTypography.displayM(
                                    s.accent ? c.accentIron : c.textPrimary,
                                  ).copyWith(
                                    fontSize: 22,
                                    letterSpacing: -0.6,
                                    height: 1,
                                    fontFeatures: [
                                      const FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                if (s.unit.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    s.unit,
                                    style:
                                        AppTypography.caption(c.textSecondary)
                                            .copyWith(fontSize: 10),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  s.label.toUpperCase(),
                                  style: AppTypography.caption(
                                    s.accent ? c.accentIron : c.textTertiary,
                                  ).copyWith(
                                      fontSize: 9,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── New PRs ─────────────────────────────────
                  if (hasPRs) ...[
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(label: 'New Personal Records'),
                          ...widget.newPRs.take(4).map((pr) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: c.accentIron.withValues(alpha: 0.08),
                                  border: Border.all(
                                      color:
                                          c.accentIron.withValues(alpha: 0.3)),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c.accentIron
                                            .withValues(alpha: 0.18),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.emoji_events_rounded,
                                            size: 16, color: c.accentIron),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pr.exercise,
                                            style: AppTypography.titleM(
                                                    c.textPrimary)
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.1),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'New best: ${WeightUnit.format(pr.weight)} × ${pr.reps}',
                                            style: AppTypography.bodyS(
                                                    c.textTertiary)
                                                .copyWith(
                                                    fontSize: 11,
                                                    fontFeatures: [
                                                  const FontFeature
                                                      .tabularFigures()
                                                ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: c.accentIron,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        'NEW PR!',
                                        style:
                                            AppTypography.caption(Colors.white)
                                                .copyWith(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // ── Exercises ───────────────────────────────
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(label: 'Exercises'),
                        Container(
                          decoration: BoxDecoration(
                            color: c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: c.divider.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: w.exercises.asMap().entries.map((entry) {
                              final i = entry.key;
                              final ex = entry.value;
                              final done =
                                  ex.sets.where((s) => s.isDone).toList();
                              if (done.isEmpty) return const SizedBox.shrink();
                              final summary = _setsSummary(ex);
                              final isLast = i == w.exercises.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ex.name,
                                                style: AppTypography.titleM(
                                                        c.textPrimary)
                                                    .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.05),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                summary,
                                                style: AppTypography.bodyS(
                                                        c.textTertiary)
                                                    .copyWith(
                                                        fontSize: 11,
                                                        fontFeatures: [
                                                      const FontFeature
                                                          .tabularFigures()
                                                    ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _ExPill(label: ex.muscle, c: c),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                        height: 0.5,
                                        thickness: 0.5,
                                        color:
                                            c.divider.withValues(alpha: 0.5)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky bottom: Share + Done ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                12,
                AppSpacing.md,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GhostButton(
                      label: 'Share',
                      onPressed: () => _showShareSheet(context, c),
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Done',
                      onPressed: widget.onDone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workout Share Sheet ─────────────────────────────────────
class _FreshWorkoutSummaryScreen extends StatelessWidget {
  const _FreshWorkoutSummaryScreen({
    required this.workout,
    required this.newPRs,
    required this.onDone,
    required this.onShare,
    required this.setsSummary,
  });

  final CompletedWorkout workout;
  final List<({String exercise, double weight, int reps})> newPRs;
  final VoidCallback onDone;
  final VoidCallback onShare;
  final String Function(WorkoutExercise) setsSummary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final minutes = workout.elapsedSecs ~/ 60;

    return VeltScreen(
      bottomPadding: 34,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VeltLabel('Workout complete'),
                const SizedBox(height: 10),
                Text(
                  workout.routineName,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 34,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: VeltMetric(value: '$minutes m', label: 'time'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          VeltMetric(value: workout.volumeLabel, label: 'load'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VeltMetric(
                        value: '${workout.doneSets}',
                        label: 'sets',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (newPRs.isNotEmpty) ...[
            const VeltSection(label: 'New records'),
            for (final pr in newPRs.take(4)) ...[
              VeltRowCard(
                icon: 'PR',
                title: pr.exercise,
                subtitle: '${WeightUnit.format(pr.weight)} x ${pr.reps}',
                trailing: const VeltPill('new', success: true),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const VeltSection(label: 'Logged exercises'),
          for (final ex in workout.exercises
              .where((exercise) => exercise.sets.any((set) => set.isDone))) ...[
            VeltRowCard(
              icon: ex.name.characters.first.toUpperCase(),
              title: ex.name,
              subtitle: setsSummary(ex),
              trailing: VeltPill(ex.muscle),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: VeltButton(
                  label: 'Share',
                  secondary: true,
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VeltButton(label: 'Done', onTap: onDone),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({
    required this.workout,
    required this.newPRs,
    required this.c,
  });
  final CompletedWorkout workout;
  final List<({String exercise, double weight, int reps})> newPRs;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        20,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Share Workout',
                style: AppTypography.titleM(c.textPrimary)
                    .copyWith(fontSize: 18, letterSpacing: -0.3),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child:
                    Icon(Icons.close_rounded, size: 20, color: c.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _WorkoutShareCard(workout: workout, newPRs: newPRs, c: c),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Saved to camera roll'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Save to Photos'),
              style: FilledButton.styleFrom(
                backgroundColor: c.accentIron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutShareCard extends StatelessWidget {
  const _WorkoutShareCard({
    required this.workout,
    required this.newPRs,
    required this.c,
  });
  final CompletedWorkout workout;
  final List<({String exercise, double weight, int reps})> newPRs;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final mins = workout.elapsedSecs ~/ 60;
    final volStr = WeightUnit.formatVolume(workout.totalVolume);
    final muscles =
        workout.exercises.map((e) => e.muscle).toSet().take(3).join(' · ');
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header band ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: c.accentIron,
            ),
            child: Row(
              children: [
                Text(
                  'VELT',
                  style: AppTypography.displayL(Colors.white).copyWith(
                      fontSize: 20,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: AppTypography.caption(
                          Colors.white.withValues(alpha: 0.75))
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // ── Workout name ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.routineName,
                  style: AppTypography.displayM(c.textPrimary).copyWith(
                      fontSize: 20,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w800),
                ),
                if (muscles.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    muscles,
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // ── Stats row ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _ShareStat(label: 'DURATION', value: '$mins min', c: c),
                _ShareDivider(c: c),
                _ShareStat(label: 'VOLUME', value: volStr, c: c),
                _ShareDivider(c: c),
                _ShareStat(label: 'SETS', value: '${workout.doneSets}', c: c),
                if (newPRs.isNotEmpty) ...[
                  _ShareDivider(c: c),
                  _ShareStat(
                      label: 'PRs',
                      value: '${newPRs.length}',
                      highlight: true,
                      c: c),
                ],
              ],
            ),
          ),

          // ── Exercise list ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: workout.exercises
                  .where((e) => e.sets.any((s) => s.isDone))
                  .take(5)
                  .map((ex) {
                final done = ex.sets.where((s) => s.isDone).length;
                final best = ex.sets
                    .where((s) => s.isDone && s.weight > 0)
                    .fold(0.0, (a, s) => s.weight > a ? s.weight : a);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text('· ',
                          style: AppTypography.bodyS(c.accentIron)
                              .copyWith(fontSize: 12)),
                      Expanded(
                        child: Text(
                          ex.name,
                          style: AppTypography.bodyS(c.textSecondary)
                              .copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        best > 0
                            ? '$done sets · ${WeightUnit.format(best)}'
                            : '$done sets',
                        style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 11,
                            fontFeatures: [const FontFeature.tabularFigures()]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][m - 1];
}

class _ShareStat extends StatelessWidget {
  const _ShareStat({
    required this.label,
    required this.value,
    required this.c,
    this.highlight = false,
  });
  final String label;
  final String value;
  final AppColors c;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.displayM(
              highlight ? c.accentIron : c.textPrimary,
            ).copyWith(
                fontSize: 16,
                letterSpacing: -0.3,
                fontWeight: FontWeight.w700,
                fontFeatures: [const FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption(c.textTertiary).copyWith(
                fontSize: 9, letterSpacing: 0.7, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ShareDivider extends StatelessWidget {
  const _ShareDivider({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) => Container(
        width: 0.5,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: c.divider,
      );
}

// ── Animated check ring (SVG equivalent) ───────────────────
class _CheckRingPainter extends CustomPainter {
  const _CheckRingPainter({
    required this.ringPct,
    required this.checkPct,
    required this.color,
  });
  final double ringPct;
  final double checkPct;
  final Color color;

  static Widget widget({
    required double ringPct,
    required double checkPct,
    required Color color,
  }) {
    return CustomPaint(
      size: const Size(120, 120),
      painter:
          _CheckRingPainter(ringPct: ringPct, checkPct: checkPct, color: color),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 50.0;

    // Background circle
    canvas.drawCircle(
        center, r, Paint()..color = color.withValues(alpha: 0.12));

    // Animated arc
    if (ringPct > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        ringPct * 2 * math.pi,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Animated checkmark
    if (checkPct > 0) {
      final checkPath = Path()
        ..moveTo(center.dx - 17, center.dy)
        ..lineTo(center.dx - 4.5, center.dy + 13.5)
        ..lineTo(center.dx + 19, center.dy - 11);

      final metric = checkPath.computeMetrics().first;
      final drawn = metric.extractPath(0, metric.length * checkPct);
      canvas.drawPath(
        drawn,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckRingPainter old) =>
      old.ringPct != ringPct || old.checkPct != checkPct || old.color != color;
}

// ── PR Celebration Overlay ────────────────────────────────
class _PRCelebrationOverlay extends StatefulWidget {
  const _PRCelebrationOverlay({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.onDismiss,
    required this.c,
  });
  final String exerciseName;
  final double weight;
  final int reps;
  final VoidCallback onDismiss;
  final AppColors c;

  @override
  State<_PRCelebrationOverlay> createState() => _PRCelebrationOverlayState();
}

class _PRCelebrationOverlayState extends State<_PRCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _glow;

  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scale = Tween(begin: 0.82, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    // Slight delay so confetti fires after the overlay scales in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _confettiCtrl.play();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  static const _gold = Color(0xFFD97706);

  static Path _starPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Stack(
      children: [
        // ── Dim backdrop + card ──────────────────────────
        FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap:
                        () {}, // swallow taps on card so backdrop still works
                    child: AnimatedBuilder(
                      animation: _glow,
                      builder: (_, child) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: _gold.withValues(
                                alpha: 0.30 + _glow.value * 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(
                                  alpha: 0.10 + _glow.value * 0.12),
                              blurRadius: 20 + _glow.value * 12,
                              spreadRadius: _glow.value * 2,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Trophy ring
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _gold.withValues(alpha: 0.10),
                                border: Border.all(
                                    color: _gold.withValues(alpha: 0.35),
                                    width: 1.5),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.emoji_events_rounded,
                                  size: 36,
                                  color: _gold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                'NEW PERSONAL RECORD',
                                style: AppTypography.caption(Colors.white)
                                    .copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Exercise name
                            Text(
                              widget.exerciseName,
                              style:
                                  AppTypography.titleM(c.textPrimary).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),

                            // Weight × reps
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: WeightUnit.format(widget.weight),
                                  style: AppTypography.displayL(_gold).copyWith(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.2,
                                    height: 1,
                                    fontFeatures: [
                                      const FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                TextSpan(
                                  text: '  ×  ${widget.reps}',
                                  style: AppTypography.titleM(c.textSecondary)
                                      .copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                    fontFeatures: [
                                      const FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 22),

                            // Divider
                            Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: c.divider.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),

                            // Dismiss hint
                            Text(
                              'Tap anywhere to dismiss',
                              style: AppTypography.caption(c.textTertiary)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Confetti — fires from top-center ────────────
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            blastDirection: math.pi / 2,
            emissionFrequency: 0.06,
            numberOfParticles: 18,
            gravity: 0.25,
            maxBlastForce: 18,
            minBlastForce: 8,
            colors: const [
              Color(0xFFD97706), // gold
              Color(0xFFFBBF24), // amber
              Color(0xFFFFFFFF), // white
              Color(0xFFF59E0B), // yellow-gold
              Color(0xFFEF4444), // red accent
            ],
            createParticlePath: _starPath,
          ),
        ),
      ],
    );
  }
}

// ── Dashed line for Add Set border ────────────────────────
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════
//  EXERCISE PICKER SHEET
// ══════════════════════════════════════════════════════════
const kExerciseCatalogue = [
  // ── Chest ──────────────────────────────────────────
  (id: 'bench', name: 'Bench Press', muscle: 'Chest', equipment: 'Barbell'),
  (
    id: 'incline-bb',
    name: 'Incline Bench Press',
    muscle: 'Chest',
    equipment: 'Barbell'
  ),
  (
    id: 'incline',
    name: 'Incline DB Press',
    muscle: 'Chest',
    equipment: 'Dumbbell'
  ),
  (id: 'decline', name: 'Decline Press', muscle: 'Chest', equipment: 'Barbell'),
  (id: 'db-fly', name: 'Dumbbell Fly', muscle: 'Chest', equipment: 'Dumbbell'),
  (id: 'cable-fly', name: 'Cable Fly', muscle: 'Chest', equipment: 'Cable'),
  (
    id: 'pec-deck',
    name: 'Pec Deck Machine',
    muscle: 'Chest',
    equipment: 'Machine'
  ),
  (id: 'dips', name: 'Dips', muscle: 'Chest', equipment: 'Bodyweight'),
  (id: 'pushup', name: 'Push-Up', muscle: 'Chest', equipment: 'Bodyweight'),
  (
    id: 'landmine-pp',
    name: 'Landmine Press',
    muscle: 'Chest',
    equipment: 'Barbell'
  ),
  (
    id: 'db-bench',
    name: 'Dumbbell Bench Press',
    muscle: 'Chest',
    equipment: 'Dumbbell'
  ),
  (
    id: 'machine-chest',
    name: 'Machine Chest Press',
    muscle: 'Chest',
    equipment: 'Machine'
  ),
  // ── Back ───────────────────────────────────────────
  (id: 'deadlift', name: 'Deadlift', muscle: 'Back', equipment: 'Barbell'),
  (id: 'row', name: 'Barbell Row', muscle: 'Back', equipment: 'Barbell'),
  (id: 'db-row', name: 'Dumbbell Row', muscle: 'Back', equipment: 'Dumbbell'),
  (id: 'tbar-row', name: 'T-Bar Row', muscle: 'Back', equipment: 'Barbell'),
  (id: 'pullup', name: 'Pull-Up', muscle: 'Back', equipment: 'Bodyweight'),
  (id: 'chinup', name: 'Chin-Up', muscle: 'Back', equipment: 'Bodyweight'),
  (id: 'lat-pull', name: 'Lat Pulldown', muscle: 'Back', equipment: 'Cable'),
  (
    id: 'cable-row',
    name: 'Seated Cable Row',
    muscle: 'Back',
    equipment: 'Cable'
  ),
  (
    id: 'straight-arm',
    name: 'Straight-Arm Pulldown',
    muscle: 'Back',
    equipment: 'Cable'
  ),
  (id: 'shrug', name: 'Barbell Shrug', muscle: 'Traps', equipment: 'Barbell'),
  (id: 'face-pull', name: 'Face Pull', muscle: 'Rear Delt', equipment: 'Cable'),
  (
    id: 'rev-fly',
    name: 'Reverse Fly',
    muscle: 'Rear Delt',
    equipment: 'Dumbbell'
  ),
  (
    id: 'chest-sup-row',
    name: 'Chest-Supported Row',
    muscle: 'Back',
    equipment: 'Machine'
  ),
  (
    id: 'rev-pec-deck',
    name: 'Reverse Pec Deck',
    muscle: 'Rear Delt',
    equipment: 'Machine'
  ),
  // ── Shoulders ──────────────────────────────────────
  (
    id: 'ohp',
    name: 'Overhead Press',
    muscle: 'Shoulders',
    equipment: 'Barbell'
  ),
  (
    id: 'db-ohp',
    name: 'DB Shoulder Press',
    muscle: 'Shoulders',
    equipment: 'Dumbbell'
  ),
  (
    id: 'arnold',
    name: 'Arnold Press',
    muscle: 'Shoulders',
    equipment: 'Dumbbell'
  ),
  (
    id: 'lat-raise',
    name: 'Lateral Raise',
    muscle: 'Shoulders',
    equipment: 'Dumbbell'
  ),
  (
    id: 'cable-lat',
    name: 'Cable Lateral Raise',
    muscle: 'Shoulders',
    equipment: 'Cable'
  ),
  (
    id: 'front-raise',
    name: 'Front Raise',
    muscle: 'Shoulders',
    equipment: 'Dumbbell'
  ),
  (
    id: 'upright-row',
    name: 'Upright Row',
    muscle: 'Shoulders',
    equipment: 'Barbell'
  ),
  // ── Biceps ─────────────────────────────────────────
  (id: 'bb-curl', name: 'Barbell Curl', muscle: 'Biceps', equipment: 'Barbell'),
  (
    id: 'db-curl',
    name: 'Dumbbell Curl',
    muscle: 'Biceps',
    equipment: 'Dumbbell'
  ),
  (id: 'hammer', name: 'Hammer Curl', muscle: 'Biceps', equipment: 'Dumbbell'),
  (
    id: 'preacher',
    name: 'Preacher Curl',
    muscle: 'Biceps',
    equipment: 'Barbell'
  ),
  (
    id: 'incline-curl',
    name: 'Incline DB Curl',
    muscle: 'Biceps',
    equipment: 'Dumbbell'
  ),
  (id: 'cable-curl', name: 'Cable Curl', muscle: 'Biceps', equipment: 'Cable'),
  (
    id: 'conc-curl',
    name: 'Concentration Curl',
    muscle: 'Biceps',
    equipment: 'Dumbbell'
  ),
  (id: 'ez-curl', name: 'EZ-Bar Curl', muscle: 'Biceps', equipment: 'Barbell'),
  (
    id: 'rev-curl',
    name: 'Reverse Curl',
    muscle: 'Biceps',
    equipment: 'Barbell'
  ),
  // ── Triceps ────────────────────────────────────────
  (
    id: 'tri-push',
    name: 'Tricep Pushdown',
    muscle: 'Triceps',
    equipment: 'Cable'
  ),
  (id: 'skull', name: 'Skullcrusher', muscle: 'Triceps', equipment: 'Barbell'),
  (
    id: 'tri-dips',
    name: 'Tricep Dips',
    muscle: 'Triceps',
    equipment: 'Bodyweight'
  ),
  (
    id: 'cg-bench',
    name: 'Close-Grip Bench Press',
    muscle: 'Triceps',
    equipment: 'Barbell'
  ),
  (
    id: 'oh-tri-ext',
    name: 'Overhead Tricep Extension',
    muscle: 'Triceps',
    equipment: 'Cable'
  ),
  (
    id: 'kickback',
    name: 'Tricep Kickback',
    muscle: 'Triceps',
    equipment: 'Dumbbell'
  ),
  (
    id: 'rope-push',
    name: 'Rope Pushdown',
    muscle: 'Triceps',
    equipment: 'Cable'
  ),
  (
    id: 'db-oh-ext',
    name: 'DB Overhead Extension',
    muscle: 'Triceps',
    equipment: 'Dumbbell'
  ),
  (
    id: 'bench-dip',
    name: 'Bench Dip',
    muscle: 'Triceps',
    equipment: 'Bodyweight'
  ),
  // ── Quads ──────────────────────────────────────────
  (id: 'squat', name: 'Squat', muscle: 'Quads', equipment: 'Barbell'),
  (
    id: 'front-squat',
    name: 'Front Squat',
    muscle: 'Quads',
    equipment: 'Barbell'
  ),
  (id: 'hack-squat', name: 'Hack Squat', muscle: 'Quads', equipment: 'Machine'),
  (id: 'leg-press', name: 'Leg Press', muscle: 'Quads', equipment: 'Machine'),
  (id: 'leg-ext', name: 'Leg Extension', muscle: 'Quads', equipment: 'Machine'),
  (
    id: 'bulgarian',
    name: 'Bulgarian Split Squat',
    muscle: 'Quads',
    equipment: 'Dumbbell'
  ),
  (id: 'goblet', name: 'Goblet Squat', muscle: 'Quads', equipment: 'Dumbbell'),
  // ── Hamstrings ─────────────────────────────────────
  (
    id: 'rdl',
    name: 'Romanian Deadlift',
    muscle: 'Hamstrings',
    equipment: 'Barbell'
  ),
  (
    id: 'sdl',
    name: 'Stiff-Leg Deadlift',
    muscle: 'Hamstrings',
    equipment: 'Barbell'
  ),
  (
    id: 'leg-curl',
    name: 'Leg Curl',
    muscle: 'Hamstrings',
    equipment: 'Machine'
  ),
  (
    id: 'db-rdl',
    name: 'DB Romanian Deadlift',
    muscle: 'Hamstrings',
    equipment: 'Dumbbell'
  ),
  (
    id: 'nordic',
    name: 'Nordic Curl',
    muscle: 'Hamstrings',
    equipment: 'Bodyweight'
  ),
  (
    id: 'good-morning',
    name: 'Good Morning',
    muscle: 'Hamstrings',
    equipment: 'Barbell'
  ),
  (
    id: 'sl-rdl',
    name: 'Single-Leg RDL',
    muscle: 'Hamstrings',
    equipment: 'Dumbbell'
  ),
  (
    id: 'lying-curl',
    name: 'Lying Leg Curl',
    muscle: 'Hamstrings',
    equipment: 'Machine'
  ),
  // ── Glutes ─────────────────────────────────────────
  (
    id: 'hip-thrust',
    name: 'Hip Thrust',
    muscle: 'Glutes',
    equipment: 'Barbell'
  ),
  (id: 'lunge', name: 'Walking Lunge', muscle: 'Glutes', equipment: 'Dumbbell'),
  (
    id: 'sumo-dl',
    name: 'Sumo Deadlift',
    muscle: 'Glutes',
    equipment: 'Barbell'
  ),
  (id: 'step-up', name: 'Step-Up', muscle: 'Glutes', equipment: 'Dumbbell'),
  (
    id: 'cable-kickback',
    name: 'Cable Glute Kickback',
    muscle: 'Glutes',
    equipment: 'Cable'
  ),
  (
    id: 'glute-bridge',
    name: 'Glute Bridge',
    muscle: 'Glutes',
    equipment: 'Bodyweight'
  ),
  (
    id: 'cable-pull-through',
    name: 'Cable Pull-Through',
    muscle: 'Glutes',
    equipment: 'Cable'
  ),
  (
    id: 'kb-swing',
    name: 'Kettlebell Swing',
    muscle: 'Glutes',
    equipment: 'Other'
  ),
  // ── Calves ─────────────────────────────────────────
  (
    id: 'calf',
    name: 'Standing Calf Raise',
    muscle: 'Calves',
    equipment: 'Machine'
  ),
  (
    id: 'seated-calf',
    name: 'Seated Calf Raise',
    muscle: 'Calves',
    equipment: 'Machine'
  ),
  (
    id: 'donkey-calf',
    name: 'Donkey Calf Raise',
    muscle: 'Calves',
    equipment: 'Machine'
  ),
  (
    id: 'single-calf',
    name: 'Single-Leg Calf Raise',
    muscle: 'Calves',
    equipment: 'Bodyweight'
  ),
  // ── Core ───────────────────────────────────────────
  (id: 'plank', name: 'Plank', muscle: 'Core', equipment: 'Bodyweight'),
  (
    id: 'side-plank',
    name: 'Side Plank',
    muscle: 'Core',
    equipment: 'Bodyweight'
  ),
  (id: 'crunch', name: 'Crunch', muscle: 'Core', equipment: 'Bodyweight'),
  (id: 'leg-raise', name: 'Leg Raise', muscle: 'Core', equipment: 'Bodyweight'),
  (
    id: 'ab-wheel',
    name: 'Ab Wheel Rollout',
    muscle: 'Core',
    equipment: 'Other'
  ),
  (
    id: 'cable-crunch',
    name: 'Cable Crunch',
    muscle: 'Core',
    equipment: 'Cable'
  ),
  (
    id: 'russian-twist',
    name: 'Russian Twist',
    muscle: 'Core',
    equipment: 'Bodyweight'
  ),
  (
    id: 'hollow-hold',
    name: 'Hollow Hold',
    muscle: 'Core',
    equipment: 'Bodyweight'
  ),
  (
    id: 'hanging-raise',
    name: 'Hanging Leg Raise',
    muscle: 'Core',
    equipment: 'Bodyweight'
  ),
  (
    id: 'rev-crunch',
    name: 'Reverse Crunch',
    muscle: 'Core',
    equipment: 'Bodyweight'
  ),
  (id: 'dead-bug', name: 'Dead Bug', muscle: 'Core', equipment: 'Bodyweight'),
  (
    id: 'pallof-press',
    name: 'Pallof Press',
    muscle: 'Core',
    equipment: 'Cable'
  ),
  (
    id: 'farmers-carry',
    name: "Farmer's Carry",
    muscle: 'Core',
    equipment: 'Dumbbell'
  ),
  // ── Cardio / Other ─────────────────────────────────
  (id: 'treadmill', name: 'Treadmill', muscle: 'Cardio', equipment: 'Machine'),
  (
    id: 'rowing',
    name: 'Rowing Machine',
    muscle: 'Cardio',
    equipment: 'Machine'
  ),
  (id: 'bike', name: 'Stationary Bike', muscle: 'Cardio', equipment: 'Machine'),
  (id: 'jump-rope', name: 'Jump Rope', muscle: 'Cardio', equipment: 'Other'),
  (
    id: 'battle-rope',
    name: 'Battle Ropes',
    muscle: 'Cardio',
    equipment: 'Other'
  ),
  (id: 'burpee', name: 'Burpee', muscle: 'Cardio', equipment: 'Bodyweight'),
  (id: 'sled-push', name: 'Sled Push', muscle: 'Cardio', equipment: 'Machine'),
];

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key, required this.onAdd});
  final void Function(List<WorkoutExercise>) onAdd;

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  String _query = '';
  String _muscle = 'All';
  final Set<String> _picked = {};

  static const _muscleFilters = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Cardio',
  ];

  static const _muscleMap = {
    'Arms': ['Biceps', 'Triceps'],
    'Legs': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    'Back': ['Back', 'Traps', 'Rear Delt'],
  };

  List<({String id, String name, String muscle, String equipment})>
      get _filtered {
    var list = kExerciseCatalogue.toList();
    if (_muscle != 'All') {
      final expanded = _muscleMap[_muscle];
      if (expanded != null) {
        list = list.where((e) => expanded.contains(e.muscle)).toList();
      } else {
        list = list.where((e) => e.muscle == _muscle).toList();
      }
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.muscle.toLowerCase().contains(q) ||
              e.equipment.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void _toggle(String name) {
    setState(() {
      if (_picked.contains(name)) {
        _picked.remove(name);
      } else {
        _picked.add(name);
      }
    });
  }

  WorkoutExercise _buildExercise(
          ({String id, String name, String muscle, String equipment}) e) =>
      WorkoutExercise(
        id: '${e.id}-${DateTime.now().millisecondsSinceEpoch}',
        name: e.name,
        muscle: e.muscle,
        equipment: e.equipment,
        sets: [
          const SetRowData(index: 0, type: SetType.normal, weight: 0, reps: 0),
        ],
      );

  void _addPicked() {
    final exercises = _picked.map((name) {
      final e = kExerciseCatalogue.firstWhere((ex) => ex.name == name);
      return _buildExercise(e);
    }).toList();
    widget.onAdd(exercises);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final filtered = _filtered;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 14, AppSpacing.md, 0),
                child: Row(
                  children: [
                    Text(
                      'Add Exercise',
                      style: AppTypography.titleM(c.textPrimary)
                          .copyWith(fontSize: 18, letterSpacing: -0.2),
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length} exercises',
                      style: AppTypography.caption(c.textTertiary)
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    border: Border.all(color: c.divider, width: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: TextField(
                    autofocus: false,
                    style: AppTypography.bodyM(c.textPrimary)
                        .copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search exercises…',
                      hintStyle: AppTypography.bodyM(c.textTertiary)
                          .copyWith(fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: c.textTertiary, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              // Muscle filter chips
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _muscleFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final m = _muscleFilters[i];
                    final active = _muscle == m;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _muscle = m);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? c.accentIron : c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: active
                              ? null
                              : Border.all(
                                  color: c.divider.withValues(alpha: 0.4),
                                  width: 0.5),
                        ),
                        child: Text(
                          m,
                          style: AppTypography.bodyS(
                            active ? Colors.white : c.textSecondary,
                          ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
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
                          'No exercises match.',
                          style: AppTypography.bodyS(c.textTertiary)
                              .copyWith(fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                            bottom: _picked.isNotEmpty ? 80 : 12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final ex = filtered[i];
                          final picked = _picked.contains(ex.name);
                          return GestureDetector(
                            onTap: () => _toggle(ex.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              color: picked
                                  ? c.accentIron.withValues(alpha: 0.05)
                                  : Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            c.divider.withValues(alpha: 0.5)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${ex.muscle} · ${ex.equipment}',
                                            style: AppTypography.bodyS(
                                                    c.textTertiary)
                                                .copyWith(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: picked
                                            ? c.accentIron
                                            : c.surfaceHigh,
                                        border: picked
                                            ? null
                                            : Border.all(
                                                color: c.divider, width: 0.5),
                                      ),
                                      child: picked
                                          ? const Icon(Icons.check_rounded,
                                              size: 14, color: Colors.white)
                                          : Icon(Icons.add_rounded,
                                              size: 14, color: c.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Sticky "Add N exercises" bar
          if (_picked.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.md, 12, AppSpacing.md, 12 + safeBottom),
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  border: Border(top: BorderSide(color: c.divider, width: 0.5)),
                ),
                child: PrimaryButton(
                  label:
                      'Add ${_picked.length} exercise${_picked.length == 1 ? '' : 's'}',
                  onPressed: _addPicked,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
