import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/prefs_service.dart';
import '../services/nutrition_store.dart';

// ══════════════════════════════════════════════════════════
//  ONBOARDING SCREEN
// ══════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  String? _goal;
  String? _experience;
  String? _unit; // null until selected

  static const _totalPages = 4;

  bool get _canContinue {
    return switch (_page) {
      0 => true,
      1 => _goal != null,
      2 => _experience != null,
      3 => _unit != null,
      _ => true,
    };
  }

  void _next() {
    if (_page < _totalPages - 1) {
      HapticFeedback.selectionClick();
      _pageCtrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    HapticFeedback.selectionClick();
    _pageCtrl.animateToPage(
      _page - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finish() {
    if (_goal != null) PrefsService.setFitnessGoal(_goal!);
    if (_experience != null) {
      PrefsService.setExperienceLevel(_experience!);
      final restSecs = switch (_experience) {
        'beginner'     => 75,
        'advanced'     => 120,
        _              => 90,
      };
      PrefsService.setRestSecs(restSecs);
    }
    final unit = _unit ?? 'kg';
    PrefsService.setUnit(unit);
    if (_goal != null && PrefsService.nutritionTargets == null) {
      final t = switch (_goal) {
        'Lose Fat'   => const NutritionTargets(calories: 1800, protein: 165, carbs: 150, fat: 60),
        'Strength'   => const NutritionTargets(calories: 2800, protein: 200, carbs: 300, fat: 90),
        'Endurance'  => const NutritionTargets(calories: 2200, protein: 140, carbs: 300, fat: 65),
        _            => const NutritionTargets(calories: 2600, protein: 190, carbs: 280, fat: 80),
      };
      NutritionStore.updateTargets(t);
    }
    widget.onFinish();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: (_page + 1) / _totalPages,
                    backgroundColor: c.surfaceHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(c.accentIron),
                  ),
                ),
              ),
            ),

            // ── Back / Skip row (pages > 0) ───────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _page > 0
                  ? Padding(
                      key: const ValueKey('back'),
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: _back,
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 14, color: c.textSecondary),
                            label: Text(
                              'Back',
                              style: AppTypography.bodyS(c.textSecondary).copyWith(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: c.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('no-back'), height: 10),
            ),

            // ── Pages ────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(c: c, onContinue: _next),
                  _GoalPage(
                    selected: _goal,
                    onSelect: (g) => setState(() => _goal = g),
                    c: c,
                  ),
                  _ExperiencePage(
                    selected: _experience,
                    onSelect: (e) => setState(() => _experience = e),
                    c: c,
                  ),
                  _UnitPage(
                    selected: _unit,
                    onSelect: (u) => setState(() => _unit = u),
                    c: c,
                  ),
                ],
              ),
            ),

            // ── Dots + CTA (pages 1-3 only) ──────────────────
            if (_page > 0) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? c.accentIron : c.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _canContinue ? 1.0 : 0.45,
                  child: PrimaryButton(
                    label: _page == _totalPages - 1 ? "Let's go →" : 'Continue',
                    onPressed: _canContinue ? _next : null,
                    disabled: !_canContinue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Page 0: Welcome ───────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.c, required this.onContinue});
  final AppColors c;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          // VELT wordmark — 72px amber
          Text(
            'VELT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 72,
              fontWeight: FontWeight.w700,
              color: c.accentIron,
              letterSpacing: -4,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Hero statement
          Text(
            'Built for people who are\nserious about training.',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 28,
              letterSpacing: -0.8,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No social feed. No fluff. Just the tools\nand the data to get stronger every week.',
            style: AppTypography.bodyM(c.textSecondary).copyWith(
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Get Started',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Goal ──────────────────────────────────────────────
class _GoalPage extends StatelessWidget {
  const _GoalPage(
      {required this.selected, required this.onSelect, required this.c});
  final String? selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  static const _goals = [
    _GoalDef(
      id: 'Build Muscle',
      label: 'Build Muscle',
      desc: 'Add lean mass & size',
      color: Color(0xFFD97706),
    ),
    _GoalDef(
      id: 'Lose Fat',
      label: 'Lose Fat',
      desc: 'Lean out, keep strength',
      color: Color(0xFF22C55E),
    ),
    _GoalDef(
      id: 'Strength',
      label: 'Strength',
      desc: 'Push your 1RM higher',
      color: Color(0xFF6366F1),
    ),
    _GoalDef(
      id: 'Endurance',
      label: 'Endurance',
      desc: 'Last longer, recover faster',
      color: Color(0xFF06B6D4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg,
          AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your\nprimary goal?",
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 26, letterSpacing: -0.8, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            "We'll tailor your nutrition targets and program recommendations.",
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: _goals.map((g) {
              final active = selected == g.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(g.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active
                        ? g.color.withValues(alpha: 0.08)
                        : c.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: active
                          ? g.color
                          : c.divider.withValues(alpha: 0.6),
                      width: active ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: active
                              ? g.color.withValues(alpha: 0.15)
                              : c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          g.icon,
                          size: 20,
                          color: active ? g.color : c.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        g.label,
                        style: AppTypography.titleM(c.textPrimary).copyWith(
                          fontSize: 14, letterSpacing: -0.1,
                          fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        g.desc,
                        style: AppTypography.bodyS(c.textSecondary).copyWith(
                          fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GoalDef {
  const _GoalDef({
    required this.id,
    required this.label,
    required this.desc,
    required this.color,
  });
  final String id;
  final String label;
  final String desc;
  final Color color;

  IconData get icon => switch (id) {
    'Build Muscle' => Icons.trending_up_rounded,
    'Lose Fat'     => Icons.local_fire_department_rounded,
    'Strength'     => Icons.bolt_rounded,
    _              => Icons.directions_run_rounded,
  };
}

// ── Page 2: Experience ────────────────────────────────────────
class _ExperiencePage extends StatelessWidget {
  const _ExperiencePage(
      {required this.selected, required this.onSelect, required this.c});
  final String? selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  static const _levels = [
    _LevelDef(
      id: 'beginner',
      label: 'Beginner',
      range: '<1y',
      desc: 'Building base strength',
      restSecs: 75,
    ),
    _LevelDef(
      id: 'intermediate',
      label: 'Intermediate',
      range: '1–3y',
      desc: 'Past the linear phase',
      restSecs: 90,
    ),
    _LevelDef(
      id: 'advanced',
      label: 'Advanced',
      range: '3+',
      desc: 'Programmed periodization',
      restSecs: 120,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg,
          AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How long have you\nbeen training?',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 26, letterSpacing: -0.8, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Sets your rest defaults and program recommendations.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._levels.map((l) {
            final active = selected == l.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(l.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: active
                        ? c.accentIron.withValues(alpha: 0.08)
                        : c.surfaceElevated,
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
                      // Range badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: active ? c.accentIron : c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            l.range,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : c.textSecondary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.label,
                              style: AppTypography.titleM(c.textPrimary)
                                  .copyWith(
                                      fontSize: 15, letterSpacing: -0.1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.desc,
                              style: AppTypography.bodyS(c.textSecondary)
                                  .copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'REST TIMER DEFAULT · ${l.restSecs}s',
                              style: AppTypography.caption(c.textTertiary)
                                  .copyWith(
                                      fontSize: 10,
                                      letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.accentIron,
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LevelDef {
  const _LevelDef({
    required this.id,
    required this.label,
    required this.range,
    required this.desc,
    required this.restSecs,
  });
  final String id;
  final String label;
  final String range;
  final String desc;
  final int restSecs;
}

// ── Page 3: Unit ──────────────────────────────────────────────
class _UnitPage extends StatelessWidget {
  const _UnitPage(
      {required this.selected, required this.onSelect, required this.c});
  final String? selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg,
          AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your\nweight unit.',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 26, letterSpacing: -0.8, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'You can change this anytime in Settings.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _UnitCard(
                unit: 'kg',
                subtitle: 'kilograms',
                selected: selected == 'kg',
                onTap: () => onSelect('kg'),
                c: c,
              )),
              const SizedBox(width: 10),
              Expanded(child: _UnitCard(
                unit: 'lbs',
                subtitle: 'pounds',
                selected: selected == 'lbs',
                onTap: () => onSelect('lbs'),
                c: c,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.c,
  });
  final String unit;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? c.accentIron.withValues(alpha: 0.08)
              : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? c.accentIron : c.divider.withValues(alpha: 0.6),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: selected ? c.accentIron : c.textSecondary,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
