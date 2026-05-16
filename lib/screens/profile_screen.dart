import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';
import '../services/prefs_service.dart';

// ── Theme preview data ─────────────────────────────────────
class _ThemePreview {
  const _ThemePreview({
    required this.key,
    required this.name,
    required this.bg,
    required this.card,
    required this.accent,
  });
  final String key;
  final String name;
  final Color bg;
  final Color card;
  final Color accent;
}

const _themePreviews = [
  _ThemePreview(key:'iron',          name:'Iron Dark',    bg:Color(0xFF0B0F17), card:Color(0xFF1A2030), accent:Color(0xFFD97706)),
  _ThemePreview(key:'warmPaper',     name:'Warm Paper',   bg:Color(0xFFFAF7F2), card:Color(0xFFFFFFFF), accent:Color(0xFFB45309)),
  _ThemePreview(key:'midnightSteel', name:'Midnight',     bg:Color(0xFF0A0A0F), card:Color(0xFF141420), accent:Color(0xFF6366F1)),
  _ThemePreview(key:'forestIron',    name:'Forest',       bg:Color(0xFF0D1A0F), card:Color(0xFF162018), accent:Color(0xFF22C55E)),
  _ThemePreview(key:'bloodOrange',   name:'Blood Orange', bg:Color(0xFF150A00), card:Color(0xFF1E1000), accent:Color(0xFFEA580C)),
  _ThemePreview(key:'espresso',      name:'Espresso',     bg:Color(0xFF1A0F0A), card:Color(0xFF261710), accent:Color(0xFFC2692A)),
  _ThemePreview(key:'arctic',        name:'Arctic',       bg:Color(0xFF0A0F18), card:Color(0xFF111827), accent:Color(0xFF38BDF8)),
  _ThemePreview(key:'obsidian',      name:'Obsidian',     bg:Color(0xFF0C0C0E), card:Color(0xFF161618), accent:Color(0xFFA78BFA)),
  _ThemePreview(key:'military',      name:'Military',     bg:Color(0xFF0F150A), card:Color(0xFF161F0D), accent:Color(0xFF84CC16)),
];

