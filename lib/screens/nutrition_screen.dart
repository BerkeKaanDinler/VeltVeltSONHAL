// ignore_for_file: dead_code, unused_element, unused_import

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/nutrition_store.dart';
import '../services/prefs_service.dart';
import '../widgets/velt_redesign_widgets.dart';
import 'paywall_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  void _showAddFood(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFoodSheet(
        onAdd: (entry) {
          NutritionStore.addEntry(entry);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTargets(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTargetsSheet(
        current: NutritionStore.targets.value,
        onSave: (t) {
          NutritionStore.updateTargets(t);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return _FreshNutritionScreen(
      onAddFood: () => _showAddFood(context),
      onEditTargets: () => _showEditTargets(context),
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<FoodEntry>>(
          valueListenable: NutritionStore.entries,
          builder: (context, entries, _) {
            return ValueListenableBuilder<NutritionTargets>(
              valueListenable: NutritionStore.targets,
              builder: (context, targets, _) {
                final totalCal = NutritionStore.totalCalories;
                final totalProt = NutritionStore.totalProtein;
                final totalCarb = NutritionStore.totalCarbs;
                final totalFat = NutritionStore.totalFat;
                final remaining = targets.calories - totalCal;
                final remainingColor = remaining < 0
                    ? c.errorRose
                    : remaining < 200
                        ? c.warningAmber
                        : c.successLime;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                            AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Nutrition',
                                    style: AppTypography.displayL(c.textPrimary)
                                        .copyWith(
                                            fontSize: 34, letterSpacing: -1),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Calories, macros & weekly consistency.',
                                    style: AppTypography.bodyS(c.textTertiary)
                                        .copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GhostButton(
                              label: 'Edit Targets',
                              onPressed: () => _showEditTargets(context),
                              height: 34,
                              fontSize: 12,
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
                          // ── Calorie ring ──────────────────────
                          _CalorieHero(
                            consumed: totalCal,
                            target: targets.calories,
                            remaining: remaining,
                            remainingColor: remainingColor,
                            goal: PrefsService.fitnessGoal,
                            c: c,
                          ),
                          const SizedBox(height: 16),

                          // ── Macro bars ────────────────────────
                          const SectionHeader(
                            label: 'Macros',
                            padding: EdgeInsets.only(bottom: 8),
                          ),
                          _MacroBars(
                            protein: (
                              current: totalProt,
                              goal: targets.protein.toDouble()
                            ),
                            carbs: (
                              current: totalCarb,
                              goal: targets.carbs.toDouble()
                            ),
                            fat: (
                              current: totalFat,
                              goal: targets.fat.toDouble()
                            ),
                            c: c,
                          ),
                          if (remaining < 0) ...[
                            const SizedBox(height: 8),
                            _OvereatBanner(excess: -remaining, c: c),
                          ],
                          const SizedBox(height: 20),

                          // ── Today's log ───────────────────────
                          SectionHeader(
                            label: "Today's Log",
                            action: '+ Add Food',
                            onAction: () => _showAddFood(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          if (entries.isEmpty)
                            _EmptyLog(
                              onAdd: () => _showAddFood(context),
                              c: c,
                            )
                          else ...[
                            ...entries.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _FoodEntryCard(
                                    entry: e.value,
                                    onDelete: () =>
                                        NutritionStore.removeEntry(e.key),
                                    onAddAgain: () =>
                                        NutritionStore.addEntry(FoodEntry(
                                      name: e.value.name,
                                      calories: e.value.calories,
                                      protein: e.value.protein,
                                      carbs: e.value.carbs,
                                      fat: e.value.fat,
                                    )),
                                    c: c,
                                  ),
                                )),
                            const SizedBox(height: 8),
                            GhostButton(
                              label: '+ Add Food',
                              onPressed: () => _showAddFood(context),
                              height: 44,
                              fontSize: 13,
                            ),
                          ],
                          const SizedBox(height: 20),

                          // ── Weekly bar chart ──────────────────
                          const SectionHeader(label: 'This Week'),
                          const SizedBox(height: AppSpacing.xs),
                          _WeeklyCalorieChart(
                            target: targets.calories,
                            c: c,
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Calorie Hero ──────────────────────────────────────────────
class _FreshNutritionScreen extends StatelessWidget {
  const _FreshNutritionScreen({
    required this.onAddFood,
    required this.onEditTargets,
  });

  final VoidCallback onAddFood;
  final VoidCallback onEditTargets;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return VeltScreen(
      child: ValueListenableBuilder<List<FoodEntry>>(
        valueListenable: NutritionStore.entries,
        builder: (context, entries, _) {
          return ValueListenableBuilder<NutritionTargets>(
            valueListenable: NutritionStore.targets,
            builder: (context, targets, _) {
              final totalCal = NutritionStore.totalCalories;
              final totalProt = NutritionStore.totalProtein;
              final totalCarb = NutritionStore.totalCarbs;
              final totalFat = NutritionStore.totalFat;
              final remaining = targets.calories - totalCal;
              final calPct =
                  targets.calories <= 0 ? 0.0 : totalCal / targets.calories;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VeltHeader(
                    eyebrow: 'Daily intake',
                    title: 'Nutrition',
                    trailing: VeltIconButton(label: '+', onTap: onAddFood),
                  ),
                  VeltPanel(
                    child: Row(
                      children: [
                        VeltRing(
                          value: _fmt(totalCal),
                          label: 'kcal',
                          progress: calPct,
                          size: 142,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              _MacroLine(
                                label: 'Protein',
                                value: '$totalProt / ${targets.protein}g',
                                pct: _pct(totalProt, targets.protein),
                                color: c.protein,
                              ),
                              const SizedBox(height: 12),
                              _MacroLine(
                                label: 'Carbs',
                                value: '$totalCarb / ${targets.carbs}g',
                                pct: _pct(totalCarb, targets.carbs),
                                color: c.carbs,
                              ),
                              const SizedBox(height: 12),
                              _MacroLine(
                                label: 'Fat',
                                value: '$totalFat / ${targets.fat}g',
                                pct: _pct(totalFat, targets.fat),
                                color: c.fat,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VeltSection(label: 'Water intake'),
                  _WaterTracker(c: c),
                  const VeltSection(label: 'Quick log'),
                  _QuickLogRow(onAdd: onAddFood, c: c),
                  const VeltSection(
                    label: 'VELT AI Nutritionist',
                    trailing: VeltPill('PRO', accent: true),
                  ),
                  _AiCoachCard(c: c),
                  VeltSection(
                    label: "Today's log",
                    trailing: VeltPill(
                      remaining >= 0
                          ? '${_fmt(remaining)} left'
                          : '${_fmt(-remaining)} over',
                      success: remaining >= 0,
                      error: remaining < 0,
                    ),
                  ),
                  if (entries.isEmpty)
                    VeltPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No food logged',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: c.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a meal to track calories and macros.',
                            style:
                                TextStyle(color: c.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          VeltButton(label: 'Add Food', onTap: onAddFood),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final e in entries.take(4)) ...[
                          VeltRowCard(
                            icon: e.name.characters.first.toUpperCase(),
                            title: e.name,
                            subtitle:
                                'P ${e.protein}g · C ${e.carbs}g · F ${e.fat}g',
                            trailing: VeltPill('${e.calories}'),
                          ),
                          if (e != entries.take(4).last)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  const VeltSection(
                    label: 'This week',
                    trailing: VeltPill('Targets', accent: true),
                  ),
                  VeltPanel(
                    child: Column(
                      children: [
                        const VeltBars(
                          values: [.58, .76, .64, .84, .71, .92, .68],
                          activeIndex: 5,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ].map((d) => VeltLabel(d)).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  VeltButton(
                    label: 'Edit Targets',
                    secondary: true,
                    onTap: onEditTargets,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static double _pct(num current, num target) =>
      target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  static String _fmt(num v) => v.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}

// ── Water tracker ─────────────────────────────────────────────
class _WaterTracker extends StatelessWidget {
  const _WaterTracker({required this.c});
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NutritionStore.waterGlasses,
      builder: (ctx, glasses, _) {
        const target = NutritionStore.waterTarget;
        return VeltPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop_rounded,
                      color: c.carbs, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$glasses of $target glasses',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      NutritionStore.removeWater();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.remove_rounded,
                          color: c.textSecondary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      NutritionStore.addWater();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.carbs.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: c.carbs.withValues(alpha: .4)),
                      ),
                      child: Icon(Icons.add_rounded,
                          color: c.carbs, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(target, (i) {
                  final on = i < glasses;
                  return Expanded(
                    child: Container(
                      height: 28,
                      margin: EdgeInsets.only(right: i == target - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: on
                            ? c.carbs.withValues(alpha: .25)
                            : c.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: on
                              ? c.carbs.withValues(alpha: .65)
                              : c.divider,
                          width: on ? 1.2 : 0.5,
                        ),
                      ),
                      child: on
                          ? Icon(Icons.water_drop_rounded,
                              color: c.carbs, size: 14)
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Quick log chips ─────────────────────────────────────────
class _QuickLogRow extends StatelessWidget {
  const _QuickLogRow({required this.onAdd, required this.c});
  final VoidCallback onAdd;
  final AppColors c;

  static const _quickItems = [
    ('Eggs', '70 kcal · 6P', 70, 6, 1, 5),
    ('Chicken breast', '165 kcal · 31P', 165, 31, 0, 4),
    ('Oats', '150 kcal · 5P', 150, 5, 27, 3),
    ('Whey shake', '120 kcal · 24P', 120, 24, 3, 1),
    ('Banana', '105 kcal · 1P', 105, 1, 27, 0),
    ('Rice', '200 kcal · 4P', 200, 4, 45, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _quickItems.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onAdd();
              },
              child: Container(
                width: 76,
                decoration: BoxDecoration(
                  color: c.accentIron.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: c.accentIron.withValues(alpha: .35)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: c.accentIron, size: 22),
                    const SizedBox(height: 4),
                    Text('Custom',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: c.accentIron,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            );
          }
          final item = _quickItems[i - 1];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              NutritionStore.addEntry(FoodEntry(
                name: item.$1,
                calories: item.$3,
                protein: item.$4.toDouble(),
                carbs: item.$5.toDouble(),
                fat: item.$6.toDouble(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.$1}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: c.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── AI Coach card (Pro upsell) ─────────────────────────────
class _AiCoachCard extends StatelessWidget {
  const _AiCoachCard({required this.c});
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
                child: Icon(Icons.auto_awesome_rounded,
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
                      'Personalized meal plan',
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
                      'AI adjusts macros to your goals & workouts',
                      maxLines: 2,
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
                'Weekly recipes',
                'Auto macro tuning',
                'Photo log',
                'Grocery lists',
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

class _MacroLine extends StatelessWidget {
  const _MacroLine({
    required this.label,
    required this.value,
    required this.pct,
    required this.color,
  });

  final String label;
  final String value;
  final double pct;
  final Color color;

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
                color: c.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        VeltProgressBar(value: pct, color: color),
      ],
    );
  }
}

class _CalorieHero extends StatelessWidget {
  const _CalorieHero({
    required this.consumed,
    required this.target,
    required this.remaining,
    required this.remainingColor,
    required this.goal,
    required this.c,
  });
  final int consumed;
  final int target;
  final int remaining;
  final Color remainingColor;
  final String goal;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final pct = (consumed / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Ring
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: pct,
                    ringColor: c.accentIron,
                    trackColor: c.surfaceHigh,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$consumed',
                          style: AppTypography.displayM(c.textPrimary).copyWith(
                            fontSize: 22,
                            letterSpacing: -0.8,
                            height: 1,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'kcal',
                          style: AppTypography.caption(c.textTertiary)
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CalStat(
                      label: 'Goal',
                      value: '$target',
                      color: c.textSecondary,
                      c: c,
                    ),
                    const SizedBox(height: 8),
                    _CalStat(
                      label: 'Consumed',
                      value: '$consumed',
                      color: c.accentIron,
                      c: c,
                    ),
                    const SizedBox(height: 8),
                    _CalStat(
                      label: remaining >= 0 ? 'Remaining' : 'Over',
                      value: '${remaining.abs()}',
                      color: remainingColor,
                      c: c,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: c.divider.withValues(alpha: 0.4), width: 0.5),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Target  ',
                      style: TextStyle(
                          fontSize: 10,
                          color: c.textTertiary,
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: goal,
                      style: TextStyle(
                          fontSize: 10,
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  const _CalStat({
    required this.label,
    required this.value,
    required this.color,
    required this.c,
  });
  final String label;
  final String value; // just the number string
  final Color color;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption(c.textTertiary)
              .copyWith(fontSize: 9, letterSpacing: 1.0),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTypography.titleS(color).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' kcal',
                style: AppTypography.caption(c.textTertiary)
                    .copyWith(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });
  final double progress;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 8;
    const strokeW = 9.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ── Macro Bars ────────────────────────────────────────────────
class _MacroBars extends StatelessWidget {
  const _MacroBars({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.c,
  });
  final ({double current, double goal}) protein;
  final ({double current, double goal}) carbs;
  final ({double current, double goal}) fat;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          _MacroBar(
            label: 'Protein',
            current: protein.current,
            goal: protein.goal,
            color: c.protein,
            c: c,
          ),
          const SizedBox(width: 10),
          _MacroBar(
            label: 'Carbs',
            current: carbs.current,
            goal: carbs.goal,
            color: c.carbs,
            c: c,
          ),
          const SizedBox(width: 10),
          _MacroBar(
            label: 'Fat',
            current: fat.current,
            goal: fat.goal,
            color: c.fat,
            c: c,
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.c,
  });
  final String label;
  final double current;
  final double goal;
  final Color color;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final rawPct = goal > 0 ? current / goal : 0.0;
    final pct = rawPct.clamp(0.0, 1.0);
    final exceeded = rawPct > 1.0;
    final barColor = exceeded ? c.errorRose : color;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption(c.textSecondary).copyWith(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${current.toInt()}',
                  style: AppTypography.displayM(
                    exceeded ? c.errorRose : c.textPrimary,
                  ).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: 'g',
                  style: AppTypography.caption(c.textTertiary)
                      .copyWith(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Stack(
              children: [
                Container(height: 5, color: c.surfaceHigh),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 5,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exceeded
                ? '+${(current - goal).toInt()}g over'
                : 'of ${goal.toInt()}g',
            style: AppTypography.caption(
              exceeded ? c.errorRose : c.textTertiary,
            ).copyWith(
              fontSize: 10,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food Entry Card ───────────────────────────────────────────
class _FoodEntryCard extends StatelessWidget {
  const _FoodEntryCard({
    required this.entry,
    required this.onDelete,
    required this.onAddAgain,
    required this.c,
  });
  final FoodEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onAddAgain;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.loggedAt.millisecondsSinceEpoch),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: c.errorRose.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.delete_outline_rounded, color: c.errorRose, size: 20),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    entry.name,
                    style: AppTypography.titleS(c.textPrimary)
                        .copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.loggedAt.hour.toString().padLeft(2, '0')}:${entry.loggedAt.minute.toString().padLeft(2, '0')}  ·  P ${entry.protein.toInt()}g  ·  C ${entry.carbs.toInt()}g  ·  F ${entry.fat.toInt()}g',
                    style: AppTypography.caption(c.textTertiary)
                        .copyWith(fontSize: 10, letterSpacing: 0.2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Add Again button
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onAddAgain();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: c.divider.withValues(alpha: 0.6), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 12, color: c.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      'Add',
                      style: AppTypography.caption(c.textSecondary)
                          .copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.calories}',
                    style: AppTypography.titleS(c.accentIron).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(
                    text: ' kcal',
                    style: AppTypography.caption(c.textTertiary)
                        .copyWith(fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overeat Banner ────────────────────────────────────────────
class _OvereatBanner extends StatelessWidget {
  const _OvereatBanner({required this.excess, required this.c});
  final int excess;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.errorRose.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border:
            Border.all(color: c.errorRose.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: c.errorRose, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: '$excess kcal ',
                  style: AppTypography.bodyS(c.errorRose).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [const FontFeature.tabularFigures()]),
                ),
                TextSpan(
                  text: 'over today\'s goal',
                  style: AppTypography.bodyS(c.errorRose)
                      .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty log ─────────────────────────────────────────────────
class _EmptyLog extends StatelessWidget {
  const _EmptyLog({required this.onAdd, required this.c});
  final VoidCallback onAdd;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: c.divider.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 28, color: c.textTertiary.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(
              'Nothing logged yet.',
              style: AppTypography.titleS(c.textSecondary)
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to log your first meal today.',
              style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Calorie Chart ──────────────────────────────────────
class _WeeklyCalorieChart extends StatelessWidget {
  const _WeeklyCalorieChart({
    required this.target,
    required this.c,
  });
  final int target;
  final AppColors c;

  static const _labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final data = NutritionStore.weeklyCaloriesByDow;
    final maxVal = math.max(data.reduce(math.max), target).toDouble();

    // Weekly insights — only count up to and including today
    final todayIdx = DateTime.now().weekday - 1;
    int daysLogged = 0;
    int totalLogged = 0;
    for (int i = 0; i <= todayIdx; i++) {
      if (data[i] > 0) {
        daysLogged++;
        totalLogged += data[i];
      }
    }
    final avgCal = daysLogged > 0 ? totalLogged ~/ daysLogged : 0;

    String fmtCal(int n) => n >= 1000
        ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}'
        : '$n';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              children: [
                // Dashed goal line
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: maxVal > 0
                      ? ((target / maxVal) * 80).clamp(0.0, 80.0)
                      : 0.0,
                  child: CustomPaint(
                    painter: _DashedLinePainter(
                        color: c.accentIron.withValues(alpha: 0.35)),
                    size: const Size(double.infinity, 1),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final val = data[i];
                    final frac = maxVal > 0 ? val / maxVal : 0.0;
                    final isToday = i == DateTime.now().weekday - 1;
                    final isFuture = i > DateTime.now().weekday - 1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isFuture && val > 0)
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: frac.clamp(0.06, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? c.accentIron
                                          : c.accentIron
                                              .withValues(alpha: 0.35),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(3)),
                                    ),
                                  ),
                                ),
                              )
                            else if (!isFuture)
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: 0.08,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: c.divider.withValues(alpha: 0.35),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(3)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: 0.06,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: c.surfaceHigh,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(3)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(7, (i) {
              final isToday = i == DateTime.now().weekday - 1;
              return Expanded(
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(
                    isToday ? c.accentIron : c.textTertiary,
                  ).copyWith(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (daysLogged == 0)
                Text(
                  'No logs this week yet.',
                  style: AppTypography.caption(c.textTertiary)
                      .copyWith(fontSize: 11),
                )
              else ...[
                Text(
                  '$daysLogged day${daysLogged == 1 ? '' : 's'} logged',
                  style: AppTypography.caption(c.accentIron)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                if (avgCal > 0) ...[
                  Text(
                    '  ·  ',
                    style: AppTypography.caption(c.textTertiary)
                        .copyWith(fontSize: 11),
                  ),
                  Text(
                    'Avg ${fmtCal(avgCal)} kcal',
                    style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 11,
                        fontFeatures: [const FontFeature.tabularFigures()]),
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Food Bottom Sheet ─────────────────────────────────────
class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet({required this.onAdd});
  final void Function(FoodEntry) onAdd;

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

typedef _Food = ({String name, int cal, int p, int c, int f, String per});

class _AddFoodSheetState extends State<_AddFoodSheet> {
  _Food? _selected;
  bool _showManual = false;

  final _searchCtrl = TextEditingController();
  String _query = '';

  double _mult = 1.0;
  double _manualMult = 1.0;

  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  bool _nameErr = false;

  static const _allFoods = <_Food>[
    (name: 'Chicken Breast', cal: 165, p: 31, c: 0, f: 4, per: '100g'),
    (name: 'Salmon', cal: 208, p: 20, c: 0, f: 13, per: '100g'),
    (name: 'Tuna (canned)', cal: 116, p: 26, c: 0, f: 1, per: '100g'),
    (name: 'Ground Beef (lean)', cal: 215, p: 26, c: 0, f: 12, per: '100g'),
    (name: 'Turkey Breast', cal: 135, p: 30, c: 0, f: 1, per: '100g'),
    (name: 'Chicken Thigh', cal: 209, p: 26, c: 0, f: 11, per: '100g'),
    (name: 'Whole Eggs', cal: 155, p: 13, c: 1, f: 11, per: '2 eggs'),
    (name: 'Egg White', cal: 17, p: 4, c: 0, f: 0, per: '1 large'),
    (name: 'Whey Protein', cal: 120, p: 24, c: 3, f: 2, per: '1 scoop'),
    (name: 'Casein Protein', cal: 120, p: 24, c: 4, f: 1, per: '1 scoop'),
    (name: 'Greek Yogurt', cal: 97, p: 9, c: 4, f: 5, per: '100g'),
    (name: 'Cottage Cheese', cal: 98, p: 11, c: 3, f: 4, per: '100g'),
    (name: 'Milk (whole)', cal: 149, p: 8, c: 12, f: 8, per: '240ml'),
    (name: 'Cheddar Cheese', cal: 114, p: 7, c: 0, f: 9, per: '30g'),
    (name: 'White Rice', cal: 130, p: 3, c: 28, f: 0, per: '100g cooked'),
    (name: 'Brown Rice', cal: 111, p: 3, c: 23, f: 1, per: '100g cooked'),
    (name: 'Oats (dry)', cal: 389, p: 17, c: 66, f: 7, per: '100g'),
    (name: 'Sweet Potato', cal: 86, p: 2, c: 20, f: 0, per: '100g'),
    (name: 'White Potato', cal: 77, p: 2, c: 17, f: 0, per: '100g'),
    (name: 'Banana', cal: 89, p: 1, c: 23, f: 0, per: '1 medium'),
    (name: 'Apple', cal: 95, p: 0, c: 25, f: 0, per: '1 medium'),
    (name: 'Blueberries', cal: 57, p: 1, c: 14, f: 0, per: '100g'),
    (name: 'Pasta (dry)', cal: 371, p: 13, c: 75, f: 2, per: '100g'),
    (name: 'Bread (white)', cal: 79, p: 3, c: 15, f: 1, per: '1 slice'),
    (name: 'Quinoa (cooked)', cal: 120, p: 4, c: 21, f: 2, per: '100g'),
    (name: 'Peanut Butter', cal: 188, p: 8, c: 6, f: 16, per: '2 tbsp'),
    (name: 'Almonds', cal: 174, p: 6, c: 6, f: 15, per: '30g'),
    (name: 'Mixed Nuts', cal: 173, p: 5, c: 6, f: 15, per: '30g'),
    (name: 'Avocado', cal: 120, p: 2, c: 6, f: 11, per: 'half'),
    (name: 'Olive Oil', cal: 119, p: 0, c: 0, f: 14, per: '1 tbsp'),
  ];

  List<_Food> get _filtered {
    if (_query.isEmpty) return _allFoods;
    final q = _query.toLowerCase();
    return _allFoods.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  String _fmtG(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _protCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    setState(() {
      if (_selected != null) {
        _selected = null;
        _mult = 1.0;
      } else {
        _showManual = false;
        _manualMult = 1.0;
        _nameErr = false;
      }
    });
  }

  void _addFromPortion() {
    final f = _selected!;
    HapticFeedback.mediumImpact();
    widget.onAdd(FoodEntry(
      name: f.name,
      calories: (f.cal * _mult).round(),
      protein: f.p.toDouble() * _mult,
      carbs: f.c.toDouble() * _mult,
      fat: f.f.toDouble() * _mult,
    ));
  }

  void _addFromManual() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameErr = true);
      return;
    }
    final rawCal = double.tryParse(_calCtrl.text.trim()) ?? 0;
    final rawProt = double.tryParse(_protCtrl.text.trim()) ?? 0;
    final rawCarb = double.tryParse(_carbCtrl.text.trim()) ?? 0;
    final rawFat = double.tryParse(_fatCtrl.text.trim()) ?? 0;
    HapticFeedback.mediumImpact();
    widget.onAdd(FoodEntry(
      name: name,
      calories: (rawCal * _manualMult).round(),
      protein: rawProt * _manualMult,
      carbs: rawCarb * _manualMult,
      fat: rawFat * _manualMult,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final hasBack = _selected != null || _showManual;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + title
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (hasBack)
                      GestureDetector(
                        onTap: _goBack,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 8, top: 2, bottom: 2),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 15, color: c.textSecondary),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _selected != null
                            ? _selected!.name
                            : _showManual
                                ? 'Enter Manually'
                                : 'Add Food',
                        style: AppTypography.titleM(c.textPrimary)
                            .copyWith(fontSize: 18, letterSpacing: -0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: _selected != null
                ? _buildPortion(c)
                : _showManual
                    ? _buildManual(c)
                    : _buildSearch(c),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(AppColors c) {
    final foods = _filtered;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showManual = true),
                child: Text(
                  'Enter manually →',
                  style: AppTypography.bodyS(c.accentIron)
                      .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style:
                    AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search foods…',
                  hintStyle: AppTypography.bodyS(c.textTertiary)
                      .copyWith(fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: c.textTertiary, size: 18),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                          child: Icon(Icons.close_rounded,
                              color: c.textTertiary, size: 16),
                        )
                      : null,
                  filled: true,
                  fillColor: c.surfaceHigh,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                        color: c.divider.withValues(alpha: 0.5), width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                        color: c.divider.withValues(alpha: 0.5), width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: c.accentIron, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: foods.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No results for "$_query"',
                      style: AppTypography.bodyS(c.textTertiary)
                          .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  itemCount: foods.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: c.divider.withValues(alpha: 0.4)),
                  itemBuilder: (_, i) {
                    final f = foods[i];
                    return InkWell(
                      onTap: () => setState(() {
                        _selected = f;
                        _mult = 1.0;
                      }),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.name,
                                      style: AppTypography.bodyS(c.textPrimary)
                                          .copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                      '${f.per} · P ${f.p}g · C ${f.c}g · F ${f.f}g',
                                      style:
                                          AppTypography.caption(c.textTertiary)
                                              .copyWith(fontSize: 10)),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '${f.cal}',
                                  style: AppTypography.titleS(c.accentIron)
                                      .copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFeatures: [
                                        const FontFeature.tabularFigures()
                                      ]),
                                ),
                                TextSpan(
                                  text: ' kcal',
                                  style: AppTypography.caption(c.textTertiary)
                                      .copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPortion(AppColors c) {
    final f = _selected!;
    final cal = (f.cal.toDouble() * _mult).round();
    final prot = f.p.toDouble() * _mult;
    final carb = f.c.toDouble() * _mult;
    final fat = f.f.toDouble() * _mult;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('per ${f.per}',
              style:
                  AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12)),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: c.divider.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: _KcalBox(
                          label: 'Calories',
                          value: '$cal',
                          unit: 'kcal',
                          accent: true,
                          c: c)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _KcalBox(
                          label: 'Protein',
                          value: _fmtG(prot),
                          unit: 'g',
                          c: c)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _KcalBox(
                          label: 'Carbs', value: _fmtG(carb), unit: 'g', c: c)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _KcalBox(
                          label: 'Fat', value: _fmtG(fat), unit: 'g', c: c)),
                ]),
                const SizedBox(height: 16),
                Text('× PORTION',
                    style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                _PortionStepper(
                  value: _mult,
                  onChanged: (v) => setState(() => _mult = v),
                  c: c,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Add to Log', onPressed: _addFromPortion),
        ],
      ),
    );
  }

  Widget _buildManual(AppColors c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOOD NAME',
              style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) {
              if (_nameErr) setState(() => _nameErr = false);
            },
            style: AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Homemade Smoothie',
              hintStyle:
                  AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 13),
              filled: true,
              fillColor: _nameErr
                  ? c.errorRose.withValues(alpha: 0.08)
                  : c.surfaceHigh,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: _nameErr
                    ? BorderSide(color: c.errorRose, width: 1)
                    : BorderSide(
                        color: c.divider.withValues(alpha: 0.5), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: _nameErr
                    ? BorderSide(color: c.errorRose, width: 1)
                    : BorderSide(
                        color: c.divider.withValues(alpha: 0.5), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: _nameErr
                    ? BorderSide(color: c.errorRose, width: 1.5)
                    : BorderSide(color: c.accentIron, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('NUTRITION',
              style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: _ManualField(
                    ctrl: _calCtrl, label: 'Calories', unit: 'kcal', c: c)),
            const SizedBox(width: 8),
            Expanded(
                child: _ManualField(
                    ctrl: _protCtrl, label: 'Protein', unit: 'g', c: c)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _ManualField(
                    ctrl: _carbCtrl, label: 'Carbs', unit: 'g', c: c)),
            const SizedBox(width: 8),
            Expanded(
                child: _ManualField(
                    ctrl: _fatCtrl, label: 'Fat', unit: 'g', c: c)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('× PORTION (scales all values)',
              style: AppTypography.caption(c.textTertiary).copyWith(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _PortionStepper(
            value: _manualMult,
            onChanged: (v) => setState(() => _manualMult = v),
            c: c,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Add to Log', onPressed: _addFromManual),
        ],
      ),
    );
  }
}

class _KcalBox extends StatelessWidget {
  const _KcalBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.c,
    this.accent = false,
  });
  final String label, value, unit;
  final AppColors c;
  final bool accent;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTypography.caption(c.textTertiary)
                  .copyWith(fontSize: 10, letterSpacing: 0.6)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: value,
                style: AppTypography.displayM(
                  accent ? c.accentIron : c.textPrimary,
                ).copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1,
                    fontFeatures: [const FontFeature.tabularFigures()]),
              ),
              TextSpan(
                text: unit,
                style: AppTypography.caption(c.textTertiary)
                    .copyWith(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ]),
          ),
        ],
      );
}

class _ManualField extends StatelessWidget {
  const _ManualField({
    required this.ctrl,
    required this.label,
    required this.unit,
    required this.c,
  });
  final TextEditingController ctrl;
  final String label, unit;
  final AppColors c;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: label.toUpperCase(),
                  style: AppTypography.caption(c.textTertiary).copyWith(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700)),
              TextSpan(
                  text: ' ($unit)',
                  style: AppTypography.caption(c.textTertiary)
                      .copyWith(fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            style: AppTypography.bodyM(c.textPrimary)
                .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle:
                  AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 13),
              filled: true,
              fillColor: c.surfaceHigh,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(
                    color: c.divider.withValues(alpha: 0.5), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(
                    color: c.divider.withValues(alpha: 0.5), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: c.accentIron, width: 1.5),
              ),
            ),
          ),
        ],
      );
}

class _PortionStepper extends StatelessWidget {
  const _PortionStepper({
    required this.value,
    required this.onChanged,
    required this.c,
  });
  final double value;
  final void Function(double) onChanged;
  final AppColors c;

  String _fmt(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border:
              Border.all(color: c.divider.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              if (value > 0.25) {
                HapticFeedback.selectionClick();
                onChanged(value - 0.25);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Text('−',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: value <= 0.25 ? c.textTertiary : c.textSecondary)),
            ),
          ),
          Expanded(
            child: Text('${_fmt(value)}×',
                textAlign: TextAlign.center,
                style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    fontFeatures: [const FontFeature.tabularFigures()])),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(value + 0.25);
            },
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Text('+',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary)),
            ),
          ),
        ]),
      );
}

class _NutrField extends StatelessWidget {
  const _NutrField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.c,
    this.isNum = false,
  });
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final AppColors c;
  final bool isNum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: isNum
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNum
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          style: AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
            filled: true,
            fillColor: c.surfaceHigh,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: c.accentIron, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit Targets Sheet ────────────────────────────────────────
class _EditTargetsSheet extends StatefulWidget {
  const _EditTargetsSheet({required this.current, required this.onSave});
  final NutritionTargets current;
  final void Function(NutritionTargets) onSave;

  @override
  State<_EditTargetsSheet> createState() => _EditTargetsSheetState();
}

class _EditTargetsSheetState extends State<_EditTargetsSheet> {
  late final TextEditingController _cal;
  late final TextEditingController _prot;
  late final TextEditingController _carb;
  late final TextEditingController _fat;

  static const _presets = [
    (label: 'Build Muscle', cal: 2600, prot: 190, carb: 280, fat: 80),
    (label: 'Lose Fat', cal: 1800, prot: 165, carb: 150, fat: 60),
    (label: 'Strength', cal: 2800, prot: 200, carb: 300, fat: 90),
    (label: 'Endurance', cal: 2200, prot: 140, carb: 300, fat: 65),
  ];

  @override
  void initState() {
    super.initState();
    _cal = TextEditingController(text: '${widget.current.calories}');
    _prot = TextEditingController(text: '${widget.current.protein}');
    _carb = TextEditingController(text: '${widget.current.carbs}');
    _fat = TextEditingController(text: '${widget.current.fat}');
  }

  @override
  void dispose() {
    _cal.dispose();
    _prot.dispose();
    _carb.dispose();
    _fat.dispose();
    super.dispose();
  }

  void _applyPreset(int cal, int prot, int carb, int fat) {
    setState(() {
      _cal.text = '$cal';
      _prot.text = '$prot';
      _carb.text = '$carb';
      _fat.text = '$fat';
    });
    HapticFeedback.selectionClick();
  }

  void _save() {
    widget.onSave(NutritionTargets(
      calories: int.tryParse(_cal.text) ?? 2400,
      protein: int.tryParse(_prot.text) ?? 180,
      carbs: int.tryParse(_carb.text) ?? 240,
      fat: int.tryParse(_fat.text) ?? 75,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final currentGoal = PrefsService.fitnessGoal;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
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
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Daily Targets',
            style: AppTypography.titleM(c.textPrimary)
                .copyWith(fontSize: 18, letterSpacing: -0.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a preset or enter custom values below.',
            style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          // Goal presets
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final p = _presets[i];
                final isActive = p.label == currentGoal;
                return GestureDetector(
                  onTap: () => _applyPreset(p.cal, p.prot, p.carb, p.fat),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? c.accentIron.withValues(alpha: 0.1)
                          : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isActive
                            ? c.accentIron.withValues(alpha: 0.5)
                            : c.divider.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      p.label,
                      style: AppTypography.caption(
                        isActive ? c.accentIron : c.textSecondary,
                      ).copyWith(
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _NutrField(
                      ctrl: _cal,
                      label: 'Calories',
                      hint: '2400',
                      isNum: true,
                      c: c)),
              const SizedBox(width: 8),
              Expanded(
                  child: _NutrField(
                      ctrl: _prot,
                      label: 'Protein (g)',
                      hint: '180',
                      isNum: true,
                      c: c)),
              const SizedBox(width: 8),
              Expanded(
                  child: _NutrField(
                      ctrl: _carb,
                      label: 'Carbs (g)',
                      hint: '240',
                      isNum: true,
                      c: c)),
              const SizedBox(width: 8),
              Expanded(
                  child: _NutrField(
                      ctrl: _fat,
                      label: 'Fat (g)',
                      hint: '75',
                      isNum: true,
                      c: c)),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Save Targets', onPressed: _save),
        ],
      ),
    );
  }
}
