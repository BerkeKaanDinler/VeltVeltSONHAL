// VELT — SetRow widget spec
// The most-used component. Every workout session shows 20-60 SetRows.
// Must be pixel-perfect, fast, and thumb-friendly.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../services/prefs_service.dart';

enum SetType { normal, warmup, drop, failure }
enum SetState { pending, active, completed }

class SetRowData {
  const SetRowData({
    required this.index,
    required this.type,
    this.weight = 0.0,
    this.reps   = 0,
    this.prev,
    this.isDone = false,
  });

  final int      index;
  final SetType  type;
  final double   weight;
  final int      reps;
  final ({double weight, int reps})? prev;
  final bool     isDone;

  Map<String, dynamic> toJson() => {
    'index':  index,
    'type':   type.index,
    'weight': weight,
    'reps':   reps,
    'isDone': isDone,
    if (prev != null) 'prev': {'weight': prev!.weight, 'reps': prev!.reps},
  };

  factory SetRowData.fromJson(Map<String, dynamic> j) => SetRowData(
    index:  j['index']  as int,
    type:   SetType.values[j['type'] as int],
    weight: (j['weight'] as num).toDouble(),
    reps:   j['reps']   as int,
    isDone: j['isDone'] as bool? ?? false,
    prev: j['prev'] == null ? null : (
      weight: (j['prev']['weight'] as num).toDouble(),
      reps:   j['prev']['reps']   as int,
    ),
  );
}

class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.data,
    required this.isActive,
    required this.onComplete,
    this.onWeightChanged,
    this.onRepsChanged,
  });

  final SetRowData data;
  final bool       isActive;
  final void Function(bool done) onComplete;
  final void Function(double weight)? onWeightChanged;
  final void Function(int reps)?    onRepsChanged;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late double _weight;
  late int    _reps;
  late bool   _done;

  @override
  void initState() {
    super.initState();
    _weight = widget.data.weight;
    _reps   = widget.data.reps;
    _done   = widget.data.isDone;
  }

  void _toggle() {
    final newDone = !_done;
    // Stronger feedback when completing a set, lighter when unchecking
    if (newDone) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() => _done = newDone);
    widget.onComplete(newDone);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    final badgeColor = switch (widget.data.type) {
      SetType.warmup  => c.accentIron,
      SetType.drop    => c.textTertiary,
      SetType.failure => c.errorRose,
      SetType.normal  => null,
    };

    final badgeBg = switch (widget.data.type) {
      SetType.warmup  => const Color(0xFF1A0F00),
      SetType.drop    => null,
      SetType.failure => null,
      SetType.normal  => null,
    };

    return Opacity(
      opacity: _done ? 0.55 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isActive ? c.surfaceElevated : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: widget.isActive ? c.accentIron : Colors.transparent,
              width: 3,
            ),
            bottom: BorderSide(color: c.divider.withValues(alpha: 0.27), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        child: Row(
          children: [
            // Set number / badge
            SizedBox(
              width: 32,
              child: Center(
                child: badgeColor != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color:        badgeBg ?? badgeColor.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.data.type.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      )
                    : Text(
                        '${widget.data.index + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: c.textTertiary,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            // Previous
            Expanded(
              child: Text(
                widget.data.prev != null
                    ? '${widget.data.prev!.weight}×${widget.data.prev!.reps} ${PrefsService.unit}'
                    : '—',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: c.textTertiary),
              ),
            ),

            // Weight stepper
            Expanded(child: _Stepper(
              value:     _weight,
              step:      PrefsService.unit != 'kg' ? 5.0 : 2.5,
              textColor: _done ? c.successLime : c.textPrimary,
              bgColor:   c.surfaceHigh,
              onChanged: (v) {
                setState(() => _weight = v);
                widget.onWeightChanged?.call(v);
              },
            )),

            // Reps stepper
            Expanded(child: _Stepper(
              value:     _reps.toDouble(),
              step:      1,
              textColor: _done ? c.successLime : c.textPrimary,
              bgColor:   c.surfaceHigh,
              onChanged: (v) {
                setState(() => _reps = v.toInt());
                widget.onRepsChanged?.call(v.toInt());
              },
            )),

            // Checkbox
            GestureDetector(
              onTap: _toggle,
              child: SizedBox(
                width: AppTouchTarget.setCheckbox,
                height: AppTouchTarget.setCheckbox,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:  _done ? c.successLime : Colors.transparent,
                      border: Border.all(
                        color: _done ? Colors.transparent : c.divider,
                        width: 2,
                      ),
                    ),
                    child: _done
                        ? Icon(Icons.check, size: 14, color: c.ink)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.step,
    required this.textColor,
    required this.bgColor,
    required this.onChanged,
  });

  final double   value;
  final double   step;
  final Color    textColor;
  final Color    bgColor;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: '−',
          size: 32,
          bg: bgColor,
          onTap: () => onChanged((value - step).clamp(0, double.infinity)),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value % 1 == 0 ? '${value.toInt()}' : '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _StepButton(
          icon: '+',
          size: 32,
          bg: bgColor,
          onTap: () => onChanged(value + step),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.bg,
    required this.onTap,
  });
  final String icon;
  final double size;
  final Color  bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(icon,
            style: TextStyle(fontSize: 18, color: c.textSecondary)),
        ),
      ),
    );
  }
}
