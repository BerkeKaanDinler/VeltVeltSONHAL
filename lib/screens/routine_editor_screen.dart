import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/set_row.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import '../utils/weight_unit.dart';
import '../models/workout.dart' show WorkoutExercise;
import 'active_workout_screen.dart' show ExercisePickerSheet;

const _palette = [
  Color(0xFFD97706), Color(0xFF3B82F6), Color(0xFF10B981),
  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFEF4444),
  Color(0xFF06B6D4), Color(0xFF84CC16),
];

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({super.key, this.existing});
  final Routine? existing;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late final TextEditingController _nameCtrl;
  late int _colorValue;
  late List<WorkoutExercise> _exercises;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _colorValue = widget.existing?.colorValue ?? _palette.first.toARGB32();
    _exercises = widget.existing != null
        ? widget.existing!.exercises
            .map((e) => WorkoutExercise(
                  id: e.id,
                  name: e.name,
                  muscle: e.muscle,
                  equipment: e.equipment,
                  sets: List<SetRowData>.from(e.sets),
                ))
            .toList()
        : [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your routine a name')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Add at least one exercise to save'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm)),
      ));
      return;
    }
    final isDuplicate = RoutineStore.routines.value.any((r) =>
        r.name.toLowerCase() == name.toLowerCase() &&
        r.id != (widget.existing?.id ?? ''));
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A routine named "$name" already exists'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      return;
    }
    final routine = Routine(
      id: widget.existing?.id ??
          'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      colorValue: _colorValue,
      exercises: _exercises,
      lastDone: widget.existing?.lastDone,
    );
    if (_isEdit) {
      await RoutineStore.update(routine);
    } else {
      await RoutineStore.add(routine);
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePickerSheet(
        onAdd: (list) {
          Navigator.of(context).pop();
          setState(() => _exercises.addAll(list));
        },
      ),
    );
  }

  void _removeExercise(int idx) {
    HapticFeedback.mediumImpact();
    setState(() => _exercises.removeAt(idx));
  }

  void _editSets(int idx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSetsSheet(
        exercise: _exercises[idx],
        onChanged: (updated) {
          setState(() => _exercises[idx] = updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(bottom: BorderSide(color: c.divider)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 44, height: 44,
                      child: Center(
                        child: Text('✕',
                            style: TextStyle(
                                fontSize: 18, color: c.textSecondary)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit Routine' : 'New Routine',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleM(c.textPrimary)
                          .copyWith(fontSize: 16, letterSpacing: -0.1),
                    ),
                  ),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.accentIron,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Save',
                        style: AppTypography.bodyS(Colors.white).copyWith(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg,
                    AppSpacing.md, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    Container(
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: TextField(
                        controller: _nameCtrl,
                        autofocus: !_isEdit,
                        style: AppTypography.titleM(c.textPrimary)
                            .copyWith(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Routine name…',
                          hintStyle: AppTypography.titleM(c.textTertiary)
                              .copyWith(fontSize: 16),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Color picker
                    const SectionHeader(label: 'Color'),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: _palette.map((color) {
                        final active = _colorValue == color.toARGB32();
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _colorValue = color.toARGB32()),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(
                                right: AppSpacing.sm),
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: active
                                  ? Border.all(
                                      color: Colors.white, width: 3)
                                  : null,
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                          color: color.withValues(
                                              alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1)
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Exercises
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionHeader(label: 'Exercises'),
                        Text(
                          '${_exercises.length} exercise${_exercises.length == 1 ? '' : 's'}',
                          style: AppTypography.bodyS(c.textTertiary)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    if (_exercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: c.divider,
                              style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Text('No exercises yet',
                                style: AppTypography.bodyM(c.textTertiary)
                                    .copyWith(fontSize: 14)),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Tap Add Exercise to get started',
                                style: AppTypography.bodyS(c.textTertiary)
                                    .copyWith(fontSize: 11)),
                          ],
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exercises.length,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx--;
                            final item =
                                _exercises.removeAt(oldIdx);
                            _exercises.insert(newIdx, item);
                          });
                        },
                        itemBuilder: (_, i) {
                          final ex = _exercises[i];
                          return _ExerciseItem(
                            key: ValueKey(ex.id),
                            exercise: ex,
                            accentColor: Color(_colorValue),
                            onEdit: () => _editSets(i),
                            onDelete: () => _removeExercise(i),
                            c: c,
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacing.md),
                    GhostButton(
                      label: '+ Add Exercise',
                      onPressed: _addExercise,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise item in editor ────────────────────────────────
class _ExerciseItem extends StatelessWidget {
  const _ExerciseItem({
    super.key,
    required this.exercise,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
    required this.c,
  });

  final WorkoutExercise exercise;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final AppColors c;

  String get _setsSummary {
    final sets = exercise.sets
        .where((s) => s.type != SetType.warmup)
        .toList();
    if (sets.isEmpty) return '0 sets';
    final reps = sets.first.reps;
    final allSameReps = sets.every((s) => s.reps == reps);
    final weight = sets.first.weight;
    final allSameWeight = sets.every((s) => s.weight == weight);
    final weightStr = allSameWeight
        ? (weight == 0 ? 'BW' : '${weight % 1 == 0 ? weight.toInt() : weight} ${WeightUnit.suffix}')
        : 'varies';
    final repsStr = allSameReps ? '$reps reps' : 'varies';
    return '${sets.length} × $repsStr · $weightStr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
        title: Text(
          exercise.name,
          style: AppTypography.bodyM(c.textPrimary)
              .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${exercise.muscle} · ${exercise.equipment}',
              style: AppTypography.bodyS(c.textTertiary)
                  .copyWith(fontSize: 11),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _setsSummary,
                  style: AppTypography.bodyS(accentColor).copyWith(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.delete_outline_rounded,
                    color: c.errorRose, size: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.drag_handle_rounded,
                  color: c.textTertiary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit Sets Sheet ────────────────────────────────────────
class _EditSetsSheet extends StatefulWidget {
  const _EditSetsSheet({
    required this.exercise,
    required this.onChanged,
  });
  final WorkoutExercise exercise;
  final void Function(WorkoutExercise) onChanged;

  @override
  State<_EditSetsSheet> createState() => _EditSetsSheetState();
}

class _EditSetsSheetState extends State<_EditSetsSheet> {
  late List<SetRowData> _sets;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.exercise.sets);
  }

  void _notify() {
    widget.onChanged(WorkoutExercise(
      id: widget.exercise.id,
      name: widget.exercise.name,
      muscle: widget.exercise.muscle,
      equipment: widget.exercise.equipment,
      sets: _sets,
    ));
  }

  void _addSet() {
    setState(() {
      final last = _sets.isNotEmpty ? _sets.last : null;
      _sets.add(SetRowData(
        index: _sets.length,
        type: SetType.normal,
        weight: last?.weight ?? 0,
        reps: last?.reps ?? 0,
      ));
    });
    _notify();
  }

  void _removeSet(int i) {
    setState(() {
      _sets.removeAt(i);
      _sets = _sets
          .asMap()
          .entries
          .map((e) => SetRowData(
                index: e.key,
                type: e.value.type,
                weight: e.value.weight,
                reps: e.value.reps,
                prev: e.value.prev,
                isDone: false,
              ))
          .toList();
    });
    _notify();
  }

  void _updateWeight(int i, double w) {
    setState(() {
      final s = _sets[i];
      _sets[i] = SetRowData(
          index: s.index, type: s.type,
          weight: w, reps: s.reps, prev: s.prev);
    });
    _notify();
  }

  void _updateReps(int i, int r) {
    setState(() {
      final s = _sets[i];
      _sets[i] = SetRowData(
          index: s.index, type: s.type,
          weight: s.weight, reps: r, prev: s.prev);
    });
    _notify();
  }

  void _toggleType(int i) {
    setState(() {
      final s = _sets[i];
      final next = s.type == SetType.warmup
          ? SetType.normal
          : s.type == SetType.normal
              ? SetType.drop
              : SetType.warmup;
      _sets[i] = SetRowData(
          index: s.index, type: next,
          weight: s.weight, reps: s.reps, prev: s.prev);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 16, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.exercise.name,
                          style: AppTypography.titleM(c.textPrimary)
                              .copyWith(
                                  fontSize: 16, letterSpacing: -0.1)),
                      Text(
                          '${widget.exercise.muscle} · ${widget.exercise.equipment}',
                          style: AppTypography.bodyS(c.textTertiary)
                              .copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text('Done',
                        style: AppTypography.bodyM(c.accentIron)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          // Column headers
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: ['Type', 'Weight (${WeightUnit.suffix})', 'Reps', '']
                  .map((h) => Expanded(
                        child: Text(h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                                letterSpacing: 0.5)),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _sets.length,
              itemBuilder: (_, i) {
                final s = _sets[i];
                final typeLabel = switch (s.type) {
                  SetType.warmup  => 'W',
                  SetType.drop    => 'D',
                  SetType.failure => 'F',
                  SetType.normal  => '${i + 1}',
                };
                final typeColor = switch (s.type) {
                  SetType.warmup  => c.accentIron,
                  SetType.drop    => c.textTertiary,
                  SetType.failure => c.errorRose,
                  SetType.normal  => c.textTertiary,
                };
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: c.divider.withValues(alpha: 0.27))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleType(i),
                          child: Center(
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color:
                                    typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Center(
                                child: Text(typeLabel,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: typeColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: _MiniStepper(
                        value: s.weight,
                        step: 2.5,
                        onChanged: (v) => _updateWeight(i, v),
                        c: c,
                      )),
                      Expanded(child: _MiniStepper(
                        value: s.reps.toDouble(),
                        step: 1,
                        onChanged: (v) => _updateReps(i, v.toInt()),
                        c: c,
                      )),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _removeSet(i),
                            child: Icon(Icons.remove_circle_outline_rounded,
                                color: c.errorRose, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm,
                AppSpacing.md, AppSpacing.md),
            child: SafeArea(
              top: false,
              child: GhostButton(
                label: '+ Add Set',
                onPressed: _addSet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
    required this.value,
    required this.step,
    required this.onChanged,
    required this.c,
  });
  final double value;
  final double step;
  final void Function(double) onChanged;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () =>
              onChanged((value - step).clamp(0, double.infinity)),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text('−',
                  style: TextStyle(
                      fontSize: 16, color: c.textSecondary)),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value % 1 == 0 ? '${value.toInt()}' : '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.textPrimary),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(value + step),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text('+',
                  style: TextStyle(
                      fontSize: 16, color: c.textSecondary)),
            ),
          ),
        ),
      ],
    );
  }
}
