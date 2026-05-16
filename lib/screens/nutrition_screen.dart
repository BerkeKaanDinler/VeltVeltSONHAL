import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/nutrition_store.dart';
import '../services/prefs_service.dart';

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
                final totalCal  = NutritionStore.totalCalories;
                final totalProt = NutritionStore.totalProtein;
                final totalCarb = NutritionStore.totalCarbs;
                final totalFat  = NutritionStore.totalFat;
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
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.lg,
                          AppSpacing.md, AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Nutrition',
                              style: AppTypography.displayL(c.textPrimary).copyWith(
                                fontSize: 34, letterSpacing: -1),
                            ),
                            const Spacer(),
                            GhostButton(
                              label: 'Goals',
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
                            c: c,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: c.divider.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                'Targets for: ${PrefsService.fitnessGoal}',
                                style: AppTypography.caption(c.textTertiary).copyWith(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Macro bars ────────────────────────
                          _MacroBars(
                            protein: (current: totalProt, goal: targets.protein.toDouble()),
                            carbs:   (current: totalCarb, goal: targets.carbs.toDouble()),
                            fat:     (current: totalFat,  goal: targets.fat.toDouble()),
                            c: c,
                          ),
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
                                onDelete: () => NutritionStore.removeEntry(e.key),
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
class _CalorieHero extends StatelessWidget {
  const _CalorieHero({
    required this.consumed,
    required this.target,
    required this.remaining,
    required this.remainingColor,
    required this.c,
  });
  final int consumed;
  final int target;
  final int remaining;
  final Color remainingColor;
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
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 100, height: 100,
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
                      style: AppTypography.caption(c.textTertiary).copyWith(
                        fontSize: 10),
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
                  value: '$target kcal',
                  color: c.textSecondary,
                  c: c,
                ),
                const SizedBox(height: 8),
                _CalStat(
                  label: 'Consumed',
                  value: '$consumed kcal',
                  color: c.accentIron,
                  c: c,
                ),
                const SizedBox(height: 8),
                _CalStat(
                  label: remaining >= 0 ? 'Remaining' : 'Over',
                  value: '${remaining.abs()} kcal',
                  color: remainingColor,
                  c: c,
                ),
              ],
            ),
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
  final String value;
  final Color color;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
        ),
        Text(
          value,
          style: AppTypography.titleS(color).copyWith(
            fontSize: 13,
            fontFeatures: [const FontFeature.tabularFigures()],
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
    final r  = math.min(cx, cy) - 8;
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
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _MacroBar(
            label: 'Protein',
            current: protein.current,
            goal: protein.goal,
            color: c.accentIron,
            c: c,
          ),
          const SizedBox(width: 10),
          _MacroBar(
            label: 'Carbs',
            current: carbs.current,
            goal: carbs.goal,
            color: const Color(0xFF38BDF8),
            c: c,
          ),
          const SizedBox(width: 10),
          _MacroBar(
            label: 'Fat',
            current: fat.current,
            goal: fat.goal,
            color: c.successLime,
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
    final pct = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyS(c.textSecondary).copyWith(
                  fontSize: 11, fontWeight: FontWeight.w500),
              ),
              Text(
                '${current.toInt()}g',
                style: AppTypography.bodyS(color).copyWith(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Stack(
              children: [
                Container(height: 6, color: c.surfaceHigh),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${goal.toInt()}g',
            style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
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
    required this.c,
  });
  final FoodEntry entry;
  final VoidCallback onDelete;
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
        child: Icon(Icons.delete_outline, color: c.errorRose, size: 20),
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
                    style: AppTypography.titleS(c.textPrimary).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'P ${entry.protein.toInt()}g  ·  C ${entry.carbs.toInt()}g  ·  F ${entry.fat.toInt()}g',
                    style: AppTypography.caption(c.textTertiary).copyWith(
                      fontSize: 10, letterSpacing: 0.2),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calories} kcal',
              style: AppTypography.titleS(c.accentIron).copyWith(
                fontSize: 14,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: c.accentIron.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 32, color: c.accentIron.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              'Tap to log your first meal',
              style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
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

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final data = NutritionStore.weeklyCaloriesByDow;
    final maxVal = math.max(data.reduce(math.max), target).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
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
                                      : c.accentIron.withValues(alpha: 0.35),
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

typedef _Food = ({String name, int cal, int p, int c, int f});

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _nameCtrl   = TextEditingController();
  final _calCtrl    = TextEditingController();
  final _protCtrl   = TextEditingController();
  final _carbCtrl   = TextEditingController();
  final _fatCtrl    = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  bool _showManual = false;
  String _query = '';

  static const _allFoods = <_Food>[
    // Proteins
    (name: 'Chicken Breast 100g',     cal: 165, p: 31, c: 0,  f: 4),
    (name: 'Chicken Thigh 100g',      cal: 209, p: 26, c: 0,  f: 11),
    (name: 'Ground Beef 100g (lean)', cal: 215, p: 26, c: 0,  f: 12),
    (name: 'Salmon 100g',             cal: 208, p: 20, c: 0,  f: 13),
    (name: 'Tuna (canned) 100g',      cal: 116, p: 26, c: 0,  f: 1),
    (name: 'Egg (1 large)',           cal: 78,  p: 6,  c: 0,  f: 5),
    (name: 'Egg White (1 large)',     cal: 17,  p: 4,  c: 0,  f: 0),
    (name: 'Turkey Breast 100g',      cal: 135, p: 30, c: 0,  f: 1),
    (name: 'Shrimp 100g',             cal: 99,  p: 24, c: 0,  f: 0),
    (name: 'Whey Protein scoop 30g',  cal: 120, p: 25, c: 3,  f: 2),
    (name: 'Casein Protein scoop',    cal: 120, p: 24, c: 4,  f: 1),
    // Dairy
    (name: 'Greek Yogurt 150g',       cal: 100, p: 17, c: 6,  f: 0),
    (name: 'Cottage Cheese 100g',     cal: 98,  p: 11, c: 3,  f: 4),
    (name: 'Milk (whole) 240ml',      cal: 149, p: 8,  c: 12, f: 8),
    (name: 'Milk (skim) 240ml',       cal: 83,  p: 8,  c: 12, f: 0),
    (name: 'Cheddar Cheese 30g',      cal: 114, p: 7,  c: 0,  f: 9),
    // Carbs
    (name: 'White Rice 100g cooked',  cal: 130, p: 3,  c: 28, f: 0),
    (name: 'Brown Rice 100g cooked',  cal: 112, p: 3,  c: 24, f: 1),
    (name: 'Oats 50g dry',            cal: 190, p: 7,  c: 32, f: 4),
    (name: 'Sweet Potato 100g',       cal: 86,  p: 2,  c: 20, f: 0),
    (name: 'White Potato 100g',       cal: 77,  p: 2,  c: 17, f: 0),
    (name: 'Bread (white) 1 slice',   cal: 79,  p: 3,  c: 15, f: 1),
    (name: 'Bread (whole wheat) 1 slice', cal: 81, p: 4, c: 14, f: 1),
    (name: 'Pasta 100g dry',          cal: 371, p: 13, c: 75, f: 2),
    (name: 'Quinoa 100g cooked',      cal: 120, p: 4,  c: 21, f: 2),
    (name: 'Banana (1 medium)',       cal: 89,  p: 1,  c: 23, f: 0),
    (name: 'Apple (1 medium)',        cal: 95,  p: 0,  c: 25, f: 0),
    (name: 'Orange (1 medium)',       cal: 62,  p: 1,  c: 15, f: 0),
    (name: 'Blueberries 100g',        cal: 57,  p: 1,  c: 14, f: 0),
    // Fats
    (name: 'Almonds 30g',             cal: 174, p: 6,  c: 6,  f: 15),
    (name: 'Peanut Butter 2 tbsp',    cal: 188, p: 8,  c: 6,  f: 16),
    (name: 'Avocado (half)',          cal: 120, p: 2,  c: 6,  f: 11),
    (name: 'Olive Oil 1 tbsp',        cal: 119, p: 0,  c: 0,  f: 14),
    (name: 'Mixed Nuts 30g',          cal: 173, p: 5,  c: 6,  f: 15),
    // Meals
    (name: 'Oatmeal w/ milk 300g',    cal: 310, p: 12, c: 52, f: 6),
    (name: 'Scrambled Eggs 2x',       cal: 182, p: 14, c: 1,  f: 13),
  ];

  List<_Food> get _filtered {
    if (_query.isEmpty) return _allFoods;
    final q = _query.toLowerCase();
    return _allFoods.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _calCtrl.dispose();
    _protCtrl.dispose(); _carbCtrl.dispose(); _fatCtrl.dispose();
    _searchCtrl.dispose(); _searchFocus.dispose();
    super.dispose();
  }

  void _fillFood(_Food f) {
    _nameCtrl.text  = f.name;
    _calCtrl.text   = '${f.cal}';
    _protCtrl.text  = '${f.p}';
    _carbCtrl.text  = '${f.c}';
    _fatCtrl.text   = '${f.f}';
    setState(() => _showManual = true);
    _searchFocus.unfocus();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final cal  = int.tryParse(_calCtrl.text.trim()) ?? 0;
    if (name.isEmpty || cal == 0) return;
    widget.onAdd(FoodEntry(
      name:     name,
      calories: cal,
      protein:  double.tryParse(_protCtrl.text.trim()) ?? 0,
      carbs:    double.tryParse(_carbCtrl.text.trim()) ?? 0,
      fat:      double.tryParse(_fatCtrl.text.trim()) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final foods = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md,
          AppSpacing.md + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header row
          Row(
            children: [
              Text(
                'Log Food',
                style: AppTypography.titleM(c.textPrimary).copyWith(
                  fontSize: 18, letterSpacing: -0.2),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showManual = !_showManual),
                child: Text(
                  _showManual ? 'Search' : 'Enter manually',
                  style: AppTypography.bodyS(c.accentIron).copyWith(
                    fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!_showManual) ...[
            // Search bar
            TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.bodyM(c.textPrimary).copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search food...',
                hintStyle: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: c.textTertiary, size: 18),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                        child: Icon(Icons.close_rounded, color: c.textTertiary, size: 16),
                      )
                    : null,
                filled: true,
                fillColor: c.surfaceHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Food list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: foods.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No results for "$_query"',
                          style: AppTypography.bodyS(c.textTertiary).copyWith(
                            fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1, color: c.divider.withValues(alpha: 0.4)),
                      itemBuilder: (_, i) {
                        final f = foods[i];
                        return InkWell(
                          onTap: () => _fillFood(f),
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
                                      Text(
                                        f.name,
                                        style: AppTypography.bodyS(c.textPrimary).copyWith(
                                          fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'P ${f.p}g · C ${f.c}g · F ${f.f}g',
                                        style: AppTypography.caption(c.textTertiary).copyWith(
                                          fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${f.cal} kcal',
                                  style: AppTypography.titleS(c.accentIron).copyWith(
                                    fontSize: 13,
                                    fontFeatures: [const FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            // Manual entry form
            _NutrField(ctrl: _nameCtrl, label: 'Food name', hint: 'e.g. Chicken Breast', c: c),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _NutrField(
                  ctrl: _calCtrl, label: 'Calories', hint: '0',
                  isNum: true, c: c)),
                const SizedBox(width: 8),
                Expanded(child: _NutrField(
                  ctrl: _protCtrl, label: 'Protein (g)', hint: '0',
                  isNum: true, c: c)),
                const SizedBox(width: 8),
                Expanded(child: _NutrField(
                  ctrl: _carbCtrl, label: 'Carbs (g)', hint: '0',
                  isNum: true, c: c)),
                const SizedBox(width: 8),
                Expanded(child: _NutrField(
                  ctrl: _fatCtrl, label: 'Fat (g)', hint: '0',
                  isNum: true, c: c)),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Add to Log', onPressed: _submit),
          ],
        ],
      ),
    );
  }
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
            hintStyle: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 12),
            filled: true,
            fillColor: c.surfaceHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide.none,
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
    (label: 'Lose Fat',     cal: 1800, prot: 165, carb: 150, fat: 60),
    (label: 'Strength',     cal: 2800, prot: 200, carb: 300, fat: 90),
    (label: 'Endurance',    cal: 2200, prot: 140, carb: 300, fat: 65),
  ];

  @override
  void initState() {
    super.initState();
    _cal  = TextEditingController(text: '${widget.current.calories}');
    _prot = TextEditingController(text: '${widget.current.protein}');
    _carb = TextEditingController(text: '${widget.current.carbs}');
    _fat  = TextEditingController(text: '${widget.current.fat}');
  }

  @override
  void dispose() {
    _cal.dispose(); _prot.dispose(); _carb.dispose(); _fat.dispose();
    super.dispose();
  }

  void _applyPreset(int cal, int prot, int carb, int fat) {
    setState(() {
      _cal.text  = '$cal';
      _prot.text = '$prot';
      _carb.text = '$carb';
      _fat.text  = '$fat';
    });
    HapticFeedback.selectionClick();
  }

  void _save() {
    widget.onSave(NutritionTargets(
      calories: int.tryParse(_cal.text)  ?? 2400,
      protein:  int.tryParse(_prot.text) ?? 180,
      carbs:    int.tryParse(_carb.text) ?? 240,
      fat:      int.tryParse(_fat.text)  ?? 75,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final currentGoal = PrefsService.fitnessGoal;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Daily Goals',
            style: AppTypography.titleM(c.textPrimary).copyWith(
              fontSize: 18, letterSpacing: -0.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a preset or enter custom values below',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
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
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
              Expanded(child: _NutrField(
                ctrl: _cal,  label: 'Calories', hint: '2400', isNum: true, c: c)),
              const SizedBox(width: 8),
              Expanded(child: _NutrField(
                ctrl: _prot, label: 'Protein (g)', hint: '180', isNum: true, c: c)),
              const SizedBox(width: 8),
              Expanded(child: _NutrField(
                ctrl: _carb, label: 'Carbs (g)', hint: '240', isNum: true, c: c)),
              const SizedBox(width: 8),
              Expanded(child: _NutrField(
                ctrl: _fat, label: 'Fat (g)', hint: '75', isNum: true, c: c)),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Save Goals', onPressed: _save),
        ],
      ),
    );
  }
}
