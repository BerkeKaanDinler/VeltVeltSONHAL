/// VELT — AppColors token system
/// Use via Theme.of(context).extension<AppColors>()!
/// 4 themes: 2 free (Iron Dark, Slate Mono) + 2 pro (Rose Gold, Emerald)

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHigh,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentIron,
    required this.accentIronSoft,
    required this.successLime,
    required this.errorRose,
    required this.warningAmber,
    // Chart colors (constant across themes)
    this.protein  = const Color(0xFFD97706),
    this.carbs    = const Color(0xFF38BDF8),
    this.fat      = const Color(0xFF22C55E),
  });

  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHigh;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentIron;
  final Color accentIronSoft;
  final Color successLime;
  final Color errorRose;
  final Color warningAmber;
  final Color protein;
  final Color carbs;
  final Color fat;

  // Convenience getters
  Color get accentIronTint   => accentIron.withOpacity(0.08);
  Color get accentIronBorder => accentIron.withOpacity(0.30);

  // ─── FREE ──────────────────────────────────────────────
  static const ironDark = AppColors(
    surface:          Color(0xFF0F0F0F),
    surfaceElevated:  Color(0xFF1A1A1A),
    surfaceHigh:      Color(0xFF242424),
    divider:          Color(0xFF2A2A2A),
    textPrimary:      Color(0xFFFFFFFF),
    textSecondary:    Color(0xFFA0A0A0),
    textTertiary:     Color(0xFF555555),
    accentIron:       Color(0xFFD97706),
    accentIronSoft:   Color(0xFF92400E),
    successLime:      Color(0xFF22C55E),
    errorRose:        Color(0xFFEF4444),
    warningAmber:     Color(0xFFF59E0B),
  );

  static const slateMono = AppColors(
    surface:          Color(0xFF0A0E1A),
    surfaceElevated:  Color(0xFF141927),
    surfaceHigh:      Color(0xFF1E2434),
    divider:          Color(0xFF252B3D),
    textPrimary:      Color(0xFFF1F5F9),
    textSecondary:    Color(0xFF94A3B8),
    textTertiary:     Color(0xFF475569),
    accentIron:       Color(0xFF94A3B8),
    accentIronSoft:   Color(0xFF475569),
    successLime:      Color(0xFF22C55E),
    errorRose:        Color(0xFFEF4444),
    warningAmber:     Color(0xFFF59E0B),
  );

  // ─── PRO ───────────────────────────────────────────────
  static const roseGold = AppColors(
    surface:          Color(0xFF100A0E),
    surfaceElevated:  Color(0xFF1B131A),
    surfaceHigh:      Color(0xFF241B22),
    divider:          Color(0xFF2D2128),
    textPrimary:      Color(0xFFFBEEF2),
    textSecondary:    Color(0xFFB89BA8),
    textTertiary:     Color(0xFF6B5662),
    accentIron:       Color(0xFFF472B6),
    accentIronSoft:   Color(0xFF9D174D),
    successLime:      Color(0xFF22C55E),
    errorRose:        Color(0xFFEF4444),
    warningAmber:     Color(0xFFF59E0B),
  );

  static const emerald = AppColors(
    surface:          Color(0xFF0A1410),
    surfaceElevated:  Color(0xFF0F1F18),
    surfaceHigh:      Color(0xFF162B22),
    divider:          Color(0xFF1F352A),
    textPrimary:      Color(0xFFE8F5EE),
    textSecondary:    Color(0xFF7BAB94),
    textTertiary:     Color(0xFF3F5D4F),
    accentIron:       Color(0xFF10B981),
    accentIronSoft:   Color(0xFF065F46),
    successLime:      Color(0xFF84CC16),
    errorRose:        Color(0xFFEF4444),
    warningAmber:     Color(0xFFF59E0B),
  );

  @override
  AppColors copyWith({
    Color? surface, Color? surfaceElevated, Color? surfaceHigh, Color? divider,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? accentIron, Color? accentIronSoft,
    Color? successLime, Color? errorRose, Color? warningAmber,
  }) => AppColors(
    surface:         surface         ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceHigh:     surfaceHigh     ?? this.surfaceHigh,
    divider:         divider         ?? this.divider,
    textPrimary:     textPrimary     ?? this.textPrimary,
    textSecondary:   textSecondary   ?? this.textSecondary,
    textTertiary:    textTertiary    ?? this.textTertiary,
    accentIron:      accentIron      ?? this.accentIron,
    accentIronSoft:  accentIronSoft  ?? this.accentIronSoft,
    successLime:     successLime     ?? this.successLime,
    errorRose:       errorRose       ?? this.errorRose,
    warningAmber:    warningAmber    ?? this.warningAmber,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface:         Color.lerp(surface,         other.surface,         t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceHigh:     Color.lerp(surfaceHigh,     other.surfaceHigh,     t)!,
      divider:         Color.lerp(divider,         other.divider,         t)!,
      textPrimary:     Color.lerp(textPrimary,     other.textPrimary,     t)!,
      textSecondary:   Color.lerp(textSecondary,   other.textSecondary,   t)!,
      textTertiary:    Color.lerp(textTertiary,    other.textTertiary,    t)!,
      accentIron:      Color.lerp(accentIron,      other.accentIron,      t)!,
      accentIronSoft:  Color.lerp(accentIronSoft,  other.accentIronSoft,  t)!,
      successLime:     Color.lerp(successLime,     other.successLime,     t)!,
      errorRose:       Color.lerp(errorRose,       other.errorRose,       t)!,
      warningAmber:    Color.lerp(warningAmber,    other.warningAmber,    t)!,
    );
  }
}

/// Theme key registry
enum VeltTheme { iron, slate, roseGold, emerald }

extension VeltThemeX on VeltTheme {
  AppColors get colors => switch (this) {
    VeltTheme.iron     => AppColors.ironDark,
    VeltTheme.slate    => AppColors.slateMono,
    VeltTheme.roseGold => AppColors.roseGold,
    VeltTheme.emerald  => AppColors.emerald,
  };

  String get displayName => switch (this) {
    VeltTheme.iron     => 'Iron Dark',
    VeltTheme.slate    => 'Slate Mono',
    VeltTheme.roseGold => 'Rose Gold',
    VeltTheme.emerald  => 'Emerald Premium',
  };

  String get description => switch (this) {
    VeltTheme.iron     => 'The signature VELT look. Deep black + amber heat.',
    VeltTheme.slate    => 'Cool industrial grayscale. Minimal, focused.',
    VeltTheme.roseGold => 'Warm noir with rose gold accents.',
    VeltTheme.emerald  => 'Deep forest with emerald highlights.',
  };

  bool get isPro => this == VeltTheme.roseGold || this == VeltTheme.emerald;
}
