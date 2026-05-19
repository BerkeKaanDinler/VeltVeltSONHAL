import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// ── PrimaryButton ──────────────────────────────────────────
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool loading;
  final double width;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final effective = widget.disabled ? null : widget.onPressed;

    return GestureDetector(
      onTapDown: (_) { if (!widget.disabled) setState(() => _pressed = true); },
      onTapUp: (_) {
        if (!widget.disabled) {
          setState(() => _pressed = false);
          HapticFeedback.mediumImpact();
          effective?.call();
        }
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: widget.disabled ? 0.4 : (_pressed ? 0.92 : 1.0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.99 : 1.0,
          child: Container(
            width: widget.width,
            height: AppTouchTarget.primaryButton,
            decoration: BoxDecoration(
              color: c.accentIron,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: widget.disabled ? null : [
                BoxShadow(
                  color: c.accentIron.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: widget.loading
                  ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: AppTypography.titleS(Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── GhostButton ────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: c.divider),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              label,
              style: AppTypography.bodyM(c.textSecondary).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TextVeltButton ─────────────────────────────────────────
class TextVeltButton extends StatelessWidget {
  const TextVeltButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: c.textTertiary,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: AppTypography.bodyS(c.textTertiary).copyWith(
        fontWeight: FontWeight.w500, fontSize: 13,
      )),
    );
  }
}

// ── SkeletonBox ── pulsing shimmer placeholder ─────────────
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadius.sm,
  });
  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(c.surfaceElevated, c.surfaceHigh, _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ── SectionHeader ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: 10),
  });

  final String label;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.sectionHeader(c.textTertiary),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTypography.bodyS(c.accentIron).copyWith(
                  fontWeight: FontWeight.w600, fontSize: 11,
                  letterSpacing: 0.02),
              ),
            ),
        ],
      ),
    );
  }
}

// ── RoutineCard ────────────────────────────────────────────
class RoutineCard extends StatefulWidget {
  const RoutineCard({
    super.key,
    required this.name,
    required this.exerciseCount,
    required this.lastDone,
    required this.color,
    required this.onTap,
  });

  final String name;
  final int exerciseCount;
  final String lastDone;
  final Color color;
  final VoidCallback onTap;

  @override
  State<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 72,
        decoration: BoxDecoration(
          color: _pressed ? c.surfaceHigh : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // left 4pt color bar
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 4, color: widget.color),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                          style: AppTypography.titleM(c.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.exerciseCount} exercises · ${widget.lastDone}',
                          style: AppTypography.bodyS(c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MethodCard ─────────────────────────────────────────────
class MethodCard extends StatelessWidget {
  const MethodCard({
    super.key,
    required this.name,
    required this.tagline,
    required this.difficulty,
    required this.frequency,
    required this.categoryColor,
    required this.onTap,
  });

  final String name;
  final String tagline;
  final String difficulty;
  final String frequency;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 9, height: 9,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    style: AppTypography.titleM(c.textPrimary).copyWith(fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(tagline,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _Pill(label: difficulty, bg: c.surfaceHigh, color: c.textTertiary),
            const SizedBox(width: 4),
            _Pill(label: frequency,  bg: c.surfaceHigh, color: c.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.color});
  final String label;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
        style: AppTypography.caption(color).copyWith(fontSize: 10)),
    );
  }
}

// ── PRCard ─────────────────────────────────────────────────
class PRCard extends StatelessWidget {
  const PRCard({
    super.key,
    required this.exercise,
    required this.value,
    required this.date,
  });

  final String exercise;
  final String value;
  final String date;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      constraints: const BoxConstraints(minWidth: 130),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(exercise,
            style: AppTypography.bodyS(c.textSecondary).copyWith(
              fontWeight: FontWeight.w500, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                style: AppTypography.displayM(c.accentIron).copyWith(
                  fontSize: 22,
                  fontFeatures: [const FontFeature.tabularFigures()],
                )),
              const SizedBox(width: 5),
              Text('↑',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: c.successLime)),
            ],
          ),
          const SizedBox(height: 2),
          Text(date,
            style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

// ── StatCard ───────────────────────────────────────────────
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.accent = false,
  });

  final String value;
  final String label;
  final String? unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                  style: AppTypography.displayM(
                    accent ? c.accentIron : c.textPrimary,
                  ).copyWith(
                    fontSize: 28,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  )),
                if (unit != null) ...[
                  const SizedBox(width: 3),
                  Text(unit!,
                    style: AppTypography.bodyS(c.textSecondary).copyWith(
                      fontWeight: FontWeight.w500, fontSize: 11)),
                ],
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: AppTypography.caption(c.textTertiary).copyWith(
                fontSize: 10, letterSpacing: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EmptyState ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(opacity: 0.35, child: icon),
            const SizedBox(height: AppSpacing.sm),
            Text(title,
              style: AppTypography.titleL(c.textPrimary).copyWith(fontSize: 18),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle,
              style: AppTypography.bodyM(c.textSecondary).copyWith(
                fontSize: 13, height: 1.5),
              textAlign: TextAlign.center),
            if (ctaLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              GhostButton(label: ctaLabel!, onPressed: onCta ?? () {}),
            ],
          ],
        ),
      ),
    );
  }
}

// ── FilterChip ─────────────────────────────────────────────
class VeltFilterChip extends StatelessWidget {
  const VeltFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.accentIron : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: active ? null : Border.all(color: c.divider),
        ),
        child: Text(
          label,
          style: AppTypography.bodyS(
            active ? Colors.white : c.textSecondary,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