// ══════════════════════════════════════════════════════════
//  PROFILE SCREEN
// ══════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onThemeChange,
    required this.currentThemeKey,
  });

  final void Function(String key) onThemeChange;
  final String currentThemeKey;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _unit;
  late int _restTime;
  late String _goal;
  double? _bodyweightKg;
  double? _heightCm;
  bool _confirmDelete = false;

  List<({DateTime date, double kg})> _bwHistory = [];

  @override
  void initState() {
    super.initState();
    _unit = PrefsService.unit;
    _restTime = PrefsService.restSecs;
    _goal = PrefsService.fitnessGoal;
    _bodyweightKg = PrefsService.bodyweightKg;
    _heightCm = PrefsService.heightCm;
    _loadBwHistory();
  }

  void _loadBwHistory() {
    final raw = PrefsService.bodyweightHistory;
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _bwHistory = list.map((e) {
        final m = e as Map<String, dynamic>;
        return (
          date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
          kg: (m['kg'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {}
  }

  Future<void> _addBwHistoryEntry(double kg) async {
    final now = DateTime.now();
    final entry = (date: now, kg: kg);
    // Keep only latest entry per day
    final today = DateTime(now.year, now.month, now.day);
    final filtered = _bwHistory.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return d != today;
    }).toList();
    filtered.add(entry);
    filtered.sort((a, b) => a.date.compareTo(b.date));
    // Keep last 90 entries
    if (filtered.length > 90) filtered.removeRange(0, filtered.length - 90);
    setState(() => _bwHistory = filtered);
    final json = jsonEncode(filtered.map((e) => {
      'date': e.date.millisecondsSinceEpoch,
      'kg': e.kg,
    }).toList());
    await PrefsService.saveBodyweightHistory(json);
  }

  void _editBodyweight() {
    _showNumberSheet(
      context,
      title: 'Bodyweight',
      unit: _unit == 'kg' ? 'kg' : 'lb',
      initialValue: _bodyweightKg == null
          ? null
          : (_unit != 'kg' ? _bodyweightKg! * 2.20462 : _bodyweightKg!),
      onSave: (v) {
        final kg = _unit != 'kg' ? v / 2.20462 : v;
        setState(() => _bodyweightKg = kg);
        PrefsService.setBodyweightKg(kg);
        _addBwHistoryEntry(kg);
      },
    );
  }

  void _editHeight() {
    _showNumberSheet(
      context,
      title: 'Height',
      unit: _unit == 'kg' ? 'cm' : 'ft',
      initialValue: _heightCm == null
          ? null
          : (_unit != 'kg' ? _heightCm! / 30.48 : _heightCm!),
      onSave: (v) {
        final cm = _unit != 'kg' ? v * 30.48 : v;
        setState(() => _heightCm = cm);
        PrefsService.setHeightCm(cm);
      },
    );
  }

  void _showNumberSheet(
    BuildContext ctx, {
    required String title,
    required String unit,
    double? initialValue,
    required void Function(double) onSave,
  }) {
    final controller = TextEditingController(
      text: initialValue == null
          ? ''
          : initialValue.toStringAsFixed(1).replaceAll('.0', ''),
    );
    final c = Theme.of(ctx).extension<AppColors>()!;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleM(c.textPrimary).copyWith(
                  fontSize: 18, letterSpacing: -0.2),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: AppTypography.displayM(c.textPrimary).copyWith(
                  fontSize: 32, letterSpacing: -0.5),
                decoration: InputDecoration(
                  suffixText: unit,
                  suffixStyle: AppTypography.bodyM(c.textTertiary).copyWith(
                    fontSize: 18),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: c.accentIron, width: 2)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: c.accentIron, width: 2)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: c.divider)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Save',
                  onPressed: () {
                    final val = double.tryParse(controller.text);
                    if (val != null && val > 0) {
                      onSave(val);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final currentPreview = _themePreviews.firstWhere(
      (t) => t.key == widget.currentThemeKey,
      orElse: () => _themePreviews.first,
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.md),
                child: Text(
                  'Profile',
                  style: AppTypography.displayL(c.textPrimary).copyWith(
                    fontSize: 34, letterSpacing: -1),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Pro Banner
                  _ProBanner(c: c),
                  const SizedBox(height: 20),

                  // Your Stats
                  _SectionTitle(title: 'Your Stats', c: c),
                  _SectionBlock(c: c, children: [
                    _SettingRow(
                      label: 'Bodyweight',
                      c: c,
                      value: _bodyweightKg == null
                          ? 'Not set'
                          : _unit != 'kg'
                              ? '${(_bodyweightKg! * 2.20462).toStringAsFixed(1)} lb'
                              : '${_bodyweightKg!.toStringAsFixed(1)} kg',
                      onTap: _editBodyweight,
                    ),
                    _SettingRow(
                      label: 'Height',
                      c: c,
                      value: _heightCm == null
                          ? 'Not set'
                          : _unit != 'kg'
                              ? '${(_heightCm! / 30.48).toStringAsFixed(1)} ft'
                              : '${_heightCm!.toStringAsFixed(0)} cm',
                      onTap: _editHeight,
                    ),
                    _SettingRow(
                      label: 'Goal',
                      isLast: true,
                      c: c,
                      rightWidget: _GoalPicker(
                        selected: _goal,
                        onSelect: (g) {
                          setState(() => _goal = g);
                          PrefsService.setFitnessGoal(g);
                        },
                        c: c,
                      ),
                    ),
                  ]),

                  // Bodyweight history chart
                  if (_bwHistory.length >= 2) ...[
                    const SizedBox(height: 12),
                    _BwHistoryChart(
                      history: _bwHistory,
                      isLbs: _unit != 'kg',
                      c: c,
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Preferences
                  _SectionTitle(title: 'Preferences', c: c),
                  _SectionBlock(c: c, children: [
                    _SettingRow(
                      label: 'Weight Unit',
                      c: c,
                      rightWidget: _UnitSegment(
                        selected: _unit,
                        onSelect: (u) {
                          setState(() => _unit = u);
                          PrefsService.setUnit(u);
                        },
                        c: c,
                      ),
                    ),
                    _SettingRow(
                      label: 'Default Rest Timer',
                      isLast: true,
                      c: c,
                      rightWidget: _RestStepper(
                        value: _restTime,
                        onDecrement: () {
                          setState(() => _restTime = (_restTime - 15).clamp(30, 300));
                          PrefsService.setRestSecs(_restTime);
                        },
                        onIncrement: () {
                          setState(() => _restTime = (_restTime + 15).clamp(30, 300));
                          PrefsService.setRestSecs(_restTime);
                        },
                        c: c,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Appearance
                  _SectionTitle(title: 'Appearance', c: c),
                  _SectionBlock(c: c, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, AppSpacing.sm, 20, AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: AppTypography.bodyM(c.textPrimary).copyWith(
                              fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _themePreviews.map((preview) =>
                                    _ThemeCard(
                                      preview: preview,
                                      active: widget.currentThemeKey == preview.key,
                                      onSelect: widget.onThemeChange,
                                    ),
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            currentPreview.name,
                            style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Data
                  _SectionTitle(title: 'Data', c: c),
                  _SectionBlock(c: c, children: [
                    _SettingRow(label: 'Export as CSV',  c: c, onTap: () {}),
                    _SettingRow(label: 'Export as JSON', c: c, onTap: () {}),
                    _SettingRow(
                      label: 'iCloud Backup',
                      sub: 'Encrypted end-to-end',
                      isLast: true,
                      c: c,
                      rightWidget: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.accentIron.withValues(alpha: 0.094),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'PRO',
                              style: AppTypography.caption(c.accentIron).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(Icons.lock_outline,
                            size: 14, color: c.textTertiary),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // About
                  _SectionTitle(title: 'About', c: c),
                  _SectionBlock(c: c, children: [
                    _SettingRow(label: 'Version', value: '1.0.0 (build 42)', c: c),
                    _SettingRow(label: 'Restore Purchases', c: c, onTap: () {}),
                    _SettingRow(label: 'Privacy Policy',    c: c, onTap: () {}),
                    _SettingRow(label: 'Terms of Service',  c: c, onTap: () {}, isLast: true),
                  ]),
                  const SizedBox(height: 20),

                  // Danger Zone
                  _SectionTitle(title: 'Danger Zone', c: c),
                  _SectionBlock(c: c, children: [
                    if (!_confirmDelete)
                      _SettingRow(
                        label: 'Delete All Data',
                        sub: 'This cannot be undone',
                        danger: true,
                        isLast: true,
                        c: c,
                        onTap: () => setState(() => _confirmDelete = true),
                      )
                    else
                      _DeleteConfirm(
                        onCancel: () => setState(() => _confirmDelete = false),
                        onConfirm: () => setState(() => _confirmDelete = false),
                        c: c,
                      ),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section helpers ────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.c});
  final String title;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption(c.textTertiary).copyWith(
          fontWeight: FontWeight.w600, letterSpacing: 0.8),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.children, required this.c});
  final List<Widget> children;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

// ── Setting Row ────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.c,
    this.sub,
    this.value,
    this.onTap,
    this.rightWidget,
    this.danger = false,
    this.isLast = false,
  });
  final String label;
  final String? sub;
  final String? value;
  final VoidCallback? onTap;
  final Widget? rightWidget;
  final bool danger;
  final bool isLast;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: c.divider.withValues(alpha: 0.27))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyM(
                      danger ? c.errorRose : c.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (rightWidget != null)
              rightWidget!
            else if (value != null) ...[
              Text(
                value!,
                style: AppTypography.bodyS(c.textTertiary).copyWith(fontSize: 13),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right, size: 14, color: c.textTertiary),
              ],
            ] else if (onTap != null)
              Icon(Icons.chevron_right, size: 14, color: c.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Pro Banner ─────────────────────────────────────────────
class _ProBanner extends StatelessWidget {
  const _ProBanner({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(width: 4, color: c.accentIron),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.accentIron.withValues(alpha: 0.094),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'FREE PLAN',
                    style: AppTypography.caption(c.accentIron).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Upgrade to VELT Pro',
                  style: AppTypography.titleM(c.textPrimary).copyWith(
                    fontSize: 17, letterSpacing: -0.1),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlimited routines · Full history · Advanced analytics',
                  style: AppTypography.bodyS(c.textSecondary).copyWith(
                    height: 1.55),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: 280,
                  child: PrimaryButton(
                    label: 'Upgrade — From \$4.99/mo',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal Picker ────────────────────────────────────────────
class _GoalPicker extends StatelessWidget {
  const _GoalPicker({
    required this.selected,
    required this.onSelect,
    required this.c,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _GoalSheet(
          selected: selected,
          onSelect: (g) {
            onSelect(g);
            Navigator.pop(context);
          },
          c: c,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected,
            style: AppTypography.bodyS(c.accentIron).copyWith(
              fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 14, color: c.textTertiary),
        ],
      ),
    );
  }
}

class _GoalSheet extends StatelessWidget {
  const _GoalSheet({
    required this.selected,
    required this.onSelect,
    required this.c,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  static const _goals = ['Build Muscle', 'Lose Fat', 'Strength', 'Endurance'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Fitness Goal',
              style: AppTypography.titleM(c.textPrimary).copyWith(
                fontSize: 17, letterSpacing: -0.2),
            ),
          ),
          const SizedBox(height: 4),
          ..._goals.map((g) => GestureDetector(
            onTap: () => onSelect(g),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c.divider.withValues(alpha: 0.3))),
                color: g == selected
                    ? c.accentIron.withValues(alpha: 0.06)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      g,
                      style: AppTypography.bodyM(
                        g == selected ? c.accentIron : c.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  if (g == selected)
                    Icon(Icons.check_rounded, size: 18, color: c.accentIron),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ── Unit Segment ───────────────────────────────────────────
class _UnitSegment extends StatelessWidget {
  const _UnitSegment({
    required this.selected,
    required this.onSelect,
    required this.c,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['kg', 'lb'].map((u) {
          final active = selected == u;
          return GestureDetector(
            onTap: () => onSelect(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active ? c.accentIron : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                u,
                style: AppTypography.bodyS(
                  active ? Colors.white : c.textTertiary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Rest Stepper ───────────────────────────────────────────
class _RestStepper extends StatelessWidget {
  const _RestStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.c,
  });
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(icon: '−', onTap: onDecrement, c: c),
        SizedBox(
          width: 36,
          child: Text(
            '${value}s',
            textAlign: TextAlign.center,
            style: AppTypography.bodyS(c.textPrimary).copyWith(
              fontSize: 13,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
        _StepBtn(icon: '+', onTap: onIncrement, c: c),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap, required this.c});
  final String icon;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(fontSize: 16, color: c.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ── Theme Card ─────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preview,
    required this.active,
    required this.onSelect,
  });
  final _ThemePreview preview;
  final bool active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(preview.key),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88, height: 68,
            decoration: BoxDecoration(
              color: preview.bg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: active ? preview.accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Card preview
                Positioned(
                  top: 10, left: 8, right: 8,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: preview.card.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Color dots
                Positioned(
                  bottom: 8, left: 8,
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: preview.card,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.13)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: preview.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                // Active check
                if (active)
                  Positioned(
                    top: 4, right: 5,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: preview.accent,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 9, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            preview.name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: active ? preview.accent : Colors.grey,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Bodyweight History Chart ───────────────────────────────
class _BwHistoryChart extends StatelessWidget {
  const _BwHistoryChart({
    required this.history,
    required this.isLbs,
    required this.c,
  });
  final List<({DateTime date, double kg})> history;
  final bool isLbs;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    final data = history.map((e) {
      final val = isLbs ? e.kg * 2.20462 : e.kg;
      return (date: e.date, val: val);
    }).toList();

    final minVal = data.map((e) => e.val).reduce(math.min);
    final maxVal = data.map((e) => e.val).reduce(math.max);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    final unit = isLbs ? 'lb' : 'kg';
    final latest = data.last.val;
    final first = data.first.val;
    final diff = latest - first;
    final diffStr = diff >= 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1);
    final diffColor = diff < 0
        ? c.successLime
        : diff > 0
            ? c.warningAmber
            : c.textTertiary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bodyweight Trend',
                style: AppTypography.caption(c.textTertiary).copyWith(
                  fontWeight: FontWeight.w700, letterSpacing: 0.7,
                  fontSize: 10),
              ),
              const Spacer(),
              Text(
                '$diffStr $unit (${data.length} entries)',
                style: AppTypography.caption(diffColor).copyWith(
                  fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _BwChartPainter(
                data: data.map((e) => e.val).toList(),
                minVal: minVal,
                range: range,
                lineColor: c.accentIron,
                fillColor: c.accentIron.withValues(alpha: 0.08),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${data.first.val.toStringAsFixed(1)} $unit',
                style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 10),
              ),
              const Spacer(),
              Text(
                '${data.last.val.toStringAsFixed(1)} $unit',
                style: AppTypography.caption(c.accentIron).copyWith(
                  fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BwChartPainter extends CustomPainter {
  const _BwChartPainter({
    required this.data,
    required this.minVal,
    required this.range,
    required this.lineColor,
    required this.fillColor,
  });
  final List<double> data;
  final double minVal;
  final double range;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final points = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      return Offset(x, y.clamp(2.0, size.height - 2));
    });

    // Fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) { fillPath.lineTo(p.dx, p.dy); }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor..style = PaintingStyle.fill);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Last point dot
    canvas.drawCircle(
      points.last,
      4,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(_BwChartPainter old) =>
      old.data != data || old.minVal != minVal;
}

// ── Delete Confirm ─────────────────────────────────────────
class _DeleteConfirm extends StatelessWidget {
  const _DeleteConfirm({
    required this.onCancel,
    required this.onConfirm,
    required this.c,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All your workouts, routines and PRs will be permanently deleted. Are you sure?',
            style: AppTypography.bodyS(c.textSecondary).copyWith(
              fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.divider),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodyM(c.textSecondary).copyWith(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.errorRose.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        'Delete All',
                        style: AppTypography.bodyM(c.errorRose).copyWith(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
