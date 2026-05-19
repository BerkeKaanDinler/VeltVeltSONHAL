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
import '../utils/home_helpers.dart';
import '../models/workout.dart' show WorkoutExercise, CompletedWorkout;
import 'workout_history_screen.dart';
import 'exercise_detail_screen.dart' show PRDetailScreen;
import '../widgets/shared_widgets.dart' show SectionHeader;

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
                HomeHelpers.isSameDay(history.first.completedAt, DateTime.now());

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
                                'VELT',
                                style: AppTypography.caption(
                                  c.accentIron.withValues(alpha: 0.65),
                                ).copyWith(
                                  fontSize: 10,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                HomeHelpers.greeting(),
                                style: AppTypography.displayL(c.textPrimary).copyWith(
                                  fontSize: 30, letterSpacing: -1, height: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                HomeHelpers.motivationLine(streak, doneToday, prs.length),
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
                            color: c.accentIron.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: c.accentIron.withValues(alpha: 0.36)),
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
                              : HomeHelpers.pickNextRoutine(routines);
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
                      const SizedBox(height: 18),

                      // ── Stats row ────────────────────────────
                      Row(
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
                      ),
                      const SizedBox(height: 20),

                      // ── Last 7 Days ───────────────────────────
                      _Last7Days(dotDays: dotDays, c: c),
                      const SizedBox(height: 20),

                      // ── Last Session ──────────────────────────
                      SectionHeader(
                        label: 'Last Session',
                        action: history.length > 1 ? 'All History' : null,
                        onAction: history.length > 1
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkoutHistoryScreen()))
                            : null,
                        padding: const EdgeInsets.only(bottom: 8),
                      ),
                      if (effectiveHistory.isNotEmpty)
                        _LastWorkoutCard(
                          workout: effectiveHistory.first,
                          c: c,
                        )
                      else
                        _SkeletonLastSession(c: c),
                      const SizedBox(height: 20),

                      // ── Personal Records ──────────────────────
                      SectionHeader(
                        label: 'Personal Records',
                        action: prs.isNotEmpty ? 'See all' : null,
                        onAction: () => onNavigate(VeltTabs.progress),
                        padding: const EdgeInsets.only(bottom: 8),
                      ),
                      if (prs.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
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
      duration: const Duration(milliseconds: 1900),
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
    final preview   = exercises
        .take(4)
        .map((e) => e.name.split(' ').first)
        .join(' · ');
    final moreCount = (exercises.length - 4).clamp(0, 99);
    final sets      = exercises.fold(0, (a, e) => a + e.sets.length);
    final estMin    = (sets * 2.5).round().clamp(15, 120);
    final label     = widget.doneToday ? 'NEXT SESSION' : "TODAY'S PLAN";

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
          // Top gradient accent
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.25, 0.75, 1.0],
                colors: [
                  Colors.transparent,
                  c.accentIron,
                  c.accentIron,
                  Colors.transparent,
                ],
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
              widget.routine!.name,
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

          // Start button — pulsing glow when not done today
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => Container(
              margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              decoration: widget.doneToday
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: c.accentIron.withValues(
                            alpha: 0.14 + _pulse.value * 0.20),
                          blurRadius: 10 + _pulse.value * 14,
                          spreadRadius: _pulse.value * 3,
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
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Start Training'),
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
            onTap: widget.onQuickStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: c.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      'or start an empty workout',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                        fontSize: 12.5, fontWeight: FontWeight.w500),
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

// ── Last 7 Days ───────────────────────────────────────────────
class _Last7Days extends StatelessWidget {
  const _Last7Days({required this.dotDays, required this.c});
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'LAST 7 DAYS',
              style: AppTypography.caption(c.textTertiary).copyWith(
                letterSpacing: 0.8, fontWeight: FontWeight.w700, fontSize: 11),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$doneCount',
                    style: AppTypography.bodyS(c.textPrimary).copyWith(
                      fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  TextSpan(
                    text: ' of 7 days',
                    style: AppTypography.bodyS(c.textSecondary).copyWith(
                      fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(7, (i) {
            final done    = dotDays[i];
            final isToday = i == dotDays.length - 1;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: isToday && !done
                          ? CustomPaint(
                              painter: _DashedRectPainter(color: c.accentIron),
                              child: const SizedBox.expand(),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: done ? c.accentIron : c.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: done
                                    ? null
                                    : Border.all(
                                        color: c.divider.withValues(alpha: 0.7),
                                        width: 0.5),
                              ),
                              child: done
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16)
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
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        const Radius.circular(AppRadius.sm),
      ));

    const dashLen = 4.0;
    const gapLen  = 3.0;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + dashLen).clamp(0, m.length)), paint);
        d += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => old.color != color;
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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.fitness_center_rounded,
                size: 18, color: c.accentIron),
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
                      fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.1),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PRDetailScreen(exerciseName: exercise),
      )),
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                  size: 13, color: c.textSecondary),
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
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c.accentIron.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.fitness_center_rounded,
                size: 20, color: c.accentIron.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No workouts yet',
                  style: AppTypography.titleS(c.textPrimary).copyWith(
                    fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Complete your first session to see it here',
                  style: AppTypography.bodyS(c.textTertiary).copyWith(
                    fontSize: 11),
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
