/// VELT — PrimaryButton
/// 52pt height, accent fill, white text. Use for primary CTAs.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = ButtonSize.lg,
    this.disabled = false,
    this.loading  = false,
  });

  final String       label;
  final VoidCallback? onPressed;
  final Widget?      icon;
  final ButtonSize   size;
  final bool         disabled;
  final bool         loading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

enum ButtonSize { sm, md, lg }

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  double get _height => switch (widget.size) {
    ButtonSize.sm => 38,
    ButtonSize.md => 44,
    ButtonSize.lg => AppTouchTarget.primary,
  };
  double get _fontSize => switch (widget.size) {
    ButtonSize.sm => 12,
    ButtonSize.md => 13,
    ButtonSize.lg => 14,
  };

  void _onTap() {
    if (widget.disabled || widget.loading) return;
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final disabled = widget.disabled || widget.onPressed == null;
    return Listener(
      onPointerDown: (_) { if (!disabled) setState(() => _pressed = true); },
      onPointerUp:   (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedOpacity(
            opacity: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: _height,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: disabled ? c.surfaceHigh : c.accentIron,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: widget.loading
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 6),
                      ],
                      Text(widget.label, style: TextStyle(
                        fontSize: _fontSize, fontWeight: FontWeight.w700,
                        color: disabled ? c.textTertiary : Colors.white,
                        letterSpacing: 0.1,
                      )),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ghost button — outlined, secondary CTAs
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.danger  = false,
    this.size    = ButtonSize.md,
  });

  final String       label;
  final VoidCallback? onPressed;
  final Widget?      icon;
  final bool         danger;
  final ButtonSize   size;

  double get _height => switch (size) {
    ButtonSize.sm => 32,
    ButtonSize.md => 38,
    ButtonSize.lg => 44,
  };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final color  = danger ? c.errorRose : c.textSecondary;
    final border = danger ? c.errorRose : c.divider;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[ icon!, const SizedBox(width: 6) ],
            Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color,
            )),
          ],
        ),
      ),
    );
  }
}
