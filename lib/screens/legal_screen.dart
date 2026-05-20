// VELT — Legal screens
// Privacy Policy, Terms of Service, and Medical Disclaimer.
// Required for App Store / Play Store submission.
// Health-and-fitness apps MUST display a medical disclaimer.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/velt_redesign_widgets.dart';

enum LegalKind { privacy, terms, medical }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final LegalKind kind;

  String get _title => switch (kind) {
        LegalKind.privacy => 'Privacy Policy',
        LegalKind.terms => 'Terms of Service',
        LegalKind.medical => 'Medical Disclaimer',
      };

  String get _eyebrow => switch (kind) {
        LegalKind.privacy => 'Effective: May 21, 2026',
        LegalKind.terms => 'Effective: May 21, 2026',
        LegalKind.medical => 'Read before training',
      };

  List<_Section> get _sections => switch (kind) {
        LegalKind.privacy => _privacySections,
        LegalKind.terms => _termsSections,
        LegalKind.medical => _medicalSections,
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return VeltScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeltTopBar(title: _title, subtitle: _eyebrow),
          const SizedBox(height: 14),
          for (final s in _sections) ...[
            _SectionHeader(label: s.heading, c: c),
            const SizedBox(height: 8),
            _BodyBlock(text: s.body, c: c),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section {
  const _Section(this.heading, this.body);
  final String heading;
  final String body;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.c});
  final String label;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          color: c.accentIron,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _BodyBlock extends StatelessWidget {
  const _BodyBlock({required this.text, required this.c});
  final String text;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        color: c.textPrimary,
        fontSize: 13.5,
        height: 1.55,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRIVACY POLICY
// ─────────────────────────────────────────────────────────────
const _privacySections = <_Section>[
  _Section(
    'Overview',
    'VELT ("we", "our", "us") respects your privacy. This Privacy Policy explains what '
        'information VELT collects, how we use it, and the choices you have. By using '
        'VELT you agree to this policy. If you do not agree, please do not use the app.',
  ),
  _Section(
    'Information you provide',
    'When you use VELT we may store the following on your device or in our cloud '
        'backend if you sign in:\n\n'
        '• Profile data: display name, fitness goal, experience level, bodyweight, '
        'height, units preference.\n'
        '• Training data: workouts, exercises, sets, reps, weights, RPE, notes, '
        'personal records, routines, programs.\n'
        '• Nutrition data: food entries, calories, macros, water intake, daily '
        'targets.\n'
        '• Account credentials: email address (and optionally Apple ID or Google ID) '
        'used solely for authentication.',
  ),
  _Section(
    'Information collected automatically',
    '• Crash diagnostics through Sentry: stack traces, device model, OS version, app '
        'version. No personally identifiable information is included.\n'
        '• Anonymous product analytics: feature usage, screen views, retention '
        'cohorts. We do not link these events to your email address.\n'
        '• Receipt verification through Apple StoreKit / Google Play Billing for '
        'subscription validity.',
  ),
  _Section(
    'How we use your information',
    'We use the information above to:\n\n'
        '• Provide and improve the core training and nutrition features.\n'
        '• Sync your workouts across devices when you sign in.\n'
        '• Diagnose crashes and performance issues.\n'
        '• Calculate aggregate, anonymized usage patterns to prioritize improvements.\n'
        '• Communicate with you about important service updates (we do NOT send '
        'marketing email unless you explicitly opt in).',
  ),
  _Section(
    'Data sharing',
    'We do not sell your personal information. We share data only with the following '
        'processors strictly to operate the service:\n\n'
        '• Supabase (auth + database) — encrypted in transit and at rest.\n'
        '• RevenueCat (subscription management).\n'
        '• Sentry (crash reporting).\n'
        '• Apple HealthKit (only if you explicitly grant permission).\n\n'
        'These processors are contractually bound to use your data only on our behalf.',
  ),
  _Section(
    'Your rights',
    'You can at any time:\n\n'
        '• Export your data via Profile → Data → Export (CSV/JSON).\n'
        '• Delete your account and all associated data via Profile → Danger Zone → '
        'Delete all data. Deletion is permanent and irreversible.\n'
        '• Withdraw consent for analytics or HealthKit by revoking the relevant OS '
        'permission.\n\n'
        'Under GDPR (EU) and KVKK (Türkiye) you also have the right to access, '
        'rectify, restrict processing of, and port your personal data. Contact '
        'support@veltfitness.com to exercise these rights.',
  ),
  _Section(
    'Children',
    'VELT is not directed to children under 13 (or 16 in the EU). We do not '
        'knowingly collect personal information from children. If you believe a child '
        'has provided us with personal information, contact us and we will delete it.',
  ),
  _Section(
    'Security',
    'All data is encrypted in transit using TLS 1.2 or higher. Data stored on our '
        'backend is encrypted at rest using AES-256. Passwords (when used) are hashed '
        'with bcrypt. No system is 100% secure; we cannot guarantee absolute security.',
  ),
  _Section(
    'Changes',
    'We may update this Privacy Policy from time to time. Material changes will be '
        'announced in-app and the "Effective" date above will be updated. Continued '
        'use after the effective date constitutes acceptance.',
  ),
  _Section(
    'Contact',
    'Questions or requests regarding this policy?\n\n'
        'Email: support@veltfitness.com\n'
        'Data controller: VELT Fitness',
  ),
];

// ─────────────────────────────────────────────────────────────
// TERMS OF SERVICE
// ─────────────────────────────────────────────────────────────
const _termsSections = <_Section>[
  _Section(
    'Acceptance',
    'By downloading, installing, or using VELT, you agree to these Terms of Service '
        '("Terms"). If you do not agree, do not use VELT.',
  ),
  _Section(
    'Service description',
    'VELT is a fitness tracking application that lets you log workouts, follow '
        'training programs, track nutrition, and view your progress. VELT may offer '
        'optional paid features ("VELT Pro").',
  ),
  _Section(
    'Account',
    'You may use VELT without an account, but creating an account enables cloud '
        'sync. You are responsible for keeping your credentials confidential and for '
        'all activity under your account. You must be at least 13 years old (16 in '
        'the EU) to use VELT.',
  ),
  _Section(
    'Subscription & payments',
    'VELT Pro is available as a monthly, annual, or lifetime purchase. '
        'Subscriptions auto-renew unless canceled at least 24 hours before the end of '
        'the period. Manage or cancel via your App Store or Google Play account. We '
        'do not store your payment details — all transactions are handled by Apple, '
        'Google, or RevenueCat. Refunds follow the policy of the platform you '
        'purchased through (Apple, Google).',
  ),
  _Section(
    'Free trial',
    'New users may be offered a free trial of VELT Pro. The trial converts to a paid '
        'subscription automatically unless canceled before it ends. Cancellation is '
        'free; you keep Pro access until the trial period ends.',
  ),
  _Section(
    'Acceptable use',
    'You agree NOT to:\n\n'
        '• Reverse-engineer, decompile, or attempt to extract source code.\n'
        '• Use VELT for any illegal purpose.\n'
        '• Resell or sublicense VELT or any portion of it.\n'
        '• Submit content that is unlawful, harmful, defamatory, or infringing.\n'
        '• Attempt to gain unauthorized access to other users\' accounts or our '
        'systems.',
  ),
  _Section(
    'Content & ownership',
    'You retain ownership of the workout, nutrition, and personal data you log into '
        'VELT. By using VELT you grant us a limited license to store, process, and '
        'display that data solely to provide the service. All VELT software, design, '
        'branding, and exercise descriptions are owned by VELT Fitness and protected '
        'by copyright and trademark laws.',
  ),
  _Section(
    'Disclaimers',
    'VELT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, WHETHER EXPRESS OR '
        'IMPLIED. To the maximum extent permitted by law we disclaim all warranties '
        'including merchantability, fitness for a particular purpose, and '
        'non-infringement. See the separate Medical Disclaimer for important health '
        'and safety information.',
  ),
  _Section(
    'Limitation of liability',
    'To the maximum extent permitted by law, in no event shall VELT Fitness, its '
        'directors, employees, or partners be liable for any indirect, incidental, '
        'special, consequential, or punitive damages, including loss of profits, '
        'data, goodwill, or other intangible losses arising from your use of VELT. '
        'Our total liability shall not exceed the amount you paid for VELT in the 12 '
        'months prior to the claim.',
  ),
  _Section(
    'Termination',
    'We may suspend or terminate your access if you breach these Terms. You may stop '
        'using VELT at any time and delete your data via Profile → Danger Zone.',
  ),
  _Section(
    'Governing law',
    'These Terms are governed by the laws of Türkiye, without regard to its conflict '
        'of laws provisions. Disputes shall be resolved in the competent courts of '
        'İstanbul, Türkiye, unless local consumer-protection law in your jurisdiction '
        'provides for a different venue.',
  ),
  _Section(
    'Changes',
    'We may update these Terms from time to time. We will notify you in-app of any '
        'material changes. Continued use of VELT after the change constitutes '
        'acceptance of the new Terms.',
  ),
  _Section(
    'Contact',
    'support@veltfitness.com',
  ),
];

// ─────────────────────────────────────────────────────────────
// MEDICAL DISCLAIMER
// ─────────────────────────────────────────────────────────────
const _medicalSections = <_Section>[
  _Section(
    'Not medical advice',
    'VELT is a fitness tracking and education tool. It is NOT a medical device and '
        'does NOT provide medical advice, diagnosis, or treatment. The information, '
        'workout programs, exercise instructions, nutrition guidance, and any '
        'AI-generated recommendations within VELT are for general educational and '
        'informational purposes only.',
  ),
  _Section(
    'Consult a professional',
    'Always consult a qualified healthcare provider before:\n\n'
        '• Starting any new fitness or nutrition program.\n'
        '• Changing your existing routine if you have a chronic condition '
        '(cardiovascular, metabolic, musculoskeletal, etc.).\n'
        '• Returning to training after injury, surgery, or pregnancy.\n'
        '• Beginning a calorie deficit or any restrictive eating pattern.',
  ),
  _Section(
    'Use at your own risk',
    'Physical exercise carries inherent risk including but not limited to muscular '
        'strain, joint injury, cardiovascular events, and in extreme cases serious '
        'injury or death. By using VELT you acknowledge and assume these risks. '
        'Listen to your body. If you feel pain, dizziness, shortness of breath, or '
        'discomfort beyond normal exertion, STOP immediately and seek medical '
        'attention.',
  ),
  _Section(
    'Form & technique',
    'The form cues and instructional content in VELT are guidelines. They do not '
        'replace in-person coaching. Beginners should consider working with a '
        'certified trainer to learn proper technique before performing heavy or '
        'complex movements (squat, deadlift, bench press, overhead press, etc.).',
  ),
  _Section(
    'Calorie & macro estimates',
    'Calorie counts, macro estimates, and food data within VELT are approximate. '
        'Individual metabolic needs vary significantly. Do not rely on these numbers '
        'as a substitute for professional dietary guidance, particularly if you have '
        'a medical condition (diabetes, eating disorder, etc.).',
  ),
  _Section(
    'Heart-rate & HealthKit data',
    'When VELT reads or writes data to Apple HealthKit or Google Health Connect, '
        'those values are sourced from your device sensors and may not be clinically '
        'accurate. Do not use them for diagnostic purposes.',
  ),
  _Section(
    'Emergencies',
    'If you experience a medical emergency, call your local emergency number '
        'immediately. VELT does not provide emergency services.',
  ),
  _Section(
    'No liability',
    'To the maximum extent permitted by law, VELT Fitness and its team are not '
        'liable for any injury, illness, loss, or damage arising from your use of '
        'VELT or your reliance on the information it provides. Your training and '
        'nutrition decisions are your own responsibility.',
  ),
];
