// ignore_for_file: dead_code, unused_element, unused_import

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/workout_history_store.dart';
import '../services/prefs_service.dart';
import '../utils/weight_unit.dart';
import '../models/workout.dart' show CompletedWorkout;
import 'exercise_detail_screen.dart';
import '../widgets/velt_redesign_widgets.dart';
import 'paywall_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _period = 'week';

  Future<void> _showBwLog(BuildContext ctx) async {
    final c = Theme.of(ctx).extension<AppColors>()!;
    await showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BwLogSheet(
        c: c,
        onSaved: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return _FreshProgressScreen(
      period: _period,
      onPeriodChanged: (p) => setState(() => _period = p),
      onLogBodyweight: () => _showBwLog(context),
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<CompletedWorkout>>(
          valueListenable: WorkoutHistoryStore.history,
          builder: (context, history, _) {
            final streak = WorkoutHistoryStore.currentStreak;
            final workouts = WorkoutHistoryStore.workoutsInPeriod(_period);
            final volume = WorkoutHistoryStore.totalVolumeInPeriod(_period);
            final prs = WorkoutHistoryStore.allTimePRs;
            final chartData = switch (_period) {
              'month' => WorkoutHistoryStore.monthlyVolumes(),
              'year' => WorkoutHistoryStore.yearlyVolumes(),
              _ => WorkoutHistoryStore.weeklyVolumes(),
            };

            final now = DateTime.now();
            final periodCutoff = switch (_period) {
              'month' => now.subtract(const Duration(days: 30)),
              'year' => now.subtract(const Duration(days: 365)),
              _ => now.subtract(const Duration(days: 7)),
            };
            final filteredHistory = history
                .where((w) => w.completedAt.isAfter(periodCutoff))
                .toList();

            final volLabel = WeightUnit.isLbs
                ? (volume * 2.20462 >= 1000
                    ? '${((volume * 2.20462) / 1000).toStringAsFixed(1)}k'
                    : (volume * 2.20462).toStringAsFixed(0))
                : (volume >= 1000
                    ? '${(volume / 1000).toStringAsFixed(1)}k'
                    : volume.toStringAsFixed(0));

            final periodLabel = _period[0].toUpperCase() + _period.substring(1);

            return CustomScrollView(
              slivers: [
                // ── Header with period selector ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                        AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: AppTypography.displayL(c.textPrimary)
                                    .copyWith(fontSize: 34, letterSpacing: -1),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Strength, volume & consistency.',
                                style: AppTypography.bodyS(c.textSecondary)
                                    .copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: _PeriodSelector(
                            selected: _period,
                            onSelect: (p) => setState(() => _period = p),
                            c: c,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── KPI strip ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                              child: _KpiCard(
                            value: volume <= 0 ? '0' : volLabel,
                            unit: volume <= 0
                                ? WeightUnit.suffix
                                : WeightUnit.suffix,
                            label: 'Volume',
                            sublabel: 'This $_period',
                            accent: false,
                            c: c,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _KpiCard(
                            value: '$workouts',
                            unit: '',
                            label: 'Sessions',
                            sublabel: 'This $_period',
                            accent: false,
                            c: c,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _KpiCard(
                            value: streak <= 0 ? 'Start' : '$streak',
                            unit: streak > 0 ? 'days' : '',
                            label: 'Streak',
                            sublabel: 'All time',
                            accent: streak > 0,
                            c: c,
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Volume chart ────────────────────────────
                      const SectionHeader(label: 'Training Volume'),
                      _VolumeChart(
                        data: chartData,
                        periodLabel: periodLabel,
                        c: c,
                      ),
                      const SizedBox(height: 24),

                      // ── Bodyweight ──────────────────────────────
                      SectionHeader(
                        label: 'Bodyweight',
                        action: '+ Log today',
                        onAction: () => _showBwLog(context),
                      ),
                      _BodyweightCard(
                        c: c,
                        onLog: () => _showBwLog(context),
                      ),
                      const SizedBox(height: 24),

                      // ── Personal Records ────────────────────────
                      SectionHeader(
                        label: prs.isEmpty
                            ? 'Personal Records'
                            : 'Personal Records  ·  ${prs.length}',
                      ),
                      if (prs.isEmpty)
                        _EmptySection(
                          title: 'No records yet',
                          label:
                              'Records unlock after completing sets.\nTrain to set your first PR.',
                          icon: Icons.emoji_events_outlined,
                          c: c,
                        )
                      else
                        _PRListCard(prs: prs, c: c),
                      const SizedBox(height: 24),

                      // ── Muscle Balance ───────────────────────────
                      const SectionHeader(label: 'Muscle Balance'),
                      _MuscleBreakdownCard(history: filteredHistory, c: c),
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

// ── Period Selector (pill, amber fill active) ──────────────────
class _FreshProgressScreen extends StatelessWidget {
  const _FreshProgressScreen({
    required this.period,
    required this.onPeriodChanged,
    required this.onLogBodyweight,
  });

  final String period;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onLogBodyweight;

  @override
  Widget build(BuildContext context) {
    return VeltScreen(
      child: ValueListenableBuilder<List<CompletedWorkout>>(
        valueListenable: WorkoutHistoryStore.history,
        builder: (context, history, _) {
          final c = Theme.of(context).extension<AppColors>()!;
          final streak = WorkoutHistoryStore.currentStreak;
          final workouts = WorkoutHistoryStore.workoutsInPeriod(period);
          final volume = WorkoutHistoryStore.totalVolumeInPeriod(period);
          final prs = WorkoutHistoryStore.allTimePRs;
          final prEntries = prs.entries.take(4).toList();
          final chartData = switch (period) {
            'month' => WorkoutHistoryStore.monthlyVolumes(),
            'year' => WorkoutHistoryStore.yearlyVolumes(),
            _ => WorkoutHistoryStore.weeklyVolumes(),
          };
          final now = DateTime.now();
          final cutoff = switch (period) {
            'month' => now.subtract(const Duration(days: 30)),
            'year' => now.subtract(const Duration(days: 365)),
            _ => now.subtract(const Duration(days: 7)),
          };
          final filteredHistory =
              history.where((w) => w.completedAt.isAfter(cutoff)).toList();
          // Previous-period comparison
          final prevCutoff = switch (period) {
            'month' => now.subtract(const Duration(days: 60)),
            'year' => now.subtract(const Duration(days: 730)),
            _ => now.subtract(const Duration(days: 14)),
          };
          final prevHistory = history
              .where((w) =>
                  w.completedAt.isAfter(prevCutoff) &&
                  w.completedAt.isBefore(cutoff))
              .toList();
          final prevVolume =
              prevHistory.fold<double>(0, (a, w) => a + w.totalVolume);
          final volumeDelta = prevVolume == 0
              ? null
              : ((volume - prevVolume) / prevVolume * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VeltHeader(
                eyebrow: 'Training signal',
                title: 'Progress',
                trailing: VeltPill(period.toUpperCase(), accent: true),
              ),
              VeltSegment(
                items: const ['Week', 'Month', 'Year'],
                selected: period == 'month'
                    ? 1
                    : period == 'year'
                        ? 2
                        : 0,
                onSelected: (i) =>
                    onPeriodChanged(['week', 'month', 'year'][i]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: VeltMetric(
                          value: WeightUnit.formatVolume(volume),
                          label: 'Volume')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: VeltMetric(value: '$workouts', label: 'Workouts')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: VeltMetric(value: '$streak', label: 'Streak')),
                ],
              ),
              if (volumeDelta != null) ...[
                const SizedBox(height: 10),
                _DeltaRow(deltaPercent: volumeDelta, c: c),
              ],
              const VeltSection(label: 'Training volume'),
              if (chartData.isEmpty)
                _EmptySection(
                  title: 'No data yet',
                  label:
                      'Complete a workout to see your volume trend appear here.',
                  icon: Icons.show_chart_rounded,
                  c: c,
                )
              else
                _VolumeChart(
                  data: chartData,
                  c: c,
                  periodLabel:
                      period[0].toUpperCase() + period.substring(1),
                ),
              VeltSection(
                label: 'Personal records',
                trailing:
                    VeltPill('${prs.length} total', success: prs.isNotEmpty),
              ),
              if (prEntries.isEmpty)
                _EmptySection(
                  title: 'No PRs yet',
                  label:
                      'Hit a heavier set than your previous best — VELT will tag it as a PR.',
                  icon: Icons.emoji_events_outlined,
                  c: c,
                )
              else
                Column(
                  children: [
                    for (final entry in prEntries) ...[
                      VeltRowCard(
                        icon: entry.key.characters.first.toUpperCase(),
                        title: entry.key,
                        subtitle:
                            '${WeightUnit.format(entry.value.weight)} · ${entry.value.dateLabel}',
                        trailing: const VeltPill('PR', success: true),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PRDetailScreen(exerciseName: entry.key)),
                        ),
                      ),
                      if (entry != prEntries.last) const SizedBox(height: 8),
                    ],
                  ],
                ),
              const VeltSection(label: 'Muscle balance'),
              _MuscleBreakdownCard(history: filteredHistory, c: c),
              const VeltSection(label: 'Bodyweight'),
              _BodyweightCard(c: c, onLog: onLogBodyweight),
              const VeltSection(
                label: 'AI Coach Insights',
                trailing: VeltPill('PRO', accent: true),
              ),
              _AiInsightsCard(c: c),
              const SizedBox(height: 12),
              VeltButton(
                label: 'Log bodyweight',
                secondary: true,
                onTap: onLogBodyweight,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.deltaPercent, required this.c});
  final int deltaPercent;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    final up = deltaPercent >= 0;
    final color = up ? c.successLime : c.errorRose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              up
                  ? 'Volume up ${deltaPercent.abs()}% vs previous period'
                  : 'Volume down ${deltaPercent.abs()}% vs previous period',
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard({required this.c});
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.accentIron.withValues(alpha: .22),
            c.surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.accentIron.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.accentIron,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.psychology_alt_rounded,
                    color: c.accentIron.computeLuminance() > .55
                        ? c.ink
                        : Colors.white,
                    size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form score & plateau detection',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI analyzes your sets, finds weak links & suggests deloads',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in const [
                'Plateau alerts',
                'Volume periodization',
                'Deload timing',
                'Recovery score',
              ])
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.surface.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: c.accentIron.withValues(alpha: .3)),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          VeltButton(
            label: 'Unlock with Pro',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({
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
            Expanded(
              child: Text(label,
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
            ),
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        VeltProgressBar(value: pct),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector(
      {required this.selected, required this.onSelect, required this.c});
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['week', 'month', 'year'].map((p) {
          final active = selected == p;
          final label = p[0].toUpperCase() + p.substring(1);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(p);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active ? c.accentIron : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                label,
                style: AppTypography.bodyS(
                  active ? c.surface : c.textSecondary,
                ).copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.accent,
    required this.c,
    this.sublabel,
  });
  final String value;
  final String unit;
  final String label;
  final bool accent;
  final AppColors c;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accent ? c.accentIron : c.divider.withValues(alpha: 0.5),
          width: accent ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.displayM(
              accent ? c.accentIron : c.textPrimary,
            ).copyWith(
              fontSize: 22,
              letterSpacing: -0.6,
              height: 1,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              unit,
              style:
                  AppTypography.caption(c.textSecondary).copyWith(fontSize: 10),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption(
              accent ? c.accentIron : c.textTertiary,
            ).copyWith(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sublabel!,
              style: AppTypography.caption(c.textTertiary)
                  .copyWith(fontSize: 9, letterSpacing: 0.2),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Volume Chart with y-axis labels + touch tooltip ───────────
class _VolumeChart extends StatefulWidget {
  const _VolumeChart({
    required this.data,
    required this.c,
    required this.periodLabel,
  });
  final List<({String label, double volume})> data;
  final AppColors c;
  final String periodLabel;

  @override
  State<_VolumeChart> createState() => _VolumeChartState();
}

class _VolumeChartState extends State<_VolumeChart> {
  int? _hoveredIndex;

  void _onTouch(double localX, double chartWidth) {
    if (widget.data.isEmpty || chartWidth <= 0) return;
    final idx = (localX / chartWidth * widget.data.length)
        .floor()
        .clamp(0, widget.data.length - 1);
    if (_hoveredIndex != idx) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final c = widget.c;
    final volumes = data.map((d) => d.volume).toList();
    final maxVol =
        volumes.isEmpty ? 0.0 : volumes.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVol <= 0 ? 1.0 : maxVol;

    final yMid = (effectiveMax / 2 / 1000).round() * 1000.0;
    final yTop = (effectiveMax / 1000).round() * 1000.0;

    String yLabel(double v) {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
      return v.toStringAsFixed(0);
    }

    final periodLower = widget.periodLabel.toLowerCase();
    final nonEmpty = data.where((d) => d.volume > 0).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: maxVol <= 0
          ? SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 28, color: c.textTertiary.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'No data yet',
                      style: AppTypography.titleS(c.textPrimary)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log workouts to build your volume trend.',
                      style: AppTypography.bodyS(c.textTertiary)
                          .copyWith(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Context row
                Row(
                  children: [
                    Text(
                      'Last 8 ${periodLower}s',
                      style: AppTypography.caption(c.textTertiary)
                          .copyWith(fontSize: 10),
                    ),
                    const Spacer(),
                    if (nonEmpty > 0)
                      Text(
                        '$nonEmpty ${nonEmpty == 1 ? periodLower : '${periodLower}s'} with data',
                        style: AppTypography.caption(c.textSecondary).copyWith(
                            fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Y-axis labels
                      SizedBox(
                        width: 36,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(yLabel(yTop),
                                style: AppTypography.caption(c.textTertiary)
                                    .copyWith(fontSize: 9, fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ])),
                            Text(yLabel(yMid),
                                style: AppTypography.caption(c.textTertiary)
                                    .copyWith(fontSize: 9, fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ])),
                            Text('0',
                                style: AppTypography.caption(c.textTertiary)
                                    .copyWith(fontSize: 9, fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ])),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Bars with gesture
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final chartWidth = constraints.maxWidth;
                            return GestureDetector(
                              onTapDown: (d) =>
                                  _onTouch(d.localPosition.dx, chartWidth),
                              onPanUpdate: (d) =>
                                  _onTouch(d.localPosition.dx, chartWidth),
                              onTapUp: (_) =>
                                  setState(() => _hoveredIndex = null),
                              onPanEnd: (_) =>
                                  setState(() => _hoveredIndex = null),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            color: c.divider
                                                .withValues(alpha: 0.5),
                                            width: 0.5),
                                        bottom: BorderSide(
                                            color: c.divider
                                                .withValues(alpha: 0.5),
                                            width: 0.5),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 1),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children:
                                            data.asMap().entries.map((entry) {
                                          final i = entry.key;
                                          final d = entry.value;
                                          final frac = d.volume / effectiveMax;
                                          final isCurrent =
                                              i == data.length - 1;
                                          final isHovered = i == _hoveredIndex;
                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: FractionallySizedBox(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                heightFactor:
                                                    frac.clamp(0.02, 1.0),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isHovered || isCurrent
                                                            ? c.accentIron
                                                            : c.surfaceHigh,
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    3)),
                                                    boxShadow: isHovered
                                                        ? [
                                                            BoxShadow(
                                                              color: c
                                                                  .accentIron
                                                                  .withValues(
                                                                      alpha:
                                                                          0.35),
                                                              blurRadius: 8,
                                                              spreadRadius: 1,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  // Touch tooltip
                                  if (_hoveredIndex != null &&
                                      _hoveredIndex! < data.length)
                                    _VolumeBarTooltip(
                                      entry: data[_hoveredIndex!],
                                      index: _hoveredIndex!,
                                      totalBars: data.length,
                                      chartWidth: chartWidth,
                                      c: c,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // X-axis labels
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final isCurrent = i == data.length - 1;
                      final isHovered = i == _hoveredIndex;
                      return Expanded(
                        child: Text(
                          data[i].label,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(
                            isHovered || isCurrent
                                ? c.accentIron
                                : c.textTertiary,
                          ).copyWith(
                            fontSize: 10,
                            fontWeight: isHovered || isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _VolumeBarTooltip extends StatelessWidget {
  const _VolumeBarTooltip({
    required this.entry,
    required this.index,
    required this.totalBars,
    required this.chartWidth,
    required this.c,
  });
  final ({String label, double volume}) entry;
  final int index;
  final int totalBars;
  final double chartWidth;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    const tipW = 80.0;
    final barW = chartWidth / totalBars;
    final centerX = index * barW + barW / 2;
    final left = (centerX - tipW / 2).clamp(0.0, chartWidth - tipW);
    final volStr = entry.volume >= 1000
        ? '${(entry.volume / 1000).toStringAsFixed(1)}k'
        : entry.volume.toStringAsFixed(0);

    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: tipW,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.accentIron.withValues(alpha: 0.5)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$volStr ${WeightUnit.suffix}',
              style: AppTypography.caption(c.accentIron).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [const FontFeature.tabularFigures()]),
              textAlign: TextAlign.center,
            ),
            Text(
              entry.label,
              style:
                  AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bodyweight Card with history chart ────────────────────────
class _BodyweightCard extends StatefulWidget {
  const _BodyweightCard({required this.c, required this.onLog});
  final AppColors c;
  final VoidCallback onLog;

  @override
  State<_BodyweightCard> createState() => _BodyweightCardState();
}

class _BodyweightCardState extends State<_BodyweightCard> {
  String _bwPeriod = '1M';

  List<({int dateMs, double kg})> _loadHistory() {
    final raw = PrefsService.bodyweightHistory;
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      final parsed = list.map((e) {
        final m = e as Map;
        return (
          dateMs: m['date'] as int,
          kg: (m['kg'] as num).toDouble(),
        );
      }).toList();
      parsed.sort((a, b) => a.dateMs.compareTo(b.dateMs));
      return parsed;
    } catch (_) {
      return [];
    }
  }

  List<({int dateMs, double kg})> _applyPeriod(
      List<({int dateMs, double kg})> all) {
    if (_bwPeriod == 'All') return all;
    final cutoff = DateTime.now()
        .subtract(switch (_bwPeriod) {
          '3M' => const Duration(days: 90),
          '1Y' => const Duration(days: 365),
          _ => const Duration(days: 30), // 1M default
        })
        .millisecondsSinceEpoch;
    return all.where((e) => e.dateMs >= cutoff).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final onLog = widget.onLog;
    final allHistory = _loadHistory();
    final history = _applyPeriod(allHistory);
    final bwKg = PrefsService.bodyweightKg;

    if (allHistory.isEmpty && bwKg == null) {
      return GestureDetector(
        onTap: onLog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.divider.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(Icons.monitor_weight_outlined,
                  size: 36, color: c.textTertiary.withValues(alpha: 0.6)),
              const SizedBox(height: 10),
              Text(
                'Track your bodyweight',
                style: AppTypography.titleS(c.textPrimary)
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Log today\'s weight to start your trend.',
                style:
                    AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: c.accentIron.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: c.accentIron.withValues(alpha: 0.35), width: 0.5),
                ),
                child: Text(
                  '+ Log today',
                  style: AppTypography.bodyS(c.accentIron)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final effectiveHistory =
        history.isNotEmpty ? history : <({int dateMs, double kg})>[];
    final displayKg =
        bwKg ?? (effectiveHistory.isNotEmpty ? effectiveHistory.last.kg : 0.0);

    final displayVal = WeightUnit.isLbs
        ? (displayKg * 2.20462).toStringAsFixed(1)
        : displayKg.toStringAsFixed(1);

    String? trendText;
    Color trendColor = c.textSecondary;
    if (effectiveHistory.length >= 2) {
      final delta = effectiveHistory.last.kg - effectiveHistory.first.kg;
      final sign = delta >= 0 ? '+' : '';
      final deltaDisplay = WeightUnit.isLbs
          ? (delta * 2.20462).toStringAsFixed(1)
          : delta.toStringAsFixed(1);
      final periodLabel = switch (_bwPeriod) {
        '3M' => 'last 3 months',
        '1Y' => 'last year',
        'All' => 'all time',
        _ => 'last 30 days',
      };
      trendText = '$sign$deltaDisplay ${WeightUnit.suffix} $periodLabel';
      final goal = PrefsService.fitnessGoal;
      final gainIsGood = goal != 'Lose Fat';
      trendColor = (delta >= 0) == gainIsGood ? c.successLime : c.errorRose;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: weight display
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: displayVal,
                  style: AppTypography.displayL(c.textPrimary).copyWith(
                    fontSize: 34,
                    letterSpacing: -1.5,
                    height: 1,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' ${WeightUnit.suffix}',
                  style: AppTypography.bodyM(c.textTertiary)
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          if (trendText != null) ...[
            const SizedBox(height: 4),
            Text(
              trendText,
              style: AppTypography.bodyS(trendColor)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
          if (allHistory.length >= 2) ...[
            const SizedBox(height: 12),
            // Period selector
            Row(
              children: ['1M', '3M', '1Y', 'All'].map((p) {
                final active = _bwPeriod == p;
                return GestureDetector(
                  onTap: () => setState(() => _bwPeriod = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? c.accentIron : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      p,
                      style: AppTypography.caption(
                        active ? Colors.white : c.textTertiary,
                      ).copyWith(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            if (effectiveHistory.length >= 2)
              SizedBox(
                height: 70,
                width: double.infinity,
                child: CustomPaint(
                  painter: _BwLinePainter(
                    data: effectiveHistory,
                    color: c.accentIron,
                    bgColor: c.surfaceElevated,
                  ),
                ),
              )
            else
              SizedBox(
                height: 40,
                child: Center(
                  child: Text(
                    'No entries in this period.',
                    style: AppTypography.bodyS(c.textTertiary)
                        .copyWith(fontSize: 12),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BwLinePainter extends CustomPainter {
  _BwLinePainter({
    required this.data,
    required this.color,
    required this.bgColor,
  });
  final List<({int dateMs, double kg})> data;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final xs = data.map((d) => d.dateMs.toDouble()).toList();
    final ys = data.map((d) => d.kg).toList();
    final xMin = xs.first;
    final xMax = xs.last;
    final yMin = ys.reduce(math.min) - 0.3;
    final yMax = ys.reduce(math.max) + 0.3;
    final xRange = xMax == xMin ? 1.0 : xMax - xMin;
    final yRange = yMax == yMin ? 1.0 : yMax - yMin;

    List<Offset> pts = List.generate(data.length, (i) {
      final x = ((xs[i] - xMin) / xRange) * size.width;
      final y = size.height - ((ys[i] - yMin) / yRange) * size.height;
      return Offset(x, y);
    });

    // Area fill
    final areaPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
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
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (final p in pts) {
      canvas.drawCircle(p, 2, Paint()..color = color);
    }

    // Last point: larger dot with white ring
    final last = pts.last;
    canvas.drawCircle(last, 5, Paint()..color = bgColor);
    canvas.drawCircle(last, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BwLinePainter old) =>
      old.data != data || old.color != color;
}

// ── PR list as single card with dividers ──────────────────────
class _PRListCard extends StatelessWidget {
  const _PRListCard({required this.prs, required this.c});
  final Map<String, ({double weight, String dateLabel})> prs;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final entries = prs.entries.take(8).toList();
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          final weightStr = WeightUnit.format(entry.value.weight);
          return Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PRDetailScreen(exerciseName: entry.key))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.accentIron.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Icon(Icons.emoji_events_outlined,
                              size: 14, color: c.accentIron),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: AppTypography.titleM(c.textPrimary)
                                  .copyWith(
                                      fontSize: 14,
                                      letterSpacing: -0.05,
                                      fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.value.dateLabel,
                              style: AppTypography.bodyS(c.textTertiary)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        weightStr,
                        style: AppTypography.displayM(c.accentIron).copyWith(
                          fontSize: 16,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          size: 16, color: c.textTertiary),
                    ],
                  ),
                ),
              ),
              if (i < entries.length - 1)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: c.divider.withValues(alpha: 0.6),
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Muscle Breakdown horizontal bar chart ─────────────────────
class _MuscleBreakdownCard extends StatelessWidget {
  const _MuscleBreakdownCard({required this.history, required this.c});
  final List<CompletedWorkout> history;
  final AppColors c;

  Map<String, double> _compute() {
    final map = <String, double>{};
    for (final w in history) {
      for (final ex in w.exercises) {
        final vol = ex.sets
            .where((s) => s.isDone && s.weight > 0)
            .fold(0.0, (a, s) => a + s.weight * s.reps);
        if (vol > 0 && ex.muscle.isNotEmpty) {
          map[ex.muscle] = (map[ex.muscle] ?? 0) + vol;
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final muscleVol = _compute();
    if (muscleVol.isEmpty) {
      return _EmptySection(
        title: 'No data yet',
        label: 'Muscle balance appears after completed workouts.',
        icon: Icons.fitness_center_outlined,
        c: c,
      );
    }

    final sorted = muscleVol.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVol = sorted.first.value;
    final totalVol = muscleVol.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: sorted.take(8).toList().asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          final frac = maxVol > 0 ? entry.value / maxVol : 0.0;
          final pct = totalVol > 0 ? (entry.value / totalVol * 100).round() : 0;
          final isLast = i == sorted.take(8).length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTypography.bodyS(c.textPrimary).copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: AppTypography.caption(
                        i == 0 ? c.accentIron : c.textSecondary,
                      ).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [const FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: frac.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: c.surfaceHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(i == 0
                        ? c.accentIron
                        : c.accentIron.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty section ──────────────────────────────────────────────
class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.label,
    required this.c,
    this.title,
    this.icon,
  });
  final String? title;
  final String label;
  final AppColors c;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 32, color: c.textTertiary.withValues(alpha: 0.6)),
              const SizedBox(height: 10),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.titleS(c.textPrimary)
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              label,
              style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bodyweight Log Sheet ───────────────────────────────────────
class _BwLogSheet extends StatefulWidget {
  const _BwLogSheet({required this.c, required this.onSaved});
  final AppColors c;
  final VoidCallback onSaved;

  @override
  State<_BwLogSheet> createState() => _BwLogSheetState();
}

class _BwLogSheetState extends State<_BwLogSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final currentKg = PrefsService.bodyweightKg;
    final display = currentKg == null
        ? ''
        : WeightUnit.isLbs
            ? (currentKg * 2.20462).toStringAsFixed(1)
            : currentKg.toStringAsFixed(1);
    _ctrl = TextEditingController(text: display);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = double.tryParse(_ctrl.text.trim());
    if (raw == null || raw <= 0) return;
    final kg = WeightUnit.isLbs ? raw / 2.20462 : raw;
    setState(() => _saving = true);
    await PrefsService.setBodyweightKg(kg);
    await _appendHistory(kg);
    HapticFeedback.mediumImpact();
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  Future<void> _appendHistory(double kg) async {
    final raw = PrefsService.bodyweightHistory;
    List<dynamic> list = raw != null ? jsonDecode(raw) as List : [];
    final today = DateTime.now();
    final todayMs =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    list.removeWhere((e) => (e as Map)['date'] == todayMs);
    list.add({'date': todayMs, 'kg': kg});
    if (list.length > 90) list = list.sublist(list.length - 90);
    await PrefsService.saveBodyweightHistory(jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final suffix = WeightUnit.suffix;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
            const SizedBox(height: 20),
            Text('Log Bodyweight',
                style: AppTypography.titleM(c.textPrimary)
                    .copyWith(fontSize: 18, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text("Today's entry will update your trend chart",
                style:
                    AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12)),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.displayM(c.textPrimary)
                  .copyWith(fontSize: 32, letterSpacing: -1),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: AppTypography.displayM(c.textTertiary)
                    .copyWith(fontSize: 32, letterSpacing: -1),
                suffixText: suffix,
                suffixStyle:
                    AppTypography.bodyM(c.textSecondary).copyWith(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.accentIron, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.divider),
                ),
                filled: true,
                fillColor: c.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: c.accentIron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Save',
                        style: AppTypography.titleM(Colors.white)
                            .copyWith(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
