import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared_widgets.dart';

const _priceYearly  = r'$29.99';
const _priceMonthly = r'$4.99';
const _saveBadge    = 'Save 50%';

// ══════════════════════════════════════════════════════════
//  VELT PRO SCREEN  (UI only — no real payments)
// ══════════════════════════════════════════════════════════
class VeltProScreen extends StatefulWidget {
  const VeltProScreen({super.key});

  @override
  State<VeltProScreen> createState() => _VeltProScreenState();
}

class _VeltProScreenState extends State<VeltProScreen> {
  bool _yearlySelected = true;

  void _handlePurchase() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('In-app purchases coming soon.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm)),
    ));
  }

  void _handleRestore() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('No active Pro subscription found.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    const ctaLabel = 'Get VELT Pro — Coming Soon';

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: close + restore
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 22, color: c.textSecondary),
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(8),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _handleRestore,
                    child: Text(
                      'Restore',
                      style: AppTypography.bodyS(c.textSecondary).copyWith(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.md,
                  AppSpacing.screenH, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'VELT PRO',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: c.accentIron,
                              letterSpacing: -1.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Advanced tools for serious training.',
                            style: AppTypography.bodyM(c.textPrimary).copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Everything you need to train smarter,\ntrack deeper, and stay consistent.',
                            style: AppTypography.bodyS(c.textTertiary)
                                .copyWith(fontSize: 13, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Benefits card
                    Container(
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: c.divider.withValues(alpha: 0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Column(
                        children: [
                          _BenefitRow(
                            icon: Icons.palette_outlined,
                            title: 'Premium Themes',
                            subtitle:
                                'Rose Gold, Emerald, and future exclusive themes.',
                          ),
                          _BenefitRow(
                            icon: Icons.bar_chart_rounded,
                            title: 'Advanced Analytics',
                            subtitle:
                                'Volume trends, PR tracking, and training consistency insights.',
                          ),
                          _BenefitRow(
                            icon: Icons.rocket_launch_outlined,
                            title: 'Priority New Features',
                            subtitle:
                                'Pro members get early access to every major upgrade as it launches.',
                          ),
                          _BenefitRow(
                            icon: Icons.schedule_rounded,
                            title: 'Data Export',
                            subtitle:
                                'Export your full workout history to CSV. Coming soon.',
                          ),
                          _BenefitRow(
                            icon: Icons.emoji_events_outlined,
                            title: 'Advanced PR Insights',
                            subtitle:
                                'Deeper per-exercise trends and record history as VELT Pro evolves.',
                          ),
                          _BenefitRow(
                            icon: Icons.favorite_border_rounded,
                            title: 'Support VELT',
                            subtitle: 'Help keep VELT independent and ad-free.',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Plan cards
                    Row(
                      children: [
                        Expanded(
                          child: _PlanCard(
                            label: 'Yearly',
                            price: _priceYearly,
                            period: 'per year',
                            badge: _saveBadge,
                            bestValue: true,
                            selected: _yearlySelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _yearlySelected = true);
                            },
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PlanCard(
                            label: 'Monthly',
                            price: _priceMonthly,
                            period: 'per month',
                            selected: !_yearlySelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _yearlySelected = false);
                            },
                            c: c,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CTA button
                    PrimaryButton(
                      label: ctaLabel,
                      onPressed: _handlePurchase,
                    ),
                    const SizedBox(height: 16),

                    // Legal footer
                    Center(
                      child: Text(
                        'Cancel anytime. Prices may vary by region.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(c.textTertiary)
                            .copyWith(fontSize: 11, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Benefit row ────────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: c.divider.withValues(alpha: 0.4), width: 0.5),
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentIron.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 16, color: c.accentIron),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM(c.textPrimary).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyS(c.textTertiary)
                      .copyWith(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.check_circle_rounded, size: 18, color: c.accentIron),
        ],
      ),
    );
  }
}

// ── Plan card ──────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    required this.c,
    this.badge,
    this.bestValue = false,
  });
  final String label;
  final String price;
  final String period;
  final bool selected;
  final VoidCallback onTap;
  final AppColors c;
  final String? badge;
  final bool bestValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected ? c.accentIron.withValues(alpha: 0.08) : c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? c.accentIron : c.divider.withValues(alpha: 0.5),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTypography.titleM(c.textPrimary).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.accentIron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      badge!,
                      style: AppTypography.caption(c.accentIron).copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              period,
              style: AppTypography.caption(c.textTertiary).copyWith(fontSize: 11),
            ),
            if (bestValue) ...[
              const SizedBox(height: 8),
              Text(
                'Best Value',
                style: AppTypography.caption(c.accentIron).copyWith(
                    fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
