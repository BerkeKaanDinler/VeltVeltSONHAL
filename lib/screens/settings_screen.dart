import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/nutrition_store.dart';
import '../services/prefs_service.dart';
import '../services/routine_store.dart';
import '../services/workout_history_store.dart';
import 'velt_pro_screen.dart';
import 'workout_history_screen.dart';

// ── Theme preview data ─────────────────────────────────────────
class _ThemePreview {
  const _ThemePreview({
    required this.key,
    required this.name,
    required this.description,
    required this.tier,
    required this.bg,
    required this.card,
    required this.accent,
    required this.dividerColor,
  });
  final String key;
  final String name;
  final String description;
  final String tier; // 'free' | 'pro'
  final Color bg;
  final Color card;
  final Color accent;
  final Color dividerColor;
}

const _themePreviews = [
  _ThemePreview(
    key: 'iron', tier: 'free', name: 'Iron Dark',
    description: 'The default. Deep black with amber highlights.',
    bg: Color(0xFF0F0F0F), card: Color(0xFF1A1A1A),
    accent: Color(0xFFD97706), dividerColor: Color(0xFF2A2A2A),
  ),
  _ThemePreview(
    key: 'slate', tier: 'free', name: 'Slate Mono',
    description: 'Cool industrial — navy base with slate accents.',
    bg: Color(0xFF0A0E1A), card: Color(0xFF141927),
    accent: Color(0xFF94A3B8), dividerColor: Color(0xFF252B3D),
  ),
  _ThemePreview(
    key: 'roseGold', tier: 'pro', name: 'Rose Gold',
    description: 'Warm noir — dark with rose gold highlights.',
    bg: Color(0xFF100A0E), card: Color(0xFF1B131A),
    accent: Color(0xFFF472B6), dividerColor: Color(0xFF2D2128),
  ),
  _ThemePreview(
    key: 'emerald', tier: 'pro', name: 'Emerald Premium',
    description: 'Deep forest — dark green with emerald accents.',
    bg: Color(0xFF0A1410), card: Color(0xFF0F1F18),
    accent: Color(0xFF10B981), dividerColor: Color(0xFF1F352A),
  ),
];

