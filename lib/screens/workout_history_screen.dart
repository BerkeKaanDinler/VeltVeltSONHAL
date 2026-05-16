import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/workout_history_store.dart';
import '../utils/weight_unit.dart';
import 'active_workout_screen.dart' show CompletedWorkout, WorkoutExercise;

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

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
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg,
                      AppSpacing.md, AppSpacing.md),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: c.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Workout History',
                          style: AppTypography.displayL(c.textPrimary).copyWith(
                            fontSize: 24,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (history.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyHistory(c: c),
                  )
                else ...[
                  // Stats strip
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                      child: _StatsStrip(history: history, c: c),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Grouped workout list
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, 80),
                    sliver: _GroupedHistoryList(history: history, c: c),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.history, required this.c});
  final List<CompletedWorkout> history;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final totalVol = history.fold(0.0, (s, w) => s + w.totalVolume);
    final totalSets = history.fold(0, (s, w) => s + w.doneSets);
    final avgDur = history.isEmpty
        ? 0
        : history.fold(0, (s, w) => s + w.elapsedSecs) ~/ history.length;
    final avgMin = avgDur ~/ 60;

    return Row(
      children: [
        _StripStat(value: '${history.length}', label: 'Workouts', c: c),
        _StripDivider(c: c),
        _StripStat(
          value: WeightUnit.isLbs
              ? (totalVol * 2.20462 >= 1000
                  ? '${((totalVol * 2.20462) / 1000).toStringAsFixed(0)}k'
                  : (totalVol * 2.20462).toStringAsFixed(0))
              : (totalVol >= 1000
                  ? '${(totalVol / 1000).toStringAsFixed(0)}k'
                  : totalVol.toStringAsFixed(0)),
          label: '${WeightUnit.suffix} Total',
          c: c,
        ),
        _StripDivider(c: c),
        _StripStat(value: '$avgMin min', label: 'Avg Dur.', c: c),
        _StripDivider(c: c),
        _StripStat(value: '$totalSets', label: 'Sets Done', c: c),
      ],
    );
  }
}

class _StripStat extends StatelessWidget {
  const _StripStat({required this.value, required this.label, required this.c});
  final String value;
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.displayM(c.textPrimary).copyWith(
                fontSize: 20,
                letterSpacing: -0.6,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption(c.textTertiary).copyWith(
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripDivider extends StatelessWidget {
  const _StripDivider({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 8);
}

// ── Grouped history list ──────────────────────────────────────
class _GroupedHistoryList extends StatelessWidget {
  const _GroupedHistoryList({required this.history, required this.c});
  final List<CompletedWorkout> history;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    // Group by year-month
    final groups = <String, List<CompletedWorkout>>{};
    for (final w in history) {
      final key = _monthKey(w.completedAt);
      groups.putIfAbsent(key, () => []).add(w);
    }
    final months = groups.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: months.length,
        (context, mi) {
          final month = months[mi];
          final workouts = groups[month]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mi > 0) const SizedBox(height: 20),
              // Month header
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      month.toUpperCase(),
                      style: AppTypography.caption(c.textTertiary).copyWith(
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: c.divider.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${workouts.length} workout${workouts.length != 1 ? 's' : ''}',
                      style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(workouts.length, (wi) => Padding(
                padding: EdgeInsets.only(
                  bottom: wi < workouts.length - 1 ? 10 : 0),
                child: _WorkoutHistoryCard(workout: workouts[wi], c: c),
              )),
            ],
          );
        },
      ),
    );
  }

  static String _monthKey(DateTime d) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ── Individual history card ───────────────────────────────────
