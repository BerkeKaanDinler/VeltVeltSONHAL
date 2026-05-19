import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/app_constants.dart';

/// Rest timer with smooth 60fps ring animation and automatic background sync.
/// Uses wall-clock time so the timer stays accurate even after the app is
/// backgrounded and resumed.
class RestTimerBanner extends StatefulWidget {
  const RestTimerBanner({
    super.key,
    required this.initialSeconds,
    required this.onSkip,
    required this.onAdd,
  });

  final int initialSeconds;
  final VoidCallback onSkip;
  final VoidCallback onAdd;

  @override
  State<RestTimerBanner> createState() => _RestTimerBannerState();
}

class _RestTimerBannerState extends State<RestTimerBanner>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late DateTime _startTime;
  int _addedSeconds = 0;
  bool _finished = false;

  // 60fps ticker drives smooth ring + display
  late Ticker _ticker;
  double _pct = 1.0;
  int _displaySecs = 0;
  int _prevDisplaySecs = -1;

  // Urgent state (<= 10s)
  bool _isUrgent = false;

  int get _totalSeconds => widget.initialSeconds + _addedSeconds;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _displaySecs = widget.initialSeconds;
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick)..start();
    // Request permission on first rest timer — non-blocking
    NotificationService.requestPermission();
  }

  void _onTick(Duration _) {
    if (_finished) return;
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
    final remaining = (_totalSeconds - elapsed).clamp(0.0, _totalSeconds.toDouble());
    final displaySecs = remaining.ceil().toInt();
    final pct = _totalSeconds > 0 ? remaining / _totalSeconds : 0.0;

    if (displaySecs != _prevDisplaySecs) {
      _prevDisplaySecs = displaySecs;
      if (displaySecs > 0 && displaySecs <= AppConstants.restTimerUrgentSecs) {
        HapticFeedback.lightImpact();
      }
      if (displaySecs == 0 && !_finished) {
        HapticFeedback.heavyImpact();
      }
    }

    if (mounted) {
      setState(() {
        _pct = pct;
        _displaySecs = displaySecs;
        _isUrgent = displaySecs <= AppConstants.restTimerUrgentSecs && displaySecs > 0;
      });
    }

    if (remaining <= 0 && !_finished) {
      _finished = true;
      _ticker.stop();
      NotificationService.cancelRestTimer();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) widget.onSkip();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ticker.stop();
      _scheduleBackgroundNotification();
    } else if (state == AppLifecycleState.resumed && !_finished) {
      NotificationService.cancelRestTimer();
      _ticker.start();
    }
  }

  void _scheduleBackgroundNotification() {
    if (_finished) return;
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
    final remainingSecs = (_totalSeconds - elapsed).ceil();
    // Skip scheduling if barely any time is left
    if (remainingSecs < 5) return;
    final expiresAt = DateTime.now().add(Duration(seconds: remainingSecs));
    NotificationService.scheduleRestTimer(expiresAt);
  }

  void _addTime() {
    HapticFeedback.selectionClick();
    setState(() => _addedSeconds += AppConstants.restTimerAddSecs);
    widget.onAdd();
  }

  void _skip() {
    HapticFeedback.mediumImpact();
    NotificationService.cancelRestTimer();
    widget.onSkip();
  }

  @override
  void dispose() {
    _ticker.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final ringColor = _isUrgent ? c.errorRose : c.accentIron;
    final mins = (_displaySecs ~/ 60).toString().padLeft(2, '0');
    final secs = (_displaySecs % 60).toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: ringColor.withValues(alpha: _isUrgent ? 0.10 : 0.08),
        border: Border(
          bottom: BorderSide(
            color: ringColor.withValues(alpha: _isUrgent ? 0.40 : 0.25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Smooth ring ─────────────────────────────────
          SizedBox(
            width: 48, height: 48,
            child: CustomPaint(
              painter: _RingPainter(pct: _pct, color: ringColor),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTypography.caption(ringColor).copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    letterSpacing: -0.5,
                  ),
                  child: Text('$mins:$secs'),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Labels ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTypography.titleS(
                    _isUrgent ? ringColor : c.textPrimary,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  child: const Text('Rest'),
                ),
                const SizedBox(height: 1),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isUrgent ? 'Get ready!' : 'Until your next set',
                    key: ValueKey(_isUrgent),
                    style: AppTypography.caption(c.textTertiary)
                        .copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // ── +15s chip ───────────────────────────────────
          _TimerChip(
            label: '+15s',
            onTap: _addTime,
            c: c,
          ),
          const SizedBox(width: AppSpacing.xs),

          // ── Skip ────────────────────────────────────────
          _TimerChip(
            label: 'Skip',
            onTap: _skip,
            textColor: c.textTertiary,
            c: c,
          ),
        ],
      ),
    );
  }
}

// ── Chip button (shared by +15s and Skip) ─────────────────────
class _TimerChip extends StatefulWidget {
  const _TimerChip({
    required this.label,
    required this.onTap,
    required this.c,
    this.textColor,
  });
  final String label;
  final VoidCallback onTap;
  final AppColors c;
  final Color? textColor;

  @override
  State<_TimerChip> createState() => _TimerChipState();
}

class _TimerChipState extends State<_TimerChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: c.divider.withValues(alpha: 0.7),
                width: 0.5,
              ),
            ),
            child: Text(
              widget.label,
              style: AppTypography.bodyS(
                widget.textColor ?? c.textSecondary,
              ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Smooth arc ring ───────────────────────────────────────────
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.pct, required this.color});
  final double pct;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2.5;
    const sw = 3.0;

    // Track ring
    canvas.drawCircle(center, radius,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);

    // Progress arc — drawn in reverse (clockwise drain)
    if (pct > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        pct * 2 * math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color;
}
