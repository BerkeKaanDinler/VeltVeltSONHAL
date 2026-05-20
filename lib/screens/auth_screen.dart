// VELT — Sign in / sign up screen
//
// Supabase-backed. Offers Apple, Google, and email magic-link.
// When Supabase is not configured, displays an "offline mode" notice.

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/pro_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/velt_redesign_widgets.dart';
import 'legal_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.onSignedIn});
  final VoidCallback? onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _emailLink() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final err = await AuthService.signInWithMagicLink(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
      _info = err == null ? 'Check your inbox for a sign-in link.' : null;
    });
  }

  Future<void> _apple() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await AuthService.signInWithApple();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return ValueListenableBuilder<VeltUser?>(
      valueListenable: AuthService.currentUser,
      builder: (context, user, _) {
        // Once signed in, close the screen
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ProService.identify(user.id);
              widget.onSignedIn?.call();
              Navigator.of(context).maybePop();
            }
          });
        }

        return VeltScreen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VeltTopBar(
                title: 'Sign in',
                subtitle: 'Sync across devices · backup your data',
              ),
              const SizedBox(height: 18),

              // Hero
              Container(
                padding: const EdgeInsets.all(18),
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
                    Icon(Icons.cloud_done_rounded,
                        size: 32, color: c.accentIron),
                    const SizedBox(height: 12),
                    Text(
                      'Never lose a workout.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textPrimary,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to back up workouts, programs, PRs, and '
                      'nutrition. Switch phones without missing a session.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (!AuthService.isConfigured) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.warningAmber.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: c.warningAmber.withValues(alpha: .4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: c.warningAmber, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Running in offline mode. Sign-in requires a '
                          'Supabase URL + anon key in this build.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: c.textPrimary,
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Apple Sign-in (iOS only)
              if (Platform.isIOS || Platform.isMacOS) ...[
                _BigAuthButton(
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  background: Colors.black,
                  foreground: Colors.white,
                  onTap: _busy ? null : _apple,
                  c: c,
                ),
                const SizedBox(height: 10),
              ],

              // Google
              _BigAuthButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Continue with Google',
                background: Colors.white,
                foreground: Colors.black,
                onTap: _busy ? null : _google,
                bordered: true,
                c: c,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: Divider(color: c.divider, height: 1)),
                  const SizedBox(width: 10),
                  Text('or email',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: c.textTertiary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      )),
                  const SizedBox(width: 10),
                  Expanded(child: Divider(color: c.divider, height: 1)),
                ],
              ),
              const SizedBox(height: 14),

              // Email field
              Container(
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.divider),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  cursorColor: c.accentIron,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: c.textTertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              VeltButton(
                label: _busy ? 'Sending…' : 'Send sign-in link',
                onTap: _busy ? null : _emailLink,
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                _Banner(text: _error!, error: true, c: c),
              ],
              if (_info != null) ...[
                const SizedBox(height: 12),
                _Banner(text: _info!, error: false, c: c),
              ],

              const SizedBox(height: 28),
              Text(
                'By continuing you agree to our',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegalLink('Terms', LegalKind.terms, c: c),
                  Text(' · ',
                      style:
                          TextStyle(color: c.textTertiary, fontSize: 11)),
                  _LegalLink('Privacy', LegalKind.privacy, c: c),
                  Text(' · ',
                      style:
                          TextStyle(color: c.textTertiary, fontSize: 11)),
                  _LegalLink('Medical', LegalKind.medical, c: c),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _BigAuthButton extends StatelessWidget {
  const _BigAuthButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.c,
    this.bordered = false,
  });
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final AppColors c;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Opacity(
        opacity: onTap == null ? .5 : 1,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: bordered ? Border.all(color: c.divider) : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.error, required this.c});
  final String text;
  final bool error;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    final color = error ? c.errorRose : c.successLime;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(
              error
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink(this.label, this.kind, {required this.c});
  final String label;
  final LegalKind kind;
  final AppColors c;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LegalScreen(kind: kind)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          color: c.accentIron,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          decorationColor: c.accentIron.withValues(alpha: .4),
        ),
      ),
    );
  }
}