// ══════════════════════════════════════════════════════════
//  SETTINGS SCREEN
// ══════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onThemeChange,
    required this.currentThemeKey,
  });

  final void Function(String key) onThemeChange;
  final String currentThemeKey;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _unit;
  late int _restSecs;
  late String _goal;
  late String _experience;

  @override
  void initState() {
    super.initState();
    _unit       = PrefsService.unit;
    _restSecs   = PrefsService.restSecs;
    _goal       = PrefsService.fitnessGoal;
    _experience = PrefsService.experienceLevel;
  }

  String get _levelLabel => switch (_experience) {
    'beginner' => 'Beginner',
    'advanced' => 'Advanced',
    _          => 'Intermediate',
  };

  String get _nutritionSummary {
    final raw = PrefsService.nutritionTargets;
    if (raw == null) return 'Not set';
    try {
      final m = jsonDecode(raw) as Map;
      final cal  = m['calories'] as int? ?? 0;
      final prot = m['protein']  as int? ?? 0;
      return '$cal kcal · ${prot}g protein';
    } catch (_) {
      return 'Not set';
    }
  }

  void _showRestSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RestTimerSheet(
        value: _restSecs,
        c: Theme.of(context).extension<AppColors>()!,
        onSave: (v) {
          setState(() => _restSecs = v);
          PrefsService.setRestSecs(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLevelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LevelSheet(
        current: _experience,
        c: Theme.of(context).extension<AppColors>()!,
        onSave: (l) {
          setState(() => _experience = l);
          PrefsService.setExperienceLevel(l);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalSheet(
        current: _goal,
        c: Theme.of(context).extension<AppColors>()!,
        onSave: (g) {
          setState(() => _goal = g);
          PrefsService.setFitnessGoal(g);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemeSheet(
        currentKey: widget.currentThemeKey,
        onSelect: (k) {
          widget.onThemeChange(k);
          Navigator.pop(context);
        },
        c: Theme.of(context).extension<AppColors>()!,
      ),
    );
  }

  void _showNutriSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NutriSheet(
        c: Theme.of(context).extension<AppColors>()!,
        onSave: (cal, prot, carbs, fat) {
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteSheet() {
    final c = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteSheet(
        c: c,
        onConfirm: () async {
          await WorkoutHistoryStore.clearAll();
          await RoutineStore.clearAll();
          await NutritionStore.clearAll();
          await PrefsService.clearActiveWorkout();
          await PrefsService.clearLastWorkout();
          await PrefsService.clearBodyweightHistory();
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('All data deleted'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
          ));
        },
      ),
    );
  }

  void _toggleUnit(String u) {
    setState(() => _unit = u);
    PrefsService.setUnit(u);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final workoutCount = WorkoutHistoryStore.history.value.length;
    final streak  = WorkoutHistoryStore.currentStreak;
    final thisWeek = WorkoutHistoryStore.workoutsInPeriod('week');

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.lg,
                  AppSpacing.screenH, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VELT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: c.accentIron,
                        letterSpacing: -1.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your training profile.',
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    // Stat strip
                    Row(
                      children: [
                        _MiniStat(
                          label: 'Sessions',
                          value: '$workoutCount',
                          c: c,
                        ),
                        _MiniStat(
                          label: 'Streak',
                          value: '${streak}d',
                          c: c,
                        ),
                        _MiniStat(
                          label: 'This Week',
                          value: '$thisWeek',
                          c: c,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Profile chips
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.accentIron.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            _goal,
                            style: AppTypography.caption(c.accentIron).copyWith(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                                color: c.divider.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            _levelLabel,
                            style: AppTypography.caption(c.textSecondary)
                                .copyWith(
                                    fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, 0,
                AppSpacing.screenH, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ══ VELT PRO CARD ═════════════════════════════
                  _VeltProCard(c: c),
                  const SizedBox(height: 20),

                  // ══ APPEARANCE ════════════════════════════════
                  _SectionLabel(label: 'APPEARANCE', c: c),
                  _SectionCard(c: c, children: [
                    _SettingRow(
                      label: 'Theme',
                      value: _themePreviews
                          .firstWhere((t) => t.key == widget.currentThemeKey,
                              orElse: () => _themePreviews.first)
                          .name,
                      rightWidget: _ThemeDot(
                        color: c.accentIron,
                        outline: c.surfaceElevated,
                        ring: c.divider,
                      ),
                      chevron: true,
                      isLast: true,
                      onTap: _showThemeSheet,
                      c: c,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ══ TRAINING ══════════════════════════════════
                  _SectionLabel(label: 'TRAINING', c: c),
                  _SectionCard(c: c, children: [
                    _SettingRow(
                      label: 'Rest Timer',
                      value: '$_restSecs seconds',
                      chevron: true,
                      onTap: _showRestSheet,
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Weight Unit',
                      rightWidget: _UnitToggle(
                        selected: _unit,
                        onSelect: _toggleUnit,
                        c: c,
                      ),
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Experience Level',
                      value: _levelLabel,
                      chevron: true,
                      isLast: true,
                      onTap: _showLevelSheet,
                      c: c,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ══ GOALS ═════════════════════════════════════
                  _SectionLabel(label: 'GOALS', c: c),
                  _SectionCard(c: c, children: [
                    _SettingRow(
                      label: 'Fitness Goal',
                      rightWidget: _GoalPill(goal: _goal, c: c),
                      chevron: true,
                      onTap: _showGoalSheet,
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Nutrition Targets',
                      value: _nutritionSummary,
                      chevron: true,
                      isLast: true,
                      onTap: _showNutriSheet,
                      c: c,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ══ DATA ══════════════════════════════════════
                  _SectionLabel(label: 'DATA', c: c),
                  _SectionCard(c: c, children: [
                    _SettingRow(
                      label: 'Workout History',
                      value: '$workoutCount workouts logged',
                      chevron: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkoutHistoryScreen()),
                      ),
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Export Data',
                      rightWidget: _ComingSoonPill(c: c),
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Clear All Data',
                      danger: true,
                      isLast: true,
                      onTap: _showDeleteSheet,
                      c: c,
                    ),
                  ]),

                  // Privacy note
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 20),
                    child: Text(
                      'Your training data stays on this device. Nothing is shared externally.',
                      style: AppTypography.caption(c.textTertiary).copyWith(
                          fontSize: 11, height: 1.5),
                    ),
                  ),

                  // ══ ABOUT ═════════════════════════════════════
                  _SectionLabel(label: 'ABOUT', c: c),
                  _SectionCard(c: c, children: [
                    _SettingRow(
                      label: 'App Version',
                      value: 'VELT 1.0.0',
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Restore Purchases',
                      chevron: true,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Nothing to restore yet.'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                      ),
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Privacy Policy',
                      chevron: true,
                      c: c,
                    ),
                    _SettingRow(
                      label: 'Terms of Use',
                      chevron: true,
                      isLast: true,
                      c: c,
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Section label ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.c});
  final String label;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: AppTypography.caption(c.textSecondary).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Section card ───────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.c, required this.children});
  final AppColors c;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

// ── Setting row ────────────────────────────────────────────────
class _SettingRow extends StatefulWidget {
  const _SettingRow({
    required this.label,
    required this.c,
    this.value,
    this.rightWidget,
    this.chevron = false,
    this.danger = false,
    this.isLast = false,
    this.onTap,
  });
  final String label;
  final String? value;
  final Widget? rightWidget;
  final bool chevron;
  final bool danger;
  final bool isLast;
  final VoidCallback? onTap;
  final AppColors c;

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null
          ? setState(() => _pressed = true)
          : null,
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? c.surfaceHigh : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: c.divider.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.bodyM(
                      widget.danger ? c.errorRose : c.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.05,
                    ),
                  ),
                  if (widget.value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.value!,
                      style: AppTypography.bodyS(c.textTertiary).copyWith(
                        fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.rightWidget != null) widget.rightWidget!,
            if (widget.chevron)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right_rounded,
                  size: 16, color: c.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small widgets ──────────────────────────────────────────────
class _ThemeDot extends StatelessWidget {
  const _ThemeDot({
    required this.color, required this.outline, required this.ring});
  final Color color;
  final Color outline;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: outline, width: 2),
        boxShadow: [
          BoxShadow(
            color: ring.withValues(alpha: 0.8),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({required this.goal, required this.c});
  final String goal;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentIron.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        goal,
        style: AppTypography.caption(c.accentIron).copyWith(
          fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: c.divider.withValues(alpha: 0.5)),
        ),
        child: Text(
          'Coming Soon',
          style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.selected, required this.onSelect, required this.c});
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['kg', 'lbs'].map((u) {
          final active = selected == u;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(u);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: active ? c.accentIron : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                u,
                style: AppTypography.bodyS(
                  active ? Colors.white : c.textTertiary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  SHEETS
// ══════════════════════════════════════════════════════════

// ── Rest Timer Sheet ───────────────────────────────────────────
class _RestTimerSheet extends StatefulWidget {
  const _RestTimerSheet({
    required this.value, required this.c, required this.onSave});
  final int value;
  final AppColors c;
  final ValueChanged<int> onSave;

  @override
  State<_RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<_RestTimerSheet> {
  late int _v;

  @override
  void initState() {
    super.initState();
    _v = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(c: c),
          const SizedBox(height: 16),
          Text('Default Rest Timer',
            style: AppTypography.titleM(c.textPrimary).copyWith(
              fontSize: 18, letterSpacing: -0.3)),
          const SizedBox(height: 20),
          // Big countdown display
          Text(
            '$_v',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: c.accentIron,
              letterSpacing: -2,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text('seconds',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 12)),
          const SizedBox(height: 16),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: c.accentIron,
              thumbColor: c.accentIron,
              inactiveTrackColor: c.surfaceHigh,
              trackHeight: 3,
              overlayColor: c.accentIron.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: _v.toDouble(),
              min: 30,
              max: 300,
              divisions: 18,
              onChanged: (v) => setState(() => _v = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30s', style: AppTypography.caption(c.textTertiary)
                  .copyWith(fontSize: 10)),
              Text('5min', style: AppTypography.caption(c.textTertiary)
                  .copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          // Quick chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [60, 90, 120, 180].map((t) {
              final active = _v == t;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _v = t);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? c.accentIron.withValues(alpha: 0.12)
                          : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: active
                            ? c.accentIron.withValues(alpha: 0.5)
                            : c.divider.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${t}s',
                      style: AppTypography.bodyS(
                        active ? c.accentIron : c.textSecondary,
                      ).copyWith(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Save',
            onPressed: () => widget.onSave(_v),
          ),
        ],
      ),
    );
  }
}

// ── Level Sheet ────────────────────────────────────────────────
class _LevelSheet extends StatefulWidget {
  const _LevelSheet({
    required this.current, required this.c, required this.onSave});
  final String current;
  final AppColors c;
  final ValueChanged<String> onSave;

  @override
  State<_LevelSheet> createState() => _LevelSheetState();
}

class _LevelSheetState extends State<_LevelSheet> {
  late String _pick;

  @override
  void initState() {
    super.initState();
    _pick = widget.current;
  }

  static const _levels = [
    (id: 'beginner',     label: 'Beginner',     desc: 'Less than 1 year of training', rest: 75),
    (id: 'intermediate', label: 'Intermediate', desc: '1 – 3 years of training',       rest: 90),
    (id: 'advanced',     label: 'Advanced',     desc: '3+ years, programmed training', rest: 120),
  ];

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(c: c),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Experience Level',
              style: AppTypography.titleM(c.textPrimary).copyWith(
                fontSize: 18, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 16),
          ..._levels.map((l) {
            final active = _pick == l.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pick = l.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: active
                        ? c.accentIron.withValues(alpha: 0.08)
                        : c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: active
                          ? c.accentIron
                          : c.divider.withValues(alpha: 0.6),
                      width: active ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.label,
                              style: AppTypography.titleM(c.textPrimary)
                                  .copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(l.desc,
                              style: AppTypography.bodyS(c.textSecondary)
                                  .copyWith(fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              'REST TIMER DEFAULT · ${l.rest}s',
                              style: AppTypography.caption(c.textTertiary)
                                  .copyWith(fontSize: 10, letterSpacing: 0.4),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.accentIron,
                          ),
                          child: const Icon(Icons.check_rounded,
                            size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Save',
            onPressed: () => widget.onSave(_pick),
          ),
        ],
      ),
    );
  }
}

// ── Goal Sheet (2×2 grid) ──────────────────────────────────────
class _GoalSheet extends StatefulWidget {
  const _GoalSheet({
    required this.current, required this.c, required this.onSave});
  final String current;
  final AppColors c;
  final ValueChanged<String> onSave;

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late String _pick;

  @override
  void initState() {
    super.initState();
    _pick = widget.current;
  }

  static const _goals = [
    (id: 'Build Muscle', desc: 'Add lean mass & size',      color: Color(0xFFD97706)),
    (id: 'Lose Fat',     desc: 'Lean out, keep strength',   color: Color(0xFF22C55E)),
    (id: 'Strength',     desc: 'Push your 1RM higher',      color: Color(0xFF6366F1)),
    (id: 'Endurance',    desc: 'Last longer, recover faster', color: Color(0xFF06B6D4)),
  ];

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(c: c),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Fitness Goal',
              style: AppTypography.titleM(c.textPrimary).copyWith(
                fontSize: 18, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
            children: _goals.map((g) {
              final active = _pick == g.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pick = g.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: active
                        ? g.color.withValues(alpha: 0.08)
                        : c.surfaceHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: active
                          ? g.color
                          : c.divider.withValues(alpha: 0.5),
                      width: active ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(g.id,
                        style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          letterSpacing: -0.05)),
                      const SizedBox(height: 3),
                      Text(g.desc,
                        style: AppTypography.bodyS(c.textSecondary).copyWith(
                          fontSize: 10, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save',
            onPressed: () => widget.onSave(_pick),
          ),
        ],
      ),
    );
  }
}

// ── Theme Sheet ────────────────────────────────────────────────
class _ThemeSheet extends StatefulWidget {
  const _ThemeSheet({
    required this.currentKey,
    required this.onSelect,
    required this.c,
  });
  final String currentKey;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  State<_ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends State<_ThemeSheet> {
  _ThemePreview? _upgradeTarget;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final freeThemes = _themePreviews.where((t) => t.tier == 'free').toList();
    final proThemes  = _themePreviews.where((t) => t.tier == 'pro').toList();

    if (_upgradeTarget != null) {
      return _UpgradePrompt(
        theme: _upgradeTarget!,
        c: c,
        onBack: () => setState(() => _upgradeTarget = null),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHandle(c: c),
        // Title + close
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text('Choose Theme',
                style: AppTypography.titleM(c.textPrimary).copyWith(
                  fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('×', style: TextStyle(
                  color: c.textSecondary, fontSize: 22,
                  fontWeight: FontWeight.w300, height: 1)),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme changes apply instantly across every screen.',
                  style: AppTypography.bodyS(c.textTertiary).copyWith(
                    fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 16),
                // FREE section
                Text('FREE',
                  style: AppTypography.caption(c.textTertiary).copyWith(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
                const SizedBox(height: 8),
                ...freeThemes.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ThemeCard(
                    preview: t,
                    active: widget.currentKey == t.key,
                    locked: false,
                    c: c,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onSelect(t.key);
                      Navigator.pop(context);
                    },
                  ),
                )),
                const SizedBox(height: 12),
                // PRO section
                Row(
                  children: [
                    Text('VELT PRO',
                      style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.accentIron.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('UPGRADE',
                        style: AppTypography.caption(c.accentIron).copyWith(
                          fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...proThemes.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ThemeCard(
                    preview: t,
                    active: widget.currentKey == t.key,
                    locked: true,
                    c: c,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _upgradeTarget = t);
                    },
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

// ── Upgrade prompt (inline, replaces the theme list) ───────────
class _UpgradePrompt extends StatelessWidget {
  const _UpgradePrompt({required this.theme, required this.c, required this.onBack});
  final _ThemePreview theme;
  final AppColors c;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(c: c),
          const SizedBox(height: 8),
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded,
                      size: 14, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text('Back to themes',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Big preview box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.dividerColor, width: 0.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accent.withValues(alpha: 0.18),
                  ),
                  child: Icon(Icons.lock_outline_rounded,
                    size: 20, color: theme.accent),
                ),
                const SizedBox(height: 12),
                Text(
                  theme.name,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
                    color: theme.bg.computeLuminance() > 0.3
                        ? const Color(0xFF1A1410)
                        : const Color(0xFFF1F5F9),
                    letterSpacing: -0.4),
                ),
                const SizedBox(height: 6),
                Text(
                  theme.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, height: 1.5,
                    color: theme.bg.computeLuminance() > 0.3
                        ? const Color(0xFF6B5B4E)
                        : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Premium themes are part of VELT Pro, alongside advanced analytics, cloud backup, and more.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyS(c.textSecondary).copyWith(
              fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Upgrade to VELT Pro',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VeltProScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Nutrition Targets Sheet ────────────────────────────────────
class _NutriSheet extends StatefulWidget {
  const _NutriSheet({required this.c, required this.onSave});
  final AppColors c;
  final void Function(int cal, int prot, int carbs, int fat) onSave;

  @override
  State<_NutriSheet> createState() => _NutriSheetState();
}

class _NutriSheetState extends State<_NutriSheet> {
  late TextEditingController _calCtrl;
  late TextEditingController _protCtrl;
  late TextEditingController _carbsCtrl;
  late TextEditingController _fatCtrl;

  @override
  void initState() {
    super.initState();
    final raw = PrefsService.nutritionTargets;
    int cal = 2500, prot = 180, carbs = 280, fat = 70;
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map;
        cal   = m['calories'] as int? ?? cal;
        prot  = m['protein']  as int? ?? prot;
        carbs = m['carbs']    as int? ?? carbs;
        fat   = m['fat']      as int? ?? fat;
      } catch (_) {}
    }
    _calCtrl   = TextEditingController(text: '$cal');
    _protCtrl  = TextEditingController(text: '$prot');
    _carbsCtrl = TextEditingController(text: '$carbs');
    _fatCtrl   = TextEditingController(text: '$fat');
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    _protCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final cal   = int.tryParse(_calCtrl.text)   ?? 0;
    final prot  = int.tryParse(_protCtrl.text)  ?? 0;
    final carbs = int.tryParse(_carbsCtrl.text) ?? 0;
    final fat   = int.tryParse(_fatCtrl.text)   ?? 0;
    NutritionStore.updateTargets(
        NutritionTargets(calories: cal, protein: prot, carbs: carbs, fat: fat));
    widget.onSave(cal, prot, carbs, fat);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(c: c),
            const SizedBox(height: 16),
            Text('Nutrition Targets',
              style: AppTypography.titleM(c.textPrimary).copyWith(
                fontSize: 18, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text('Set your daily macro targets.',
              style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _NutriField(
                  label: 'Calories',
                  unit: 'kcal',
                  ctrl: _calCtrl,
                  c: c,
                )),
                const SizedBox(width: 8),
                Expanded(child: _NutriField(
                  label: 'Protein',
                  unit: 'g',
                  ctrl: _protCtrl,
                  c: c,
                )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _NutriField(
                  label: 'Carbs',
                  unit: 'g',
                  ctrl: _carbsCtrl,
                  c: c,
                )),
                const SizedBox(width: 8),
                Expanded(child: _NutriField(
                  label: 'Fat',
                  unit: 'g',
                  ctrl: _fatCtrl,
                  c: c,
                )),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _NutriField extends StatelessWidget {
  const _NutriField({
    required this.label,
    required this.unit,
    required this.ctrl,
    required this.c,
  });
  final String label;
  final String unit;
  final TextEditingController ctrl;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption(c.textTertiary).copyWith(
            fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: c.surfaceHigh,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: c.divider.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyM(c.textPrimary).copyWith(
                    fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: AppTypography.bodyM(c.textTertiary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(unit,
                  style: AppTypography.caption(c.textTertiary).copyWith(
                    fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Delete Sheet ───────────────────────────────────────────────
class _DeleteSheet extends StatelessWidget {
  const _DeleteSheet({required this.c, required this.onConfirm});
  final AppColors c;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(c: c),
          const SizedBox(height: 16),
          Text('Clear All Data?',
            style: AppTypography.titleM(c.textPrimary).copyWith(
              fontSize: 18, letterSpacing: -0.3)),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTypography.bodyS(c.textSecondary).copyWith(
                fontSize: 14, height: 1.6),
              children: [
                const TextSpan(
                  text: 'This will permanently delete all your workouts, routines, PRs, and nutrition logs. '),
                TextSpan(
                  text: 'This cannot be undone.',
                  style: TextStyle(
                    color: c.errorRose, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  height: 44,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.errorRose,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        'Delete Everything',
                        style: AppTypography.titleS(Colors.white).copyWith(
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

// ── Sheet handle ───────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36, height: 4,
        decoration: BoxDecoration(
          color: c.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Mini stat (header strip) ───────────────────────────────────
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.c,
    this.isLast = false,
  });
  final String label;
  final String value;
  final AppColors c;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.5,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(c.textTertiary)
                  .copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── VELT Pro card (standalone promo, top of list) ──────────────
class _VeltProCard extends StatefulWidget {
  const _VeltProCard({required this.c});
  final AppColors c;

  @override
  State<_VeltProCard> createState() => _VeltProCardState();
}

class _VeltProCardState extends State<_VeltProCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VeltProScreen()),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.8 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.accentIron.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.accentIron.withValues(alpha: 0.06),
                c.surfaceElevated,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accentIron.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.bolt_rounded, size: 20, color: c.accentIron),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VELT Pro',
                      style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Premium themes, advanced analytics & more.',
                      style: AppTypography.bodyS(c.textSecondary)
                          .copyWith(fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: c.accentIron.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme Card (horizontal list item) ─────────────────────────
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preview,
    required this.active,
    required this.locked,
    required this.c,
    required this.onTap,
  });
  final _ThemePreview preview;
  final bool active;
  final bool locked;
  final AppColors c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: active
                ? c.accentIron
                : c.divider.withValues(alpha: 0.5),
            width: active ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // 64×64 preview swatch
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: preview.bg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: preview.dividerColor.withValues(alpha: 0.8),
                  width: 0.5),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8, left: 6, right: 6,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: preview.card,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 26, left: 6,
                    child: Container(
                      width: 28, height: 8,
                      decoration: BoxDecoration(
                        color: preview.card.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 6,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: preview.accent,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14, right: 6,
                    child: Container(
                      width: 22, height: 6,
                      decoration: BoxDecoration(
                        color: preview.accent.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        preview.name,
                        style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 14, letterSpacing: -0.1),
                      ),
                      if (locked) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.lock_outline_rounded,
                          size: 12, color: c.textTertiary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview.description,
                    style: AppTypography.bodyS(c.textTertiary).copyWith(
                      fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Trailing
            if (active)
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accentIron,
                ),
                child: const Icon(Icons.check_rounded,
                  size: 12, color: Colors.white),
              )
            else if (locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: c.accentIron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('PRO',
                  style: AppTypography.caption(c.accentIron).copyWith(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
              ),
          ],
        ),
      ),
    );
  }
}
