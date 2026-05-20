// VELT — About screen
// Version, brand statement, links to legal docs, support email.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/velt_redesign_widgets.dart';
import 'legal_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _email() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@veltfitness.com',
      query: 'subject=VELT%20support',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return VeltScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VeltTopBar(title: 'About', subtitle: 'Made with intent'),
          const SizedBox(height: 14),

          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.surfaceElevated,
                  c.accentIron.withValues(alpha: .14),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.accentIron,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: c.accentIron.withValues(alpha: .45),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'V',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: c.accentIron.computeLuminance() > .55
                          ? c.ink
                          : Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'VELT',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium fitness tracker built for serious lifters',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const VeltSection(label: 'Legal'),
          VeltRowCard(
            icon: 'P',
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            trailing: const VeltPill('Read'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(kind: LegalKind.privacy),
              ),
            ),
          ),
          const SizedBox(height: 8),
          VeltRowCard(
            icon: 'T',
            title: 'Terms of Service',
            subtitle: 'Your agreement with VELT',
            trailing: const VeltPill('Read'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(kind: LegalKind.terms),
              ),
            ),
          ),
          const SizedBox(height: 8),
          VeltRowCard(
            icon: 'M',
            title: 'Medical Disclaimer',
            subtitle: 'Read before training',
            trailing: const VeltPill('Important', accent: true),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(kind: LegalKind.medical),
              ),
            ),
          ),

          const VeltSection(label: 'Support'),
          VeltRowCard(
            icon: '@',
            title: 'support@veltfitness.com',
            subtitle: 'Email us with questions or feedback',
            trailing: const VeltPill('Email'),
            onTap: () {
              HapticFeedback.selectionClick();
              _email();
            },
          ),

          const VeltSection(label: 'App'),
          VeltPanel(
            child: Column(
              children: [
                _MetaRow(
                    label: 'Version', value: '1.0.0 (Build 1)', c: c),
                Divider(height: 18, color: c.divider),
                _MetaRow(
                    label: 'Bundle',
                    value: 'com.veltfitness.app',
                    c: c),
                Divider(height: 18, color: c.divider),
                _MetaRow(
                    label: 'Made with',
                    value: 'Flutter 3 · Dart 3',
                    c: c),
                Divider(height: 18, color: c.divider),
                _MetaRow(
                    label: 'Designed in',
                    value: 'İstanbul, Türkiye',
                    c: c),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text(
            '© 2026 VELT Fitness · All rights reserved',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value, required this.c});
  final String label;
  final String value;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
        ),
        Text(value,
            style: TextStyle(
              fontFamily: 'Inter',
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
      ],
    );
  }
}
