import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_spacing.dart';
import 'services/prefs_service.dart';
import 'services/routine_store.dart';
import 'services/workout_history_store.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/train_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/profile_screen.dart';

// ── Global theme notifier ──────────────────────────────────
final ValueNotifier<String> veltThemeKey = ValueNotifier(PrefsService.theme);

ThemeData _themeForKey(String key) {
  return switch (key) {
    'warmPaper'     => AppTheme.warmPaper,
    'midnightSteel' => AppTheme.midnightSteel,
    'forestIron'    => AppTheme.forestIron,
    'bloodOrange'   => AppTheme.bloodOrange,
    'espresso'      => AppTheme.espresso,
    'arctic'        => AppTheme.arctic,
    'obsidian'      => AppTheme.obsidian,
    'military'      => AppTheme.military,
    _               => AppTheme.darkIron,
  };
}

// ── Root widget ────────────────────────────────────────────
class VeltRoot extends StatelessWidget {
  const VeltRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: veltThemeKey,
      builder: (_, key, __) {
        return MaterialApp(
          title: 'VELT',
          debugShowCheckedModeBanner: false,
          theme: _themeForKey(key),
          home: const VeltApp(),
        );
      },
    );
  }
}

// ── App shell ──────────────────────────────────────────────
class VeltApp extends StatefulWidget {
  const VeltApp({super.key});

  @override
  State<VeltApp> createState() => _VeltAppState();
}

class _VeltAppState extends State<VeltApp> {
  bool _onboardingDone = PrefsService.onboardingDone;
  int  _activeTab      = 0;
  String? _activeWorkoutName;
  bool _showSummary = false;
  CompletedWorkout? _completedWorkout;
  CompletedWorkout? _lastCompletedWorkout;
  List<WorkoutExercise>? _pendingExercises;
  List<({String exercise, double weight, int reps})> _newPRs = [];
  int _restoredElapsedSecs = 0;

