/// VELT — Typography
/// Inter for everything; JetBrains Mono for numerics in workout/timer contexts.
/// ALL numeric Text widgets must use tabular figures.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  AppTypography._();

  static const _tabular = [FontFeature.tabularFigures()];

  // ─── Display ──────────────────────────────────────────────
  /// 56pt — PR hero number
  static TextStyle displayXL(Color color) => GoogleFonts.inter(
    fontSize: 56, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -2.8, height: 1.0, fontFeatures: _tabular,
  );

  /// 34pt — Screen titles (Home, Train, Progress headers)
  static TextStyle displayL(Color color) => GoogleFonts.inter(
    fontSize: 34, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -1.36, height: 1.05,
  );

  /// 28pt — Detail screen titles, big stat values
  static TextStyle displayM(Color color) => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -0.98, height: 1.1,
  );

  /// 22pt — Stat box values
  static TextStyle displayS(Color color) => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -0.55, height: 1.0, fontFeatures: _tabular,
  );

  // ─── Title ────────────────────────────────────────────────
  /// 18pt — Active workout exercise names
  static TextStyle titleL(Color color) => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -0.36,
  );

  /// 16pt — Card titles, primary list items
  static TextStyle titleM(Color color) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w700, color: color,
    letterSpacing: -0.16,
  );

  /// 15pt — Primary buttons (lg)
  static TextStyle titleS(Color color) => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w700, color: color,
    letterSpacing: 0.15,
  );

  // ─── Body ─────────────────────────────────────────────────
  /// 14pt — Default body
  static TextStyle bodyL(Color color) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500, color: color,
    letterSpacing: -0.07,
  );

  /// 13pt — Secondary body, motivation, button labels (sm)
  static TextStyle bodyM(Color color) => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w500, color: color,
  );

  /// 12pt — Captions, metadata
  static TextStyle bodyS(Color color) => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, color: color,
  );

  /// 11pt — Tertiary metadata, dates
  static TextStyle bodyXS(Color color) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500, color: color,
  );

  // ─── Mono (numerics) ──────────────────────────────────────
  /// 16pt — Workout set weight × reps, timers
  static TextStyle mono(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 16, fontWeight: FontWeight.w600, color: color,
    letterSpacing: -0.32, fontFeatures: _tabular,
  );

  /// 14pt — Compact mono (set rows)
  static TextStyle monoSm(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 14, fontWeight: FontWeight.w700, color: color,
    fontFeatures: _tabular,
  );

  // ─── Caption (uppercase tracking) ─────────────────────────
  /// 11pt — Section labels: uppercase, tracked
  static TextStyle sectionHeader(Color color) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, color: color,
    letterSpacing: 0.88, // 0.08em
  );

  /// 10pt — Pro/special labels (more tracking)
  static TextStyle proLabel(Color color) => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700, color: color,
    letterSpacing: 1.0, // 0.10em
  );

  /// 10pt — Stat box labels
  static TextStyle statLabel(Color color) => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w600, color: color,
    letterSpacing: 0.8, // 0.08em
  );
}
