// ignore_for_file: dead_code, unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/velt_redesign_widgets.dart';
import '../services/prefs_service.dart';
import '../services/nutrition_store.dart';
import '../services/tracking_service.dart';

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
  int? _daysPerWeek;
  double? _bodyweightKg;
  bool? _notificationsAllowed;

  // Pages: 0 Welcome, 1 Goal, 2 Experience, 3 Frequency, 4 Bodyweight,
  // 5 Unit, 6 Notifications, 7 Paywall
  static const _totalPages = 8;

  bool get _canContinue {
    return switch (_page) {
      0 => true,
      1 => _goal != null,
      2 => _experience != null,
      3 => _daysPerWeek != null,
      4 => _bodyweightKg != null,
      5 => _unit != null,
      6 => _notificationsAllowed != null,
      7 => true, // paywall — always can skip
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

  Future<void> _requestNotificationPerm() async {
    HapticFeedback.selectionClick();
    // Best-effort — uses existing NotificationService init flow.
    // The OS permission dialog will follow the rationale screen.
    setState(() => _notificationsAllowed = true);
    _next();
  }

  void _skipNotifications() {
    HapticFeedback.selectionClick();
    setState(() => _notificationsAllowed = false);
    _next();
  }

  void _finish() {
    // iOS App Tracking Transparency: ask once, after onboarding.
    // No-op on Android.
    TrackingService.requestIfNeeded();

    if (_goal != null) PrefsService.setFitnessGoal(_goal!);
    if (_experience != null) {
      PrefsService.setExperienceLevel(_experience!);
      final restSecs = switch (_experience) {
        'beginner' => 75,
        'advanced' => 120,
        _ => 90,
      };
      PrefsService.setRestSecs(restSecs);
    }
    if (_bodyweightKg != null) {
      PrefsService.setBodyweightKg(_bodyweightKg!);
    }
    final unit = _unit ?? 'kg';
    PrefsService.setUnit(unit);
    if (_goal != null && PrefsService.nutritionTargets == null) {
      final t = switch (_goal) {
        'Lose Fat' => const NutritionTargets(
            calories: 1800, protein: 165, carbs: 150, fat: 60),
        'Strength' => const NutritionTargets(
            calories: 2800, protein: 200, carbs: 300, fat: 90),
        'Endurance' => const NutritionTargets(
            calories: 2200, protein: 140, carbs: 300, fat: 65),
        _ => const NutritionTargets(
            calories: 2600, protein: 190, carbs: 280, fat: 80),
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

    return _FreshOnboardingFlow(
      pageController: _pageCtrl,
      page: _page,
      totalPages: _totalPages,
      canContinue: _canContinue,
      goal: _goal,
      experience: _experience,
      unit: _unit,
      daysPerWeek: _daysPerWeek,
      bodyweightKg: _bodyweightKg,
      onPageChanged: (page) => setState(() => _page = page),
      onGoalChanged: (goal) => setState(() => _goal = goal),
      onExperienceChanged: (experience) =>
          setState(() => _experience = experience),
      onUnitChanged: (unit) => setState(() => _unit = unit),
      onDaysChanged: (d) => setState(() => _daysPerWeek = d),
      onBodyweightChanged: (kg) => setState(() => _bodyweightKg = kg),
      onAllowNotifications: _requestNotificationPerm,
      onSkipNotifications: _skipNotifications,
      onStartTrial: () {
        // Mark onboarding finished — main app shows the paywall after Home
        // loads (handled by VeltApp). Skipping is the same as finishing.
        _finish();
      },
      onBack: _back,
      onNext: _next,
    );

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
                              style: AppTypography.bodyS(c.textSecondary)
                                  .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
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
class _FreshOnboardingFlow extends StatelessWidget {
  const _FreshOnboardingFlow({
    required this.pageController,
    required this.page,
    required this.totalPages,
    required this.canContinue,
    required this.goal,
    required this.experience,
    required this.unit,
    required this.daysPerWeek,
    required this.bodyweightKg,
    required this.onPageChanged,
    required this.onGoalChanged,
    required this.onExperienceChanged,
    required this.onUnitChanged,
    required this.onDaysChanged,
    required this.onBodyweightChanged,
    required this.onAllowNotifications,
    required this.onSkipNotifications,
    required this.onStartTrial,
    required this.onBack,
    required this.onNext,
  });

  final PageController pageController;
  final int page;
  final int totalPages;
  final bool canContinue;
  final String? goal;
  final String? experience;
  final String? unit;
  final int? daysPerWeek;
  final double? bodyweightKg;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<double> onBodyweightChanged;
  final VoidCallback onAllowNotifications;
  final VoidCallback onSkipNotifications;
  final VoidCallback onStartTrial;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return VeltStaticScreen(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: VeltProgressBar(value: (page + 1) / totalPages),
              ),
              const SizedBox(width: 12),
              VeltPill('${page + 1}/$totalPages', accent: true),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: [
                const _FreshOnboardingPage(
                  eyebrow: 'Welcome',
                  title: 'VELT adapts to your training.',
                  subtitle:
                      'A focused fitness log for lifting, nutrition and steady progress.',
                  children: [
                    _FreshOnboardingStat(value: '5', label: 'themes'),
                    SizedBox(height: 8),
                    _FreshOnboardingStat(value: '0', label: 'clutter'),
                  ],
                ),
                _FreshOnboardingPage(
                  eyebrow: 'Goal',
                  title: 'What are you building toward?',
                  subtitle:
                      'This tunes your nutrition defaults and training tone.',
                  children: [
                    _FreshChoiceTile(
                      title: 'Build Muscle',
                      subtitle:
                          'More volume, balanced calories and hypertrophy.',
                      selected: goal == 'Build Muscle',
                      onTap: () => onGoalChanged('Build Muscle'),
                    ),
                    _FreshChoiceTile(
                      title: 'Lose Fat',
                      subtitle:
                          'Protein-forward targets and consistency focus.',
                      selected: goal == 'Lose Fat',
                      onTap: () => onGoalChanged('Lose Fat'),
                    ),
                    _FreshChoiceTile(
                      title: 'Strength',
                      subtitle:
                          'Heavier progressions with longer rest defaults.',
                      selected: goal == 'Strength',
                      onTap: () => onGoalChanged('Strength'),
                    ),
                    _FreshChoiceTile(
                      title: 'Endurance',
                      subtitle: 'More work capacity and recovery awareness.',
                      selected: goal == 'Endurance',
                      onTap: () => onGoalChanged('Endurance'),
                    ),
                  ],
                ),
                _FreshOnboardingPage(
                  eyebrow: 'Experience',
                  title: 'How trained are you right now?',
                  subtitle: 'Rest timers and routine suggestions start here.',
                  children: [
                    _FreshChoiceTile(
                      title: 'Beginner',
                      subtitle: 'Simple plans, shorter sessions, cleaner cues.',
                      selected: experience == 'beginner',
                      onTap: () => onExperienceChanged('beginner'),
                    ),
                    _FreshChoiceTile(
                      title: 'Intermediate',
                      subtitle: 'Balanced volume and measured progression.',
                      selected: experience == 'intermediate',
                      onTap: () => onExperienceChanged('intermediate'),
                    ),
                    _FreshChoiceTile(
                      title: 'Advanced',
                      subtitle: 'Higher workload with more recovery space.',
                      selected: experience == 'advanced',
                      onTap: () => onExperienceChanged('advanced'),
                    ),
                  ],
                ),
                // Page 3 — Frequency
                _FreshOnboardingPage(
                  eyebrow: 'Frequency',
                  title: 'How many days a week?',
                  subtitle:
                      'Used to suggest a program that actually fits your schedule.',
                  children: [
                    for (final d in const [3, 4, 5, 6])
                      _FreshChoiceTile(
                        title: '$d days / week',
                        subtitle: switch (d) {
                          3 => 'Full body or upper/lower light — quick recovery.',
                          4 => 'Upper/lower split — balanced volume.',
                          5 => 'Push pull legs + upper — high volume.',
                          _ => 'Push pull legs 2x — advanced volume.',
                        },
                        selected: daysPerWeek == d,
                        onTap: () => onDaysChanged(d),
                      ),
                  ],
                ),
                // Page 4 — Bodyweight
                _BodyweightPage(
                  bodyweightKg: bodyweightKg,
                  unit: unit ?? 'kg',
                  onChanged: onBodyweightChanged,
                ),
                // Page 5 — Units
                _FreshOnboardingPage(
                  eyebrow: 'Units',
                  title: 'Pick your default weight unit.',
                  subtitle: 'You can change this later from Profile.',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FreshChoiceTile(
                            title: 'KG',
                            subtitle: 'Metric plates',
                            selected: unit == 'kg',
                            onTap: () => onUnitChanged('kg'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FreshChoiceTile(
                            title: 'LB',
                            subtitle: 'Imperial plates',
                            selected: unit == 'lb',
                            onTap: () => onUnitChanged('lb'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Page 6 — Notifications rationale
                _NotificationsPage(
                  onAllow: onAllowNotifications,
                  onSkip: onSkipNotifications,
                ),
                // Page 7 — Mini paywall / free trial
                _OnboardingPaywallPage(
                  onStartTrial: onStartTrial,
                  onSkip: onStartTrial,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Notifications page (6) and Paywall page (7) have their own
          // in-card buttons — hide the global action bar there.
          if (page != 6 && page != 7) Row(
            children: [
              if (page > 0) ...[
                SizedBox(
                  width: 92,
                  child: VeltButton(
                    label: 'Back',
                    secondary: true,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: VeltButton(
                  label: page == totalPages - 1 ? 'Start training' : 'Continue',
                  onTap: canContinue ? onNext : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your choices stay on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreshOnboardingPage extends StatelessWidget {
  const _FreshOnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VeltLabel(eyebrow),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 34,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FreshChoiceTile extends StatelessWidget {
  const _FreshChoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: VeltPanel(
          borderColor: selected ? c.accentIron : null,
          backgroundColor: selected
              ? Color.lerp(c.surfaceElevated, c.accentIron, .10)
              : null,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              VeltPill(selected ? 'Selected' : 'Tap',
                  accent: selected, success: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreshOnboardingStat extends StatelessWidget {
  const _FreshOnboardingStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return VeltPanel(
      child: VeltMetric(value: value, label: label),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.c, required this.onContinue});
  final AppColors c;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your\nprimary goal?",
            style: AppTypography.displayM(c.textPrimary)
                .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.2),
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
                      color:
                          active ? g.color : c.divider.withValues(alpha: 0.6),
                      width: active ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
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
                            fontSize: 14,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        g.desc,
                        style: AppTypography.bodyS(c.textSecondary)
                            .copyWith(fontSize: 11, height: 1.4),
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
        'Lose Fat' => Icons.local_fire_department_rounded,
        'Strength' => Icons.bolt_rounded,
        _ => Icons.directions_run_rounded,
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How long have you\nbeen training?',
            style: AppTypography.displayM(c.textPrimary)
                .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.2),
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
                        width: 48,
                        height: 48,
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
                                  .copyWith(fontSize: 15, letterSpacing: -0.1),
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
                                  .copyWith(fontSize: 10, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        Container(
                          width: 24,
                          height: 24,
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your\nweight unit.',
            style: AppTypography.displayM(c.textPrimary)
                .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'You can change this anytime in Settings.',
            style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                  child: _UnitCard(
                unit: 'kg',
                subtitle: 'kilograms',
                selected: selected == 'kg',
                onTap: () => onSelect('kg'),
                c: c,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _UnitCard(
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

// ── Bodyweight page ────────────────────────────────────────
class _BodyweightPage extends StatefulWidget {
  const _BodyweightPage({
    required this.bodyweightKg,
    required this.unit,
    required this.onChanged,
  });
  final double? bodyweightKg;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  State<_BodyweightPage> createState() => _BodyweightPageState();
}

class _BodyweightPageState extends State<_BodyweightPage> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.bodyweightKg ?? 75.0;
    // Push initial value to parent so Continue is enabled immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_value);
    });
  }

  bool get _useLb => widget.unit == 'lb';

  String get _display {
    final v = _useLb ? _value * 2.20462 : _value;
    return v.toStringAsFixed(_useLb || _value % 1 != 0 ? 1 : 0);
  }

  void _adjust(double deltaKg) {
    HapticFeedback.selectionClick();
    setState(() => _value = (_value + deltaKg).clamp(30.0, 250.0));
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return _FreshOnboardingPage(
      eyebrow: 'Bodyweight',
      title: 'How much do you weigh?',
      subtitle: 'Used for volume tracking and calorie estimates. You can '
          'update this anytime.',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: c.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _adjust(_useLb ? -0.5 : -0.5),
                    onLongPress: () => _adjust(-5),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.remove_rounded,
                          color: c.textPrimary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    _display,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 58,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _useLb ? 'lb' : 'kg',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: () => _adjust(_useLb ? 0.5 : 0.5),
                    onLongPress: () => _adjust(5),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: c.accentIron.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: c.accentIron.withValues(alpha: .4)),
                      ),
                      child: Icon(Icons.add_rounded,
                          color: c.accentIron, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Hold buttons for ±5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Notifications opt-in page ─────────────────────────────
class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({required this.onAllow, required this.onSkip});
  final VoidCallback onAllow;
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltPanel(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications_active_rounded,
                    color: c.accentIron, size: 36),
                const SizedBox(height: 14),
                VeltLabel('Notifications'),
                const SizedBox(height: 10),
                Text(
                  'Stay on track without checking the app.',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'VELT uses notifications for rest timers, streak '
                  'reminders, and your weekly progress digest. Never '
                  'marketing — we respect your inbox.',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final f in const [
            (icon: Icons.timer_rounded, text: 'Rest timer alerts'),
            (
              icon: Icons.local_fire_department_rounded,
              text: 'Streak save (don\'t break the chain)'
            ),
            (
              icon: Icons.insights_rounded,
              text: 'Weekly Sunday digest with insights'
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: c.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.accentIron.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(f.icon, color: c.accentIron, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f.text,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: c.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          VeltButton(
            label: 'Allow notifications',
            onTap: onAllow,
          ),
          const SizedBox(height: 8),
          VeltButton(
            label: 'Maybe later',
            secondary: true,
            onTap: onSkip,
          ),
        ],
      ),
    );
  }
}

// ── Mini paywall (last onboarding step) ───────────────────
class _OnboardingPaywallPage extends StatelessWidget {
  const _OnboardingPaywallPage({
    required this.onStartTrial,
    required this.onSkip,
  });
  final VoidCallback onStartTrial;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.accentIron, c.accentIronSoft],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: c.accentIron.computeLuminance() > .55
                            ? c.ink
                            : Colors.white,
                        size: 30),
                    const SizedBox(width: 8),
                    Text(
                      'VELT PRO',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.accentIron.computeLuminance() > .55
                            ? c.ink
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Try Pro free for 7 days.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.accentIron.computeLuminance() > .55
                        ? c.ink
                        : Colors.white,
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI Nutritionist, AI Coach Insights, premium themes, '
                  'unlimited history, and Apple Health 2-way sync. Cancel '
                  'anytime — no charge until day 8.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: (c.accentIron.computeLuminance() > .55
                            ? c.ink
                            : Colors.white)
                        .withValues(alpha: .88),
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final f in const [
            'AI meal plans & macro tuning',
            'Plateau alerts & deload timing',
            '3 premium themes',
            'Full history + CSV/JSON export',
            'Custom multi-week programs',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: c.successLime, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          VeltButton(
            label: 'Start 7-day free trial',
            onTap: onStartTrial,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSkip,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Continue with Free',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                  decorationColor: c.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
