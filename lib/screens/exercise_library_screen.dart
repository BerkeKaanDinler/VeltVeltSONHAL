// VELT — Exercise Library
// Browse all 80+ exercises with muscle/equipment filters, live search,
// and a detail sheet showing instructions, tips, and "Start as quick set".
//
// Used from Train → Library tab.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../data/exercise_library.dart';
import '../models/workout.dart' show WorkoutExercise;
import '../widgets/set_row.dart' show SetRowData, SetType;
import '../widgets/shared_widgets.dart' show VeltFilterChip;

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.onStartWorkout});

  /// Called when the user starts a single-exercise quick workout from the
  /// detail sheet. If null, the start CTA is hidden.
  final void Function(String name, List<WorkoutExercise> exercises)?
      onStartWorkout;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _muscle = 'All';
  String _equipment = 'All';
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final results = filterExercises(
      muscle: _muscle,
      equipment: _equipment,
      query: _query,
    );
    final isBrowsing = _muscle == 'All' && _query.isEmpty;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(count: results.length, c: c, muscle: _muscle),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, 4, AppSpacing.screenH, 0),
                child: _SearchField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  c: c,
                ),
              ),
            ),
            // Active filter chip when a muscle is selected
            if (_muscle != 'All' || _equipment != 'All')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 12, AppSpacing.screenH, 0),
                  child: _ActiveFilterRow(
                    muscle: _muscle,
                    equipment: _equipment,
                    c: c,
                    onClearMuscle: () => setState(() => _muscle = 'All'),
                    onClearEquipment: () =>
                        setState(() => _equipment = 'All'),
                  ),
                ),
              ),
            // Muscle grid — only when browsing all
            if (isBrowsing)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 18, AppSpacing.screenH, 0),
                  child: _SectionHeading('Browse by muscle', c: c),
                ),
              ),
            if (isBrowsing)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, 12, AppSpacing.screenH, 4),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final m = _browseMuscles[i];
                      return _MuscleTile(
                        muscle: m,
                        count: filterExercises(muscle: m).length,
                        onTap: () => setState(() {
                          _muscle = m;
                          HapticFeedback.selectionClick();
                        }),
                        c: c,
                      );
                    },
                    childCount: _browseMuscles.length,
                  ),
                ),
              ),
            // Equipment chips
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenH, isBrowsing ? 22 : 14, 0, 0),
                child: _SectionHeading(
                  isBrowsing ? 'Filter by equipment' : 'Equipment',
                  c: c,
                  padding: const EdgeInsets.only(right: AppSpacing.screenH),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, 10, 0, 4),
                child: _ChipRow(
                  values: kEquipmentTypes,
                  selected: _equipment,
                  onTap: (v) => setState(() => _equipment = v),
                  dim: true,
                ),
              ),
            ),
            // Results header
            if (!isBrowsing || _equipment != 'All')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 18, AppSpacing.screenH, 0),
                  child: _SectionHeading(
                    '${results.length} exercise${results.length == 1 ? '' : 's'}',
                    c: c,
                  ),
                ),
              ),
            if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyView(
                  c: c,
                  onReset: () => setState(() {
                    _muscle = 'All';
                    _equipment = 'All';
                    _query = '';
                    _searchCtrl.clear();
                  }),
                ),
              )
            else if (!isBrowsing || _equipment != 'All' || _query.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, 12, AppSpacing.screenH, 96),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ExerciseRow(
                    exercise: results[i],
                    onTap: () => _openDetail(results[i]),
                    c: c,
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  static const _browseMuscles = [
    'Chest',
    'Back',
    'Shoulders',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Biceps',
    'Triceps',
    'Core',
    'Calves',
    'Traps',
    'Forearms',
  ];

  void _openDetail(VeltExercise e) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(
        exercise: e,
        onStart: widget.onStartWorkout == null
            ? null
            : () {
                Navigator.of(context).pop();
                _startSingleExercise(e);
              },
      ),
    );
  }

  void _startSingleExercise(VeltExercise e) {
    final exercise = WorkoutExercise(
      id: e.id,
      name: e.name,
      muscle: e.muscle,
      equipment: e.equipment,
      sets: const [
        SetRowData(index: 0, type: SetType.warmup, weight: 0, reps: 10),
        SetRowData(index: 1, type: SetType.normal, weight: 0, reps: 8),
        SetRowData(index: 2, type: SetType.normal, weight: 0, reps: 8),
        SetRowData(index: 3, type: SetType.normal, weight: 0, reps: 8),
      ],
    );
    widget.onStartWorkout!(e.name, [exercise]);
  }
}

