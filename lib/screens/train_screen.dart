import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import '../services/prefs_service.dart';
import '../data/program_data.dart';
import '../models/workout.dart' show WorkoutExercise;
import 'routine_editor_screen.dart';
import '../utils/training_helpers.dart';

// ── Program catalogue ─────────────────────────────────────────
class _Program {
  const _Program({
    required this.id,
    required this.name,
    required this.tagline,
    required this.level,
    required this.daysPerWeek,
    required this.goal,
    required this.goalColor,
    required this.muscleGroups,
    required this.description,
    required this.bestFor,
  });
  final String id;
  final String name;
  final String tagline;
  final String level;
  final String daysPerWeek;
  final String goal;
  final Color goalColor;
  final List<String> muscleGroups;
  final String description;
  final String bestFor;
}

const _programs = [
  _Program(
    id: 'ppl',
    name: 'Push Pull Legs',
    tagline: 'The most popular muscle-building split',
    level: 'Intermediate',
    daysPerWeek: '6 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Chest', 'Back', 'Shoulders', 'Legs', 'Arms'],
    description:
        'Groups exercises by movement type: pushing muscles (chest/shoulders/triceps), pulling muscles (back/biceps), and legs. '
        'Each group is trained twice per week. Most popular split for building a balanced physique.',
    bestFor: 'Someone who can train 5-6 days/week and wants to build muscle evenly.',
  ),
  _Program(
    id: '5x5',
    name: 'StrongLifts 5×5',
    tagline: 'The fastest way for beginners to get strong',
    level: 'Beginner',
    daysPerWeek: '3 days/week',
    goal: 'Get Strong',
    goalColor: Color(0xFF22C55E),
    muscleGroups: ['Full Body', 'Compound', 'Squat', 'Bench', 'Row'],
    description:
        'Only 3 compound exercises per session: Squat, Bench Press/OHP, and Barbell Row/Deadlift. '
        'Add 2.5 kg every workout. Simple, proven, and very effective for beginners.',
    bestFor: 'Absolute beginners who want to get strong fast with minimum complexity.',
  ),
  _Program(
    id: '531',
    name: '5/3/1 by Wendler',
    tagline: 'Long-term strength through wave loading',
    level: 'Intermediate',
    daysPerWeek: '4 days/week',
    goal: 'Get Strong',
    goalColor: Color(0xFF22C55E),
    muscleGroups: ['Squat', 'Bench', 'Deadlift', 'OHP'],
    description:
        '4 main lifts, each trained once per week with rotating intensity: 65/75/85%, 70/80/90%, 75/85/95%, then deload. '
        'The top set is taken to near failure (AMRAP). Works for years without burning out.',
    bestFor: 'Someone who has been lifting 6+ months and wants to keep getting stronger long-term.',
  ),
  _Program(
    id: 'ul',
    name: 'Upper / Lower',
    tagline: 'Balanced 4-day split, great for beginners',
    level: 'Beginner',
    daysPerWeek: '4 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Upper Body', 'Lower Body', 'Compound'],
    description:
        'Two upper-body days and two lower-body days per week. Upper A focuses on strength (lower reps), Upper B on volume (higher reps). '
        'Each muscle gets hit twice per week, which is ideal for growth.',
    bestFor: 'Beginners or intermediates who want a simple, proven 4-day schedule.',
  ),
  _Program(
    id: 'gzclp',
    name: 'GZCLP',
    tagline: 'Tier-based training for strength + volume',
    level: 'Intermediate',
    daysPerWeek: '3–4 days/week',
    goal: 'Strength + Size',
    goalColor: Color(0xFF6366F1),
    muscleGroups: ['Full Body', 'Compound', 'Accessories'],
    description:
        'Uses a tier system: T1 (5×3 max strength), T2 (4×6 volume), T3 (isolation/accessories). '
        'Linear progression on all tiers with different failure protocols. Very systematic.',
    bestFor: 'Lifters who want a structured system that builds both strength and size simultaneously.',
  ),
  _Program(
    id: 'nsuns',
    name: 'nSuns 5/3/1',
    tagline: 'High volume powerlifting — not for beginners',
    level: 'Advanced',
    daysPerWeek: '5 days/week',
    goal: 'Powerlifting',
    goalColor: Color(0xFF6366F1),
    muscleGroups: ['Squat', 'Bench', 'Deadlift', 'OHP'],
    description:
        'Adds significant volume to the classic 5/3/1 framework through 8-9 set ladders per main lift. '
        'Weekly progression on training maxes. Very demanding — requires good recovery.',
    bestFor: 'Experienced lifters who want maximum strength gains and can handle 5 hard sessions/week.',
  ),
  _Program(
    id: 'beg-full',
    name: 'Beginner Full Body',
    tagline: 'The safest way to start lifting',
    level: 'Beginner',
    daysPerWeek: '3 days/week',
    goal: 'Get Strong',
    goalColor: Color(0xFF22C55E),
    muscleGroups: ['Full Body', 'Compound', 'Squat', 'Bench', 'Deadlift'],
    description:
        'Two alternating full-body workouts, each containing a squat, a press, a pull, and a hinge. '
        'Trains every muscle three times per week with low enough volume to recover between sessions.',
    bestFor: 'True beginners who want to build a foundation of strength and technique.',
  ),
  _Program(
    id: 'ppl-3d',
    name: 'PPL 3-Day',
    tagline: 'Push Pull Legs — compact 3-day version',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Chest', 'Back', 'Shoulders', 'Legs', 'Arms'],
    description:
        'A condensed PPL where each muscle group is trained once per week with higher volume per session. '
        'Good for those who want the PPL split but can only train 3 days.',
    bestFor: 'Intermediates with busy schedules who prefer full sessions over training frequency.',
  ),
  _Program(
    id: 'fb-hyper',
    name: 'Full Body Hypertrophy',
    tagline: 'High-frequency full body for muscle growth',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Full Body', 'Compound', 'Isolation'],
    description:
        'Trains every muscle three times per week with moderate weight and higher rep ranges. '
        'Each of the three sessions has a different emphasis: squat, hip hinge, and deadlift patterns.',
    bestFor: 'Intermediates who want maximum muscle growth with 3 training days.',
  ),
  _Program(
    id: 'strength-3d',
    name: 'Strength 3-Day',
    tagline: 'Pure strength, minimum fluff',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Get Strong',
    goalColor: Color(0xFF22C55E),
    muscleGroups: ['Squat', 'Bench', 'Deadlift', 'OHP', 'Row'],
    description:
        'Two alternating workouts focused on the big 5 compound lifts with low reps and high intensity. '
        'No isolation work — just the movements that build the most strength.',
    bestFor: 'Lifters who want to increase their squat, bench, deadlift, and overhead press.',
  ),
  _Program(
    id: 'powerbuilding',
    name: 'Powerbuilding',
    tagline: 'Strength and size — best of both worlds',
    level: 'Intermediate',
    daysPerWeek: '4 days/week',
    goal: 'Strength + Size',
    goalColor: Color(0xFF6366F1),
    muscleGroups: ['Squat', 'Bench', 'Deadlift', 'OHP', 'Full Body'],
    description:
        'Each session starts with a powerlifting-style strength block (low reps, high intensity) '
        'followed by bodybuilding-style accessory volume. The best approach for getting both stronger and bigger.',
    bestFor: 'Intermediate lifters who want to get strong on the big lifts while building visible muscle.',
  ),
  _Program(
    id: 'chest-tri',
    name: 'Chest & Triceps Focus',
    tagline: 'Build a powerful pushing presence',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
    description:
        'Three rotating push sessions targeting chest and triceps from multiple angles. '
        'Combines heavy compound pressing with isolation work for complete development.',
    bestFor: 'Anyone who wants to prioritize upper body pushing strength and chest size.',
  ),
  _Program(
    id: 'back-bi',
    name: 'Back & Biceps Focus',
    tagline: 'Build width, thickness, and arm size',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Back', 'Biceps', 'Rear Delt'],
    description:
        'Three rotating pull sessions targeting back width, back thickness, and biceps. '
        'Includes deadlifts, rows, pulldowns, and curls for complete posterior chain development.',
    bestFor: 'Anyone who wants to build a wider, thicker back and bigger arms.',
  ),
  _Program(
    id: 'leg-growth',
    name: 'Leg Growth Focus',
    tagline: 'Quad, hamstring, and glute development',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    description:
        'Three leg sessions with different emphases: quad-dominant, posterior chain, and full leg. '
        'Combines squats, hinges, hip thrusts, lunges, and isolation work for complete leg development.',
    bestFor: 'Anyone who wants to build bigger, more defined legs.',
  ),
  _Program(
    id: 'shoulders',
    name: 'Shoulder Width Focus',
    tagline: 'Build the width that defines your physique',
    level: 'Intermediate',
    daysPerWeek: '3 days/week',
    goal: 'Build Muscle',
    goalColor: Color(0xFFD97706),
    muscleGroups: ['Shoulders', 'Traps', 'Rear Delt'],
    description:
        'Three shoulder sessions targeting front, side, and rear deltoids. '
        'High lateral raise volume for width, balanced with pressing strength and rear delt health.',
    bestFor: 'Anyone who wants broader shoulders and a more athletic-looking upper body.',
  ),
];