  @override
  void initState() {
    super.initState();
    // Restore an in-progress workout from previous session
    final saved = PrefsService.activeWorkout;
    if (saved != null) {
      try {
        final data = jsonDecode(saved) as Map<String, dynamic>;
        _activeWorkoutName = data['routineName'] as String;
        _pendingExercises = (data['exercises'] as List)
            .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
            .toList();
        _restoredElapsedSecs = data['elapsedSecs'] as int? ?? 0;
      } catch (_) {
        PrefsService.clearActiveWorkout();
      }
    }
    // Load last completed workout for HomeScreen
    final lastJson = PrefsService.lastWorkout;
    if (lastJson != null) {
      try {
        _lastCompletedWorkout = CompletedWorkout.fromJson(
            jsonDecode(lastJson) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  void _finishOnboarding() {
    PrefsService.setOnboardingDone();
    setState(() => _onboardingDone = true);
  }

  void _startWorkout(String name, List<WorkoutExercise>? exercises) {
    final enriched = exercises != null
        ? WorkoutHistoryStore.enrichWithPrev(exercises)
        : null;
    setState(() {
      _activeWorkoutName = name;
      _pendingExercises = enriched;
      _restoredElapsedSecs = 0;
      _showSummary = false;
      _completedWorkout = null;
    });
  }

  List<({String exercise, double weight, int reps})> _newPRsFor(CompletedWorkout w) {
    final prevPRs = WorkoutHistoryStore.allTimePRs;
    final result = <({String exercise, double weight, int reps})>[];
    for (final ex in w.exercises) {
      double bestWeight = 0;
      int bestReps = 0;
      for (final s in ex.sets) {
        if (s.isDone && s.weight > bestWeight) {
          bestWeight = s.weight;
          bestReps = s.reps;
        }
      }
      if (bestWeight <= 0) continue;
      final prevBest = prevPRs[ex.name]?.weight ?? 0;
      if (bestWeight > prevBest) {
        result.add((exercise: ex.name, weight: bestWeight, reps: bestReps));
      }
    }
    return result;
  }

  void _finishWorkout(CompletedWorkout w) {
    final newPRs = _newPRsFor(w);
    if (newPRs.isNotEmpty) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    PrefsService.saveLastWorkout(jsonEncode(w.toJson()));
    WorkoutHistoryStore.add(w);
    // Mark the matching routine as done so Today's Plan updates correctly
    final match = RoutineStore.routines.value
        .where((r) => r.name == w.routineName)
        .firstOrNull;
    if (match != null) RoutineStore.markDone(match.id);
    setState(() {
      _showSummary = true;
      _completedWorkout = w;
      _lastCompletedWorkout = w;
      _pendingExercises = null;
      _newPRs = newPRs;
    });
  }

  void _doneWithSummary() {
    setState(() {
      _activeWorkoutName = null;
      _showSummary = false;
      _completedWorkout = null;
      _pendingExercises = null;
      _restoredElapsedSecs = 0;
      _activeTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingDone) {
      return OnboardingScreen(onFinish: _finishOnboarding);
    }

    if (_activeWorkoutName != null) {
      if (_showSummary && _completedWorkout != null) {
        return WorkoutSummaryScreen(
          workout: _completedWorkout!,
          newPRs: _newPRs,
          onDone: _doneWithSummary,
        );
      }
      return ActiveWorkoutScreen(
        routineName: _activeWorkoutName!,
        exercises: _pendingExercises,
        initialElapsedSecs: _restoredElapsedSecs,
        onFinish: _finishWorkout,
      );
    }

    final screens = [
      HomeScreen(
        onStartWorkout: _startWorkout,
        onNavigate: (tab) => setState(() => _activeTab = tab),
        lastWorkout: _lastCompletedWorkout,
      ),
      TrainScreen(onStartWorkout: _startWorkout),
      const NutritionScreen(),
      const ProgressScreen(),
      ProfileScreen(
        onThemeChange: (key) {
          veltThemeKey.value = key;
          PrefsService.setTheme(key);
        },
        currentThemeKey: veltThemeKey.value,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _activeTab, children: screens),
      bottomNavigationBar: _VeltBottomNav(
        activeIndex: _activeTab,
        onTap: (i) => setState(() => _activeTab = i),
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────
class _VeltBottomNav extends StatelessWidget {
  const _VeltBottomNav({required this.activeIndex, required this.onTap});
  final int activeIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    const tabs = [
      _NavItem(icon: _NavIcon.home,      label: 'Home'),
      _NavItem(icon: _NavIcon.train,     label: 'Train'),
      _NavItem(icon: _NavIcon.nutrition, label: 'Nutrition'),
      _NavItem(icon: _NavIcon.progress,  label: 'Progress'),
      _NavItem(icon: _NavIcon.profile,   label: 'Profile'),
    ];

    return Container(
      height: 56 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final i = e.key;
            final tab = e.value;
            final active = i == activeIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(i);
                },
                child: SizedBox(
                  height: AppTouchTarget.tabBar,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIcon(tab.icon, active, c),
                      if (active)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 20, height: 2,
                          decoration: BoxDecoration(
                            color: c.accentIron,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIcon(_NavIcon icon, bool active, AppColors c) {
    final color = active ? c.accentIron : c.textTertiary;
    return CustomPaint(
      size: const Size(24, 24),
      painter: _NavIconPainter(icon: icon, color: color, active: active),
    );
  }
}

enum _NavIcon { home, train, nutrition, progress, profile }

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final _NavIcon icon;
  final String label;
}

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({
    required this.icon,
    required this.color,
    required this.active,
  });
  final _NavIcon icon;
  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = active ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sx = size.width / 24;
    final sy = size.height / 24;
    canvas.scale(sx, sy);

    switch (icon) {
      case _NavIcon.home:
        _drawHome(canvas, paint, active, color);
      case _NavIcon.train:
        _drawTrain(canvas, paint, active, color);
      case _NavIcon.nutrition:
        _drawNutrition(canvas, paint, active, color);
      case _NavIcon.progress:
        _drawProgress(canvas, paint, active, color);
      case _NavIcon.profile:
        _drawProfile(canvas, paint, active, color);
    }
  }

  void _drawHome(Canvas canvas, Paint p, bool active, Color c) {
    final path = Path()
      ..moveTo(3, 9.5)
      ..lineTo(12, 3)
      ..lineTo(21, 9.5)
      ..lineTo(21, 20)
      ..arcToPoint(const Offset(20, 21), radius: const Radius.circular(1))
      ..lineTo(15, 21)
      ..lineTo(15, 15)
      ..lineTo(9, 15)
      ..lineTo(9, 21)
      ..lineTo(4, 21)
      ..arcToPoint(const Offset(3, 20), radius: const Radius.circular(1))
      ..close();
    p.style = active ? PaintingStyle.fill : PaintingStyle.stroke;
    p.strokeWidth = 1.6;
    canvas.drawPath(path, p);
  }

  void _drawTrain(Canvas canvas, Paint p, bool active, Color c) {
    final sw = active ? 2.0 : 1.5;
    final stroke = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = sw;

    // center bar
    canvas.drawLine(const Offset(9, 12), const Offset(15, 12),
      Paint()..color = c..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round..strokeWidth = 2.2);
    // left grip
    final lGrip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.5, 9.5, 3.5, 5), const Radius.circular(1));
    canvas.drawRRect(lGrip, stroke);
    // right grip
    final rGrip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 9.5, 3.5, 5), const Radius.circular(1));
    canvas.drawRRect(rGrip, stroke);
    // left plate
    final fillPaint = Paint()..color = c..style = PaintingStyle.fill;
    final lPlate = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, 8, 3.5, 8), const Radius.circular(1.5));
    if (active) {
      canvas.drawRRect(lPlate, fillPaint);
    } else {
      canvas.drawRRect(lPlate, stroke);
    }
    // right plate
    final rPlate = RRect.fromRectAndRadius(
      const Rect.fromLTWH(18.5, 8, 3.5, 8), const Radius.circular(1.5));
    if (active) {
      canvas.drawRRect(rPlate, fillPaint);
    } else {
      canvas.drawRRect(rPlate, stroke);
    }
  }

  void _drawNutrition(Canvas canvas, Paint p, bool active, Color c) {
    final sw = active ? 2.0 : 1.6;
    final stroke = Paint()
      ..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeWidth = sw;
    // fork tines
    canvas.drawLine(const Offset(7, 3), const Offset(7, 7.5), stroke);
    canvas.drawLine(const Offset(5, 3), const Offset(5, 6), stroke);
    canvas.drawLine(const Offset(9, 3), const Offset(9, 6), stroke);
    // fork curve
    final curvePath = Path()
      ..moveTo(5, 6)
      ..quadraticBezierTo(5, 8, 7, 8)
      ..quadraticBezierTo(9, 8, 9, 6);
    canvas.drawPath(curvePath, stroke);
    // fork handle
    canvas.drawLine(const Offset(7, 8), const Offset(7, 21), stroke);
    // knife
    final knifePath = Path()
      ..moveTo(17, 3)
      ..cubicTo(17, 3, 19, 5.5, 19, 9)
      ..cubicTo(19, 11, 17.5, 12, 17, 12)
      ..lineTo(17, 21);
    canvas.drawPath(knifePath, stroke);
  }

  void _drawProgress(Canvas canvas, Paint p, bool active, Color c) {
    final sw = active ? 2.0 : 1.6;
    final stroke = Paint()
      ..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..strokeWidth = sw;
    final path = Path()
      ..moveTo(4, 18)
      ..lineTo(8, 13)
      ..lineTo(12, 15.5)
      ..lineTo(17, 9)
      ..lineTo(21, 6);
    canvas.drawPath(path, stroke);
    if (active) {
      canvas.drawCircle(const Offset(21, 6), 1.5,
        Paint()..color = c..style = PaintingStyle.fill);
    }
  }

  void _drawProfile(Canvas canvas, Paint p, bool active, Color c) {
    if (active) {
      canvas.drawCircle(const Offset(12, 8), 4,
        Paint()..color = c..style = PaintingStyle.fill);
      final bodyPath = Path()
        ..moveTo(4, 20)
        ..quadraticBezierTo(4, 13, 12, 13)
        ..quadraticBezierTo(20, 13, 20, 20)
        ..close();
      canvas.drawPath(bodyPath, Paint()..color = c..style = PaintingStyle.fill);
    } else {
      final stroke = Paint()
        ..color = c..style = PaintingStyle.stroke..strokeWidth = 1.6;
      canvas.drawCircle(const Offset(12, 8), 4, stroke);
      final bodyPath = Path()
        ..moveTo(4, 20)
        ..quadraticBezierTo(4, 13, 12, 13)
        ..quadraticBezierTo(20, 13, 20, 20);
      stroke.strokeCap = StrokeCap.round;
      canvas.drawPath(bodyPath, stroke);
    }
  }

  @override
  bool shouldRepaint(_NavIconPainter old) =>
      old.color != color || old.active != active;
}

// ── AppTypography extension ────────────────────────────────
extension AppColorsContext on BuildContext {
  AppColors get vColors => Theme.of(this).extension<AppColors>()!;
}
