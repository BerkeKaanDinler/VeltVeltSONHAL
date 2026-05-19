/// VELT — SetRow widget (the most-used component in the app)
/// 5-column row in active workout: [#] [prev] [weight] [reps] [check]

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum SetType { normal, warmup, drop, failure }

class SetRowData {
  const SetRowData({
    required this.label,        // "W", "1", "2", "D"
    required this.type,
    required this.weight,
    required this.reps,
    this.prev,                  // {w, r} or null
    this.done = false,
  });

  final String      label;
  final SetType     type;
  final double      weight;
  final int         reps;
  final ({double w, int r})? prev;
  final bool        done;
}

class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.data,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggle,
  });

  final SetRowData                 data;
  final ValueChanged<double>       onWeightChanged;
  final ValueChanged<int>          onRepsChanged;
  final ValueChanged<bool>         onToggle;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late double _weight = widget.data.weight;
  late int    _reps   = widget.data.reps;
  late bool   _done   = widget.data.done;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _done = !_done);
    widget.onToggle(_done);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final isNumeric = RegExp(r'^\d+$').hasMatch(widget.data.label);

    Color? badgeColor = switch (widget.data.type) {
      SetType.warmup  => c.accentIron,
      SetType.drop    => c.textTertiary,
      SetType.failure => c.errorRose,
      SetType.normal  => null,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _done ? c.successLime.withOpacity(0.04) : Colors.transparent,
        border: Border(top: BorderSide(
          color: c.divider.withOpacity(0.5), width: 0.5,
        )),
      ),
      child: Opacity(
        opacity: _done ? 0.85 : 1.0,
        child: Row(
          children: [
            // ── Set badge / number (32pt) ─────────────────
            SizedBox(width: 32, child: Center(
              child: isNumeric
                ? Text(widget.data.label, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _done ? c.successLime : c.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(widget.data.label, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      color: badgeColor, letterSpacing: 0.5,
                    )),
                  ),
            )),
            const SizedBox(width: 6),

            // ── Previous (flex) ────────────────────────────
            Expanded(child: Text.rich(
              widget.data.prev != null
                ? TextSpan(children: [
                    TextSpan(text: 'PREV: ',
                      style: TextStyle(color: c.textTertiary, fontSize: 11)),
                    TextSpan(text: '${widget.data.prev!.w}kg × ${widget.data.prev!.r}',
                      style: AppTypography.bodyXS(c.textSecondary)
                        .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  ])
                : TextSpan(text: '—',
                    style: TextStyle(color: c.textTertiary, fontSize: 11)),
            )),
            const SizedBox(width: 6),

            // ── Weight stepper (80pt) ──────────────────────
            SizedBox(width: 80, child: _CompactStepper(
              value: _weight, step: 2.5, unit: 'kg', done: _done,
              onChanged: (v) {
                setState(() => _weight = v);
                widget.onWeightChanged(v);
              },
            )),
            const SizedBox(width: 6),

            // ── Reps stepper (80pt) ────────────────────────
            SizedBox(width: 80, child: _CompactStepper(
              value: _reps.toDouble(), step: 1, unit: '', done: _done,
              onChanged: (v) {
                setState(() => _reps = v.toInt());
                widget.onRepsChanged(v.toInt());
              },
            )),
            const SizedBox(width: 6),

            // ── Done checkmark (44pt hit area, 36pt visual) ─
            SizedBox(width: 44, child: Center(
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _done ? c.successLime : Colors.transparent,
                    border: _done ? null
                      : Border.all(color: c.divider, width: 1.5),
                  ),
                  child: _done
                    ? Icon(Icons.check, color: c.surface, size: 18)
                    : null,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// ── Compact stepper used inside SetRow ─────────────────
class _CompactStepper extends StatelessWidget {
  const _CompactStepper({
    required this.value,
    required this.step,
    required this.unit,
    required this.done,
    required this.onChanged,
  });

  final double                  value;
  final double                  step;
  final String                  unit;
  final bool                    done;
  final ValueChanged<double>   onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Row(
        children: [
          _IconBtn(symbol: '−', onTap: () =>
            onChanged((value - step).clamp(0, double.infinity))),
          Expanded(child: Center(child: RichText(text: TextSpan(
            children: [
              TextSpan(text: value % 1 == 0 ? '${value.toInt()}' : value.toStringAsFixed(1),
                style: AppTypography.monoSm(done ? c.successLime : c.textPrimary)
                  .copyWith(fontSize: 13)),
              if (unit.isNotEmpty)
                TextSpan(text: unit, style: TextStyle(
                  fontSize: 9, color: c.textTertiary, fontWeight: FontWeight.w500,
                )),
            ],
          )))),
          _IconBtn(symbol: '+', onTap: () => onChanged(value + step)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({ required this.symbol, required this.onTap });
  final String      symbol;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 22, height: 36,
        child: Center(child: Text(symbol, style: TextStyle(
          color: c.textTertiary, fontWeight: FontWeight.w700, fontSize: 14,
        ))),
      ),
    );
  }
}
