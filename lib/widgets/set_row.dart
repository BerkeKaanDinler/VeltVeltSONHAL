import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
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
    this.rpe,
  });

  final int      index;
  final SetType  type;
  final double   weight;
  final int      reps;
  final ({double weight, int reps})? prev;
  final bool     isDone;
  /// RPE (Rate of Perceived Exertion), 6.0–10.0. Optional.
  final double?  rpe;

  Map<String, dynamic> toJson() => {
    'index':  index,
    'type':   type.index,
    'weight': weight,
    'reps':   reps,
    'isDone': isDone,
    if (prev != null) 'prev': {'weight': prev!.weight, 'reps': prev!.reps},
    if (rpe != null) 'rpe': rpe,
  };

  factory SetRowData.fromJson(Map<String, dynamic> j) => SetRowData(
    index:  j['index']  as int,
    type:   SetType.values[j['type'] as int],
    weight: (j['weight'] as num).toDouble(),
    reps:   j['reps']   as int,
    isDone: j['isDone'] as bool? ?? false,
    rpe:    (j['rpe'] as num?)?.toDouble(),
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
    this.onTypeChanged,
    this.onRpeChanged,
    this.prWeight,
  });

  final SetRowData data;
  final bool       isActive;
  final void Function(bool done) onComplete;
  final void Function(double weight)? onWeightChanged;
  final void Function(int reps)?    onRepsChanged;
  final void Function(SetType type)? onTypeChanged;
  final void Function(double? rpe)? onRpeChanged;
  final double? prWeight;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow>
    with SingleTickerProviderStateMixin {
  late double _weight;
  late int    _reps;
  late bool   _done;

  late AnimationController _checkAnim;
  late Animation<double>   _checkScale;
  late Animation<double>   _rowFlash;

  @override
  void initState() {
    super.initState();
    _weight = widget.data.weight;
    _reps   = widget.data.reps;
    _done   = widget.data.isDone;

    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    // Elastic spring for the checkmark icon
    _checkScale = CurvedAnimation(
      parent: _checkAnim,
      curve: Curves.elasticOut,
    );
    // Quick flash for the row background (0→1→0 in first 30% of animation)
    _rowFlash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _checkAnim, curve: Curves.easeOut));

    if (_done) _checkAnim.value = 1.0;
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  void _usePrev() {
    if (widget.data.prev == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _weight = widget.data.prev!.weight;
      _reps   = widget.data.prev!.reps;
    });
    widget.onWeightChanged?.call(_weight);
    widget.onRepsChanged?.call(_reps);
  }

  void _showTypeMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetTypeSheet(
        currentType: widget.data.type,
        onSelected: (type) {
          Navigator.pop(context);
          widget.onTypeChanged?.call(type);
        },
      ),
    );
  }

  void _toggle() {
    final newDone = !_done;
    if (newDone) {
      HapticFeedback.mediumImpact();
      _checkAnim.forward(from: 0.0);
    } else {
      HapticFeedback.selectionClick();
      _checkAnim.reverse();
    }
    setState(() => _done = newDone);
    widget.onComplete(newDone);
  }

  double? _estimate1RM() {
    if (_weight <= 0 || _reps <= 1) return null;
    return _weight * (1 + _reps / 30.0);
  }

  String _format1RM(double rm) {
    if (PrefsService.unit == 'kg') {
      final rounded = (rm * 2).round() / 2.0;
      return rounded % 1 == 0 ? '${rounded.toInt()} kg' : '${rounded.toStringAsFixed(1)} kg';
    } else {
      return '${rm.round()} lb';
    }
  }

  void _showRpeSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final c = Theme.of(context).extension<AppColors>()!;
    const options = [6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0];
    final descs = <double, String>{
      6.0: 'Easy — 4 reps left in tank',
      7.0: 'Moderate — 3 reps left',
      8.0: 'Hard — 2 reps left',
      8.5: 'Very hard — 1.5 reps left',
      9.0: 'Very hard — 1 rep left',
      9.5: 'Near max — half rep left',
      10.0: 'Max effort — no reps left',
    };
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg)),
        ),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md,
            MediaQuery.of(context).padding.bottom + AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Text('Rate of Perceived Exertion',
                style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
              widget.data.rpe == null
                  ? 'Tap a value — how hard was this set?'
                  : descs[widget.data.rpe!] ??
                      descs.entries
                          .lastWhere((e) => e.key <= widget.data.rpe!,
                              orElse: () => descs.entries.first)
                          .value,
              textAlign: TextAlign.center,
              style: AppTypography.bodyS(c.textTertiary)
                  .copyWith(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final v in options)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onRpeChanged?.call(v);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 54,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.data.rpe == v
                            ? c.warningAmber.withValues(alpha: .2)
                            : c.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.data.rpe == v
                              ? c.warningAmber
                              : c.divider,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: widget.data.rpe == v
                              ? c.warningAmber
                              : c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.data.rpe != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onRpeChanged?.call(null);
                  Navigator.pop(context);
                },
                child: Text('Clear RPE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.errorRose,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPlateCalc(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlateCalcSheet(targetWeight: _weight),
    );
  }

  Widget _buildInfoRow(BuildContext context, AppColors c) {
    final isKg = PrefsService.unit == 'kg';
    final smallStep = isKg ? 2.5 : 5.0;
    final bigStep = isKg ? 5.0 : 10.0;
    final rm = _estimate1RM();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const SizedBox(width: 36),
          // Quick adjust chips for WEIGHT
          _QuickChip(
            label: '−${_fmtStep(smallStep)}',
            onTap: () {
              HapticFeedback.selectionClick();
              final nv = (_weight - smallStep).clamp(0.0, 9999.0);
              setState(() => _weight = nv);
              widget.onWeightChanged?.call(nv);
            },
            c: c,
          ),
          const SizedBox(width: 4),
          _QuickChip(
            label: '+${_fmtStep(smallStep)}',
            accent: true,
            onTap: () {
              HapticFeedback.selectionClick();
              final nv = _weight + smallStep;
              setState(() => _weight = nv);
              widget.onWeightChanged?.call(nv);
            },
            c: c,
          ),
          const SizedBox(width: 4),
          _QuickChip(
            label: '+${_fmtStep(bigStep)}',
            accent: true,
            onTap: () {
              HapticFeedback.selectionClick();
              final nv = _weight + bigStep;
              setState(() => _weight = nv);
              widget.onWeightChanged?.call(nv);
            },
            c: c,
          ),
          const Spacer(),
          if (PrefsService.showRpe) ...[
            GestureDetector(
              onTap: () => _showRpeSheet(context),
              child: Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: widget.data.rpe != null
                      ? c.warningAmber.withValues(alpha: .15)
                      : c.surfaceHigh,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.data.rpe != null
                        ? c.warningAmber.withValues(alpha: .4)
                        : c.divider,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.data.rpe != null
                      ? 'RPE ${widget.data.rpe!.toStringAsFixed(widget.data.rpe! % 1 == 0 ? 0 : 1)}'
                      : 'RPE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: widget.data.rpe != null
                        ? c.warningAmber
                        : c.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (rm != null) ...[
            Text(
              '1RM ${_format1RM(rm)}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: c.textTertiary,
                letterSpacing: 0.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => _showPlateCalc(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_outlined,
                      size: 12, color: c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Plates',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  static String _fmtStep(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    final badgeColor = switch (widget.data.type) {
      SetType.warmup  => c.accentIron,
      SetType.drop    => c.textTertiary,
      SetType.failure => c.errorRose,
      SetType.normal  => null,
    };

    final pr = widget.prWeight;
    final overPR = !_done &&
        pr != null && pr > 0 &&
        _weight > pr * 1.2;

    return AnimatedBuilder(
      animation: _checkAnim,
      builder: (context, child) {
        // Flash overlay alpha peaks at start of animation
        final flashAlpha = _done ? _rowFlash.value * 0.12 : 0.0;
        return Opacity(
          opacity: _done ? 0.85 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: _done
                ? c.successLime.withValues(
                    alpha: 0.04 + flashAlpha)
                : overPR
                    ? c.errorRose.withValues(alpha: 0.04)
                    : Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: c.divider.withValues(alpha: 0.27), width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 10, AppSpacing.md, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grid: 32px | 1fr | 80px | 80px | 44px
              Row(
                children: [
                  // Set badge — 36px  long-press → type menu
                  GestureDetector(
                    onLongPress: () => _showTypeMenu(context),
                    child: SizedBox(
                    width: 36,
                    height: 48,
                    child: Center(
                      child: badgeColor != null
                          ? Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        badgeColor.withValues(alpha: .45)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.data.type.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12, fontWeight: FontWeight.w900,
                                  color: badgeColor,
                                ),
                              ),
                            )
                          : Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _done
                                    ? c.successLime.withValues(alpha: .14)
                                    : c.surfaceHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.data.index + 1}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14, fontWeight: FontWeight.w900,
                                  color: _done
                                      ? c.successLime
                                      : c.textPrimary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  ),

                  // Previous — flex 1  tap → copy to steppers
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.data.prev != null ? _usePrev : null,
                      child: SizedBox(
                        height: 48,
                        child: widget.data.prev != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    () {
                                      final pw = widget.data.prev!.weight;
                                      final ws = pw % 1 == 0
                                          ? '${pw.toInt()}'
                                          : pw.toStringAsFixed(1);
                                      return '$ws ${PrefsService.unit} × ${widget.data.prev!.reps}';
                                    }(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: c.textPrimary,
                                      letterSpacing: -0.1,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'tap to copy',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: c.accentIron
                                          .withValues(alpha: .8),
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text('— first set —',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: c.textTertiary,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                      ),
                    ),
                  ),

                  // Weight stepper — 92px
                  SizedBox(
                    width: 92,
                    child: _Stepper(
                      value:     _weight,
                      step:      PrefsService.unit != 'kg' ? 5.0 : 2.5,
                      unit:      PrefsService.unit,
                      textColor: _done
                          ? c.successLime
                          : overPR
                              ? c.errorRose
                              : c.textPrimary,
                      borderColor: overPR ? c.errorRose.withValues(alpha: 0.5) : c.divider,
                      surfaceColor: overPR
                          ? c.errorRose.withValues(alpha: 0.08)
                          : c.surface,
                      onChanged: (v) {
                        setState(() => _weight = v);
                        widget.onWeightChanged?.call(v);
                      },
                    ),
                  ),

                  // Reps stepper — 92px
                  SizedBox(
                    width: 92,
                    child: _Stepper(
                      value:     _reps.toDouble(),
                      step:      1,
                      unit:      '',
                      textColor: _done ? c.successLime : c.textPrimary,
                      borderColor: c.divider,
                      surfaceColor: c.surface,
                      onChanged: (v) {
                        setState(() => _reps = v.toInt());
                        widget.onRepsChanged?.call(v.toInt());
                      },
                    ),
                  ),

                  // Check button — spring bounce animation
                  Semantics(
                    label: _done
                        ? 'Mark set ${widget.data.index + 1} as incomplete'
                        : 'Mark set ${widget.data.index + 1} as complete: '
                            '${_weight} ${PrefsService.unit} times $_reps reps',
                    button: true,
                    selected: _done,
                    child: GestureDetector(
                    onTap: _toggle,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _done ? c.successLime : Colors.transparent,
                            border: _done
                                ? null
                                : Border.all(color: c.divider, width: 2),
                            boxShadow: _done
                                ? [
                                    BoxShadow(
                                      color: c.successLime
                                          .withValues(alpha: .45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _done
                              ? ScaleTransition(
                                  scale: _checkScale,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),

              // Info row: 1RM (left) + plate calc (right) — shown when weight > 0
              if (_weight > 0) _buildInfoRow(context, c),
            ],
          ),
        ),
      ),
    );
  },
  );
  }
}

// Stepper: height 44, 0.5px border, rxs corners, ±32px buttons
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.step,
    required this.unit,
    required this.textColor,
    required this.borderColor,
    required this.surfaceColor,
    required this.onChanged,
  });

  final double   value;
  final double   step;
  final String   unit;
  final Color    textColor;
  final Color    borderColor;
  final Color    surfaceColor;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged((value - step).clamp(0, double.infinity)),
            child: SizedBox(
              width: 32, height: 48,
              child: Center(
                child: Icon(Icons.remove_rounded,
                    size: 18, color: c.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: unit.isEmpty
                ? Text(
                    value % 1 == 0 ? '${value.toInt()}' : '$value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19, fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                : RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: value % 1 == 0
                            ? '${value.toInt()}'
                            : value.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 19, fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.3,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ]),
                  ),
          ),
          GestureDetector(
            onTap: () => onChanged(value + step),
            child: SizedBox(
              width: 32, height: 48,
              child: Center(
                child: Icon(Icons.add_rounded,
                    size: 18, color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Set Type Bottom Sheet ─────────────────────────────────────
class _SetTypeSheet extends StatelessWidget {
  const _SetTypeSheet({
    required this.currentType,
    required this.onSelected,
  });
  final SetType currentType;
  final void Function(SetType) onSelected;

  static const _items = [
    (type: SetType.normal,  label: 'Normal',    icon: Icons.radio_button_unchecked_rounded, desc: 'Standard working set'),
    (type: SetType.warmup,  label: 'Warm-up',   icon: Icons.whatshot_rounded,               desc: 'Light weight, higher reps'),
    (type: SetType.drop,    label: 'Drop Set',  icon: Icons.arrow_downward_rounded,         desc: 'Reduce weight, no rest'),
    (type: SetType.failure, label: 'To Failure',icon: Icons.local_fire_department_rounded,  desc: 'Push to maximum'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Text(
            'Set Type',
            style: AppTypography.titleM(c.textPrimary).copyWith(
              fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
          const SizedBox(height: 16),
          ..._items.map((item) {
            final isActive = item.type == currentType;
            return GestureDetector(
              onTap: () => onSelected(item.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? c.accentIron.withValues(alpha: 0.08)
                      : c.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? c.accentIron.withValues(alpha: 0.4)
                        : c.divider.withValues(alpha: 0.5),
                    width: isActive ? 1.0 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(item.icon,
                      size: 20,
                      color: isActive ? c.accentIron : c.textSecondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: AppTypography.titleS(
                              isActive ? c.accentIron : c.textPrimary,
                            ).copyWith(
                              fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.desc,
                            style: AppTypography.caption(c.textTertiary).copyWith(
                              fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Icon(Icons.check_circle_rounded,
                        size: 18, color: c.accentIron),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Plate Calculator Bottom Sheet ─────────────────────────────
class _PlateCalcSheet extends StatefulWidget {
  const _PlateCalcSheet({required this.targetWeight});
  final double targetWeight;

  @override
  State<_PlateCalcSheet> createState() => _PlateCalcSheetState();
}

class _PlateCalcSheetState extends State<_PlateCalcSheet> {
  static const _kgBars   = [20.0, 15.0];
  static const _lbBars   = [45.0, 35.0];
  static const _kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
  static const _lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  late double _bar;
  late final bool _isLbs;

  @override
  void initState() {
    super.initState();
    _isLbs = PrefsService.unit != 'kg';
    _bar = _isLbs ? 45.0 : 20.0;
  }

  List<({double plate, int count})> _calcPlates() {
    final available = _isLbs ? _lbPlates : _kgPlates;
    double remaining = (widget.targetWeight - _bar) / 2.0;
    final result = <({double plate, int count})>[];
    if (remaining <= 0) return result;
    for (final p in available) {
      if (remaining < 0.01) break;
      final count = (remaining / p).floor();
      if (count > 0) {
        result.add((plate: p, count: count));
        remaining -= count * p;
      }
    }
    return result;
  }

  double _loadedWeight(List<({double plate, int count})> plates) {
    final perSide = plates.fold(0.0, (s, e) => s + e.plate * e.count);
    return _bar + perSide * 2;
  }

  String _fmt(double v) {
    if (v % 1 == 0) return '${v.toInt()}';
    final s = v.toStringAsFixed(2);
    return s.endsWith('0') ? s.substring(0, s.length - 1) : s;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final unit = PrefsService.unit;
    final bars = _isLbs ? _lbBars : _kgBars;
    final plates = _calcPlates();
    final loaded = _loadedWeight(plates);
    final hasRounding = (loaded - widget.targetWeight).abs() > 0.05;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          // Title + target weight
          Row(
            children: [
              Expanded(
                child: Text(
                  'Plate Calculator',
                  style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                ),
              ),
              Text(
                '${_fmt(widget.targetWeight)} $unit',
                style: AppTypography.bodyM(c.textSecondary).copyWith(
                  fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bar selector
          Row(
            children: List.generate(bars.length, (i) {
              final b = bars[i];
              final isSelected = b == _bar;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _bar = b),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < bars.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.accentIron.withValues(alpha: 0.08)
                          : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? c.accentIron.withValues(alpha: 0.4)
                            : c.divider.withValues(alpha: 0.5),
                        width: isSelected ? 1.0 : 0.5,
                      ),
                    ),
                    child: Text(
                      '${_fmt(b)} $unit bar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: isSelected ? c.accentIron : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Plate breakdown or Bar only state
          if (plates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.fitness_center_rounded, size: 28, color: c.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'Bar only',
                    style: AppTypography.bodyM(c.textSecondary).copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (widget.targetWeight < _bar) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Target is below bar weight',
                      style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            )
          else ...[
            // Per-side header + rounding notice
            Row(
              children: [
                Text(
                  'Per side',
                  style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 11),
                ),
                if (hasRounding) ...[
                  const Spacer(),
                  Text(
                    'Loads ${_fmt(loaded)} $unit',
                    style: AppTypography.caption(c.warningAmber).copyWith(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            ...plates.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: c.divider.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Text(
                      '${_fmt(entry.plate)} $unit',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '× ${entry.count}',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Quick-adjust chip ─────────────────────────────────────────
class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onTap,
    required this.c,
    this.accent = false,
  });
  final String label;
  final VoidCallback onTap;
  final AppColors c;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: accent
              ? c.accentIron.withValues(alpha: .12)
              : c.surfaceHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: accent
                  ? c.accentIron.withValues(alpha: .35)
                  : c.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: accent ? c.accentIron : c.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
