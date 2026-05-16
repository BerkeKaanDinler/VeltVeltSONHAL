// VELT — AppTypography
// Inter Tight (Bold 700) for display/headings
// Inter (Regular 400 / Medium 500 / SemiBold 600) for body
// ALWAYS use FontFeature.tabularFigures() on numeric Text widgets.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  AppTypography._();

  // ── Display ──────────────────────────────────────────────
  /// PR celebrations, hero numbers — USE SPARINGLY
  static TextStyle displayXL(Color color) => GoogleFonts.interTight(
    fontSize: 48, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -1.5,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Screen titles (Home, Progress)
  static TextStyle displayL(Color color) => GoogleFonts.interTight(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -1.0,
  );

  /// Section headers, large stats
  static TextStyle displayM(Color color) => GoogleFonts.interTight(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -0.6,
  );

  // ── Title ────────────────────────────────────────────────
  /// Card titles, exercise names in active workout
  static TextStyle titleL(Color color) => GoogleFonts.interTight(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: color, letterSpacing: -0.3,
  );

  /// List row titles, routine names
  static TextStyle titleM(Color color) => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: color, letterSpacing: -0.2,
  );

  /// Buttons, tab labels, form labels
  static TextStyle titleS(Color color) => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: color, letterSpacing: 0.1,
  );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle bodyL(Color color) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: color,
  );

  static TextStyle bodyM(Color color) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: color,
  );

  static TextStyle bodyS(Color color) => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: color,
  );

  // ── Mono / Numbers ───────────────────────────────────────
  /// Set numbers (weight × reps) — ALWAYS tabular
  static TextStyle mono(Color color) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w500, color: color,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  // ── Caption ──────────────────────────────────────────────
  /// Pills, tags, badges — letter-spacing +5%
  static TextStyle caption(Color color) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500, color: color,
    letterSpacing: 0.5,
  );

  // ── Section Header ───────────────────────────────────────
  /// ALL section labels: 11px / 600 / uppercase / 0.08em tracking
  static TextStyle sectionHeader(Color color) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, color: color,
    letterSpacing: 0.9, // ~0.08em
  );
}

/// Extension for quick access from BuildContext
extension AppTypographyContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
