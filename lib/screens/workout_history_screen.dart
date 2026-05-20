// ignore_for_file: dead_code, unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/prefs_service.dart';
import '../services/workout_history_store.dart';
import '../utils/weight_unit.dart';
import '../widgets/set_row.dart' show SetType;
import '../widgets/shared_widgets.dart';
import '../widgets/velt_redesign_widgets.dart';
import '../models/workout.dart' show CompletedWorkout, WorkoutExercise;
import 'exercise_detail_screen.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key, this.onStartWorkout});

  /// When provided, completed workouts can be repeated as a new session.
  final void Function(String name, List<WorkoutExercise> exercises)?
      onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return _FreshWorkoutHistoryScreen(onStartWorkout: onStartWorkout);

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
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                        AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

class _FreshWorkoutHistoryScreen extends StatelessWidget {
  const _FreshWorkoutHistoryScreen({this.onStartWorkout});
  final void Function(String name, List<WorkoutExercise> exercises)?
      onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CompletedWorkout>>(
      valueListenable: WorkoutHistoryStore.history,
      builder: (context, history, _) {
        final totalVolume =
            history.fold<double>(0, (sum, w) => sum + w.totalVolume);
        final totalSets = history.fold<int>(0, (sum, w) => sum + w.doneSets);
        final avgMin = history.isEmpty
            ? 0
            : history.fold<int>(0, (sum, w) => sum + w.elapsedSecs) ~/
                history.length ~/
                60;

        return VeltScreen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VeltTopBar(
                title: 'Workout history',
                subtitle: '${history.length} completed sessions',
                onBack: () => Navigator.pop(context),
                trailing: VeltPill('${history.length}', accent: true),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: VeltMetric(
                      value: '${history.length}',
                      label: 'workouts',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: VeltMetric(
                      value: WeightUnit.formatVolume(totalVolume),
                      label: 'volume',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: VeltMetric(value: '$avgMin m', label: 'avg'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              VeltPanel(
                child: Row(
                  children: [
                    const Expanded(
                      child: VeltLabel('Lifetime sets'),
                    ),
                    VeltPill('$totalSets done', success: totalSets > 0),
                  ],
                ),
              ),
              const VeltSection(label: 'Recent sessions'),
              if (history.isEmpty)
                const VeltPanel(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: VeltLabel('No workouts yet')),
                  ),
                )
              else
                for (final workout in history.take(24)) ...[
                  _FreshWorkoutHistoryItem(
                      workout: workout, onStartWorkout: onStartWorkout),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _FreshWorkoutHistoryItem extends StatelessWidget {
  const _FreshWorkoutHistoryItem({
    required this.workout,
    this.onStartWorkout,
  });
  final CompletedWorkout workout;
  final void Function(String name, List<WorkoutExercise> exercises)?
      onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final d = workout.completedAt;
    final subtitle =
        '${_freshMonth(d.month)} ${d.day} · ${workout.durationLabel} · ${workout.doneSets} sets';
    return VeltRowCard(
      icon: workout.routineName.characters.first.toUpperCase(),
      title: workout.routineName,
      subtitle: subtitle,
      trailing: VeltPill(workout.volumeLabel, accent: true),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(
            workout: workout,
            onRepeat: onStartWorkout == null
                ? null
                : (src) => onStartWorkout!(
                      src.routineName,
                      WorkoutHistoryStore.templateFromCompleted(src),
                    ),
          ),
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
  Widget build(BuildContext context) => const SizedBox(width: 8);
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
              ...List.generate(
                  workouts.length,
                  (wi) => Padding(
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
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
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
                    style: AppTypography.titleM(c.textPrimary)
                        .copyWith(fontSize: 15, letterSpacing: -0.2),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dayLabel,
                      style: AppTypography.caption(c.textSecondary)
                          .copyWith(fontSize: 10),
                    ),
                    Text(
                      timeLabel,
                      style: AppTypography.caption(c.textTertiary)
                          .copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InlineTag(
                    icon: Icons.timer_outlined, label: w.durationLabel, c: c),
                const SizedBox(width: 6),
                _InlineTag(
                    icon: Icons.fitness_center_outlined,
                    label: w.volumeLabel,
                    c: c),
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
    const n = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return n[(d - 1).clamp(0, 6)];
  }

  static String _monthShort(int m) {
    const n = [
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
    return n[(m - 1).clamp(0, 11)];
  }
}

// ── PR computation helper ─────────────────────────────────────
List<({String exercise, double weight, int reps})> _prsFor(CompletedWorkout w) {
  final history = WorkoutHistoryStore.history.value;
  final prevBests = <String, double>{};
  for (final h in history) {
    if (!h.completedAt.isBefore(w.completedAt)) continue;
    for (final ex in h.exercises) {
      for (final s in ex.sets) {
        if (s.isDone && s.weight > (prevBests[ex.name] ?? 0)) {
          prevBests[ex.name] = s.weight;
        }
      }
    }
  }
  final result = <({String exercise, double weight, int reps})>[];
  for (final ex in w.exercises) {
    double best = 0;
    int bestR = 0;
    for (final s in ex.sets) {
      if (s.isDone && s.weight > best) {
        best = s.weight;
        bestR = s.reps;
      }
    }
    if (best > 0 && best > (prevBests[ex.name] ?? 0)) {
      result.add((exercise: ex.name, weight: best, reps: bestR));
    }
  }
  return result;
}

String _freshMonth(int m) {
  const names = [
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
  ];
  return names[(m - 1).clamp(0, 11)];
}

// ── Workout Detail Screen ─────────────────────────────────────
class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    this.onRepeat,
  });
  final CompletedWorkout workout;
  /// Optional — when provided, a "Repeat workout" CTA appears. Called with
  /// the source workout so the caller can build a fresh template from it.
  final void Function(CompletedWorkout source)? onRepeat;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late String _note;

  String get _noteKey =>
      'session_${widget.workout.completedAt.millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _note = PrefsService.getNote(_noteKey) ?? '';
  }

  Future<void> _editNote(AppColors c) async {
    final ctrl = TextEditingController(text: _note);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Text(
                'SESSION NOTE',
                style: AppTypography.caption(c.accentIron).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 5,
                style: AppTypography.bodyS(c.textPrimary)
                    .copyWith(fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'How did the session feel?',
                  hintStyle: AppTypography.bodyS(c.textTertiary)
                      .copyWith(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: c.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        BorderSide(color: c.divider.withValues(alpha: 0.6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: c.accentIron),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: c.surface,
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Save',
                onPressed: () async {
                  final text = ctrl.text.trim();
                  if (text.isEmpty) {
                    await PrefsService.clearNote(_noteKey);
                  } else {
                    await PrefsService.setNote(_noteKey, text);
                  }
                  setState(() => _note = text);
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final w = widget.workout;
    final d = w.completedAt;
    final dateStr = '${_fullDay(d.weekday)}, ${_fullMonth(d.month)} ${d.day}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final prs = _prsFor(w);
    final prCount = prs.length;

    return _FreshWorkoutDetailScreen(
      workout: w,
      dateText: '$dateStr · $timeStr',
      prs: prs,
      note: _note,
      onEditNote: () => _editNote(c),
      onRepeat: widget.onRepeat == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
              widget.onRepeat!(w);
            },
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Sticky header ──────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.sm, AppSpacing.screenH, AppSpacing.md),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(
                    bottom: BorderSide(
                        color: c.divider.withValues(alpha: 0.6), width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 6),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: c.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    GhostButton(
                      label: 'Share',
                      onPressed: () {},
                      height: 32,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'COMPLETED WORKOUT',
                    style: AppTypography.caption(c.accentIron).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    w.routineName,
                    style: AppTypography.displayL(c.textPrimary).copyWith(
                        fontSize: 26, letterSpacing: -0.8, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr · $timeStr',
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2×2 stats grid
                    Row(children: [
                      Expanded(
                          child: _DetailStatTile(
                              label: 'Duration', value: w.durationLabel, c: c)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _DetailStatTile(
                              label: 'Volume', value: w.volumeLabel, c: c)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: _DetailStatTile(
                              label: 'Sets', value: '${w.doneSets}', c: c)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _DetailStatTile(
                              label: 'PRs',
                              value: '$prCount',
                              c: c,
                              accent: prCount > 0)),
                    ]),

                    // Avg rest pill
                    if (w.avgRestSecs > 0) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.surfaceHigh,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                                color: c.divider.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 12, color: c.textSecondary),
                              const SizedBox(width: 5),
                              Text.rich(
                                TextSpan(
                                  style: AppTypography.bodyS(c.textSecondary)
                                      .copyWith(fontSize: 12),
                                  children: [
                                    const TextSpan(text: 'Avg rest: '),
                                    TextSpan(
                                      text: '${w.avgRestSecs}s',
                                      style: TextStyle(
                                          color: c.textPrimary,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // PR callout section
                    if (prs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        '${prs.length} NEW PERSONAL RECORD${prs.length > 1 ? 'S' : ''}',
                        style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      ...prs.map((pr) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: c.accentIron.withValues(alpha: 0.08),
                                border: Border.all(
                                    color: c.accentIron.withValues(alpha: 0.3)),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.accentIron.withValues(alpha: 0.18),
                                  ),
                                  child: Icon(Icons.emoji_events_rounded,
                                      size: 14, color: c.accentIron),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pr.exercise,
                                        style:
                                            AppTypography.bodyS(c.textPrimary)
                                                .copyWith(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${WeightUnit.format(pr.weight)} × ${pr.reps}',
                                      style: AppTypography.bodyS(c.accentIron)
                                          .copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: [
                                            const FontFeature.tabularFigures()
                                          ]),
                                    ),
                                  ],
                                )),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: c.accentIron,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text('NEW PR',
                                      style: AppTypography.caption(Colors.white)
                                          .copyWith(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800)),
                                ),
                              ]),
                            ),
                          )),
                    ],

                    // Session note
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                        child: Text(
                          'SESSION NOTE',
                          style: AppTypography.caption(c.textTertiary).copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _editNote(c),
                        child: Text(
                          _note.isEmpty ? 'Add' : 'Edit',
                          style: AppTypography.bodyS(c.accentIron).copyWith(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _editNote(c),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: c.divider.withValues(alpha: 0.5)),
                        ),
                        child: _note.isEmpty
                            ? Text(
                                'Tap to add a session note…',
                                style: AppTypography.bodyS(c.textTertiary)
                                    .copyWith(fontSize: 13, height: 1.5),
                              )
                            : Text(
                                '"$_note"',
                                style: AppTypography.bodyS(c.textSecondary)
                                    .copyWith(
                                        fontSize: 13,
                                        height: 1.55,
                                        fontStyle: FontStyle.italic),
                              ),
                      ),
                    ),

                    // Exercises
                    const SizedBox(height: 24),
                    Text(
                      'EXERCISES',
                      style: AppTypography.caption(c.textTertiary).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 10),
                    ...w.exercises.map((ex) {
                      final prWeight = prs
                              .where((p) => p.exercise == ex.name)
                              .map((p) => p.weight)
                              .firstOrNull ??
                          0.0;
                      return _ExerciseDetailCard(
                          ex: ex, c: c, prWeight: prWeight);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fullDay(int d) {
    const n = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return n[(d - 1).clamp(0, 6)];
  }

  static String _fullMonth(int m) {
    const n = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return n[(m - 1).clamp(0, 11)];
  }
}

// ── 2×2 stat tile (design-matching) ──────────────────────────
class _FreshWorkoutDetailScreen extends StatelessWidget {
  const _FreshWorkoutDetailScreen({
    required this.workout,
    required this.dateText,
    required this.prs,
    required this.note,
    required this.onEditNote,
    this.onRepeat,
  });

  final CompletedWorkout workout;
  final String dateText;
  final List<({String exercise, double weight, int reps})> prs;
  final String note;
  final VoidCallback onEditNote;
  final VoidCallback? onRepeat;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final doneExercises =
        workout.exercises.where((ex) => ex.sets.any((set) => set.isDone));

    return VeltScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltTopBar(
            title: workout.routineName,
            subtitle: dateText,
            onBack: () => Navigator.pop(context),
            trailing: VeltPill('${prs.length} PR', accent: prs.isNotEmpty),
          ),
          const SizedBox(height: 14),
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VeltLabel('Session result'),
                const SizedBox(height: 10),
                Text(
                  workout.volumeLabel,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: VeltMetric(
                        value: workout.durationLabel,
                        label: 'duration',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VeltMetric(
                        value: '${workout.doneSets}',
                        label: 'sets',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VeltMetric(
                        value: workout.avgRestSecs > 0
                            ? '${workout.avgRestSecs}s'
                            : '-',
                        label: 'rest',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (prs.isNotEmpty) ...[
            const VeltSection(label: 'Personal records'),
            for (final pr in prs.take(5)) ...[
              VeltRowCard(
                icon: 'PR',
                title: pr.exercise,
                subtitle: '${WeightUnit.format(pr.weight)} x ${pr.reps}',
                trailing: const VeltPill('new', success: true),
              ),
              const SizedBox(height: 8),
            ],
          ],
          VeltSection(
            label: 'Session note',
            trailing: VeltPill(note.isEmpty ? 'Add' : 'Edit', accent: true),
          ),
          GestureDetector(
            onTap: onEditNote,
            child: VeltPanel(
              child: Text(
                note.isEmpty ? 'Tap to add how the workout felt.' : note,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const VeltSection(label: 'Exercises'),
          for (final ex in doneExercises) ...[
            _FreshWorkoutExerciseSummary(exercise: ex),
            const SizedBox(height: 8),
          ],
          if (onRepeat != null) ...[
            const SizedBox(height: 16),
            VeltButton(
              label: 'Repeat this workout',
              onTap: onRepeat,
            ),
          ],
        ],
      ),
    );
  }
}

class _FreshWorkoutExerciseSummary extends StatelessWidget {
  const _FreshWorkoutExerciseSummary({required this.exercise});
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final done = exercise.sets.where((set) => set.isDone).toList();
    final summary = done
        .map((set) =>
            '${set.weight == 0 ? 'BW' : WeightUnit.format(set.weight)} x ${set.reps}')
        .join(' · ');

    return VeltRowCard(
      icon: exercise.name.characters.first.toUpperCase(),
      title: exercise.name,
      subtitle: summary.isEmpty ? '${done.length} sets' : summary,
      trailing: VeltPill(exercise.muscle),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(exerciseName: exercise.name),
        ),
      ),
    );
  }
}

class _DetailStatTile extends StatelessWidget {
  const _DetailStatTile({
    required this.label,
    required this.value,
    required this.c,
    this.accent = false,
  });
  final String label;
  final String value;
  final AppColors c;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            accent ? c.accentIron.withValues(alpha: 0.08) : c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accent ? c.accentIron : c.divider.withValues(alpha: 0.5),
          width: accent ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTypography.displayM(
                accent ? c.accentIron : c.textPrimary,
              ).copyWith(
                fontSize: 24,
                letterSpacing: -0.5,
                height: 1,
                fontFeatures: [const FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 6),
          Text(label.toUpperCase(),
              style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7)),
        ],
      ),
    );
  }
}

// ── Exercise card with type-badge | w×r | trophy/check ───────
class _ExerciseDetailCard extends StatelessWidget {
  const _ExerciseDetailCard({
    required this.ex,
    required this.c,
    this.prWeight = 0.0,
  });
  final WorkoutExercise ex;
  final AppColors c;
  final double prWeight;

  @override
  Widget build(BuildContext context) {
    final doneSets = ex.sets.where((s) => s.isDone).toList();
    if (doneSets.isEmpty) return const SizedBox.shrink();

    int normalIdx = 0;

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
            // Header → tappable → ExerciseDetailScreen
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ExerciseDetailScreen(exerciseName: ex.name)));
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: c.divider.withValues(alpha: 0.4))),
                ),
                child: Row(children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name,
                          style: AppTypography.titleS(c.textPrimary).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(ex.muscle,
                            style: AppTypography.caption(c.textTertiary)
                                .copyWith(fontSize: 10)),
                      ),
                    ],
                  )),
                  Icon(Icons.chevron_right_rounded,
                      size: 14, color: c.accentIron.withValues(alpha: 0.5)),
                ]),
              ),
            ),

            // Set rows: 32px badge | w×r | trophy/check
            ...doneSets.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final isPR = prWeight > 0 && s.weight >= prWeight;

              // Badge
              Widget badge;
              switch (s.type) {
                case SetType.warmup:
                  badge = Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.accentIron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('W',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(c.accentIron).copyWith(
                            fontSize: 9, fontWeight: FontWeight.w700)),
                  );
                case SetType.drop:
                  badge = Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.textTertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('D',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, fontWeight: FontWeight.w700)),
                  );
                case SetType.failure:
                  badge = Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.textTertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('F',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9, fontWeight: FontWeight.w700)),
                  );
                case SetType.normal:
                  normalIdx++;
                  badge = Text('$normalIdx',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w700));
              }

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isPR
                      ? c.accentIron.withValues(alpha: 0.06)
                      : Colors.transparent,
                  border: i < doneSets.length - 1
                      ? Border(
                          bottom: BorderSide(
                              color: c.divider.withValues(alpha: 0.4),
                              width: 0.5))
                      : null,
                ),
                child: Row(children: [
                  SizedBox(width: 32, child: Center(child: badge)),
                  Expanded(
                    child: Text(
                      s.weight > 0
                          ? '${WeightUnit.format(s.weight)} × ${s.reps}'
                          : 'BW × ${s.reps}',
                      style: AppTypography.bodyS(c.textPrimary).copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [const FontFeature.tabularFigures()]),
                    ),
                  ),
                  isPR
                      ? Icon(Icons.emoji_events_rounded,
                          size: 14, color: c.accentIron)
                      : Icon(Icons.check_rounded,
                          size: 14, color: c.successLime),
                ]),
              );
            }),

            // Exercise notes if present
            if (ex.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  border: Border(
                      top: BorderSide(color: c.divider.withValues(alpha: 0.4))),
                ),
                child: Text('"${ex.notes}"',
                    style: AppTypography.bodyS(c.textTertiary).copyWith(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.4)),
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
          width: 72,
          height: 72,
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
