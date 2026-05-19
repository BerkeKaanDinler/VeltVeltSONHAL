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
      'exercises':   _exercises.map((e) => e.toJson()).toList(),
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
                style: AppTypography.bodyM(c.textPrimary).copyWith(
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard',
                style: AppTypography.bodyM(c.errorRose).copyWith(
                    fontWeight: FontWeight.w500)),
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
  int get _doneSets  => _exercises.fold(0, (a, e) => a + e.sets.where((s) => s.isDone).length);

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
        index: old.index, type: old.type,
        weight: weight, reps: old.reps, prev: old.prev, isDone: old.isDone,
      );
    });
    _saveToPrefs();
  }

  void _updateReps(int exIdx, int setIdx, int reps) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index, type: old.type,
        weight: old.weight, reps: reps, prev: old.prev, isDone: old.isDone,
      );
    });
    _saveToPrefs();
  }

  void _updateSetType(int exIdx, int setIdx, SetType type) {
    setState(() {
      final old = _exercises[exIdx].sets[setIdx];
      _exercises[exIdx].sets[setIdx] = SetRowData(
        index: old.index, type: type,
        weight: old.weight, reps: old.reps, prev: old.prev, isDone: old.isDone,
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
      ex.sets = newSets.asMap().entries.map((e) => SetRowData(
        index: e.key, type: e.value.type,
        weight: e.value.weight, reps: e.value.reps,
        prev: e.value.prev, isDone: e.value.isDone,
      )).toList();
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
              ex2.sets = newSets.asMap().entries.map((e) => SetRowData(
                index: e.key, type: e.value.type,
                weight: e.value.weight, reps: e.value.reps,
                prev: e.value.prev, isDone: e.value.isDone,
              )).toList();
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
      ex.sets = ex.sets.asMap().entries.map((e) => SetRowData(
        index: e.key, type: e.value.type,
        weight: e.value.weight, reps: e.value.reps,
        prev: e.value.prev, isDone: e.value.isDone,
      )).toList();
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
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fitness_center_outlined,
                                size: 44,
                                color: c.textTertiary.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises yet',
                                style: AppTypography.titleS(c.textPrimary).copyWith(
                                  fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first movement to start logging.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyS(c.textTertiary).copyWith(
                                  fontSize: 13, height: 1.45),
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
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.md,
                          AppSpacing.md, 100),
                        itemCount: _exercises.length,
                        onReorder: _reorderExercise,
                        proxyDecorator: (child, index, animation) => Material(
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
                    style: AppTypography.titleM(c.textPrimary).copyWith(
                      fontSize: 14, fontWeight: FontWeight.w700),
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
                        fontSize: 15, fontWeight: FontWeight.w700,
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
                width: 5, height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accentIron,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.elapsed,
                style: AppTypography.displayM(c.accentIron).copyWith(
                  fontSize: 16, fontWeight: FontWeight.w700,
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
                    fontSize: 13, fontWeight: FontWeight.w700,
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
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 16, letterSpacing: -0.1,
                          fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Set progress badge
                    Container(
                      margin: const EdgeInsets.only(left: 8, right: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: allDone
                            ? c.successLime.withValues(alpha: 0.12)
                            : c.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '$doneCount / $totalSets',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: allDone ? c.successLime : c.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    // Notes toggle
                    GestureDetector(
                      onTap: () => setState(() => _showNotes = !_showNotes),
                      child: SizedBox(
                        width: 44, height: 44,
                        child: Icon(
                          _showNotes
                              ? Icons.sticky_note_2_rounded
                              : Icons.sticky_note_2_outlined,
                          size: 18,
                          color: _showNotes ? c.accentIron : c.textTertiary,
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
                        child: SizedBox(
                          width: 36, height: 44,
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

          // Column header — matches SetRow grid: 32 | 1fr | 80 | 80 | 44
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 7),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.divider.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text('SET', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: c.textSecondary.withValues(alpha: 0.55), letterSpacing: 0.8)),
                ),
                Expanded(
                  child: Text('LAST',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: c.textSecondary.withValues(alpha: 0.55), letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('WEIGHT', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: c.textSecondary.withValues(alpha: 0.55), letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('REPS', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: c.textSecondary.withValues(alpha: 0.55), letterSpacing: 0.8)),
                ),
                const SizedBox(width: 44),
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
                ),
              );
            },
          ),

          // Add set — dashed top border
          GestureDetector(
            onTap: widget.onAddSet,
            child: Column(
              children: [
                SizedBox(
                  height: 1,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _DashedLinePainter(
                      color: c.accentIron.withValues(alpha: 0.2)),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  color: c.accentIron.withValues(alpha: 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 14,
                          color: c.accentIron.withValues(alpha: 0.75)),
                      const SizedBox(width: 4),
                      Text(
                        'Add Set',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyS(c.accentIron).copyWith(
                          fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
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
      ),
      child: Text(
        label,
        style: AppTypography.caption(c.textSecondary).copyWith(
          fontSize: 10, fontWeight: FontWeight.w600),
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
      begin: const Offset(0, 0.08), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

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
      builder: (_) => _ShareSheet(workout: widget.workout, newPRs: widget.newPRs, c: c),
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
        .map((e) => '${e.value} × ${e.key == 0 ? 'BW' : WeightUnit.format(e.key)}')
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
        (label: 'PRs', value: '${widget.newPRs.length}', unit: '', accent: true),
    ];

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
                            style: AppTypography.displayL(c.textPrimary).copyWith(
                              fontSize: 26, letterSpacing: -0.8, height: 1.1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            w.routineName,
                            style: AppTypography.bodyS(c.textSecondary).copyWith(
                              fontSize: 14),
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
                                    fontSize: 22, letterSpacing: -0.6, height: 1,
                                    fontFeatures: [const FontFeature.tabularFigures()],
                                  ),
                                ),
                                if (s.unit.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    s.unit,
                                    style: AppTypography.caption(c.textSecondary)
                                        .copyWith(fontSize: 10),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  s.label.toUpperCase(),
                                  style: AppTypography.caption(
                                    s.accent ? c.accentIron : c.textTertiary,
                                  ).copyWith(fontSize: 9, letterSpacing: 0.8,
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
                                    color: c.accentIron.withValues(alpha: 0.3)),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c.accentIron.withValues(alpha: 0.18),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.emoji_events_rounded,
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
                                              c.textPrimary).copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.1),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'New best: ${WeightUnit.format(pr.weight)} × ${pr.reps}',
                                            style: AppTypography.bodyS(
                                              c.textTertiary).copyWith(
                                                fontSize: 11,
                                                fontFeatures: [const FontFeature.tabularFigures()]),
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
                                        style: AppTypography.caption(Colors.white)
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
                              final isLast =
                                  i == w.exercises.length - 1;
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
                                                  c.textPrimary).copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: -0.05),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                summary,
                                                style: AppTypography.bodyS(
                                                  c.textTertiary).copyWith(
                                                    fontSize: 11,
                                                    fontFeatures: [
                                                      const FontFeature.tabularFigures()]),
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
                                      height: 0.5, thickness: 0.5,
                                      color: c.divider.withValues(alpha: 0.5)),
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
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md, 12,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, 20, AppSpacing.md,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
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
                style: AppTypography.titleM(c.textPrimary).copyWith(
                  fontSize: 18, letterSpacing: -0.3),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded,
                  size: 20, color: c.textTertiary),
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
    final muscles = workout.exercises
        .map((e) => e.muscle)
        .toSet()
        .take(3)
        .join(' · ');
    final now = DateTime.now();
    final dateStr =
        '${now.day} ${_monthName(now.month)} ${now.year}';

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
                    fontSize: 20, letterSpacing: -1,
                    fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: AppTypography.caption(
                    Colors.white.withValues(alpha: 0.75)).copyWith(
                    fontSize: 11),
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
                    fontSize: 20, letterSpacing: -0.6,
                    fontWeight: FontWeight.w800),
                ),
                if (muscles.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    muscles,
                    style: AppTypography.bodyS(c.textTertiary).copyWith(
                      fontSize: 12),
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
                _ShareStat(
                  label: 'SETS',
                  value: '${workout.doneSets}',
                  c: c),
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
              children: workout.exercises.where((e) =>
                e.sets.any((s) => s.isDone)).take(5).map((ex) {
                  final done = ex.sets.where((s) => s.isDone).length;
                  final best = ex.sets
                      .where((s) => s.isDone && s.weight > 0)
                      .fold(0.0, (a, s) =>
                          s.weight > a ? s.weight : a);
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
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
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
              fontSize: 16, letterSpacing: -0.3,
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption(c.textTertiary).copyWith(
              fontSize: 9, letterSpacing: 0.7,
              fontWeight: FontWeight.w600),
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
    width: 0.5, height: 28,
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
      painter: _CheckRingPainter(
        ringPct: ringPct, checkPct: checkPct, color: color),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 50.0;

    // Background circle
    canvas.drawCircle(center, r,
        Paint()..color = color.withValues(alpha: 0.12));

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
      old.ringPct != ringPct ||
      old.checkPct != checkPct ||
      old.color != color;
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

    _fade  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _scale = Tween(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _glow  = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _confettiCtrl = ConfettiController(
      duration: const Duration(seconds: 3));

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
                onTap: () {}, // swallow taps on card so backdrop still works
                child: AnimatedBuilder(
                  animation: _glow,
                  builder: (_, child) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: c.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.30 + _glow.value * 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.10 + _glow.value * 0.12),
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
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withValues(alpha: 0.10),
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.35), width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 36, color: _gold,
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
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'NEW PERSONAL RECORD',
                            style: AppTypography.caption(Colors.white).copyWith(
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
                          style: AppTypography.titleM(c.textPrimary).copyWith(
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
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                            TextSpan(
                              text: '  ×  ${widget.reps}',
                              style: AppTypography.titleM(c.textSecondary).copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 22),

                        // Divider
                        Divider(
                          height: 0.5, thickness: 0.5,
                          color: c.divider.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),

                        // Dismiss hint
                        Text(
                          'Tap anywhere to dismiss',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 11),
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
  (id:'db-bench',     name:'Dumbbell Bench Press',     muscle:'Chest',      equipment:'Dumbbell'),
  (id:'machine-chest',name:'Machine Chest Press',      muscle:'Chest',      equipment:'Machine'),
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
  (id:'chest-sup-row',name:'Chest-Supported Row',      muscle:'Back',       equipment:'Machine'),
  (id:'rev-pec-deck', name:'Reverse Pec Deck',         muscle:'Rear Delt',  equipment:'Machine'),
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
  (id:'ez-curl',      name:'EZ-Bar Curl',              muscle:'Biceps',     equipment:'Barbell'),
  (id:'rev-curl',     name:'Reverse Curl',             muscle:'Biceps',     equipment:'Barbell'),
  // ── Triceps ────────────────────────────────────────
  (id:'tri-push',     name:'Tricep Pushdown',          muscle:'Triceps',    equipment:'Cable'),
  (id:'skull',        name:'Skullcrusher',             muscle:'Triceps',    equipment:'Barbell'),
  (id:'tri-dips',     name:'Tricep Dips',              muscle:'Triceps',    equipment:'Bodyweight'),
  (id:'cg-bench',     name:'Close-Grip Bench Press',   muscle:'Triceps',    equipment:'Barbell'),
  (id:'oh-tri-ext',   name:'Overhead Tricep Extension',muscle:'Triceps',    equipment:'Cable'),
  (id:'kickback',     name:'Tricep Kickback',          muscle:'Triceps',    equipment:'Dumbbell'),
  (id:'rope-push',    name:'Rope Pushdown',            muscle:'Triceps',    equipment:'Cable'),
  (id:'db-oh-ext',    name:'DB Overhead Extension',    muscle:'Triceps',    equipment:'Dumbbell'),
  (id:'bench-dip',    name:'Bench Dip',                muscle:'Triceps',    equipment:'Bodyweight'),
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
  (id:'good-morning', name:'Good Morning',             muscle:'Hamstrings', equipment:'Barbell'),
  (id:'sl-rdl',       name:'Single-Leg RDL',           muscle:'Hamstrings', equipment:'Dumbbell'),
  (id:'lying-curl',   name:'Lying Leg Curl',           muscle:'Hamstrings', equipment:'Machine'),
  // ── Glutes ─────────────────────────────────────────
  (id:'hip-thrust',   name:'Hip Thrust',               muscle:'Glutes',     equipment:'Barbell'),
  (id:'lunge',        name:'Walking Lunge',            muscle:'Glutes',     equipment:'Dumbbell'),
  (id:'sumo-dl',      name:'Sumo Deadlift',            muscle:'Glutes',     equipment:'Barbell'),
  (id:'step-up',      name:'Step-Up',                  muscle:'Glutes',     equipment:'Dumbbell'),
  (id:'cable-kickback',name:'Cable Glute Kickback',    muscle:'Glutes',     equipment:'Cable'),
  (id:'glute-bridge', name:'Glute Bridge',             muscle:'Glutes',     equipment:'Bodyweight'),
  (id:'cable-pull-through',name:'Cable Pull-Through',  muscle:'Glutes',     equipment:'Cable'),
  (id:'kb-swing',     name:'Kettlebell Swing',         muscle:'Glutes',     equipment:'Other'),
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
  (id:'rev-crunch',   name:'Reverse Crunch',           muscle:'Core',       equipment:'Bodyweight'),
  (id:'dead-bug',     name:'Dead Bug',                 muscle:'Core',       equipment:'Bodyweight'),
  (id:'pallof-press', name:'Pallof Press',             muscle:'Core',       equipment:'Cable'),
  (id:'farmers-carry',name:"Farmer's Carry",           muscle:'Core',       equipment:'Dumbbell'),
  // ── Cardio / Other ─────────────────────────────────
  (id:'treadmill',    name:'Treadmill',                muscle:'Cardio',     equipment:'Machine'),
  (id:'rowing',       name:'Rowing Machine',           muscle:'Cardio',     equipment:'Machine'),
  (id:'bike',         name:'Stationary Bike',          muscle:'Cardio',     equipment:'Machine'),
  (id:'jump-rope',    name:'Jump Rope',                muscle:'Cardio',     equipment:'Other'),
  (id:'battle-rope',  name:'Battle Ropes',             muscle:'Cardio',     equipment:'Other'),
  (id:'burpee',       name:'Burpee',                   muscle:'Cardio',     equipment:'Bodyweight'),
  (id:'sled-push',    name:'Sled Push',                muscle:'Cardio',     equipment:'Machine'),
];

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key, required this.onAdd});
  final void Function(List<WorkoutExercise>) onAdd;

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  String _query  = '';
  String _muscle = 'All';
  final Set<String> _picked = {};

  static const _muscleFilters = [
    'All', 'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core', 'Cardio',
  ];

  static const _muscleMap = {
    'Arms': ['Biceps', 'Triceps'],
    'Legs': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    'Back': ['Back', 'Traps', 'Rear Delt'],
  };

  List<({String id, String name, String muscle, String equipment})> get _filtered {
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
      list = list.where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.muscle.toLowerCase().contains(q) ||
          e.equipment.toLowerCase().contains(q)).toList();
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
        name: e.name, muscle: e.muscle, equipment: e.equipment,
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
    final c        = Theme.of(context).extension<AppColors>()!;
    final filtered = _filtered;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Stack(
        children: [
          Column(
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 14, AppSpacing.md, 0),
                child: Row(
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
                    style: AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search exercises…',
                      hintStyle: AppTypography.bodyM(c.textTertiary).copyWith(fontSize: 13),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _muscleFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final m      = _muscleFilters[i];
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
                          style: AppTypography.bodyS(c.textTertiary).copyWith(
                              fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: _picked.isNotEmpty ? 80 : 12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final ex     = filtered[i];
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
                                    horizontal: AppSpacing.sm, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: c.divider.withValues(alpha: 0.5)),
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
                                                    fontWeight: FontWeight.w600),
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
                                      duration: const Duration(milliseconds: 150),
                                      width: 28, height: 28,
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
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.md, 12, AppSpacing.md, 12 + safeBottom),
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  border: Border(top: BorderSide(color: c.divider, width: 0.5)),
                ),
                child: PrimaryButton(
                  label: 'Add ${_picked.length} exercise${_picked.length == 1 ? '' : 's'}',
                  onPressed: _addPicked,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
