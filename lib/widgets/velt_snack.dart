// VELT — Standardized snackbar.
//
// Use this everywhere instead of raw SnackBar so corner radius, behavior,
// duration, and action style stay consistent.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum VeltSnackKind { info, success, warning, error }

class VeltSnack {
  VeltSnack._();

  static void show(
    BuildContext context,
    String message, {
    VeltSnackKind kind = VeltSnackKind.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final c = Theme.of(context).extension<AppColors>()!;
    final accent = switch (kind) {
      VeltSnackKind.success => c.successLime,
      VeltSnackKind.warning => c.warningAmber,
      VeltSnackKind.error => c.errorRose,
      VeltSnackKind.info => c.accentIron,
    };
    final icon = switch (kind) {
      VeltSnackKind.success => Icons.check_circle_rounded,
      VeltSnackKind.warning => Icons.warning_amber_rounded,
      VeltSnackKind.error => Icons.error_outline_rounded,
      VeltSnackKind.info => Icons.info_outline_rounded,
    };

    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: c.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: accent.withValues(alpha: .35)),
        ),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, 0, AppSpacing.screenH, 16),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: accent,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
