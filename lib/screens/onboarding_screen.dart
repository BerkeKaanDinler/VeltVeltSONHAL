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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  // Selections
  String? _goal;
  String? _experience;
  String _unit = 'kg';

  static const _totalPages = 4; // welcome, goal, experience, unit

  void _next() {
    if (_page < _totalPages - 1) {
      HapticFeedback.lightImpact();
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
    HapticFeedback.lightImpact();
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
      // Set smart rest timer default based on experience
      final restSecs = switch (_experience) {
        'beginner'     => 75,
        'advanced'     => 120,
        _              => 90,
      };
      PrefsService.setRestSecs(restSecs);
    }
    PrefsService.setUnit(_unit);
    // Set goal-appropriate nutrition targets (only if not previously customised)
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

  bool get _canContinue {
    return switch (_page) {
      0 => true,
      1 => _goal != null,
      2 => _experience != null,
      _ => true,
    };
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
            // ── Top bar with back + dots ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _page > 0 ? 1 : 0,
                    child: GestureDetector(
                      onTap: _page > 0 ? _back : null,
                      child: SizedBox(
                        width: 44, height: 44,
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_page > 0)
                    GestureDetector(
                      onTap: _finish,
                      child: Text(
                        'Skip',
                        style: AppTypography.bodyS(c.textTertiary).copyWith(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),

            // ── Progress dots ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  final active = i == _page;
                  final passed = i < _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? c.accentIron
                          : passed
                              ? c.accentIron.withValues(alpha: 0.4)
                              : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(c: c),
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

            // ── Bottom button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canContinue ? 1.0 : 0.45,
                child: PrimaryButton(
                  label: _page == _totalPages - 1 ? 'Start Training' : 'Continue',
                  onPressed: _canContinue ? _next : null,
                  disabled: !_canContinue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 0: Welcome ───────────────────────────────────────────
class _WelcomePage extends StatefulWidget {
  const _WelcomePage({required this.c});
  final AppColors c;

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo mark
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.accentIron,
                      c.accentIron.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'VELT',
                style: AppTypography.displayXL(c.accentIron).copyWith(
                  fontSize: 52,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Track your lifts.\nPrivately. Offline.',
                style: AppTypography.displayM(c.textPrimary).copyWith(
                  fontSize: 26,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No account. No cloud. No tracking.\nJust you, the bar, and your progress.',
                style: AppTypography.bodyM(c.textSecondary).copyWith(
                  height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Feature pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeaturePill(label: '95 Exercises', icon: Icons.fitness_center_rounded, c: c),
                  _FeaturePill(label: 'PR Tracking', icon: Icons.emoji_events_outlined, c: c),
                  _FeaturePill(label: 'Rest Timer', icon: Icons.timer_outlined, c: c),
                  _FeaturePill(label: '100% Offline', icon: Icons.cloud_off_rounded, c: c),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.icon, required this.c});
  final String label;
  final IconData icon;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: c.divider.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.accentIron),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.bodyS(c.textSecondary).copyWith(
              fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Goal ──────────────────────────────────────────────
class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.selected, required this.onSelect, required this.c});
  final String? selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  static const _goals = [
    (id: 'Build Muscle',  icon: Icons.trending_up_rounded,       sub: 'Hypertrophy & size gains'),
    (id: 'Lose Fat',      icon: Icons.local_fire_department_rounded, sub: 'Cut weight, keep muscle'),
    (id: 'Strength',      icon: Icons.bolt_rounded,              sub: 'Bigger numbers on the bar'),
    (id: 'Endurance',     icon: Icons.directions_run_rounded,    sub: 'Stamina & conditioning'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your\nprimary goal?',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 30, letterSpacing: -0.6, height: 1.15),
          ),
          const SizedBox(height: 6),
          Text(
            'We\'ll tailor your experience around this.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._goals.map((g) {
            final active = selected == g.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(g.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: active
                        ? c.accentIron.withValues(alpha: 0.08)
                        : c.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: active
                          ? c.accentIron
                          : c.divider.withValues(alpha: 0.6),
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: active
                              ? c.accentIron.withValues(alpha: 0.15)
                              : c.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          g.icon,
                          size: 20,
                          color: active ? c.accentIron : c.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.id,
                              style: AppTypography.titleM(
                                active ? c.accentIron : c.textPrimary,
                              ).copyWith(fontSize: 15, letterSpacing: -0.1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              g.sub,
                              style: AppTypography.bodyS(c.textSecondary)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        Icon(Icons.check_circle_rounded,
                          size: 20, color: c.accentIron),
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

// ── Page 2: Experience ────────────────────────────────────────
class _ExperiencePage extends StatelessWidget {
  const _ExperiencePage({
    required this.selected, required this.onSelect, required this.c});
  final String? selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  static const _levels = [
    (
      id: 'beginner',
      label: 'Beginner',
      sub: 'Less than 1 year of consistent training',
      detail: 'Starting fresh or getting back in',
    ),
    (
      id: 'intermediate',
      label: 'Intermediate',
      sub: '1–3 years of consistent training',
      detail: 'Comfortable with compound lifts',
    ),
    (
      id: 'advanced',
      label: 'Advanced',
      sub: '3+ years of serious training',
      detail: 'Chasing percentage-based gains',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training\nexperience?',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 30, letterSpacing: -0.6, height: 1.15),
          ),
          const SizedBox(height: 6),
          Text(
            'Helps set smart defaults for rest and volume.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._levels.map((lvl) {
            final active = selected == lvl.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(lvl.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
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
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lvl.label,
                              style: AppTypography.titleM(
                                active ? c.accentIron : c.textPrimary,
                              ).copyWith(fontSize: 16, letterSpacing: -0.2),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              lvl.sub,
                              style: AppTypography.bodyS(c.textSecondary)
                                  .copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lvl.detail,
                              style: AppTypography.bodyS(c.textTertiary)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? c.accentIron : Colors.transparent,
                          border: Border.all(
                            color: active ? c.accentIron : c.divider,
                            width: 2,
                          ),
                        ),
                        child: active
                            ? const Icon(Icons.check,
                                size: 13, color: Colors.white)
                            : null,
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

// ── Page 3: Unit ──────────────────────────────────────────────
class _UnitPage extends StatelessWidget {
  const _UnitPage({required this.selected, required this.onSelect, required this.c});
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you\nmeasure weight?',
            style: AppTypography.displayM(c.textPrimary).copyWith(
              fontSize: 30, letterSpacing: -0.6, height: 1.15),
          ),
          const SizedBox(height: 6),
          Text(
            'You can change this anytime in Profile.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: _UnitCard(
                unit: 'kg',
                label: 'Kilograms',
                example: '100 kg',
                selected: selected == 'kg',
                onTap: () => onSelect('kg'),
                c: c,
              )),
              const SizedBox(width: 12),
              Expanded(child: _UnitCard(
                unit: 'lb',
                label: 'Pounds',
                example: '220 lb',
                selected: selected == 'lb',
                onTap: () => onSelect('lb'),
                c: c,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Summary
          if (selected.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: c.divider.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                    size: 16, color: c.textTertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All weights, volumes, and PRs will be displayed in $selected.',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                        fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.label,
    required this.example,
    required this.selected,
    required this.onTap,
    required this.c,
  });
  final String unit;
  final String label;
  final String example;
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
        height: 130,
        decoration: BoxDecoration(
          color: selected
              ? c.accentIron.withValues(alpha: 0.08)
              : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? c.accentIron : c.divider.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit,
              style: AppTypography.displayL(
                selected ? c.accentIron : c.textPrimary,
              ).copyWith(
                fontSize: 38, letterSpacing: -1.5, height: 1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodyS(
                selected ? c.accentIron : c.textSecondary,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              example,
              style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
