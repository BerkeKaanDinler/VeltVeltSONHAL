// VELT — Paywall screen
//
// Backed by RevenueCat ProService. Lists current offerings (monthly,
// annual, lifetime), shows benefits, handles purchase + restore.
//
// When RevenueCat is not configured (no API keys at build time) shows
// a "Pro is coming soon" placeholder instead of failing silently.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pro_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/velt_redesign_widgets.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedIdx = -1; // selected offering index
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (ProService.isConfigured) {
      ProService.refresh();
    }
  }

  Future<void> _purchase() async {
    final list = ProService.offerings.value;
    if (_selectedIdx < 0 || _selectedIdx >= list.length) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ProService.purchase(list[_selectedIdx]);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null && mounted) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _restore() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ProService.restore();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err ?? 'Purchases restored. Welcome back.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return ValueListenableBuilder<List<ProOffering>>(
      valueListenable: ProService.offerings,
      builder: (context, offerings, _) {
        // Pre-select annual if available, otherwise first offering
        if (_selectedIdx < 0 && offerings.isNotEmpty) {
          _selectedIdx = offerings.indexWhere((o) => o.period == 'annual');
          if (_selectedIdx < 0) _selectedIdx = 0;
        }

        return VeltScreen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VeltTopBar(
                title: 'VELT Pro',
                subtitle: 'Unlock everything · cancel anytime',
              ),
              const SizedBox(height: 14),

              // Hero
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c.accentIron,
                      c.accentIronSoft,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: c.accentIron.computeLuminance() > .55
                                ? c.ink
                                : Colors.white,
                            size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'VELT PRO',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.accentIron.computeLuminance() > .55
                                ? c.ink
                                : Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The complete experience.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.accentIron.computeLuminance() > .55
                            ? c.ink
                            : Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const VeltSection(label: 'What you unlock'),
              for (final f in _proFeatures) _FeatureRow(feature: f, c: c),

              const VeltSection(label: 'Pick a plan'),
              if (!ProService.isConfigured)
                _OfflinePlaceholder(c: c)
              else if (offerings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: c.divider),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading plans…',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (int i = 0; i < offerings.length; i++) ...[
                  _PlanCard(
                    offering: offerings[i],
                    selected: i == _selectedIdx,
                    onTap: () => setState(() => _selectedIdx = i),
                    c: c,
                  ),
                  const SizedBox(height: 8),
                ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.warningAmber.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: c.warningAmber.withValues(alpha: .4)),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              VeltButton(
                label: _busy
                    ? 'Processing…'
                    : (offerings.isNotEmpty
                        ? 'Start free trial'
                        : 'Coming soon'),
                onTap: (_busy ||
                        offerings.isEmpty ||
                        !ProService.isConfigured)
                    ? null
                    : _purchase,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _busy ? null : _restore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Restore purchases',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      decorationColor: c.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Subscription auto-renews unless cancelled at least 24 h '
                'before period end. Manage in App Store / Play Store.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textTertiary,
                  fontSize: 10.5,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature, required this.c});
  final ({IconData icon, String title, String body}) feature;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.accentIron.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(feature.icon, color: c.accentIron, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.1,
                      )),
                  const SizedBox(height: 3),
                  Text(feature.body,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.offering,
    required this.selected,
    required this.onTap,
    required this.c,
  });
  final ProOffering offering;
  final bool selected;
  final VoidCallback onTap;
  final AppColors c;

  String get _label {
    switch (offering.period) {
      case 'annual':
        return 'Annual';
      case 'monthly':
        return 'Monthly';
      case 'lifetime':
        return 'Lifetime';
      case 'weekly':
        return 'Weekly';
      default:
        return offering.title;
    }
  }

  String get _sub {
    switch (offering.period) {
      case 'annual':
        return '7-day free trial · then ${offering.priceString} / year';
      case 'monthly':
        return '${offering.priceString} / month';
      case 'lifetime':
        return 'One-time ${offering.priceString} · forever';
      default:
        return offering.priceString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? c.accentIron.withValues(alpha: .12)
              : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? c.accentIron : c.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? c.accentIron : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? c.accentIron : c.divider,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      color: c.accentIron.computeLuminance() > .55
                          ? c.ink
                          : Colors.white,
                      size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: c.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (offering.period == 'annual') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.successLime,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: c.successLime.computeLuminance() > .55
                                  ? c.ink
                                  : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _sub,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              offering.priceString,
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflinePlaceholder extends StatelessWidget {
  const _OfflinePlaceholder({required this.c});
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  color: c.warningAmber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Coming soon',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Subscriptions launch once VELT goes live on the App Store and '
            'Play Store. Stay tuned.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textSecondary,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const _proFeatures = <({IconData icon, String title, String body})>[
  (
    icon: Icons.auto_awesome_rounded,
    title: 'AI Nutritionist',
    body:
        'Weekly meal plans generated to your goals, allergies, and budget.'
  ),
  (
    icon: Icons.psychology_alt_rounded,
    title: 'AI Coach Insights',
    body: 'Plateau alerts, deload timing, and recovery score.'
  ),
  (
    icon: Icons.palette_outlined,
    title: 'Premium themes',
    body: 'Slate Mono, Rose Gold, Emerald Premium.'
  ),
  (
    icon: Icons.stacked_line_chart_rounded,
    title: 'Advanced analytics',
    body: 'Year-over-year volume, muscle balance heatmap, lift correlations.'
  ),
  (
    icon: Icons.cloud_sync_rounded,
    title: 'Unlimited history & export',
    body: 'Full history, CSV/JSON export, two-way Apple Health sync.'
  ),
  (
    icon: Icons.tune_rounded,
    title: 'Custom programs',
    body: 'Build, save, and share your own multi-week programs.'
  ),
];
