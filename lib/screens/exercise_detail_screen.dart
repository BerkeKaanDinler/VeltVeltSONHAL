// ignore_for_file: dead_code, unused_element, unused_import

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/workout_history_store.dart';
import '../services/prefs_service.dart';
import '../utils/weight_unit.dart';
import '../utils/app_constants.dart';
import '../models/workout.dart' show CompletedWorkout;
import '../widgets/velt_redesign_widgets.dart';

// ─────────────────────────────────────────────────────────────
//  DATA HELPERS
// ─────────────────────────────────────────────────────────────

class _ExerciseStats {
  const _ExerciseStats({
    required this.exerciseName,
    required this.muscle,
    required this.equipment,
    required this.topSet,
    required this.totalVolume,
    required this.sessionCount,
    required this.prCount,
    required this.progression,
    required this.recentSessions,
    this.thirtyDayBest,
    this.estimated1RM,
  });

  final String exerciseName;
  final String muscle;
  final String equipment;
  final String topSet;
  final double totalVolume;
  final int sessionCount;
  final int prCount;
  final List<({String label, double weight})> progression;
  final List<({String date, String sets, bool isPR})> recentSessions;
  final double? thirtyDayBest;
  final double? estimated1RM;

  static _ExerciseStats? compute(String exerciseName) {
    final history = WorkoutHistoryStore.history.value;

    String muscle = '';
    String equipment = '';
    double allTimeBest = 0;
    int bestReps = 0;
    double totalVolume = 0;
    int prCount = 0;
    double runningBest = 0;

    final sessions = <CompletedWorkout>[];
    for (final w in history) {
      if (w.exercises.any((e) => e.name == exerciseName)) sessions.add(w);
    }
    if (sessions.isEmpty) return null;

    final sessionsAsc = sessions.reversed.toList();
    final progression = <({String label, double weight})>[];
    final recentSessions = <({String date, String sets, bool isPR})>[];

    final cutoff30 = DateTime.now().subtract(const Duration(days: 30));
    double thirtyDayBest = 0;

    for (final w in sessionsAsc) {
      final ex = w.exercises.firstWhere((e) => e.name == exerciseName);
      if (muscle.isEmpty) {
        muscle = ex.muscle;
        equipment = ex.equipment;
      }

      double sessionBest = 0;
      final doneSets = ex.sets.where((s) => s.isDone && s.weight > 0).toList();

      for (final s in doneSets) {
        totalVolume += s.weight * s.reps;
        if (s.weight > sessionBest) {
          sessionBest = s.weight;
        }
        if (s.weight > allTimeBest) {
          allTimeBest = s.weight;
          bestReps = s.reps;
        }
      }

      if (sessionBest > 0) {
        final isPR = sessionBest > runningBest;
        if (isPR) {
          runningBest = sessionBest;
          prCount++;
        }
        progression
            .add((label: _shortDate(w.completedAt), weight: sessionBest));

        if (w.completedAt.isBefore(cutoff30) && sessionBest > thirtyDayBest) {
          thirtyDayBest = sessionBest;
        }

        final setStrs =
            doneSets.take(4).map((s) => '${s.weight}×${s.reps}').join(', ');
        final suffix = doneSets.length > 4 ? '…' : '';
        recentSessions.add((
          date: w.relativeDate,
          sets: setStrs + suffix,
          isPR: isPR,
        ));
      }
    }

    final chartData = progression.length > 8
        ? progression.sublist(progression.length - 8)
        : progression;
    final recent = recentSessions.reversed.take(5).toList();

    return _ExerciseStats(
      exerciseName: exerciseName,
      muscle: muscle,
      equipment: equipment,
      topSet: allTimeBest > 0
          ? '${WeightUnit.format(allTimeBest)} × $bestReps'
          : '—',
      totalVolume: totalVolume,
      sessionCount: sessionsAsc.length,
      prCount: prCount,
      progression: chartData,
      recentSessions: recent,
      thirtyDayBest: thirtyDayBest > 0 ? thirtyDayBest : null,
      estimated1RM: allTimeBest > 0 && bestReps > 0
          ? AppConstants.epley1RM(allTimeBest, bestReps)
          : null,
    );
  }

