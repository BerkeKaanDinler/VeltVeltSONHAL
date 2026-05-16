import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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

class _RestTimerBannerState extends State<RestTimerBanner> {
  late int _remaining;
  Timer? _timer;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(RestTimerBanner old) {
    super.didUpdateWidget(old);
    if (old.initialSeconds != widget.initialSeconds) {
      _remaining = widget.initialSeconds;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) {
          _remaining--;
          // Last 10 seconds: light haptic pulse
          if (_remaining <= 10 && _remaining > 0) {
            HapticFeedback.lightImpact();
          }
          if (_remaining == 0) {
            HapticFeedback.heavyImpact();
          }
        }
      });
    });
  }

  void _addTime() {
    setState(() => _remaining += 15);
    widget.onAdd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final urgent = _remaining <= 30;

    final mins = (_remaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_remaining % 60).toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: urgent ? c.accentIron : c.accentIronSoft,
        border: Border(
          bottom: BorderSide(color: c.accentIron, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Skip
          SizedBox(
            width: 44, height: 44,
            child: GestureDetector(
              onTap: widget.onSkip,
              child: Center(
                child: Text(
                  'Skip',
                  style: AppTypography.titleS(
                    urgent ? Colors.white.withValues(alpha: 0.8) : c.textTertiary,
                  ).copyWith(fontSize: 13),
                ),
              ),
            ),
          ),

          // Timer
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$mins:$secs',
                  style: AppTypography.displayM(
                    urgent ? Colors.white : c.accentIron,
                  ).copyWith(
                    fontSize: 32,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'REST',
                  style: AppTypography.caption(
                    urgent ? Colors.white.withValues(alpha: 0.6) : c.textTertiary,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),

          // +15s
          GestureDetector(
            onTap: _addTime,
            child: Container(
              height: 32, width: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: urgent
                      ? Colors.white.withValues(alpha: 0.3)
                      : c.divider),
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: urgent ? Colors.white.withValues(alpha: 0.1) : c.surfaceElevated,
              ),
              child: Center(
                child: Text(
                  '+15s',
                  style: AppTypography.bodyS(
                    urgent ? Colors.white : c.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
