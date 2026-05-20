// VELT — Plate Calculator
// Shows what plates to load on each side of an Olympic barbell to hit
// a target weight. Supports kg and lb plate sets. Triggered from a long
// press on the weight cell in SetRow, or from a quick-action chip.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/prefs_service.dart';

/// Standard plate weights in kilograms (per plate, not per side).
const _kgPlates = <double>[25, 20, 15, 10, 5, 2.5, 1.25];

/// Standard plate weights in pounds.
const _lbPlates = <double>[45, 35, 25, 10, 5, 2.5];

const double _kgBar = 20.0;
const double _lbBar = 45.0;

/// Decompose [targetWeight] (TOTAL on the bar) into one side's plate list.
/// Greedy descending — matches what every commercial gym actually loads.
List<double> computePlatesPerSide({
  required double targetWeight,
  required bool useLb,
  double? barWeight,
}) {
  final bar = barWeight ?? (useLb ? _lbBar : _kgBar);
  final remainingTotal = targetWeight - bar;
  if (remainingTotal <= 0) return const [];

  final perSide = remainingTotal / 2;
  final available = useLb ? _lbPlates : _kgPlates;

  final result = <double>[];
  var left = perSide;
  for (final p in available) {
    while (left + 0.001 >= p) {
      result.add(p);
      left -= p;
    }
  }
  return result;
}

/// Show a modal bottom sheet that decomposes [targetWeight] into plates.
Future<void> showPlateCalculator(
  BuildContext context, {
  required double targetWeight,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlateCalculatorSheet(initialWeight: targetWeight),
  );
}

class _PlateCalculatorSheet extends StatefulWidget {
  const _PlateCalculatorSheet({required this.initialWeight});
  final double initialWeight;

  @override
  State<_PlateCalculatorSheet> createState() => _PlateCalculatorSheetState();
}

class _PlateCalculatorSheetState extends State<_PlateCalculatorSheet> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight > 0 ? widget.initialWeight : 60;
  }

  void _adjust(double delta) {
    HapticFeedback.selectionClick();
    setState(() => _weight = (_weight + delta).clamp(0.0, 500.0));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final useLb = PrefsService.unit != 'kg';
    final bar = useLb ? _lbBar : _kgBar;
    final plates = computePlatesPerSide(
      targetWeight: _weight,
      useLb: useLb,
    );
    final unit = useLb ? 'lb' : 'kg';
    final loadable = bar + plates.fold<double>(0, (a, p) => a + p) * 2;
    final mismatch = (loadable - _weight).abs() > 0.01;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        border: Border.all(color: c.divider),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, 12, AppSpacing.screenH, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Plate Calculator',
                  style: AppTypography.titleL(c.textPrimary)
                      .copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                'Per side, ${bar.toStringAsFixed(0)} $unit bar',
                style: AppTypography.bodyS(c.textTertiary)
                    .copyWith(fontSize: 12),
              ),
              const SizedBox(height: 18),

              // Big weight number + steppers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepBtn(
                      label: '−${useLb ? '5' : '2.5'}',
                      onTap: () => _adjust(useLb ? -5 : -2.5),
                      c: c),
                  const SizedBox(width: 14),
                  Text(
                    '${_weight.toStringAsFixed(useLb || _weight % 1 == 0 ? 0 : 1)} $unit',
                    style: AppTypography.displayL(c.textPrimary).copyWith(
                      fontSize: 42,
                      letterSpacing: -1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _StepBtn(
                      label: '+${useLb ? '5' : '2.5'}',
                      onTap: () => _adjust(useLb ? 5 : 2.5),
                      c: c),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepBtn(
                      label: '−${useLb ? '10' : '5'}',
                      onTap: () => _adjust(useLb ? -10 : -5),
                      c: c, small: true),
                  const SizedBox(width: 8),
                  _StepBtn(
                      label: '+${useLb ? '10' : '5'}',
                      onTap: () => _adjust(useLb ? 10 : 5),
                      c: c, small: true),
                ],
              ),

              const SizedBox(height: 22),
              _BarVisualization(plates: plates, useLb: useLb, c: c),
              const SizedBox(height: 16),

              if (plates.isEmpty)
                Text('Just the bar',
                    style: AppTypography.bodyM(c.textTertiary)
                        .copyWith(fontSize: 13))
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final p in plates)
                      _PlateChip(
                        weight: p,
                        unit: unit,
                        color: _colorForPlate(p, useLb),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              if (mismatch)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.warningAmber.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: c.warningAmber.withValues(alpha: .4)),
                  ),
                  child: Text(
                    'Closest: ${loadable.toStringAsFixed(loadable % 1 == 0 ? 0 : 1)} $unit',
                    style: AppTypography.bodyS(c.warningAmber)
                        .copyWith(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarVisualization extends StatelessWidget {
  const _BarVisualization({
    required this.plates,
    required this.useLb,
    required this.c,
  });
  final List<double> plates;
  final bool useLb;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left collar
          _Collar(c: c),
          // Left plates (largest closest to collar — gym standard)
          for (final p in plates) _Plate(weight: p, useLb: useLb),
          // Bar
          Container(
            width: 80,
            height: 8,
            decoration: BoxDecoration(
              color: c.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Right plates (mirrored)
          for (final p in plates.reversed) _Plate(weight: p, useLb: useLb),
          _Collar(c: c),
        ],
      ),
    );
  }
}

class _Collar extends StatelessWidget {
  const _Collar({required this.c});
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: c.textSecondary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.weight, required this.useLb});
  final double weight;
  final bool useLb;
  @override
  Widget build(BuildContext context) {
    // Scale plate size by weight class
    final color = _colorForPlate(weight, useLb);
    final maxRef = useLb ? 45.0 : 25.0;
    final h = 30 + (weight / maxRef) * 40;
    final w = 8 + (weight / maxRef) * 6;
    return Container(
      width: w,
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.black.withValues(alpha: .25)),
      ),
    );
  }
}

class _PlateChip extends StatelessWidget {
  const _PlateChip({
    required this.weight,
    required this.unit,
    required this.color,
  });
  final double weight;
  final String unit;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 2)} $unit',
        style: TextStyle(
          fontFamily: 'Inter',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Color _colorForPlate(double w, bool useLb) {
  if (useLb) {
    return switch (w) {
      45 => const Color(0xFF1E3A8A),     // blue
      35 => const Color(0xFFEAB308),     // yellow
      25 => const Color(0xFF16A34A),     // green
      10 => const Color(0xFFFFFFFF),
      5  => const Color(0xFFD97706),     // amber
      _  => const Color(0xFFEF4444),     // red (2.5)
    };
  }
  return switch (w) {
    25 => const Color(0xFFEF4444),       // red
    20 => const Color(0xFF1E3A8A),       // blue
    15 => const Color(0xFFEAB308),       // yellow
    10 => const Color(0xFF16A34A),       // green
    5  => const Color(0xFFFFFFFF),       // white
    2.5 => const Color(0xFFD97706),      // amber
    _  => const Color(0xFFA855F7),       // purple (1.25)
  };
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.label,
    required this.onTap,
    required this.c,
    this.small = false,
  });
  final String label;
  final VoidCallback onTap;
  final AppColors c;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: small ? 60 : 56,
        height: small ? 32 : 48,
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(small ? 8 : 12),
          border: Border.all(color: c.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: c.textPrimary,
            fontSize: small ? 11 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