  static String _shortDate(DateTime d) {
    const m = [
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
    return '${m[d.month - 1]} ${d.day}';
  }
}

class _PRHistory {
  const _PRHistory({
    required this.exerciseName,
    required this.currentWeight,
    required this.currentReps,
    required this.achievedDate,
    required this.gainedKg,
    required this.progression,
    required this.attempts,
  });

  final String exerciseName;
  final double currentWeight;
  final int currentReps;
  final String achievedDate;
  final double gainedKg;
  final List<({String label, double weight})> progression;
  final List<({String date, String value, bool isCurrent})> attempts;

  static _PRHistory? compute(String exerciseName) {
    final history = WorkoutHistoryStore.history.value;

    final sessions = <CompletedWorkout>[];
    for (final w in history) {
      if (w.exercises.any((e) => e.name == exerciseName)) sessions.add(w);
    }
    if (sessions.isEmpty) return null;

    final sessionsAsc = sessions.reversed.toList();

    double runningBest = 0;
    int runningBestReps = 0;
    String achievedDate = '';
    double firstBest = 0;

    final progression = <({String label, double weight})>[];
    final attempts = <({String date, String value, bool isCurrent})>[];

    for (final w in sessionsAsc) {
      final ex = w.exercises.firstWhere((e) => e.name == exerciseName);

      double sessionBest = 0;
      int sessionBestReps = 0;
      for (final s in ex.sets) {
        if (s.isDone && s.weight > sessionBest) {
          sessionBest = s.weight;
          sessionBestReps = s.reps;
        }
      }

      if (sessionBest > 0) {
        progression
            .add((label: _shortDate(w.completedAt), weight: sessionBest));
        if (firstBest == 0) firstBest = sessionBest;

        if (sessionBest > runningBest) {
          runningBest = sessionBest;
          runningBestReps = sessionBestReps;
          achievedDate = w.relativeDate;
          attempts.insert(0, (
            date: w.relativeDate,
            value: '${WeightUnit.format(sessionBest)} × $sessionBestReps',
            isCurrent: false,
          ));
        }
      }
    }

    if (runningBest <= 0 || attempts.isEmpty) return null;

    // Mark current
    final current = attempts.first;
    attempts[0] = (date: current.date, value: current.value, isCurrent: true);

    final chartData = progression.length > 8
        ? progression.sublist(progression.length - 8)
        : progression;

    return _PRHistory(
      exerciseName: exerciseName,
      currentWeight: runningBest,
      currentReps: runningBestReps,
      achievedDate: achievedDate,
      gainedKg: runningBest - firstBest,
      progression: chartData,
      attempts: attempts.take(5).toList(),
    );
  }

  static String _shortDate(DateTime d) {
    const m = [
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
    return '${m[d.month - 1]} ${d.day}';
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED DETAIL HEADER
// ─────────────────────────────────────────────────────────────

class _FreshExerciseDetailScreen extends StatelessWidget {
  const _FreshExerciseDetailScreen({
    required this.exerciseName,
    required this.data,
    required this.note,
    required this.onEditNote,
  });

  final String exerciseName;
  final _ExerciseStats? data;
  final String note;
  final VoidCallback onEditNote;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final stats = data;

    if (stats == null) {
      return VeltScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VeltTopBar(
              title: exerciseName,
              subtitle: 'No sessions logged yet',
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            const VeltPanel(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: VeltLabel('No data yet')),
              ),
            ),
          ],
        ),
      );
    }

