import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class VeltScreen extends StatelessWidget {
  const VeltScreen({
    super.key,
    required this.child,
    this.bottomPadding = 96,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 0),
  });

  final Widget child;
  final double bottomPadding;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _VeltGridPainter(c))),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: padding.copyWith(bottom: bottomPadding),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class VeltStaticScreen extends StatelessWidget {
  const VeltStaticScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _VeltGridPainter(c))),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class VeltHeader extends StatelessWidget {
  const VeltHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VeltLabel(eyebrow),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class VeltTopBar extends StatelessWidget {
  const VeltTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        children: [
          VeltIconButton(
              label: '<', onTap: onBack ?? () => Navigator.maybePop(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                    fontSize: 19,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textSecondary,
                        fontSize: 11,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing ?? const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class VeltPanel extends StatelessWidget {
  const VeltPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.hero = false,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool hero;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final bg = backgroundColor ?? c.surfaceElevated;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? c.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: c.surface.computeLuminance() > .5 ? .08 : .26),
            blurRadius: 28,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: hero
          ? Stack(
              children: [
                Positioned(
                  right: -58,
                  top: 16,
                  child: IgnorePointer(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c.accentIron.withValues(alpha: .13),
                          width: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

class VeltLabel extends StatelessWidget {
  const VeltLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        color: color ?? c.textSecondary,
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class VeltPill extends StatelessWidget {
  const VeltPill(
    this.text, {
    super.key,
    this.accent = false,
    this.success = false,
    this.error = false,
  });

  final String text;
  final bool accent;
  final bool success;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final fg = error
        ? c.errorRose
        : success
            ? c.successLime
            : accent
                ? c.accentIron
                : c.textSecondary;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color.lerp(c.surfaceElevated, fg, .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Color.lerp(c.divider, fg, .34)!),
      ),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class VeltMetric extends StatelessWidget {
  const VeltMetric({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      constraints: const BoxConstraints(minHeight: 55),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textPrimary,
              fontSize: 20,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class VeltButton extends StatelessWidget {
  const VeltButton({
    super.key,
    required this.label,
    required this.onTap,
    this.secondary = false,
    this.destructive = false,
    this.height = 45,
  });

  final String label;
  final VoidCallback? onTap;
  final bool secondary;
  final bool destructive;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final bg = destructive
        ? c.errorRose
        : secondary
            ? c.surfaceHigh
            : c.accentIron;
    final fg = destructive
        ? Colors.white
        : secondary
            ? c.textPrimary
            : _onAccent(c);
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
      child: Opacity(
        opacity: onTap == null ? .45 : 1,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: secondary ? Border.all(color: c.divider) : null,
            boxShadow: secondary
                ? null
                : [
                    BoxShadow(
                      color: bg.withValues(alpha: .16),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VeltIconButton extends StatelessWidget {
  const VeltIconButton({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class VeltSection extends StatelessWidget {
  const VeltSection({super.key, required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
      child: Row(
        children: [
          Expanded(child: VeltLabel(label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class VeltRowCard extends StatelessWidget {
  const VeltRowCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: c.surface.computeLuminance() > .5 ? .06 : .20),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color.lerp(c.surfaceHigh, c.accentIron, .13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.accentIron,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 17,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class VeltSegment extends StatelessWidget {
  const VeltSegment({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.divider),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == selected ? c.accentIron : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      items[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: i == selected ? _onAccent(c) : c.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VeltProgressBar extends StatelessWidget {
  const VeltProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 7,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: c.surfaceHigh,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(color: color ?? c.accentIron),
          ),
        ),
      ),
    );
  }
}

class VeltRing extends StatelessWidget {
  const VeltRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    this.size = 68,
  });

  final String value;
  final String label;
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(c, progress.clamp(0.0, 1.0)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textPrimary,
                  fontSize: size > 90 ? 29 : 22,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (size > 90)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: VeltLabel(label),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VeltLineChart extends StatelessWidget {
  const VeltLineChart({super.key, this.height = 130});
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return VeltPanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        child: CustomPaint(painter: _LineChartPainter(c)),
      ),
    );
  }
}

class VeltBars extends StatelessWidget {
  const VeltBars({super.key, required this.values, this.activeIndex});
  final List<double> values;
  final int? activeIndex;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            Expanded(
              child: FractionallySizedBox(
                heightFactor: values[i].clamp(0.0, 1.0),
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: i == activeIndex ? c.accentIron : c.surfaceHigh,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
            if (i != values.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

Color _onAccent(AppColors c) =>
    c.accentIron.computeLuminance() > .55 ? c.ink : Colors.white;

class _VeltGridPainter extends CustomPainter {
  const _VeltGridPainter(this.c);
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = c.textPrimary
          .withValues(alpha: c.surface.computeLuminance() > .5 ? .035 : .022)
      ..strokeWidth = .7;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * .45), paint);
    }
    for (double y = 0; y < size.height * .45; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VeltGridPainter oldDelegate) =>
      oldDelegate.c != c;
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.c, this.progress);
  final AppColors c;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .12;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..color = c.surfaceHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = c.accentIron
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bg);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.c != c || oldDelegate.progress != progress;
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter(this.c);
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = c.textPrimary.withValues(alpha: .055)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final points = <Offset>[
      Offset(10, size.height * .67),
      Offset(size.width * .25, size.height * .48),
      Offset(size.width * .45, size.height * .64),
      Offset(size.width * .68, size.height * .30),
      Offset(size.width - 10, size.height * .34),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final fill = Path.from(path)
      ..lineTo(size.width - 10, size.height - 16)
      ..lineTo(10, size.height - 16)
      ..close();
    canvas.drawPath(fill, Paint()..color = c.accentIron.withValues(alpha: .10));
    canvas.drawPath(
      path,
      Paint()
        ..color = c.accentIron
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.c != c;
}