class _WorkoutHistoryCard extends StatelessWidget {
  const _WorkoutHistoryCard({required this.workout, required this.c});
  final CompletedWorkout workout;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final w = workout;
    final d = w.completedAt;
    final dayLabel = '${_dayName(d.weekday)}, ${_monthShort(d.month)} ${d.day}';
    final timeLabel =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: w),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                Expanded(
                  child: Text(
                    w.routineName,
                    style: AppTypography.titleM(c.textPrimary).copyWith(
                      fontSize: 15, letterSpacing: -0.2),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dayLabel,
                      style: AppTypography.caption(c.textSecondary).copyWith(
                        fontSize: 10),
                    ),
                    Text(
                      timeLabel,
                      style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InlineTag(icon: Icons.timer_outlined, label: w.durationLabel, c: c),
                const SizedBox(width: 6),
                _InlineTag(icon: Icons.fitness_center_outlined, label: w.volumeLabel, c: c),
                const SizedBox(width: 6),
                _InlineTag(
                  icon: Icons.check_circle_outline_rounded,
                  label: '${w.doneSets} sets',
                  c: c,
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: c.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _dayName(int d) {
    const n = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return n[(d - 1).clamp(0, 6)];
  }

  static String _monthShort(int m) {
    const n = ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec'];
    return n[(m - 1).clamp(0, 11)];
  }
}

// ── Workout Detail Screen ─────────────────────────────────────
class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});
  final CompletedWorkout workout;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final w = workout;
    final d = w.completedAt;
    final dateStr =
        '${_fullDay(d.weekday)}, ${_fullMonth(d.month)} ${d.day}, ${d.year}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg,
                  AppSpacing.md, AppSpacing.md),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16, color: c.textSecondary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.routineName,
                            style: AppTypography.titleM(c.textPrimary).copyWith(
                              fontSize: 20, letterSpacing: -0.4),
                          ),
                          Text(
                            '$dateStr · $timeStr',
                            style: AppTypography.caption(c.textTertiary).copyWith(
                              fontSize: 11),
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
                AppSpacing.md, 0, AppSpacing.md, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats strip
                  Row(
                    children: [
                      _DetailStat(
                        label: 'Duration',
                        value: w.durationLabel,
                        icon: Icons.timer_outlined,
                        c: c,
                      ),
                      const SizedBox(width: 8),
                      _DetailStat(
                        label: 'Volume',
                        value: w.volumeLabel,
                        icon: Icons.fitness_center_outlined,
                        c: c,
                      ),
                      const SizedBox(width: 8),
                      _DetailStat(
                        label: 'Sets',
                        value: '${w.doneSets}',
                        icon: Icons.check_circle_outline_rounded,
                        c: c,
                      ),
                      const SizedBox(width: 8),
                      _DetailStat(
                        label: 'Exercises',
                        value: '${w.exercises.length}',
                        icon: Icons.format_list_bulleted_rounded,
                        c: c,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Exercise breakdown
                  Text(
                    'EXERCISES',
                    style: AppTypography.caption(c.textTertiary).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...w.exercises.map((ex) => _ExerciseDetailCard(ex: ex, c: c)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fullDay(int d) {
    const n = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return n[(d - 1).clamp(0, 6)];
  }

  static String _fullMonth(int m) {
    const n = ['January','February','March','April','May','June',
               'July','August','September','October','November','December'];
    return n[(m - 1).clamp(0, 11)];
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.c,
  });
  final String label;
  final String value;
  final IconData icon;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: c.accentIron),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleS(c.textPrimary).copyWith(
                fontSize: 14,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: AppTypography.caption(c.textTertiary).copyWith(
                fontSize: 9, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  const _ExerciseDetailCard({required this.ex, required this.c});
  final WorkoutExercise ex;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final doneSets = ex.sets.where((s) => s.isDone).toList();
    if (doneSets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c.divider.withValues(alpha: 0.4))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ex.name,
                      style: AppTypography.titleS(c.textPrimary).copyWith(
                        fontSize: 14, letterSpacing: -0.1),
                    ),
                  ),
                  Text(
                    '${ex.muscle} · ${ex.equipment}',
                    style: AppTypography.caption(c.textTertiary).copyWith(
                      fontSize: 10),
                  ),
                ],
              ),
            ),
            // Sets
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(
                children: [
                  // Column headers
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          'SET',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, letterSpacing: 0.5,
                            fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'WEIGHT',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, letterSpacing: 0.5,
                            fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REPS',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, letterSpacing: 0.5,
                            fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'VOLUME',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, letterSpacing: 0.5,
                            fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(doneSets.length, (i) {
                    final s = doneSets[i];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${i + 1}',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyS(c.textTertiary).copyWith(
                                fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              WeightUnit.format(s.weight),
                              textAlign: TextAlign.center,
                              style: AppTypography.titleS(c.textPrimary).copyWith(
                                fontSize: 13,
                                fontFeatures: [const FontFeature.tabularFigures()]),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${s.reps}',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyS(c.textSecondary).copyWith(
                                fontSize: 13,
                                fontFeatures: [const FontFeature.tabularFigures()]),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              WeightUnit.format(s.weight * s.reps),
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyS(c.accentIron).copyWith(
                                fontSize: 12,
                                fontFeatures: [const FontFeature.tabularFigures()]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Notes if present
                  if (ex.notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        ex.notes,
                        style: AppTypography.bodyS(c.textTertiary).copyWith(
                          fontSize: 11, fontStyle: FontStyle.italic,
                          height: 1.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({required this.icon, required this.label, required this.c});
  final IconData icon;
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: c.textTertiary),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.caption(c.textSecondary).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.history_rounded,
            size: 32,
            color: c.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No workouts yet',
          style: AppTypography.titleM(c.textPrimary).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          'Complete your first workout to\nsee your history here.',
          style: AppTypography.bodyS(c.textSecondary).copyWith(
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