    return VeltScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltTopBar(
            title: exerciseName,
            subtitle: '${stats.muscle} · ${stats.equipment}',
            onBack: () => Navigator.pop(context),
            trailing: VeltPill('${stats.prCount} PR', accent: true),
          ),
          const SizedBox(height: 14),
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VeltLabel('Current top set'),
                const SizedBox(height: 10),
                Text(
                  stats.topSet,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 36,
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
                        value: WeightUnit.formatVolume(stats.totalVolume),
                        label: 'volume',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VeltMetric(
                        value: '${stats.sessionCount}',
                        label: 'sessions',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VeltMetric(
                        value: stats.estimated1RM == null
                            ? '-'
                            : WeightUnit.format(stats.estimated1RM!),
                        label: 'est 1rm',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (stats.progression.length >= 2) ...[
            const VeltSection(label: 'Progress trend'),
            const VeltLineChart(height: 118),
          ],
          VeltSection(
            label: 'Exercise note',
            trailing: VeltPill(note.isEmpty ? 'Add' : 'Edit', accent: true),
          ),
          GestureDetector(
            onTap: onEditNote,
            child: VeltPanel(
              child: Text(
                note.isEmpty
                    ? 'Tap to add cues, setup notes or targets.'
                    : note,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const VeltSection(label: 'Recent sessions'),
          for (final session in stats.recentSessions) ...[
            VeltRowCard(
              icon: session.isPR ? 'PR' : 'S',
              title: session.date,
              subtitle: session.sets,
              trailing:
                  session.isPR ? const VeltPill('record', success: true) : null,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FreshPRDetailScreen extends StatelessWidget {
  const _FreshPRDetailScreen({
    required this.exerciseName,
    required this.data,
  });

  final String exerciseName;
  final _PRHistory? data;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final pr = data;

    if (pr == null) {
      return VeltScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VeltTopBar(
              title: exerciseName,
              subtitle: 'No PR data yet',
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            const VeltPanel(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: VeltLabel('No PR data yet')),
              ),
            ),
          ],
        ),
      );
    }

    return VeltScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltTopBar(
            title: exerciseName,
            subtitle: pr.achievedDate,
            onBack: () => Navigator.pop(context),
            trailing: const VeltPill('1RM PR', accent: true),
          ),
          const SizedBox(height: 14),
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VeltLabel('Personal record'),
                const SizedBox(height: 10),
                Text(
                  WeightUnit.format(pr.currentWeight),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 42,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${pr.currentReps} reps · +${WeightUnit.format(pr.gainedKg)} gained',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (pr.progression.length >= 2) ...[
            const VeltSection(label: 'All-time progression'),
            const VeltLineChart(height: 126),
          ],
          const VeltSection(label: 'Attempts'),
          for (final attempt in pr.attempts) ...[
            VeltRowCard(
              icon: attempt.isCurrent ? 'PR' : 'A',
              title: attempt.date,
              subtitle: attempt.value,
              trailing: attempt.isCurrent
                  ? const VeltPill('current', success: true)
                  : null,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.onBack,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.right,
  });
  final VoidCallback onBack;
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.sm, AppSpacing.screenH, AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
            bottom: BorderSide(
                color: c.divider.withValues(alpha: 0.6), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 16, 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: c.textSecondary),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (right != null) right!,
            ],
          ),
          const SizedBox(height: 4),
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                eyebrow!,
                style: AppTypography.caption(c.accentIron).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          Text(
            title,
            style: AppTypography.displayL(c.textPrimary)
                .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.1),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style:
                    AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EXERCISE DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late String _note;

  @override
  void initState() {
    super.initState();
    _note = PrefsService.getNote('ex_${widget.exerciseName}') ?? '';
  }

  Future<void> _editNote(AppColors c) async {
    final ctrl = TextEditingController(text: _note);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: c.divider, borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('FORM NOTES',
                    style: AppTypography.caption(c.accentIron).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLines: 5,
                  style: AppTypography.bodyS(c.textPrimary)
                      .copyWith(fontSize: 14, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Bar path, cues, technique notes…',
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
                      await PrefsService.clearNote('ex_${widget.exerciseName}');
                    } else {
                      await PrefsService.setNote(
                          'ex_${widget.exerciseName}', text);
                    }
                    setState(() => _note = text);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final data = _ExerciseStats.compute(widget.exerciseName);

    return _FreshExerciseDetailScreen(
      exerciseName: widget.exerciseName,
      data: data,
      note: _note,
      onEditNote: () => _editNote(c),
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailHeader(
              onBack: () => Navigator.pop(context),
              eyebrow: data != null
                  ? '${data.muscle.toUpperCase()} · ${data.equipment.toUpperCase()}'
                  : null,
              title: widget.exerciseName,
            ),
            if (data == null)
              Expanded(
                child: Center(
                  child: Text('No data yet',
                      style: AppTypography.bodyM(c.textTertiary)),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.lg, AppSpacing.screenH, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BestSetCard(data: data, c: c),
                      const SizedBox(height: 12),

                      Row(children: [
                        Expanded(
                            child: _StatTile(
                          label: 'Volume',
                          value: WeightUnit.formatVolume(data.totalVolume),
                          c: c,
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _StatTile(
                          label: 'Sessions',
                          value: '${data.sessionCount}',
                          c: c,
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _StatTile(
                          label: 'PRs',
                          value: '${data.prCount}',
                          c: c,
                          accent: true,
                        )),
                      ]),

                      if (data.progression.length >= 2) ...[
                        const SizedBox(height: 20),
                        const _SectionLabel(label: 'TOP SET PROGRESSION'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: c.divider.withValues(alpha: 0.5)),
                          ),
                          child:
                              _ProgressionChart(data: data.progression, c: c),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const _SectionLabel(label: 'RECENT SESSIONS'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: c.divider.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children:
                              data.recentSessions.asMap().entries.map((e) {
                            final i = e.key;
                            final s = e.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: s.isPR
                                    ? c.accentIron.withValues(alpha: 0.04)
                                    : Colors.transparent,
                                border: i < data.recentSessions.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: c.divider
                                                .withValues(alpha: 0.5),
                                            width: 0.5))
                                    : null,
                              ),
                              child: Row(children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.date,
                                        style:
                                            AppTypography.bodyS(c.textPrimary)
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(s.sets,
                                        style:
                                            AppTypography.bodyS(c.textSecondary)
                                                .copyWith(
                                                    fontSize: 11,
                                                    fontFeatures: [
                                              const FontFeature.tabularFigures()
                                            ])),
                                  ],
                                )),
                                if (s.isPR)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          c.accentIron.withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: Text('PR',
                                        style:
                                            AppTypography.caption(c.accentIron)
                                                .copyWith(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                  ),
                              ]),
                            );
                          }).toList(),
                        ),
                      ),

                      // Form notes section
                      const SizedBox(height: 24),
                      Row(children: [
                        const Expanded(
                            child: _SectionLabel(label: 'FORM NOTES')),
                        GestureDetector(
                          onTap: () => _editNote(c),
                          child: Text(_note.isEmpty ? 'Add' : 'Edit',
                              style: AppTypography.bodyS(c.accentIron).copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _editNote(c),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: c.accentIron.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: c.accentIron.withValues(alpha: 0.25)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 3,
                                    color: c.accentIron.withValues(alpha: 0.6),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(
                                              Icons.lightbulb_outline_rounded,
                                              size: 13,
                                              color: c.accentIron,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'TECHNIQUE CUES',
                                              style: AppTypography.caption(
                                                      c.accentIron)
                                                  .copyWith(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ]),
                                          const SizedBox(height: 8),
                                          _note.isEmpty
                                              ? Text(
                                                  'Tap to add cues and technique reminders…',
                                                  style: AppTypography.bodyS(
                                                          c.textTertiary)
                                                      .copyWith(
                                                          fontSize: 13,
                                                          height: 1.5))
                                              : Text(_note,
                                                  style: AppTypography.bodyS(
                                                          c.textSecondary)
                                                      .copyWith(
                                                          fontSize: 13,
                                                          height: 1.6)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

class _BestSetCard extends StatelessWidget {
  const _BestSetCard({required this.data, required this.c});
  final _ExerciseStats data;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEST SET (CURRENT)',
                  style: AppTypography.caption(c.accentIron).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.9),
                ),
                const SizedBox(height: 6),
                Text(
                  data.topSet,
                  style: AppTypography.displayL(c.textPrimary).copyWith(
                      fontSize: 26,
                      letterSpacing: -0.8,
                      fontFeatures: [const FontFeature.tabularFigures()],
                      height: 1),
                ),
                if (data.thirtyDayBest != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '↑ +${(data.progression.last.weight - data.thirtyDayBest!).toStringAsFixed(1)} ${WeightUnit.suffix} vs 30 days ago',
                    style: AppTypography.bodyS(c.successLime)
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ] else if (data.progression.length >= 2) ...[
                  const SizedBox(height: 8),
                  Text(
                    '↑ +${(data.progression.last.weight - data.progression.first.weight).toStringAsFixed(1)} ${WeightUnit.suffix} total gain',
                    style: AppTypography.bodyS(c.successLime)
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accentIron.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.emoji_events_rounded,
                    color: c.accentIron, size: 24),
              ),
              if (data.estimated1RM != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: c.divider.withValues(alpha: 0.7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EST. 1RM',
                        style: AppTypography.caption(c.textTertiary).copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        WeightUnit.format(data.estimated1RM!),
                        style: AppTypography.displayM(c.textPrimary).copyWith(
                            fontSize: 15,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.w700,
                            fontFeatures: [const FontFeature.tabularFigures()]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PR DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class PRDetailScreen extends StatefulWidget {
  const PRDetailScreen({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<PRDetailScreen> createState() => _PRDetailScreenState();
}

class _PRDetailScreenState extends State<PRDetailScreen> {
  late String _note;

  @override
  void initState() {
    super.initState();
    _note = PrefsService.getNote('pr_${widget.exerciseName}') ?? '';
  }

  Future<void> _editNote(AppColors c) async {
    final ctrl = TextEditingController(text: _note);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, _) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: c.divider, borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('PR NOTE',
                    style: AppTypography.caption(c.accentIron).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLines: 5,
                  style: AppTypography.bodyS(c.textPrimary)
                      .copyWith(fontSize: 14, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'How did this PR feel? What made it possible?',
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
                      await PrefsService.clearNote('pr_${widget.exerciseName}');
                    } else {
                      await PrefsService.setNote(
                          'pr_${widget.exerciseName}', text);
                    }
                    setState(() => _note = text);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final data = _PRHistory.compute(widget.exerciseName);

    return _FreshPRDetailScreen(
      exerciseName: widget.exerciseName,
      data: data,
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailHeader(
              onBack: () => Navigator.pop(context),
              eyebrow: '1RM PERSONAL RECORD',
              title: widget.exerciseName,
              subtitle: data?.achievedDate,
              right: GhostButton(
                label: 'Share',
                onPressed: () {},
                height: 32,
              ),
            ),
            if (data == null)
              Expanded(
                child: Center(
                  child: Text('No PR data yet',
                      style: AppTypography.bodyM(c.textTertiary)),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.lg, AppSpacing.screenH, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero PR value
                      _HeroPRCard(data: data, c: c),
                      const SizedBox(height: 20),

                      // Progression chart
                      if (data.progression.length >= 2) ...[
                        const _SectionLabel(label: 'ALL-TIME PROGRESSION'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: c.divider.withValues(alpha: 0.5)),
                          ),
                          child: _BigProgressionChart(
                            data: data.progression,
                            gainedKg: data.gainedKg,
                            c: c,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const _SectionLabel(label: 'PR ATTEMPTS'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: c.divider.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: data.attempts.asMap().entries.map((e) {
                            final i = e.key;
                            final a = e.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: i < data.attempts.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: c.divider
                                                .withValues(alpha: 0.4),
                                            width: 0.5))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Timeline dot
                                  SizedBox(
                                    width: 16,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (i < data.attempts.length - 1)
                                          Positioned(
                                            top: 14,
                                            bottom: -12,
                                            child: Container(
                                              width: 1,
                                              color: c.divider,
                                            ),
                                          ),
                                        Container(
                                          width: a.isCurrent ? 14 : 10,
                                          height: a.isCurrent ? 14 : 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: a.isCurrent
                                                ? c.accentIron
                                                : c.surfaceHigh,
                                            border: a.isCurrent
                                                ? Border.all(
                                                    color: c.surface, width: 2)
                                                : Border.all(
                                                    color: c.divider, width: 1),
                                            boxShadow: a.isCurrent
                                                ? [
                                                    BoxShadow(
                                                        color: c.accentIron
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 0,
                                                        spreadRadius: 3)
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.date,
                                          style: AppTypography.bodyS(a.isCurrent
                                                  ? c.accentIron
                                                  : c.textPrimary)
                                              .copyWith(
                                                  fontSize: 13,
                                                  fontWeight: a.isCurrent
                                                      ? FontWeight.w700
                                                      : FontWeight.w500),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          a.value,
                                          style: AppTypography.bodyS(
                                                  c.textSecondary)
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
                                  if (a.isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: c.accentIron,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text('CURRENT',
                                          style: AppTypography.caption(
                                                  Colors.white)
                                              .copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: c.accentIron
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text('PR',
                                          style: AppTypography.caption(
                                                  c.accentIron)
                                              .copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700)),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // PR Note section
                      const SizedBox(height: 24),
                      Row(children: [
                        const Expanded(child: _SectionLabel(label: 'PR NOTE')),
                        GestureDetector(
                          onTap: () => _editNote(c),
                          child: Text(_note.isEmpty ? 'Add' : 'Edit',
                              style: AppTypography.bodyS(c.accentIron).copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
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
                              ? Text('Tap to record how this PR felt…',
                                  style: AppTypography.bodyS(c.textTertiary)
                                      .copyWith(fontSize: 13, height: 1.5))
                              : Text('"$_note"',
                                  style: AppTypography.bodyS(c.textSecondary)
                                      .copyWith(
                                          fontSize: 13,
                                          height: 1.6,
                                          fontStyle: FontStyle.italic)),
                        ),
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

class _HeroPRCard extends StatelessWidget {
  const _HeroPRCard({required this.data, required this.c});
  final _PRHistory data;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.accentIron.withValues(alpha: 0.12),
            c.accentIron.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.accentIron.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentIron.withValues(alpha: 0.18),
            ),
            child:
                Icon(Icons.emoji_events_rounded, color: c.accentIron, size: 26),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.currentWeight % 1 == 0
                    ? '${data.currentWeight.toInt()}'
                    : '${data.currentWeight}',
                style: AppTypography.displayL(c.accentIron).copyWith(
                  fontSize: 56,
                  letterSpacing: -2,
                  height: 1,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                WeightUnit.suffix,
                style: AppTypography.titleM(c.textSecondary)
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '× ${data.currentReps} reps',
            style: AppTypography.bodyS(c.textTertiary).copyWith(
                fontSize: 12,
                fontFeatures: [const FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:
            accent ? c.accentIron.withValues(alpha: 0.08) : c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accent
              ? c.accentIron.withValues(alpha: 0.4)
              : c.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.displayM(accent ? c.accentIron : c.textPrimary)
                .copyWith(
                    fontSize: 22,
                    letterSpacing: -0.5,
                    height: 1,
                    fontFeatures: [const FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption(accent ? c.accentIron : c.textTertiary)
                .copyWith(fontSize: 8, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Text(
      label,
      style: AppTypography.caption(c.textTertiary).copyWith(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CHARTS
// ─────────────────────────────────────────────────────────────

class _ProgressionChart extends StatefulWidget {
  const _ProgressionChart({required this.data, required this.c});
  final List<({String label, double weight})> data;
  final AppColors c;

  @override
  State<_ProgressionChart> createState() => _ProgressionChartState();
}

class _ProgressionChartState extends State<_ProgressionChart> {
  int? _hoveredIndex;

  void _onTouch(double localX, double chartWidth) {
    if (widget.data.length < 2) return;
    final idx = (localX / chartWidth * (widget.data.length - 1))
        .round()
        .clamp(0, widget.data.length - 1);
    setState(() => _hoveredIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    const chartH = 100.0;
    return Column(
      children: [
        LayoutBuilder(builder: (_, constraints) {
          final w = constraints.maxWidth;
          return GestureDetector(
            onTapDown: (d) => _onTouch(d.localPosition.dx, w),
            onPanUpdate: (d) => _onTouch(d.localPosition.dx, w),
            onPanEnd: (_) => setState(() => _hoveredIndex = null),
            onTapUp: (_) => setState(() => _hoveredIndex = null),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _LinePainter(
                    data: widget.data.map((d) => d.weight).toList(),
                    color: c.accentIron,
                    bgColor: c.surfaceElevated,
                    fillColor: c.accentIron,
                    highlightIndex: _hoveredIndex,
                  ),
                  size: Size(w, chartH),
                ),
                if (_hoveredIndex != null)
                  _ChartTooltip(
                    index: _hoveredIndex!,
                    data: widget.data,
                    chartWidth: w,
                    chartHeight: chartH,
                    c: c,
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.data.asMap().entries.map((e) {
            final isLast = e.key == widget.data.length - 1;
            final isHovered = e.key == _hoveredIndex;
            return Text(
              e.value.label,
              style: AppTypography.caption(
                isHovered
                    ? c.accentIron
                    : isLast
                        ? c.accentIron
                        : c.textTertiary,
              ).copyWith(
                  fontSize: 9,
                  fontWeight: (isLast || isHovered)
                      ? FontWeight.w700
                      : FontWeight.w500),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BigProgressionChart extends StatefulWidget {
  const _BigProgressionChart({
    required this.data,
    required this.gainedKg,
    required this.c,
  });
  final List<({String label, double weight})> data;
  final double gainedKg;
  final AppColors c;

  @override
  State<_BigProgressionChart> createState() => _BigProgressionChartState();
}

class _BigProgressionChartState extends State<_BigProgressionChart> {
  int? _hoveredIndex;

  void _onTouch(double localX, double chartWidth) {
    if (widget.data.length < 2) return;
    final idx = (localX / chartWidth * (widget.data.length - 1))
        .round()
        .clamp(0, widget.data.length - 1);
    setState(() => _hoveredIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    const chartH = 130.0;
    return Column(
      children: [
        LayoutBuilder(builder: (_, constraints) {
          final w = constraints.maxWidth;
          return GestureDetector(
            onTapDown: (d) => _onTouch(d.localPosition.dx, w),
            onPanUpdate: (d) => _onTouch(d.localPosition.dx, w),
            onPanEnd: (_) => setState(() => _hoveredIndex = null),
            onTapUp: (_) => setState(() => _hoveredIndex = null),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _LinePainter(
                    data: widget.data.map((d) => d.weight).toList(),
                    color: c.accentIron,
                    bgColor: c.surfaceElevated,
                    fillColor: c.accentIron,
                    strokeWidth: 2.5,
                    highlightLast: _hoveredIndex == null,
                    highlightIndex: _hoveredIndex,
                  ),
                  size: Size(w, chartH),
                ),
                if (_hoveredIndex != null)
                  _ChartTooltip(
                    index: _hoveredIndex!,
                    data: widget.data,
                    chartWidth: w,
                    chartHeight: chartH,
                    c: c,
                  ),
              ],
            ),
          );
        }),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.divider, width: 0.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChartStat(
                label: 'Started',
                value: '${widget.data.first.weight} ${WeightUnit.suffix}',
                color: c.textSecondary,
              ),
              _ChartStat(
                label: 'Gained',
                value:
                    '+${widget.gainedKg.toStringAsFixed(1)} ${WeightUnit.suffix}',
                color: c.successLime,
              ),
              _ChartStat(
                label: 'Current',
                value: '${widget.data.last.weight} ${WeightUnit.suffix}',
                color: c.accentIron,
                alignEnd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartStat extends StatelessWidget {
  const _ChartStat({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption(c.textTertiary).copyWith(
              fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyS(color).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CHART TOOLTIP
// ─────────────────────────────────────────────────────────────

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.index,
    required this.data,
    required this.chartWidth,
    required this.chartHeight,
    required this.c,
  });
  final int index;
  final List<({String label, double weight})> data;
  final double chartWidth;
  final double chartHeight;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    if (index < 0 || index >= data.length) return const SizedBox.shrink();
    final item = data[index];

    // Compute x position of the touched point
    final xFraction = data.length > 1 ? index / (data.length - 1) : 0.5;
    final xPos = xFraction * chartWidth;

    // Tooltip width
    const tipW = 76.0;
    const tipH = 40.0;
    const margin = 6.0;

    double left = xPos - tipW / 2;
    left = left.clamp(0.0, chartWidth - tipW);

    return Positioned(
      top: margin,
      left: left,
      child: Container(
        width: tipW,
        height: tipH,
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
              color: c.accentIron.withValues(alpha: 0.4), width: 0.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              WeightUnit.format(item.weight),
              style: AppTypography.bodyS(c.accentIron).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  fontFeatures: [const FontFeature.tabularFigures()]),
            ),
            Text(
              item.label,
              style:
                  AppTypography.caption(c.textTertiary).copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LINE PAINTER
// ─────────────────────────────────────────────────────────────

class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.data,
    required this.color,
    required this.bgColor,
    required this.fillColor,
    this.strokeWidth = 2.0,
    this.highlightLast = false,
    this.highlightIndex,
  });

  final List<double> data;
  final Color color;
  final Color bgColor;
  final Color fillColor;
  final double strokeWidth;
  final bool highlightLast;
  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minY = data.reduce(math.min);
    final maxY = data.reduce(math.max);
    final range = (maxY - minY).clamp(1.0, double.infinity);
    final pad = range * 0.15;
    final lo = minY - pad;
    final hi = maxY + pad;

    List<Offset> pts = List.generate(
        data.length,
        (i) => Offset(
              (i / (data.length - 1)) * size.width,
              size.height - ((data[i] - lo) / (hi - lo)) * size.height,
            ));

    // Fill area
    final fillPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor.withValues(alpha: 0.3),
            fillColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (int i = 0; i < pts.length; i++) {
      final p = pts[i];
      final isLast = i == pts.length - 1;
      final isTouched = i == highlightIndex;
      if (isTouched) {
        canvas.drawCircle(p, 7, Paint()..color = color.withAlpha(40));
        canvas.drawCircle(p, 5, Paint()..color = color);
        canvas.drawCircle(p, 3, Paint()..color = bgColor);
        canvas.drawCircle(p, 2, Paint()..color = color);
      } else if (isLast && highlightLast) {
        canvas.drawCircle(p, 6, Paint()..color = color);
        canvas.drawCircle(p, 4, Paint()..color = bgColor);
        canvas.drawCircle(p, 2.5, Paint()..color = color);
      } else {
        canvas.drawCircle(p, 2.5, Paint()..color = bgColor);
        canvas.drawCircle(
            p,
            2,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