// ── Header ─────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.count, required this.c, required this.muscle});
  final int count;
  final AppColors c;
  final String muscle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            muscle == 'All' ? 'Exercise Library' : muscle,
            style: AppTypography.displayL(c.textPrimary).copyWith(
              fontSize: 32,
              height: 1.04,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            muscle == 'All'
                ? '${kExerciseLibrary.length} exercises • detailed form cues'
                : '$count ${muscle.toLowerCase()} exercise${count == 1 ? '' : 's'}',
            style: AppTypography.bodyS(c.textTertiary)
                .copyWith(fontSize: 13, height: 1),
          ),
        ],
      ),
    );
  }
}

// ── Search ─────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.c,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: c.textTertiary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: c.accentIron,
              style: AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search exercises…',
                hintStyle: AppTypography.bodyM(c.textTertiary)
                    .copyWith(fontSize: 14),
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
                HapticFeedback.selectionClick();
              },
              child: Icon(Icons.close_rounded, color: c.textTertiary, size: 18),
            ),
        ],
      ),
    );
  }
}

// ── Section heading ─────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text, {required this.c, this.padding});
  final String text;
  final AppColors c;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          color: c.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Muscle tile (browse grid) ───────────────────────────────────
class _MuscleTile extends StatelessWidget {
  const _MuscleTile({
    required this.muscle,
    required this.count,
    required this.onTap,
    required this.c,
  });
  final String muscle;
  final int count;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final hue = _muscleColor(muscle, c);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hue.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: hue.withValues(alpha: .35)),
                ),
                alignment: Alignment.center,
                child: Icon(_muscleIcon(muscle), color: hue, size: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    muscle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 12.5,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _muscleIcon(String m) {
  switch (m) {
    case 'Chest':       return Icons.shield_outlined;
    case 'Back':        return Icons.swap_vert_rounded;
    case 'Shoulders':
    case 'Rear Delts':
    case 'Traps':       return Icons.architecture_outlined;
    case 'Quads':
    case 'Hamstrings':
    case 'Glutes':
    case 'Calves':      return Icons.directions_run_rounded;
    case 'Biceps':
    case 'Triceps':
    case 'Forearms':    return Icons.front_hand_outlined;
    case 'Core':        return Icons.center_focus_strong_rounded;
    default:            return Icons.fitness_center_rounded;
  }
}

// ── Active filter row ───────────────────────────────────────────
class _ActiveFilterRow extends StatelessWidget {
  const _ActiveFilterRow({
    required this.muscle,
    required this.equipment,
    required this.c,
    required this.onClearMuscle,
    required this.onClearEquipment,
  });
  final String muscle;
  final String equipment;
  final AppColors c;
  final VoidCallback onClearMuscle;
  final VoidCallback onClearEquipment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (muscle != 'All') _Tag(muscle, onClear: onClearMuscle, c: c),
        if (equipment != 'All')
          _Tag(equipment, onClear: onClearEquipment, c: c),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.onClear, required this.c});
  final String label;
  final VoidCallback onClear;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClear,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
        decoration: BoxDecoration(
          color: c.accentIron.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.accentIron.withValues(alpha: .3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.accentIron,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.close_rounded, color: c.accentIron, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Chip row ───────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.onTap,
    this.dim = false,
  });
  final List<String> values;
  final String selected;
  final ValueChanged<String> onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: AppSpacing.screenH),
        itemCount: values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => VeltFilterChip(
          label: values[i],
          active: values[i] == selected,
          onTap: () => onTap(values[i]),
        ),
      ),
    );
  }
}

