import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../velt_tabs.dart';
import '../services/prefs_service.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import '../services/workout_history_store.dart';
import '../utils/weight_unit.dart';
import 'active_workout_screen.dart' show WorkoutExercise, CompletedWorkout;
import 'workout_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartWorkout,
    required this.onNavigate,
    this.lastWorkout,
  });

  final void Function(String, List<WorkoutExercise>?) onStartWorkout;
  final void Function(int tab) onNavigate;
  final CompletedWorkout? lastWorkout;

  static Routine _pickNextRoutine(List<Routine> routines) {
    return routines.reduce((a, b) {
      if (a.lastDone == null) return a;
      if (b.lastDone == null) return b;
      return a.lastDone!.isBefore(b.lastDone!) ? a : b;
    });
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5)  return 'Still up?';
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Good afternoon.';
    if (h < 21) return 'Good evening.';
    return 'Late session?';
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _motivationLine(int streak, bool doneToday) {
    if (doneToday) return 'Session complete. Rest and recover.';
    if (streak == 0) return 'Every legend starts somewhere.';
    if (streak < 4)  return 'Building the habit. Keep going.';
    if (streak < 8)  return 'The streak is real — don\'t break it.';
    if (streak < 15) return '$streak days and counting. Impressive.';
    return 'You\'re in the top 1%. $streak day streak.';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<CompletedWorkout>>(
          valueListenable: WorkoutHistoryStore.history,
          builder: (context, history, _) {
            final streak     = WorkoutHistoryStore.currentStreak;
            final dotDays    = WorkoutHistoryStore.last7Days;
            final weekVolume = WorkoutHistoryStore.totalVolumeInPeriod('week');
            final monthCount = WorkoutHistoryStore.workoutsInPeriod('month');
            final prs        = WorkoutHistoryStore.allTimePRs;

            final doneToday = history.isNotEmpty &&
                _isSameDay(history.first.completedAt, DateTime.now());

            final effectiveHistory = history.isNotEmpty
                ? history
                : (lastWorkout != null ? [lastWorkout!] : <CompletedWorkout>[]);

            return CustomScrollView(
              slivers: [
                // ── Greeting ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, AppSpacing.lg,
                      AppSpacing.screenH, AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: AppTypography.displayL(c.textPrimary).copyWith(
                                  fontSize: 30, letterSpacing: -1, height: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _motivationLine(streak, doneToday),
                                style: AppTypography.bodyS(c.textTertiary).copyWith(
                                  fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        // Goal chip
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.accentIron.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: c.accentIron.withValues(alpha: 0.22)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_goalIcon(PrefsService.fitnessGoal),
                                size: 11, color: c.accentIron),
                              const SizedBox(width: 5),
                              Text(
                                PrefsService.fitnessGoal,
                                style: AppTypography.caption(c.accentIron).copyWith(
                                  fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, AppSpacing.sm,
                    AppSpacing.screenH, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── Today's Training ─────────────────────
                      ValueListenableBuilder<List<Routine>>(
                        valueListenable: RoutineStore.routines,
                        builder: (ctx, routines, _) {
                          final next = routines.isEmpty
                              ? null
                              : _pickNextRoutine(routines);
                          return _TodayCard(
                            routine: next,
                            doneToday: doneToday,
                            onStart: next == null
                                ? () => onStartWorkout('Empty Workout', null)
                                : () => onStartWorkout(next.name, next.exercises),
                            onQuickStart: () => onStartWorkout('Empty Workout', null),
                            onBrowsePrograms: () => onNavigate(VeltTabs.train),
                            c: c,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // ── Stats + Activity ──────────────────────
                      _StatsAndActivity(
                        streak: streak,
                        weekVolumeKg: weekVolume,
                        monthWorkouts: monthCount,
                        dotDays: dotDays,
                        c: c,
                      ),
                      const SizedBox(height: 22),

                      // ── Last Session ──────────────────────────
                      if (effectiveHistory.isNotEmpty) ...[
                        _SectionLabel(
                          label: 'Last Session',
                          action: history.length > 1 ? 'All History' : null,
                          onAction: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkoutHistoryScreen())),
                        ),
                        const SizedBox(height: 8),
                        _LastWorkoutCard(
                          workout: effectiveHistory.first,
                          c: c,
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Personal Records ──────────────────────
                      _SectionLabel(
                        label: 'Personal Records',
                        action: prs.isNotEmpty ? 'See all' : null,
                        onAction: () => onNavigate(VeltTabs.progress),
                      ),
                      const SizedBox(height: 8),
                      if (prs.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: prs.entries.take(8).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final entry = prs.entries.toList()[i];
                              return _PRChip(
                                exercise: entry.key,
                                value: WeightUnit.format(entry.value.weight),
                                date: entry.value.dateLabel,
                                c: c,
                              );
                            },
                          ),
                        )
                      else
                        _EmptyPRCard(
                          onStart: () => onNavigate(VeltTabs.train),
                          c: c,
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static IconData _goalIcon(String goal) => switch (goal) {
    'Lose Fat'  => Icons.local_fire_department_rounded,
    'Strength'  => Icons.bolt_rounded,
    'Endurance' => Icons.directions_run_rounded,
    _           => Icons.trending_up_rounded,
  };
}

// ── Section Label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.action, this.onAction});
  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption(c.textTertiary).copyWith(
            letterSpacing: 0.8, fontWeight: FontWeight.w700, fontSize: 11),
        ),
        const Spacer(),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                action!,
                style: AppTypography.bodyS(c.accentIron).copyWith(
                  fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Today Card ────────────────────────────────────────────────
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.routine,
    required this.doneToday,
    required this.onStart,
    required this.onQuickStart,
    required this.onBrowsePrograms,
    required this.c,
  });
  final Routine? routine;
  final bool doneToday;
  final VoidCallback onStart;
  final VoidCallback onQuickStart;
  final VoidCallback onBrowsePrograms;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    if (routine == null) {
      return _SetupCard(
        onBrowse: onBrowsePrograms,
        onQuickStart: onQuickStart,
        c: c,
      );
    }

    final exercises = routine!.exercises;
    final preview   = exercises
        .take(4)
        .map((e) => e.name.split(' ').first)
        .join(' · ');
    final moreCount = (exercises.length - 4).clamp(0, 99);
    final sets      = exercises.fold(0, (a, e) => a + e.sets.length);
    final estMin    = (sets * 2.5).round().clamp(15, 120);
    final label     = doneToday ? 'NEXT SESSION' : "TODAY'S PLAN";

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.accentIron.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient accent
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.accentIron, c.accentIron.withValues(alpha: 0.3)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Row(
              children: [
                Text(
                  label,
                  style: AppTypography.caption(c.accentIron).copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center_rounded,
                        size: 10, color: c.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${exercises.length} ex · ~$estMin min',
                        style: AppTypography.caption(c.textSecondary).copyWith(
                          fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Routine name
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Text(
              routine!.name,
              style: AppTypography.displayM(c.textPrimary).copyWith(
                fontSize: 24, letterSpacing: -0.8, height: 1.1),
            ),
          ),

          // Exercise preview
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
              child: Text(
                moreCount > 0 ? '$preview  +$moreCount more' : preview,
                style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Start button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onStart();
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text('Start ${routine!.name}'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.accentIron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),

          // Quick start link
          GestureDetector(
            onTap: onQuickStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: Center(
                child: Text(
                  'or start an empty workout →',
                  style: AppTypography.bodyS(c.textTertiary).copyWith(
                    fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Setup Card (no routines) ──────────────────────────────────
class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.onBrowse,
    required this.onQuickStart,
    required this.c,
  });
  final VoidCallback onBrowse;
  final VoidCallback onQuickStart;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: c.accentIron.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.fitness_center_rounded,
                  color: c.accentIron, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to train?',
                      style: AppTypography.titleM(c.textPrimary).copyWith(
                        fontSize: 16, letterSpacing: -0.2),
                    ),
                    Text(
                      'Set up a routine or jump straight in',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                        fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onBrowse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: c.accentIron,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        'Browse Programs',
                        style: AppTypography.titleS(Colors.white).copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onQuickStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: c.divider),
                    ),
                    child: Center(
                      child: Text(
                        '⚡ Quick Start',
                        style: AppTypography.titleS(c.textPrimary).copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats + Activity ──────────────────────────────────────────
class _StatsAndActivity extends StatelessWidget {
  const _StatsAndActivity({
    required this.streak,
    required this.weekVolumeKg,
    required this.monthWorkouts,
    required this.dotDays,
    required this.c,
  });
  final int streak;
  final double weekVolumeKg;
  final int monthWorkouts;
  final List<bool> dotDays;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final volLabel = WeightUnit.formatVolume(weekVolumeKg);

    return Column(
      children: [
        // Stat row
        Row(
          children: [
            _StatBox(
              value: streak > 0 ? '$streak' : '0',
              label: 'Day Streak',
              icon: Icons.local_fire_department_rounded,
              highlight: streak >= 3,
              c: c,
            ),
            const SizedBox(width: 8),
            _StatBox(
              value: weekVolumeKg > 0 ? volLabel : '—',
              label: 'This Week',
              icon: Icons.fitness_center_rounded,
              highlight: false,
              c: c,
            ),
            const SizedBox(width: 8),
            _StatBox(
              value: monthWorkouts > 0 ? '$monthWorkouts' : '0',
              label: 'This Month',
              icon: Icons.calendar_today_outlined,
              highlight: false,
              c: c,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Weekly activity
        _WeeklyActivity(dotDays: dotDays, c: c),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.highlight,
    required this.c,
  });
  final String value;
  final String label;
  final IconData icon;
  final bool highlight;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? c.accentIron : c.textPrimary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: highlight
                ? c.accentIron.withValues(alpha: 0.3)
                : c.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13,
              color: highlight ? c.accentIron : c.textTertiary),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.displayM(color).copyWith(
                fontSize: 22,
                letterSpacing: -0.8,
                height: 1,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(c.textTertiary).copyWith(
                fontSize: 10, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyActivity extends StatelessWidget {
  const _WeeklyActivity({required this.dotDays, required this.c});
  final List<bool> dotDays;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final doneCount = dotDays.where((d) => d).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAST 7 DAYS',
                style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '$doneCount / 7 sessions',
                style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final done    = dotDays[i];
              final isToday = i == dotDays.length - 1;
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: done
                            ? (isToday
                                ? c.accentIron
                                : c.accentIron.withValues(alpha: 0.55))
                            : c.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                        border: isToday && !done
                            ? Border.all(
                                color: c.accentIron.withValues(alpha: 0.4),
                                width: 1.5)
                            : null,
                      ),
                      child: done
                          ? Icon(Icons.check_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.9))
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: AppTypography.caption(
                        done ? c.textSecondary : c.textTertiary,
                      ).copyWith(fontSize: 9),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Last Workout Card ─────────────────────────────────────────
class _LastWorkoutCard extends StatelessWidget {
  const _LastWorkoutCard({required this.workout, required this.c});
  final CompletedWorkout workout;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final preview = workout.exercises
        .take(3)
        .map((e) => e.name.split(' ').first)
        .join(' · ');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.fitness_center_rounded,
                size: 18, color: c.textTertiary),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.routineName,
                    style: AppTypography.titleM(c.textPrimary).copyWith(
                      fontSize: 15, letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (workout.exercises.isNotEmpty)
                    Text(
                      preview,
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                        fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Mini stats
                  Row(
                    children: [
                      _MiniStat(icon: Icons.timer_outlined,
                        label: workout.durationLabel, c: c),
                      const SizedBox(width: 14),
                      _MiniStat(icon: Icons.fitness_center_outlined,
                        label: workout.volumeLabel, c: c),
                      const SizedBox(width: 14),
                      _MiniStat(icon: Icons.check_circle_outline_rounded,
                        label: '${workout.doneSets} sets', c: c),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    workout.relativeDate,
                    style: AppTypography.caption(c.textTertiary).copyWith(
                      fontSize: 10),
                  ),
                ),
                const SizedBox(height: 14),
                Icon(Icons.chevron_right_rounded,
                  size: 18, color: c.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label, required this.c});
  final IconData icon;
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: c.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.caption(c.textSecondary).copyWith(
            fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ── PR Chip ───────────────────────────────────────────────────
class _PRChip extends StatelessWidget {
  const _PRChip({
    required this.exercise,
    required this.value,
    required this.date,
    required this.c,
  });
  final String exercise;
  final String value;
  final String date;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 11),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                size: 14, color: c.accentIron),
              const Spacer(),
              Text(
                date,
                style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 9),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 22,
              letterSpacing: -0.6,
              height: 1,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exercise,
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Empty PR Card ─────────────────────────────────────────────
class _EmptyPRCard extends StatelessWidget {
  const _EmptyPRCard({required this.onStart, required this.c});
  final VoidCallback onStart;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.emoji_events_outlined,
                size: 18, color: c.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No records yet',
                    style: AppTypography.titleS(c.textPrimary).copyWith(
                      fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Finish a workout to set your first PR',
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
