// ignore_for_file: dead_code, unused_element, unused_import

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
import '../services/nutrition_store.dart';
import '../utils/weight_unit.dart';
import '../utils/home_helpers.dart';
import '../models/workout.dart' show WorkoutExercise, CompletedWorkout;
import 'workout_history_screen.dart';
import 'exercise_detail_screen.dart' show PRDetailScreen;
import '../widgets/shared_widgets.dart' show SectionHeader;
import '../widgets/velt_redesign_widgets.dart';

// ── Helpers ───────────────────────────────────────────────────
IconData _goalIcon(String goal) => switch (goal) {
      'Lose Fat' => Icons.local_fire_department_rounded,
      'Strength' => Icons.bolt_rounded,
      'Endurance' => Icons.directions_run_rounded,
      _ => Icons.trending_up_rounded,
    };

// ─────────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return _FreshHomeScreen(
      onStartWorkout: onStartWorkout,
      onNavigate: onNavigate,
      lastWorkout: lastWorkout,
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<CompletedWorkout>>(
          valueListenable: WorkoutHistoryStore.history,
          builder: (context, history, _) {
            final streak = WorkoutHistoryStore.currentStreak;
            final dotDays = WorkoutHistoryStore.last7Days;
            final weekVolume = WorkoutHistoryStore.totalVolumeInPeriod('week');
            final monthCount = WorkoutHistoryStore.workoutsInPeriod('month');
            final prs = WorkoutHistoryStore.allTimePRs;

            final doneToday = history.isNotEmpty &&
                HomeHelpers.isSameDay(
                    history.first.completedAt, DateTime.now());

            final effectiveHistory = history.isNotEmpty
                ? history
                : (lastWorkout != null ? [lastWorkout!] : <CompletedWorkout>[]);

            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    streak: streak,
                    doneToday: doneToday,
                    c: c,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 0, AppSpacing.screenH, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Today's Training ─────────────────
                      ValueListenableBuilder<List<Routine>>(
                        valueListenable: RoutineStore.routines,
                        builder: (ctx, routines, _) {
                          final next = routines.isEmpty
                              ? null
                              : HomeHelpers.pickNextRoutine(routines);
                          return _TodayCard(
                            routine: next,
                            doneToday: doneToday,
                            onStart: next == null
                                ? () => onStartWorkout('Empty Workout', null)
                                : () =>
                                    onStartWorkout(next.name, next.exercises),
                            onQuickStart: () =>
                                onStartWorkout('Empty Workout', null),
                            onBrowsePrograms: () => onNavigate(VeltTabs.train),
                            c: c,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Weekly consistency ────────────────
                      _WeeklyStrip(dotDays: dotDays, c: c),
                      const SizedBox(height: 20),

                      // ── Stats row ─────────────────────────
                      _StatsRow(
                        streak: streak,
                        weekVolume: weekVolume,
                        monthCount: monthCount,
                        c: c,
                      ),
                      const SizedBox(height: 24),

                      // ── Last Session ──────────────────────
                      SectionHeader(
                        label: 'Last Session',
                        action: history.length > 1 ? 'All History' : null,
                        onAction: history.length > 1
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => WorkoutHistoryScreen(
                                          onStartWorkout: onStartWorkout,
                                        )))
                            : null,
                        padding: const EdgeInsets.only(bottom: 10),
                      ),
                      if (effectiveHistory.isNotEmpty)
                        _LastWorkoutCard(
                          workout: effectiveHistory.first,
                          c: c,
                        )
                      else
                        _SkeletonLastSession(c: c),
                      const SizedBox(height: 24),

                      // ── Personal Records ──────────────────
                      SectionHeader(
                        label: 'Personal Records',
                        action: prs.isNotEmpty ? 'See all' : null,
                        onAction: () => onNavigate(VeltTabs.progress),
                        padding: const EdgeInsets.only(bottom: 10),
                      ),
                      if (prs.isNotEmpty)
                        SizedBox(
                          height: 104,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: prs.entries.take(8).length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
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
}

// ── Home Header ───────────────────────────────────────────────
class _FreshHomeScreen extends StatelessWidget {
  const _FreshHomeScreen({
    required this.onStartWorkout,
    required this.onNavigate,
    this.lastWorkout,
  });

  final void Function(String, List<WorkoutExercise>?) onStartWorkout;
  final void Function(int tab) onNavigate;
  final CompletedWorkout? lastWorkout;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return VeltScreen(
      onRefresh: () async {
        await WorkoutHistoryStore.init();
        await NutritionStore.init();
        HapticFeedback.lightImpact();
      },
      child: ValueListenableBuilder<List<CompletedWorkout>>(
        valueListenable: WorkoutHistoryStore.history,
        builder: (context, history, _) {
          final streak = WorkoutHistoryStore.currentStreak;
          final weekVolume = WorkoutHistoryStore.totalVolumeInPeriod('week');
          final effectiveHistory = history.isNotEmpty
              ? history
              : (lastWorkout != null ? [lastWorkout!] : <CompletedWorkout>[]);
          final last = effectiveHistory.isEmpty ? null : effectiveHistory.first;
          final readiness = (72 + (streak * 3)).clamp(72, 92);

          return ValueListenableBuilder<List<Routine>>(
            valueListenable: RoutineStore.routines,
            builder: (context, routines, _) {
              final next = routines.isEmpty
                  ? null
                  : HomeHelpers.pickNextRoutine(routines);
              final nextName = next?.name ?? 'Empty Workout';
              final nextExercises = next?.exercises.length ?? 0;
              final nextSets = next == null
                  ? 0
                  : next.exercises
                      .fold<int>(0, (sum, e) => sum + e.sets.length);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VeltHeader(
                    eyebrow: _dateLabel(),
                    title: 'Home',
                    trailing: _Wordmark(c: c),
                  ),
                  VeltPanel(
                    hero: true,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const VeltPill("Today's plan", accent: true),
                        const SizedBox(height: 9),
                        Text(
                          '$nextName is ready.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textPrimary,
                            fontSize: 34,
                            height: 1.06,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          next == null
                              ? 'Start fast and build the session as you lift.'
                              : 'A focused session with one clear progression target.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                                child: VeltMetric(
                                    value: '$nextExercises',
                                    label: 'Exercises')),
                            const SizedBox(width: 8),
                            Expanded(
                                child: VeltMetric(
                                    value: nextSets == 0
                                        ? '—'
                                        : '${(nextSets * 2.5).round()}',
                                    label: 'Minutes')),
                            const SizedBox(width: 8),
                            Expanded(
                                child: VeltMetric(
                                    value:
                                        nextSets == 0 ? '+ Set' : '$nextSets',
                                    label: 'Sets')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: VeltButton(
                                label: 'Start Workout',
                                onTap: () =>
                                    onStartWorkout(nextName, next?.exercises),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              child: VeltButton(
                                label: 'Edit',
                                secondary: true,
                                onTap: () => onNavigate(VeltTabs.train),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const VeltSection(
                    label: 'Readiness',
                    trailing: VeltPill('Good load', success: true),
                  ),
                  Row(
                    children: [
                      VeltPanel(
                        child: SizedBox(
                          width: 86,
                          height: 102,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              VeltRing(
                                value: '$readiness',
                                label: 'Score',
                                progress: readiness / 100,
                              ),
                              const SizedBox(height: 9),
                              const VeltLabel('Score'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: VeltPanel(
                          child: Column(
                            children: [
                              _HomeLoadLine(
                                label: 'Weekly volume',
                                value: WeightUnit.formatVolume(weekVolume),
                                pct: (weekVolume / 10000).clamp(0, 1).toDouble(),
                              ),
                              const SizedBox(height: 9),
                              _HomeLoadLine(
                                label: 'Streak',
                                value: '$streak day${streak == 1 ? '' : 's'}',
                                pct: (streak / 7).clamp(0, 1).toDouble(),
                              ),
                              const SizedBox(height: 9),
                              _HomeLoadLine(
                                label: 'Sessions / wk',
                                value: '${_sessionsThisWeek(history)} / 7',
                                pct: (_sessionsThisWeek(history) / 7)
                                    .clamp(0, 1)
                                    .toDouble(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VeltSection(label: 'Quick access'),
                  Row(
                    children: [
                      Expanded(
                          child: _HomeQuickTile(
                              icon: Icons.library_books_rounded,
                              label: 'Exercises',
                              sublabel: '90+ moves',
                              onTap: () => onNavigate(VeltTabs.train),
                              c: c)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _HomeQuickTile(
                              icon: Icons.fitness_center_rounded,
                              label: 'Programs',
                              sublabel: '10 plans',
                              onTap: () => onNavigate(VeltTabs.train),
                              c: c)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _HomeQuickTile(
                              icon: Icons.trending_up_rounded,
                              label: 'Progress',
                              sublabel: 'Track PRs',
                              onTap: () => onNavigate(VeltTabs.progress),
                              c: c)),
                    ],
                  ),
                  VeltSection(
                    label: 'Last workout',
                    trailing: VeltPill(last == null ? 'Empty' : 'View'),
                  ),
                  if (last == null)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            c.surfaceElevated,
                            c.accentIron.withValues(alpha: .14),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: c.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.accentIron.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.rocket_launch_rounded,
                              color: c.accentIron,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Day one — let\'s go.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: c.textPrimary,
                              fontSize: 26,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start your first workout — VELT remembers every '
                            'set, every PR, every minute from here on.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: c.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          VeltButton(
                            label: 'Start your first workout',
                            onTap: () =>
                                onStartWorkout('Empty Workout', null),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    VeltRowCard(
                      icon: last.routineName.characters.first.toUpperCase(),
                      title: last.routineName,
                      subtitle:
                          '${last.relativeDate} · ${last.durationLabel} · ${last.doneSets} sets · ${last.volumeLabel}',
                      trailing: VeltPill(
                        last.totalVolume > 0 ? 'Open' : 'Empty',
                        accent: last.totalVolume > 0,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workout: last,
                            onRepeat: (src) => onStartWorkout(
                              src.routineName,
                              WorkoutHistoryStore.templateFromCompleted(src),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (WorkoutHistoryStore.recentTemplates().isNotEmpty) ...[
                    const VeltSection(
                      label: 'Repeat a session',
                      trailing: VeltPill('From history', accent: true),
                    ),
                    SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount:
                            WorkoutHistoryStore.recentTemplates().length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final w = WorkoutHistoryStore.recentTemplates()[i];
                          return _RepeatCard(
                            workout: w,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              onStartWorkout(
                                w.routineName,
                                WorkoutHistoryStore.templateFromCompleted(w),
                              );
                            },
                            c: c,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _dateLabel() {
    const months = [
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
      'Dec'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _RepeatCard extends StatelessWidget {
  const _RepeatCard({
    required this.workout,
    required this.onTap,
    required this.c,
  });
  final CompletedWorkout workout;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.accentIron.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.replay_rounded,
                      color: c.accentIron, size: 16),
                ),
                const Spacer(),
                Text(
                  workout.relativeDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  workout.routineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                    fontSize: 13,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${workout.exercises.length} ex · ${workout.totalSets} sets',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textTertiary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int _sessionsThisWeek(List<CompletedWorkout> history) {
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  return history.where((w) => w.completedAt.isAfter(weekAgo)).length;
}

class _HomeQuickTile extends StatelessWidget {
  const _HomeQuickTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    required this.c,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 92,
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: c.accentIron.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: c.accentIron, size: 14),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    )),
                const SizedBox(height: 2),
                Text(sublabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textTertiary,
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Color.lerp(c.surfaceElevated, c.accentIron, .16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.lerp(c.divider, c.accentIron, .34)!),
      ),
      child: Center(
        child: Text(
          'VELT',
          style: TextStyle(
            fontFamily: 'Inter',
            color: c.accentIron,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _HomeLoadLine extends StatelessWidget {
  const _HomeLoadLine({
    required this.label,
    required this.value,
    required this.pct,
  });

  final String label;
  final String value;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: VeltLabel(label)),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        VeltProgressBar(value: pct),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.streak,
    required this.doneToday,
    required this.c,
  });
  final int streak;
  final bool doneToday;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
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
      'Dec'
    ];
    final wdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dateStr =
        '${wdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wordmark
                Text(
                  'VELT',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: c.accentIron,
                    letterSpacing: 3.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                // Greeting
                Text(
                  HomeHelpers.greeting(),
                  style: AppTypography.displayL(c.textPrimary)
                      .copyWith(fontSize: 28, letterSpacing: -0.8, height: 1.1),
                ),
                const SizedBox(height: 5),
                // Date + streak
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: AppTypography.bodyS(c.textTertiary)
                          .copyWith(fontSize: 12),
                    ),
                    if (streak >= 2) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: c.textTertiary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '$streak day streak',
                        style: AppTypography.bodyS(c.accentIron).copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (doneToday && streak < 2) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: c.textTertiary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        'Trained today',
                        style: AppTypography.bodyS(c.successLime).copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Goal chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: c.accentIron.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: c.accentIron.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_goalIcon(PrefsService.fitnessGoal),
                    size: 11, color: c.accentIron),
                const SizedBox(width: 5),
                Text(
                  PrefsService.fitnessGoal,
                  style: AppTypography.caption(c.accentIron)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today Card ────────────────────────────────────────────────
class _TodayCard extends StatefulWidget {
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
  State<_TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<_TodayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;

    if (widget.routine == null) {
      return _SetupCard(
        onBrowse: widget.onBrowsePrograms,
        onQuickStart: widget.onQuickStart,
        c: c,
      );
    }

    final exercises = widget.routine!.exercises;
    final preview =
        exercises.take(4).map((e) => e.name.split(' ').first).join(' · ');
    final moreCount = (exercises.length - 4).clamp(0, 99);
    final sets = exercises.fold(0, (a, e) => a + e.sets.length);
    final estMin = (sets * 2.5).round().clamp(15, 120);
    final label = widget.doneToday ? 'NEXT SESSION' : "TODAY'S PLAN";

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent stripe
          Container(
            height: 3,
            color: widget.doneToday
                ? c.accentIron.withValues(alpha: 0.35)
                : c.accentIron,
          ),

          // Label row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.accentIron
                        .withValues(alpha: widget.doneToday ? 0.07 : 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.caption(
                      widget.doneToday
                          ? c.accentIron.withValues(alpha: 0.65)
                          : c.accentIron,
                    ).copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                // Meta pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: c.divider.withValues(alpha: 0.6), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 10, color: c.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${exercises.length} ex · ~$estMin min',
                        style: AppTypography.caption(c.textSecondary)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Routine name
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Text(
              widget.routine!.name,
              style: AppTypography.displayM(c.textPrimary)
                  .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.1),
            ),
          ),

          // Exercise preview
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
              child: Text(
                moreCount > 0 ? '$preview  +$moreCount more' : preview,
                style: AppTypography.bodyS(c.textTertiary)
                    .copyWith(fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Start button with subtle pulse on CTA
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => Container(
              margin: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              decoration: widget.doneToday
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: c.accentIron
                              .withValues(alpha: 0.06 + _pulse.value * 0.08),
                          blurRadius: 12 + _pulse.value * 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
              child: child,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onStart();
                },
                icon: Icon(
                  widget.doneToday
                      ? Icons.skip_next_rounded
                      : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                    widget.doneToday ? 'Start Next Session' : 'Start Training'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.accentIron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
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

          // Quick start ghost link
          GestureDetector(
            onTap: widget.onQuickStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 13, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'or start an empty workout',
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
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
          Text(
            'Ready to lift?',
            style: AppTypography.titleL(c.textPrimary)
                .copyWith(fontSize: 20, letterSpacing: -0.4),
          ),
          const SizedBox(height: 4),
          Text(
            'Set up a program or jump straight in.',
            style: AppTypography.bodyM(c.textTertiary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onBrowse();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.accentIron,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onQuickStart();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: c.divider, width: 0.5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              size: 14, color: c.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            'Quick Start',
                            style: AppTypography.titleS(c.textSecondary)
                                .copyWith(
                                    fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
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

// ── Weekly Consistency Strip ──────────────────────────────────
class _WeeklyStrip extends StatelessWidget {
  const _WeeklyStrip({required this.dotDays, required this.c});
  final List<bool> dotDays;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final today = DateTime.now();
    final labels = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return dayLabels[day.weekday - 1];
    });
    final doneCount = dotDays.where((d) => d).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'CONSISTENCY',
                style: AppTypography.caption(c.textTertiary).copyWith(
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    fontSize: 10),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '$doneCount',
                    style: AppTypography.titleS(c.textPrimary)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' / 7',
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 12),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final done = dotDays[i];
              final isToday = i == dotDays.length - 1;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? c.accentIron
                                : isToday
                                    ? Colors.transparent
                                    : c.surfaceHigh,
                            border: done
                                ? null
                                : Border.all(
                                    color: isToday
                                        ? c.accentIron
                                        : c.divider.withValues(alpha: 0.7),
                                    width: isToday ? 1.8 : 0.5,
                                  ),
                          ),
                          child: done
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 13)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labels[i],
                        style: AppTypography.caption(
                          isToday ? c.accentIron : c.textTertiary,
                        ).copyWith(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.streak,
    required this.weekVolume,
    required this.monthCount,
    required this.c,
  });
  final int streak;
  final double weekVolume;
  final int monthCount;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          value: streak > 0 ? '$streak' : '—',
          label: 'Day Streak',
          icon: Icons.local_fire_department_rounded,
          highlight: streak >= 3,
          c: c,
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: WeightUnit.formatVolume(weekVolume),
          label: 'This Week',
          icon: Icons.fitness_center_rounded,
          highlight: false,
          c: c,
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: '$monthCount',
          label: 'This Month',
          icon: Icons.calendar_today_outlined,
          highlight: false,
          c: c,
        ),
      ],
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────
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
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: highlight
                ? c.accentIron.withValues(alpha: 0.22)
                : c.divider.withValues(alpha: 0.4),
            width: highlight ? 1.0 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 14, color: highlight ? c.accentIron : c.textTertiary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.displayM(color).copyWith(
                fontSize: 21,
                letterSpacing: -0.8,
                height: 1,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(
                highlight
                    ? c.accentIron.withValues(alpha: 0.65)
                    : c.textTertiary,
              ).copyWith(fontSize: 10.5, letterSpacing: 0.2),
            ),
          ],
        ),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.accentIron.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.fitness_center_rounded,
                  size: 19, color: c.accentIron),
            ),
            const SizedBox(width: 13),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.routineName,
                    style: AppTypography.titleM(c.textPrimary).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (workout.exercises.isNotEmpty)
                    Text(
                      preview,
                      style: AppTypography.bodyS(c.textTertiary)
                          .copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _MiniStat(
                          icon: Icons.timer_outlined,
                          label: workout.durationLabel,
                          c: c),
                      const SizedBox(width: 12),
                      _MiniStat(
                          icon: Icons.fitness_center_outlined,
                          label: workout.volumeLabel,
                          c: c),
                      const SizedBox(width: 12),
                      _MiniStat(
                          icon: Icons.check_circle_outline_rounded,
                          label: '${workout.doneSets} sets',
                          c: c),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Date + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  workout.relativeDate,
                  style: AppTypography.caption(c.textTertiary)
                      .copyWith(fontSize: 10),
                ),
                const SizedBox(height: 14),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: c.textTertiary.withValues(alpha: 0.5)),
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
          style: AppTypography.caption(c.textSecondary)
              .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PRDetailScreen(exerciseName: exercise),
      )),
      child: Container(
        width: 140,
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
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
                Icon(Icons.emoji_events_rounded, size: 14, color: c.accentIron),
                const Spacer(),
                Text(
                  date,
                  style: AppTypography.caption(c.textTertiary)
                      .copyWith(fontSize: 9.5),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: AppTypography.displayM(c.textPrimary).copyWith(
                fontSize: 21,
                letterSpacing: -0.6,
                height: 1,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise,
                    style: AppTypography.bodyS(c.textSecondary)
                        .copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 12, color: c.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Last Session ────────────────────────────────────────
class _SkeletonLastSession extends StatelessWidget {
  const _SkeletonLastSession({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                  color: c.divider.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Icon(Icons.fitness_center_rounded,
                size: 19, color: c.textTertiary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No workouts yet',
                  style: AppTypography.titleS(c.textPrimary)
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Complete your first session to see it here.',
                  style: AppTypography.bodyS(c.textTertiary)
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                    color: c.divider.withValues(alpha: 0.6), width: 0.5),
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
                    style: AppTypography.titleS(c.textPrimary)
                        .copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Finish a workout to set your first PR.',
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: c.textTertiary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
