// VELT — AppColors
// All colors defined as const. Widgets NEVER hardcode hex values.
// Dark theme is default; Warm Paper is Pro-only optional.
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

  // ── Iron Dark (default) ──────────────────────────────────
  static const ironDark = AppColors(
    ink:              Color(0xFF0B0F17),
    surface:          Color(0xFF0B0F17),
    surfaceElevated:  Color(0xFF1A2030),
    surfaceHigh:      Color(0xFF252D3D),
    divider:          Color(0xFF2A3142),
    textPrimary:      Color(0xFFF1F5F9),
    textSecondary:    Color(0xFF94A3B8),
    textTertiary:     Color(0xFF64748B),
    accentIron:       Color(0xFFD97706),
    accentIronSoft:   Color(0xFF92400E),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Warm Paper (Pro only) ────────────────────────────────
  static const warmPaper = AppColors(
    ink:              Color(0xFFF5F0E8),
    surface:          Color(0xFFFAF7F2),
    surfaceElevated:  Color(0xFFFFFFFF),
    surfaceHigh:      Color(0xFFF0EBE3),
    divider:          Color(0xFFDDD5C8),
    textPrimary:      Color(0xFF1A1410),
    textSecondary:    Color(0xFF6B5B4E),
    textTertiary:     Color(0xFF9C8878),
    accentIron:       Color(0xFFB45309),
    accentIronSoft:   Color(0xFFFEF3C7),
    successLime:      Color(0xFF65A30D),
    warningAmber:     Color(0xFFD97706),
    errorRose:        Color(0xFFDC2626),
  );

  // ── Midnight Steel ───────────────────────────────────────
  static const midnightSteel = AppColors(
    ink:              Color(0xFF050508),
    surface:          Color(0xFF0A0A0F),
    surfaceElevated:  Color(0xFF141420),
    surfaceHigh:      Color(0xFF1C1C2E),
    divider:          Color(0xFF252540),
    textPrimary:      Color(0xFFE2E4F0),
    textSecondary:    Color(0xFF8B8FAF),
    textTertiary:     Color(0xFF5A5E7A),
    accentIron:       Color(0xFF6366F1),
    accentIronSoft:   Color(0xFF3730A3),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Forest Iron ──────────────────────────────────────────
  static const forestIron = AppColors(
    ink:              Color(0xFF050F07),
    surface:          Color(0xFF0D1A0F),
    surfaceElevated:  Color(0xFF162018),
    surfaceHigh:      Color(0xFF1E2B20),
    divider:          Color(0xFF253228),
    textPrimary:      Color(0xFFE4EFE6),
    textSecondary:    Color(0xFF7FA882),
    textTertiary:     Color(0xFF4E6B51),
    accentIron:       Color(0xFF22C55E),
    accentIronSoft:   Color(0xFF14532D),
    successLime:      Color(0xFF86EFAC),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Blood Orange ─────────────────────────────────────────
  static const bloodOrange = AppColors(
    ink:              Color(0xFF0A0500),
    surface:          Color(0xFF150A00),
    surfaceElevated:  Color(0xFF1E1000),
    surfaceHigh:      Color(0xFF291500),
    divider:          Color(0xFF362000),
    textPrimary:      Color(0xFFFFF1E6),
    textSecondary:    Color(0xFFC4956B),
    textTertiary:     Color(0xFF7A5434),
    accentIron:       Color(0xFFEA580C),
    accentIronSoft:   Color(0xFF7C2D12),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Espresso ─────────────────────────────────────────────
  static const espresso = AppColors(
    ink:              Color(0xFF0F0805),
    surface:          Color(0xFF1A0F0A),
    surfaceElevated:  Color(0xFF261710),
    surfaceHigh:      Color(0xFF322010),
    divider:          Color(0xFF3D2A18),
    textPrimary:      Color(0xFFF5EEE8),
    textSecondary:    Color(0xFFB08060),
    textTertiary:     Color(0xFF7A5A3A),
    accentIron:       Color(0xFFC2692A),
    accentIronSoft:   Color(0xFF7C3B10),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Arctic ───────────────────────────────────────────────
  static const arctic = AppColors(
    ink:              Color(0xFF050A12),
    surface:          Color(0xFF0A0F18),
    surfaceElevated:  Color(0xFF111827),
    surfaceHigh:      Color(0xFF1A2438),
    divider:          Color(0xFF243044),
    textPrimary:      Color(0xFFE8F4FE),
    textSecondary:    Color(0xFF8BAFC8),
    textTertiary:     Color(0xFF4A6E8A),
    accentIron:       Color(0xFF38BDF8),
    accentIronSoft:   Color(0xFF0C4A6E),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Obsidian ─────────────────────────────────────────────
  static const obsidian = AppColors(
    ink:              Color(0xFF080808),
    surface:          Color(0xFF0C0C0E),
    surfaceElevated:  Color(0xFF161618),
    surfaceHigh:      Color(0xFF1E1E22),
    divider:          Color(0xFF28282E),
    textPrimary:      Color(0xFFEEE8FF),
    textSecondary:    Color(0xFF8B82B0),
    textTertiary:     Color(0xFF5A5272),
    accentIron:       Color(0xFFA78BFA),
    accentIronSoft:   Color(0xFF4C1D95),
    successLime:      Color(0xFF84CC16),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  // ── Military ─────────────────────────────────────────────
  static const military = AppColors(
    ink:              Color(0xFF080C05),
    surface:          Color(0xFF0F150A),
    surfaceElevated:  Color(0xFF161F0D),
    surfaceHigh:      Color(0xFF1E2B14),
    divider:          Color(0xFF283818),
    textPrimary:      Color(0xFFE8F0E0),
    textSecondary:    Color(0xFF8AA870),
    textTertiary:     Color(0xFF5A7040),
    accentIron:       Color(0xFF84CC16),
    accentIronSoft:   Color(0xFF3A5A0A),
    successLime:      Color(0xFFA3E635),
    warningAmber:     Color(0xFFF59E0B),
    errorRose:        Color(0xFFE11D48),
  );

  @override
  AppColors copyWith({
    Color? ink, Color? surface, Color? surfaceElevated,
    Color? surfaceHigh, Color? divider,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? accentIron, Color? accentIronSoft,
    Color? successLime, Color? warningAmber, Color? errorRose,
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
    );
  }
}