// ── Exercise row ───────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.onTap,
    required this.c,
  });
  final VeltExercise exercise;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.divider),
          ),
          child: Row(
            children: [
              _MuscleBadge(muscle: exercise.muscle, c: c),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.bodyL(c.textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exercise.equipment} • ${exercise.mechanic} • ${exercise.difficulty}',
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                          fontSize: 11.5, height: 1.1),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: c.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleBadge extends StatelessWidget {
  const _MuscleBadge({required this.muscle, required this.c});
  final String muscle;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final hue = _muscleColor(muscle, c);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: hue.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hue.withValues(alpha: .32)),
      ),
      alignment: Alignment.center,
      child: Text(
        _muscleAbbr(muscle),
        style: TextStyle(
          fontFamily: 'Inter',
          color: hue,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

String _muscleAbbr(String m) {
  switch (m) {
    case 'Chest':       return 'CHE';
    case 'Back':        return 'BCK';
    case 'Shoulders':   return 'SHL';
    case 'Rear Delts':  return 'RDL';
    case 'Quads':       return 'QDS';
    case 'Hamstrings':  return 'HAM';
    case 'Glutes':      return 'GLT';
    case 'Calves':      return 'CLV';
    case 'Biceps':      return 'BIC';
    case 'Triceps':     return 'TRI';
    case 'Core':        return 'COR';
    case 'Traps':       return 'TRP';
    case 'Forearms':    return 'FRM';
    default:            return m.substring(0, 3).toUpperCase();
  }
}

Color _muscleColor(String m, AppColors c) {
  switch (m) {
    case 'Chest':
    case 'Front Delts':
      return const Color(0xFFD97706);
    case 'Back':
    case 'Rear Delts':
    case 'Traps':
      return const Color(0xFF3B82F6);
    case 'Shoulders':
      return const Color(0xFFA855F7);
    case 'Quads':
    case 'Hamstrings':
    case 'Glutes':
    case 'Calves':
      return const Color(0xFF10B981);
    case 'Biceps':
    case 'Triceps':
    case 'Forearms':
      return const Color(0xFFEF4444);
    case 'Core':
      return const Color(0xFFF59E0B);
    default:
      return c.accentIron;
  }
}

// ── Empty state ────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.c, required this.onReset});
  final AppColors c;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: c.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text('No matches',
                style: AppTypography.titleL(c.textPrimary)
                    .copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Try a different muscle group, equipment, or search term.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyM(c.textTertiary)
                  .copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.divider),
                ),
                child: Text(
                  'Clear filters',
                  style: AppTypography.bodyM(c.textPrimary).copyWith(
                      fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail sheet ───────────────────────────────────────────────
class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({required this.exercise, this.onStart});
  final VeltExercise exercise;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg)),
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
                  Text(exercise.name,
                      style: AppTypography.displayM(c.textPrimary)
                          .copyWith(fontSize: 26, letterSpacing: -0.4)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Pill(exercise.muscle, c.accentIron, c),
                      _Pill(exercise.equipment, c.textSecondary, c),
                      _Pill(exercise.mechanic, c.textSecondary, c),
                      _Pill(exercise.difficulty, c.warningAmber, c),
                      _Pill(exercise.force, c.textSecondary, c),
                    ],
                  ),
                  if (exercise.secondary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionLabel('Also Works', c),
                    const SizedBox(height: 6),
                    Text(exercise.secondary.join(' • '),
                        style: AppTypography.bodyM(c.textSecondary)
                            .copyWith(fontSize: 13.5)),
                  ],
                  const SizedBox(height: 18),
                  _SectionLabel('How to', c),
                  const SizedBox(height: 8),
                  ...List.generate(exercise.instructions.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: c.accentIron.withValues(alpha: .14),
                              border: Border.all(
                                  color: c.accentIron.withValues(alpha: .35)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: c.accentIron,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.instructions[i],
                              style: AppTypography.bodyM(c.textPrimary)
                                  .copyWith(fontSize: 13.5, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionLabel('Coach Tips', c),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: c.warningAmber.withValues(alpha: .35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final t in exercise.tips)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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
                                    child: Text(
                                      t,
                                      style: AppTypography.bodyM(c.textPrimary)
                                          .copyWith(
                                              fontSize: 13, height: 1.45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onStart != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 8, AppSpacing.screenH, 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onStart!();
                    },
                    child: Container(
                      height: AppTouchTarget.primaryButton,
                      decoration: BoxDecoration(
                        color: c.accentIron,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Quick start workout',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: c.accentIron.computeLuminance() > .55
                              ? c.ink
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.c);
  final String text;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        color: c.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color, this.c);
  final String text;
  final Color color;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .32)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
