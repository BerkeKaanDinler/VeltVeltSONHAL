// VELT — AppColors
// 4 themes: iron (free), slate (free), roseGold (pro), emerald (pro)
// Colors match tokens.js exactly. Never hardcode hex in widgets.
// Apply via Theme.of(context).extension<AppColors>()

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink,
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
    required this.warningAmber,
    required this.errorRose,
    this.protein  = const Color(0xFFD97706),
    this.carbs    = const Color(0xFF38BDF8),
    this.fat      = const Color(0xFF22C55E),
  });

  final Color ink;
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
  final Color warningAmber;
  final Color errorRose;
  final Color protein;
  final Color carbs;
  final Color fat;

  // ── Iron Dark (free) — signature VELT look, deep black + amber ──
  static const ironDark = AppColors(
    ink:              Color(0xFF0F0F0F),
    surface:          Color(0xFF0F0F0F),
    surfaceElevated:  Color(0xFF1A1A1A),
    surfaceHigh:      Color(0xFF242424),
    divider:          Color(0xFF2A2A2A),
    textPrimary:      Color(0xFFFFFFFF),
    textSecondary:    Color(0xFFA0A0A0),
    textTertiary:     Color(0xFF6B6B6B),
    accentIron:       Color(0xFFD97706),
    accentIronSoft:   Color(0xFF92400E),
    successLime:      Color(0xFF22C55E),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFEF4444),
  );

  // ── Slate Mono (free) — cool industrial grayscale ───────────────
  static const slateMono = AppColors(
    ink:              Color(0xFF0A0E1A),
    surface:          Color(0xFF0A0E1A),
    surfaceElevated:  Color(0xFF141927),
    surfaceHigh:      Color(0xFF1E2434),
    divider:          Color(0xFF252B3D),
    textPrimary:      Color(0xFFF1F5F9),
    textSecondary:    Color(0xFF94A3B8),
    textTertiary:     Color(0xFF64748B),
    accentIron:       Color(0xFF94A3B8),
    accentIronSoft:   Color(0xFF475569),
    successLime:      Color(0xFF22C55E),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFEF4444),
  );

  // ── Rose Gold (pro) — warm noir with rose gold accents ──────────
  static const roseGold = AppColors(
    ink:              Color(0xFF100A0E),
    surface:          Color(0xFF100A0E),
    surfaceElevated:  Color(0xFF1B131A),
    surfaceHigh:      Color(0xFF241B22),
    divider:          Color(0xFF2D2128),
    textPrimary:      Color(0xFFFBEEF2),
    textSecondary:    Color(0xFFB89BA8),
    textTertiary:     Color(0xFF896678),
    accentIron:       Color(0xFFF472B6),
    accentIronSoft:   Color(0xFF9D174D),
    successLime:      Color(0xFF22C55E),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFEF4444),
  );

  // ── Warm Paper — editorial warm ivory, premium light theme ────
  static const warmPaper = AppColors(
    ink:              Color(0xFFF2EAD9),
    surface:          Color(0xFFF2EAD9),
    surfaceElevated:  Color(0xFFFBF6ED),
    surfaceHigh:      Color(0xFFEAE1D0),
    divider:          Color(0xFFD8CEBC),
    textPrimary:      Color(0xFF1C1309),
    textSecondary:    Color(0xFF5C4A38),
    textTertiary:     Color(0xFF8A7865),
    accentIron:       Color(0xFFC55F18),
    accentIronSoft:   Color(0xFFE6A668),
    successLime:      Color(0xFF5A8740),
    warningAmber:     Color(0xFFC97A22),
    errorRose:        Color(0xFFC03C3C),
    protein:          Color(0xFFA85820),
    carbs:            Color(0xFF4A7EA0),
    fat:              Color(0xFF4E7040),
  );

  // ── Emerald Premium (pro) — deep forest with emerald highlights ─
  static const emeraldPremium = AppColors(
    ink:              Color(0xFF0A1410),
    surface:          Color(0xFF0A1410),
    surfaceElevated:  Color(0xFF0F1F18),
    surfaceHigh:      Color(0xFF162B22),
    divider:          Color(0xFF1F352A),
    textPrimary:      Color(0xFFE8F5EE),
    textSecondary:    Color(0xFF7BAB94),
    textTertiary:     Color(0xFF527A68),
    accentIron:       Color(0xFF10B981),
    accentIronSoft:   Color(0xFF065F46),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFEF4444),
  );

  @override
  AppColors copyWith({
    Color? ink, Color? surface, Color? surfaceElevated,
    Color? surfaceHigh, Color? divider,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? accentIron, Color? accentIronSoft,
    Color? successLime, Color? warningAmber, Color? errorRose,
    Color? protein, Color? carbs, Color? fat,
  }) => AppColors(
    ink:             ink             ?? this.ink,
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
    warningAmber:    warningAmber    ?? this.warningAmber,
    errorRose:       errorRose       ?? this.errorRose,
    protein:         protein         ?? this.protein,
    carbs:           carbs           ?? this.carbs,
    fat:             fat             ?? this.fat,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ink:             Color.lerp(ink,             other.ink,             t)!,
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
      warningAmber:    Color.lerp(warningAmber,    other.warningAmber,    t)!,
      errorRose:       Color.lerp(errorRose,       other.errorRose,       t)!,
      protein:         Color.lerp(protein,         other.protein,         t)!,
      carbs:           Color.lerp(carbs,           other.carbs,           t)!,
      fat:             Color.lerp(fat,             other.fat,             t)!,
    );
  }
}
