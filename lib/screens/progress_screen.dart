import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/workout_history_store.dart';
import '../services/prefs_service.dart';
import '../utils/weight_unit.dart';
import 'active_workout_screen.dart' show CompletedWorkout;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _period = 'month';

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

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<CompletedWorkout>>(
          valueListenable: WorkoutHistoryStore.history,
          builder: (context, history, _) {
            final streak   = WorkoutHistoryStore.currentStreak;
            final workouts = WorkoutHistoryStore.workoutsInPeriod(_period);
            final volume   = WorkoutHistoryStore.totalVolumeInPeriod(_period);
            final prs      = WorkoutHistoryStore.allTimePRs;
            final weekly   = WorkoutHistoryStore.weeklyVolumes();

            final volLabel = WeightUnit.isLbs
                ? (volume * 2.20462 >= 1000
                    ? '${((volume * 2.20462) / 1000).toStringAsFixed(1)}k'
                    : (volume * 2.20462).toStringAsFixed(0))
                : (volume >= 1000
                    ? '${(volume / 1000).toStringAsFixed(1)}k'
                    : volume.toStringAsFixed(0));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg,
                      AppSpacing.md, AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Progress',
                          style: AppTypography.displayL(c.textPrimary).copyWith(
                            fontSize: 34, letterSpacing: -1),
                        ),
                        const Spacer(),
                        _PeriodSegment(
                          selected: _period,
                          onSelect: (p) => setState(() => _period = p),
                          c: c,
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

                      // ── KPI strip ──────────────────────────
                      Row(
                        children: [
                          Expanded(child: _BigStatCard(
                            value: volLabel,
                            unit: WeightUnit.suffix,
                            label: 'Volume',
                            accent: false,
                            c: c,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _BigStatCard(
                            value: '$workouts',
                            unit: '',
                            label: 'Workouts',
                            accent: false,
                            c: c,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _BigStatCard(
                            value: '$streak',
                            unit: '',
                            label: 'Streak',
                            accent: true,
                            c: c,
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Weekly Volume chart ─────────────────
                      const SectionHeader(label: 'Weekly Volume'),
                      const SizedBox(height: AppSpacing.xs),
                      _WeeklyVolumeChart(data: weekly, c: c),
                      const SizedBox(height: 20),

                      // ── Volume by Muscle — Pro gated ────────
                      const SectionHeader(label: 'Volume by Muscle'),
                      const SizedBox(height: AppSpacing.xs),
                      _ProGatedMuscleBars(c: c, onUpgrade: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('VELT Pro coming soon — stay tuned!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // ── Personal Records ────────────────────
                      const SectionHeader(label: 'Personal Records'),
                      const SizedBox(height: AppSpacing.xs),
                      if (prs.isEmpty)
                        _EmptySection(
                          label: 'Complete workouts to track your PRs',
                          c: c,
                        )
                      else
                        ...prs.entries.take(8).toList().asMap().entries.map((e) {
                          final i = e.key;
                          final entry = e.value;
                          final weightStr = WeightUnit.format(entry.value.weight);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i < (prs.length - 1).clamp(0, 7) ? 10 : 0),
                            child: _PRRow(
                              exercise: entry.key,
                              value: weightStr,
                              date: entry.value.dateLabel,
                              c: c,
                            ),
                          );
                        }),
                      const SizedBox(height: 20),

                      // ── Bodyweight ──────────────────────────
                      SectionHeader(
                        label: 'Bodyweight',
                        action: 'Log',
                        onAction: () => _showBwLog(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _BodyweightCard(
                        c: c,
                        onLog: () => _showBwLog(context),
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

// ── Period Segment ─────────────────────────────────────────────
class _PeriodSegment extends StatelessWidget {
  const _PeriodSegment({
    required this.selected, required this.onSelect, required this.c});
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['week', 'month', 'year'].map((p) {
          final active = selected == p;
          return GestureDetector(
            onTap: () => onSelect(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: active ? c.accentIron : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                p[0].toUpperCase() + p.substring(1),
                style: AppTypography.bodyS(
                  active ? Colors.white : c.textTertiary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Big Stat Card ──────────────────────────────────────────────
class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.value, required this.unit, required this.label,
    required this.accent, required this.c,
  });
  final String value;
  final String unit;
  final String label;
  final bool accent;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accent
              ? c.accentIron.withValues(alpha: 0.3)
              : c.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.displayM(
                  accent ? c.accentIron : c.textPrimary,
                ).copyWith(
                  fontSize: 28, letterSpacing: -0.9, height: 1,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: AppTypography.bodyS(c.textSecondary).copyWith(
                    fontWeight: FontWeight.w500, fontSize: 11),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption(c.textTertiary).copyWith(
              fontSize: 10, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Volume Chart ────────────────────────────────────────
class _WeeklyVolumeChart extends StatelessWidget {
  const _WeeklyVolumeChart({required this.data, required this.c});
  final List<({String label, double volume})> data;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final maxVol = data.isEmpty
        ? 1.0
        : data.map((d) => d.volume).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVol <= 0 ? 1.0 : maxVol;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (maxVol <= 0)
            SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Log workouts to see volume trends',
                  style: AppTypography.bodyS(c.textTertiary).copyWith(
                    fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((d) {
                  final frac = d.volume / effectiveMax;
                  final isThisWeek = d == data.last;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: frac.clamp(0.04, 1.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: isThisWeek
                                          ? [c.accentIron,
                                             c.accentIron.withValues(alpha: 0.7)]
                                          : [c.surfaceHigh,
                                             c.surfaceHigh],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: data.map((d) => Expanded(
                child: Text(
                  d.label.split(' ').last, // day number only
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(c.textTertiary).copyWith(
                    fontSize: 8,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pro Gated Muscle Bars ──────────────────────────────────────
class _ProGatedMuscleBars extends StatelessWidget {
  const _ProGatedMuscleBars({required this.c, required this.onUpgrade});
  final AppColors c;
  final VoidCallback onUpgrade;

  static const _muscles = [
    (name: 'Chest',     pct: 0.85),
    (name: 'Back',      pct: 0.70),
    (name: 'Shoulders', pct: 0.60),
    (name: 'Legs',      pct: 0.90),
    (name: 'Arms',      pct: 0.40),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          Column(
            children: _muscles.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(m.name,
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 11)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: m.pct,
                        child: Container(
                          decoration: BoxDecoration(
                            color: c.accentIron,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                color: c.surface.withValues(alpha: 0.87),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surfaceHigh,
                      ),
                      child: Icon(Icons.lock_outline_rounded,
                          size: 17, color: c.textTertiary),
                    ),
                    const SizedBox(height: 6),
                    Text('Advanced Analytics',
                      style: AppTypography.titleM(c.textPrimary)
                          .copyWith(fontSize: 14, letterSpacing: -0.1)),
                    const SizedBox(height: 3),
                    Text('Unlock with VELT Pro',
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 11)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onUpgrade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.accentIron),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text('Upgrade',
                          style: AppTypography.bodyS(c.accentIron).copyWith(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
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

// ── PR Row ─────────────────────────────────────────────────────
class _PRRow extends StatelessWidget {
  const _PRRow({
    required this.exercise, required this.value,
    required this.date, required this.c,
  });
  final String exercise;
  final String value;
  final String date;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentIron.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: c.accentIron,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 14, letterSpacing: -0.1),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTypography.bodyS(c.textTertiary).copyWith(
                    fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTypography.displayM(c.accentIron).copyWith(
              fontSize: 16,
              letterSpacing: -0.2,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty section ──────────────────────────────────────────────
class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.label, required this.c});
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.bodyS(c.textTertiary).copyWith(
            fontSize: 12, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Bodyweight Card ────────────────────────────────────────────
class _BodyweightCard extends StatelessWidget {
  const _BodyweightCard({required this.c, required this.onLog});
  final AppColors c;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final bwKg = PrefsService.bodyweightKg;
    final hasData = bwKg != null;

    final displayVal = hasData
        ? (WeightUnit.isLbs
            ? (bwKg * 2.20462).toStringAsFixed(1)
            : bwKg.toStringAsFixed(1))
        : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: hasData
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: displayVal,
                        style: AppTypography.displayL(c.textPrimary).copyWith(
                          fontSize: 34, letterSpacing: -1,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: ' ${WeightUnit.suffix}',
                        style: AppTypography.bodyM(c.textSecondary).copyWith(
                          fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onLog,
                  child: Text(
                    '+ Log today',
                    style: AppTypography.bodyS(c.accentIron).copyWith(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: onLog,
              child: Column(
                children: [
                  Icon(Icons.monitor_weight_outlined,
                    size: 32, color: c.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to log your bodyweight',
                    style: AppTypography.bodyS(c.textTertiary).copyWith(
                      fontSize: 12, fontStyle: FontStyle.italic),
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
    final todayMs = DateTime(today.year, today.month, today.day)
        .millisecondsSinceEpoch;
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Log Bodyweight',
              style: AppTypography.titleM(c.textPrimary).copyWith(
                fontSize: 18, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text('Today\'s entry will update your trend chart',
              style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12)),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.displayM(c.textPrimary).copyWith(
                fontSize: 32, letterSpacing: -1),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: AppTypography.displayM(c.textTertiary).copyWith(
                  fontSize: 32, letterSpacing: -1),
                suffixText: suffix,
                suffixStyle: AppTypography.bodyM(c.textSecondary).copyWith(
                  fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.accentIron, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.divider),
                ),
                filled: true,
                fillColor: c.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
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
                    borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : Text('Save',
                        style: AppTypography.titleM(Colors.white).copyWith(
                          fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