// ── TrainScreen ───────────────────────────────────────────────
class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key, required this.onStartWorkout});
  final void Function(String, List<WorkoutExercise>?) onStartWorkout;

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  String _levelFilter = 'All';
  _Program? _selectedProgram;

  void _openNewRoutine() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RoutineEditorScreen()),
    );
  }

  void _showRoutineOptions(BuildContext context, Routine r) {
    final c = Theme.of(context).extension<AppColors>()!;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                r.name,
                style: AppTypography.titleM(c.textPrimary).copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ListTile(
              leading: Icon(Icons.play_circle_outline_rounded,
                  color: c.accentIron),
              title: Text('Start Workout',
                  style: AppTypography.bodyM(c.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _startRoutine(r);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: c.textSecondary),
              title: Text('Edit Routine',
                  style: AppTypography.bodyM(c.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RoutineEditorScreen(existing: r),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.errorRose),
              title: Text('Delete Routine',
                  style: AppTypography.bodyM(c.errorRose)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(r);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _startRoutine(Routine r) {
    widget.onStartWorkout(r.name, r.exercises.isNotEmpty ? r.exercises : null);
  }

  void _confirmDelete(Routine r) {
    RoutineStore.delete(r.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('"${r.name}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => RoutineStore.add(r),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProgram != null) {
      return _ProgramDetailScreen(
        program: _selectedProgram!,
        onBack: () => setState(() => _selectedProgram = null),
        onStartWorkout: widget.onStartWorkout,
        onProgramAdded: () => setState(() => _selectedProgram = null),
      );
    }

    final c = Theme.of(context).extension<AppColors>()!;
    final experienceLevel = PrefsService.experienceLevel;
    final fitnessGoal = PrefsService.fitnessGoal;
    final filtered = _levelFilter == 'All'
        ? _programs
        : _programs.where((p) => p.level == _levelFilter).toList();

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xl,
                  AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Train',
                      style: AppTypography.displayL(c.textPrimary).copyWith(
                        fontSize: 34, letterSpacing: -1, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your routines & programs',
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                        fontSize: 13, height: 1),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── My Routines ──────────────────────────
                  Row(
                    children: [
                      const SectionHeader(label: 'My Routines'),
                      const Spacer(),
                      GhostButton(
                        label: '+ New Routine',
                        onPressed: _openNewRoutine,
                        height: 32,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ValueListenableBuilder<List<Routine>>(
                    valueListenable: RoutineStore.routines,
                    builder: (context, routines, _) {
                      if (routines.isEmpty) {
                        return _EmptyRoutines(
                          onAdd: _openNewRoutine,
                          onBrowsePrograms: () =>
                              setState(() => _levelFilter = 'All'),
                          c: c,
                        );
                      }
                      return Column(
                        children: List.generate(routines.length, (i) {
                          final r = routines[i];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i < routines.length - 1 ? 12 : 0),
                            child: _RoutineCard(
                              routine: r,
                              onTap: () => _startRoutine(r),
                              onLongPress: () =>
                                  _showRoutineOptions(context, r),
                              c: c,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Quick Start strip ─────────────────────
                  _QuickStartBar(
                    onQuickStart: () =>
                        widget.onStartWorkout('Empty Workout', null),
                    c: c,
                  ),
                  const SizedBox(height: 28),

                  // ── Training Programs ─────────────────────
                  // Section divider
                  Row(
                    children: [
                      Expanded(child: Container(
                        height: 1,
                        color: c.divider.withValues(alpha: 0.4))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'EXPLORE PROGRAMS',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, letterSpacing: 1.4,
                            fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(child: Container(
                        height: 1,
                        color: c.divider.withValues(alpha: 0.4))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Recommended banner
                  _RecommendedBanner(
                    text: TrainingHelpers.recommendationText(fitnessGoal, experienceLevel),
                    c: c,
                  ),
                  const SizedBox(height: 12),

                  // Filter chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        const levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
                        return VeltFilterChip(
                          label: levels[i],
                          active: _levelFilter == levels[i],
                          onTap: () => setState(() => _levelFilter = levels[i]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Program cards — goal-matching first
                  ...() {
                    final sorted = [...filtered]..sort((a, b) {
                      final aM = TrainingHelpers.programMatchesGoal(a.goal, fitnessGoal) ? 0 : 1;
                      final bM = TrainingHelpers.programMatchesGoal(b.goal, fitnessGoal) ? 0 : 1;
                      return aM.compareTo(bM);
                    });
                    return List.generate(sorted.length, (i) {
                      final p = sorted[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i < sorted.length - 1 ? 10 : 0),
                        child: _ProgramCard(
                          program: p,
                          onTap: () => setState(() => _selectedProgram = p),
                          matchesGoal: TrainingHelpers.programMatchesGoal(p.goal, fitnessGoal),
                          c: c,
                        ),
                      );
                    });
                  }(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Start Bar (compact) ─────────────────────────────────
class _QuickStartBar extends StatelessWidget {
  const _QuickStartBar({required this.onQuickStart, required this.c});
  final VoidCallback onQuickStart;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onQuickStart();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: c.accentIron.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.bolt_rounded,
                color: c.accentIron, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empty Workout',
                    style: AppTypography.titleS(c.textPrimary).copyWith(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Quick session — no routine needed',
                    style: AppTypography.bodyS(c.textTertiary).copyWith(
                      fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: c.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Routine Card (rich version) ───────────────────────────────
class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onLongPress,
    required this.c,
  });
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final AppColors c;

  String get _estimatedTime {
    final sets = routine.exercises.fold(0, (a, e) => a + e.sets.length);
    final mins = (sets * 2.5).round();
    return '~$mins min';
  }

  List<String> get _muscleGroups {
    final groups = routine.exercises.map((e) => e.muscle).toSet().toList();
    return groups.take(3).toList();
  }

  bool get _doneToday {
    if (routine.lastDone == null) return false;
    final now = DateTime.now();
    final d = routine.lastDone!;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _muscleGroups;
    final exCount = routine.exercises.length;
    final doneToday = _doneToday;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Opacity(
        opacity: doneToday ? 0.70 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            border: Border.all(color: c.divider.withValues(alpha: 0.5), width: 0.5),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left color bar — thicker accent
                Container(width: 4, color: routine.color),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.name,
                                style: AppTypography.titleM(c.textPrimary).copyWith(
                                  fontSize: 15, letterSpacing: -0.1),
                              ),
                              const SizedBox(height: 7),
                              if (muscles.isNotEmpty)
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 4,
                                  children: muscles.map((m) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: routine.color.withValues(alpha: 0.13),
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: Text(
                                      m,
                                      style: AppTypography.caption(routine.color).copyWith(
                                        fontSize: 10.5, fontWeight: FontWeight.w600,
                                        letterSpacing: 0.02),
                                    ),
                                  )).toList(),
                                ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Text(
                                    '$exCount ex · $_estimatedTime',
                                    style: AppTypography.caption(c.textTertiary).copyWith(
                                      fontSize: 10, letterSpacing: 0.01),
                                  ),
                                  if (doneToday) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: c.successLime.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_rounded, size: 9, color: c.successLime),
                                          const SizedBox(width: 3),
                                          Text('Done today', style: AppTypography.caption(c.successLime).copyWith(
                                            fontSize: 9.5, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ] else if (routine.lastDone != null) ...[
                                    Text(
                                      ' · Done ${routine.lastDoneLabel}',
                                      style: AppTypography.caption(c.textTertiary).copyWith(
                                        fontSize: 10, letterSpacing: 0.01),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: onLongPress,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(Icons.more_horiz_rounded,
                                  size: 20, color: c.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                onTap();
                              },
                              child: doneToday
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 9),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                        border: Border.all(
                                          color: routine.color.withValues(alpha: 0.55),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.replay_rounded,
                                            size: 11, color: routine.color.withValues(alpha: 0.85)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Again',
                                            style: AppTypography.caption(
                                              routine.color.withValues(alpha: 0.85),
                                            ).copyWith(
                                              fontSize: 12, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 13, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: routine.color,
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.play_arrow_rounded,
                                            size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Start',
                                            style: AppTypography.caption(Colors.white).copyWith(
                                              fontSize: 12, fontWeight: FontWeight.w700,
                                              letterSpacing: 0.02),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty Routines state ──────────────────────────────────────
class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines({
    required this.onAdd,
    required this.onBrowsePrograms,
    required this.c,
  });
  final VoidCallback onAdd;
  final VoidCallback onBrowsePrograms;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_outlined, size: 32, color: c.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No routines yet',
            style: AppTypography.titleS(c.textPrimary).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your own routine or add a ready-made program below.',
            style: AppTypography.bodyS(c.textTertiary).copyWith(
              fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GhostButton(
                  label: 'Create Routine',
                  onPressed: onAdd,
                  height: 40,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Browse Programs',
                  onPressed: onBrowsePrograms,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recommended banner ────────────────────────────────────────
class _RecommendedBanner extends StatelessWidget {
  const _RecommendedBanner({required this.text, required this.c});
  final String text;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.accentIron.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.accentIron.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: c.accentIron.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.lightbulb_outline_rounded,
                size: 16, color: c.accentIron),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMMENDED FOR YOU',
                  style: AppTypography.caption(c.accentIron).copyWith(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    letterSpacing: 0.02),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: AppTypography.bodyS(c.textPrimary).copyWith(
                    fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Program Card ──────────────────────────────────────────────
class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.onTap,
    required this.c,
    this.matchesGoal = false,
  });
  final _Program program;
  final VoidCallback onTap;
  final AppColors c;
  final bool matchesGoal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: matchesGoal
                ? c.accentIron.withValues(alpha: 0.5)
                : c.divider.withValues(alpha: 0.5),
            width: matchesGoal ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: AppTypography.titleS(c.textPrimary).copyWith(
                          fontSize: 15, letterSpacing: -0.1),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        program.tagline,
                        style: AppTypography.bodyS(c.textSecondary).copyWith(
                          fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _levelColor(program.level).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    program.level.toUpperCase(),
                    style: AppTypography.caption(
                      _levelColor(program.level),
                    ).copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _PillStat(
                  icon: Icons.calendar_today_rounded,
                  label: program.daysPerWeek,
                  c: c,
                ),
                const SizedBox(width: 8),
                _PillStat(
                  icon: Icons.flag_outlined,
                  label: program.goal,
                  color: program.goalColor,
                  c: c,
                ),
                const Spacer(),
                if (matchesGoal)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                        size: 10, color: c.accentIron),
                      const SizedBox(width: 3),
                      Text(
                        'Your goal',
                        style: AppTypography.caption(c.accentIron).copyWith(
                          fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                else
                  Text(
                    'View details →',
                    style: AppTypography.caption(c.accentIron).copyWith(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) => switch (level) {
    'Beginner'     => const Color(0xFF22C55E),
    'Advanced'     => const Color(0xFFEF4444),
    _              => const Color(0xFFD97706),
  };
}

class _PillStat extends StatelessWidget {
  const _PillStat({
    required this.icon,
    required this.label,
    required this.c,
    this.color,
  });
  final IconData icon;
  final String label;
  final AppColors c;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final col = color ?? c.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: col),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption(col).copyWith(
              fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Program Detail Screen ─────────────────────────────────────
class _ProgramDetailScreen extends StatelessWidget {
  const _ProgramDetailScreen({
    required this.program,
    required this.onBack,
    required this.onStartWorkout,
    required this.onProgramAdded,
  });

  final _Program program;
  final VoidCallback onBack;
  final void Function(String, List<WorkoutExercise>?) onStartWorkout;
  final VoidCallback onProgramAdded;

  void _addProgram(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final veltProgram = programById(program.id);
    if (veltProgram == null) return;

    final alreadyAdded = veltProgram.routines.isNotEmpty &&
        RoutineStore.containsId(veltProgram.routines.first.id);

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${veltProgram.name} is already in My Routines'),
          backgroundColor: c.surfaceHigh,
        ),
      );
      return;
    }

    RoutineStore.addAll(veltProgram.routines);
    HapticFeedback.mediumImpact();

    // Show success dialog with option to start now
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: c.successLime, size: 22),
            const SizedBox(width: 8),
            Text('Program Added!',
                style: AppTypography.titleM(c.textPrimary)),
          ],
        ),
        content: Text(
          '${veltProgram.routines.length} routines from ${veltProgram.name} are now in My Routines.\n\nStart your first workout?',
          style: AppTypography.bodyS(c.textSecondary).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onProgramAdded();
            },
            child: Text('Later', style: AppTypography.bodyM(c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final firstRoutine = veltProgram.routines.first;
              onStartWorkout(
                firstRoutine.name,
                firstRoutine.exercises,
              );
            },
            child: Text('Start Now',
                style: AppTypography.bodyM(c.accentIron).copyWith(
                  fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final veltData = _programStaticData[program.id];

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Sticky header ──────────────────────────────
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
                    onTap: onBack,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 44, minHeight: 44),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_new_rounded,
                              size: 14, color: c.accentIron),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: AppTypography.bodyM(c.accentIron).copyWith(
                              fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      program.name,
                      style: AppTypography.titleM(c.textPrimary).copyWith(
                        fontSize: 16, letterSpacing: -0.15),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _levelColor(program.level).withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      program.level.toUpperCase(),
                      style: AppTypography.caption(
                        _levelColor(program.level),
                      ).copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 0.5,
                        fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg,
                  AppSpacing.md, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal + days badges
                    Row(
                      children: [
                        _PillStat(
                          icon: Icons.calendar_today_rounded,
                          label: program.daysPerWeek,
                          c: c,
                        ),
                        const SizedBox(width: 8),
                        _PillStat(
                          icon: Icons.flag_outlined,
                          label: program.goal,
                          color: program.goalColor,
                          c: c,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      program.description,
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                        fontSize: 14, height: 1.65),
                    ),
                    const SizedBox(height: 20),

                    // Best for callout
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.accentIron.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border(
                          left: BorderSide(color: c.accentIron, width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEST FOR',
                            style: AppTypography.caption(c.accentIron).copyWith(
                              fontWeight: FontWeight.w700, letterSpacing: 0.8,
                              fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            program.bestFor,
                            style: AppTypography.bodyS(c.textSecondary).copyWith(
                              fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (veltData != null) ...[
                      // Weekly schedule
                      _DetailSection(label: 'Weekly Schedule', c: c),
                      Container(
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          children: List.generate(
                            veltData.schedule.length, (i) {
                            final row = veltData.schedule[i];
                            final isRest = row.$2 == 'Rest';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                border: i < veltData.schedule.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          color: c.divider.withValues(alpha: 0.3)))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      row.$1,
                                      style: AppTypography.titleS(
                                        c.accentIron,
                                      ).copyWith(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      row.$2,
                                      style: AppTypography.bodyS(
                                        isRest ? c.textTertiary : c.textPrimary,
                                      ).copyWith(
                                        fontSize: 13,
                                        fontStyle: isRest
                                            ? FontStyle.italic
                                            : FontStyle.normal),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sample day
                      _DetailSection(
                        label: 'Sample: ${veltData.sampleDayName}', c: c),
                      ...veltData.sampleExercises.map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c.accentIron,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ex.$1,
                                  style: AppTypography.bodyS(c.textPrimary).copyWith(
                                    fontSize: 13),
                                ),
                              ),
                              Text(
                                ex.$2,
                                style: AppTypography.caption(c.textTertiary).copyWith(
                                  fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),

            // ── Sticky CTA ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                border: Border(top: BorderSide(color: c.divider)),
              ),
              child: SafeArea(
                top: false,
                child: ValueListenableBuilder(
                  valueListenable: RoutineStore.routines,
                  builder: (context, routines, _) {
                    final vp = programById(program.id);
                    final alreadyAdded = vp != null &&
                        vp.routines.isNotEmpty &&
                        routines.any((r) => r.id == vp.routines.first.id);
                    return PrimaryButton(
                      label: alreadyAdded
                          ? '✓ Program Added to Routines'
                          : 'Add Program to My Routines',
                      disabled: alreadyAdded,
                      onPressed: () => _addProgram(context),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) => switch (level) {
    'Beginner' => const Color(0xFF22C55E),
    'Advanced' => const Color(0xFFEF4444),
    _          => const Color(0xFFD97706),
  };
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.c});
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption(c.textTertiary).copyWith(
          fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 10),
      ),
    );
  }
}

// ── Static program content ─────────────────────────────────────
class _ProgramStaticData {
  const _ProgramStaticData({
    required this.schedule,
    required this.sampleDayName,
    required this.sampleExercises,
  });
  final List<(String, String)> schedule;
  final String sampleDayName;
  final List<(String, String)> sampleExercises;
}

const _programStaticData = <String, _ProgramStaticData>{
  'ppl': _ProgramStaticData(
    schedule: [
      ('Mon', 'Push — Chest, Shoulders, Triceps'),
      ('Tue', 'Pull — Back, Biceps'),
      ('Wed', 'Legs — Quads, Hamstrings, Glutes'),
      ('Thu', 'Push — Shoulders focus'),
      ('Fri', 'Pull — Back focus'),
      ('Sat', 'Legs — Hip hinge focus'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Push A (Monday)',
    sampleExercises: [
      ('Bench Press', '4 × 6-8'),
      ('Incline DB Press', '3 × 10'),
      ('Cable Fly', '3 × 12'),
      ('Overhead Press', '3 × 8'),
      ('Lateral Raise', '3 × 15'),
      ('Tricep Pushdown', '3 × 12'),
    ],
  ),
  '5x5': _ProgramStaticData(
    schedule: [
      ('Mon', 'Workout A'),
      ('Tue', 'Rest'),
      ('Wed', 'Workout B'),
      ('Thu', 'Rest'),
      ('Fri', 'Workout A'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Workout A',
    sampleExercises: [
      ('Squat', '5 × 5'),
      ('Bench Press', '5 × 5'),
      ('Barbell Row', '5 × 5'),
    ],
  ),
  '531': _ProgramStaticData(
    schedule: [
      ('Mon', 'Press Day (OHP + assistance)'),
      ('Tue', 'Deadlift Day (DL + assistance)'),
      ('Wed', 'Rest'),
      ('Thu', 'Bench Day (Bench + assistance)'),
      ('Fri', 'Squat Day (Squat + assistance)'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Bench Day',
    sampleExercises: [
      ('Bench Press (65%)', '5 reps'),
      ('Bench Press (75%)', '5 reps'),
      ('Bench Press (85%)', '5+ reps (AMRAP)'),
      ('Incline DB Press', '3 × 10'),
      ('Tricep Pushdown', '3 × 12'),
      ('Face Pull', '3 × 15'),
    ],
  ),
  'ul': _ProgramStaticData(
    schedule: [
      ('Mon', 'Upper A — Strength focus'),
      ('Tue', 'Lower A — Squat dominant'),
      ('Wed', 'Rest'),
      ('Thu', 'Upper B — Hypertrophy focus'),
      ('Fri', 'Lower B — Hinge dominant'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Upper A (Monday)',
    sampleExercises: [
      ('Bench Press', '4 × 5'),
      ('Barbell Row', '4 × 5'),
      ('Overhead Press', '3 × 8'),
      ('Lat Pulldown', '3 × 8'),
      ('Lateral Raise', '3 × 12'),
    ],
  ),
  'gzclp': _ProgramStaticData(
    schedule: [
      ('Mon', 'T1 Squat + T2 Bench + T3 Lat Pull'),
      ('Wed', 'T1 OHP + T2 Deadlift + T3 Row'),
      ('Fri', 'T1 Squat + T2 Bench + T3 Lat Pull'),
      ('Sat', 'T1 OHP + T2 Deadlift + T3 Row'),
    ],
    sampleDayName: 'Day 1',
    sampleExercises: [
      ('Squat (T1)', '5 × 3 — max strength'),
      ('Bench Press (T2)', '4 × 6 — volume'),
      ('Lat Pulldown (T3)', '3 × 10 — accessory'),
    ],
  ),
  'nsuns': _ProgramStaticData(
    schedule: [
      ('Mon', 'OHP + Bench accessory'),
      ('Tue', 'Deadlift + Squat accessory'),
      ('Wed', 'Bench + OHP accessory'),
      ('Thu', 'Squat + Deadlift accessory'),
      ('Fri', 'OHP + Bench accessory'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Bench Day',
    sampleExercises: [
      ('Bench Press × 9 sets', '65–95% ladder'),
      ('OHP (secondary) × 8 sets', '55–90% ladder'),
      ('Dips', '3 × 10'),
      ('Tricep Pushdown', '3 × 12'),
    ],
  ),
  'beg-full': _ProgramStaticData(
    schedule: [
      ('Mon', 'Full Body A'),
      ('Tue', 'Rest'),
      ('Wed', 'Full Body B'),
      ('Thu', 'Rest'),
      ('Fri', 'Full Body A'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Full Body A',
    sampleExercises: [
      ('Squat', '3 × 5'),
      ('Bench Press', '3 × 5'),
      ('Barbell Row', '3 × 5'),
      ('Romanian Deadlift', '2 × 8'),
      ('Plank', '3 × 30 s'),
    ],
  ),
  'ppl-3d': _ProgramStaticData(
    schedule: [
      ('Mon', 'Push — Chest, Shoulders, Triceps'),
      ('Tue', 'Rest'),
      ('Wed', 'Pull — Back, Biceps'),
      ('Thu', 'Rest'),
      ('Fri', 'Legs — Quads, Hamstrings, Glutes'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Push Day',
    sampleExercises: [
      ('Bench Press', '4 × 8'),
      ('Incline DB Press', '3 × 10'),
      ('Lateral Raise', '3 × 15'),
      ('Overhead Press', '3 × 8'),
      ('Tricep Pushdown', '3 × 12'),
    ],
  ),
  'fb-hyper': _ProgramStaticData(
    schedule: [
      ('Mon', 'Full Body A — Squat focus'),
      ('Tue', 'Rest'),
      ('Wed', 'Full Body B — Hip hinge focus'),
      ('Thu', 'Rest'),
      ('Fri', 'Full Body C — Deadlift focus'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Full Body A',
    sampleExercises: [
      ('Squat', '4 × 8'),
      ('Bench Press', '4 × 8'),
      ('Lat Pulldown', '3 × 10'),
      ('Romanian Deadlift', '3 × 10'),
      ('Lateral Raise', '3 × 15'),
    ],
  ),
  'strength-3d': _ProgramStaticData(
    schedule: [
      ('Mon', 'Workout A'),
      ('Tue', 'Rest'),
      ('Wed', 'Workout B'),
      ('Thu', 'Rest'),
      ('Fri', 'Workout A'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Workout A',
    sampleExercises: [
      ('Squat', '4 × 5'),
      ('Bench Press', '4 × 5'),
      ('Barbell Row', '4 × 5'),
      ('Overhead Press', '3 × 5'),
    ],
  ),
  'powerbuilding': _ProgramStaticData(
    schedule: [
      ('Mon', 'Bench — strength + push accessories'),
      ('Tue', 'Squat — legs and quads'),
      ('Wed', 'Rest'),
      ('Thu', 'Deadlift — pull + back accessories'),
      ('Fri', 'OHP — shoulders and arms'),
      ('Sat', 'Rest'),
      ('Sun', 'Rest'),
    ],
    sampleDayName: 'Bench Day',
    sampleExercises: [
      ('Bench Press', '4 × 5 — strength'),
      ('Bench Press', '3 × 8 — volume'),
      ('Incline DB Press', '3 × 10'),
      ('Overhead Press', '3 × 8'),
      ('Tricep Pushdown', '3 × 12'),
    ],
  ),
  'chest-tri': _ProgramStaticData(
    schedule: [
      ('Mon', 'Chest & Triceps A'),
      ('Wed', 'Chest & Triceps B'),
      ('Fri', 'Chest & Triceps C'),
    ],
    sampleDayName: 'Session A',
    sampleExercises: [
      ('Bench Press', '4 × 6'),
      ('Incline Bench Press', '3 × 8'),
      ('Cable Fly', '3 × 12'),
      ('Close-Grip Bench Press', '3 × 8'),
      ('Tricep Pushdown', '3 × 12'),
    ],
  ),
  'back-bi': _ProgramStaticData(
    schedule: [
      ('Mon', 'Back & Biceps A'),
      ('Wed', 'Back & Biceps B'),
      ('Fri', 'Back & Biceps C'),
    ],
    sampleDayName: 'Session A',
    sampleExercises: [
      ('Deadlift', '3 × 5'),
      ('Barbell Row', '4 × 8'),
      ('Lat Pulldown', '3 × 10'),
      ('Barbell Curl', '3 × 10'),
      ('Hammer Curl', '3 × 10'),
    ],
  ),
  'leg-growth': _ProgramStaticData(
    schedule: [
      ('Mon', 'Legs A — Quad focus'),
      ('Wed', 'Legs B — Posterior chain'),
      ('Fri', 'Legs C — Full leg day'),
    ],
    sampleDayName: 'Legs A',
    sampleExercises: [
      ('Squat', '4 × 6'),
      ('Leg Press', '3 × 12'),
      ('Leg Extension', '3 × 15'),
      ('Romanian Deadlift', '3 × 10'),
      ('Leg Curl', '3 × 12'),
    ],
  ),
  'shoulders': _ProgramStaticData(
    schedule: [
      ('Mon', 'Shoulders A — Pressing + width'),
      ('Wed', 'Shoulders B — Volume + isolation'),
      ('Fri', 'Shoulders C — Overhead strength'),
    ],
    sampleDayName: 'Session A',
    sampleExercises: [
      ('Overhead Press', '4 × 6'),
      ('DB Shoulder Press', '3 × 10'),
      ('Lateral Raise', '4 × 15'),
      ('Face Pull', '3 × 15'),
      ('Barbell Shrug', '3 × 12'),
    ],
  ),
};
