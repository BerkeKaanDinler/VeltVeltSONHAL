import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  AppTypography._();

  static const _inter = 'Inter';

  // ── Display ──────────────────────────────────────────────
  static TextStyle displayXL(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 48, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -1.5,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle displayL(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 34, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -1.0,
  );

  static TextStyle displayM(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 28, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -0.6,
  );

  // ── Title ────────────────────────────────────────────────
  static TextStyle titleL(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 22, fontWeight: FontWeight.w600,
    color: color, letterSpacing: -0.3,
  );

  static TextStyle titleM(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 17, fontWeight: FontWeight.w600,
    color: color, letterSpacing: -0.2,
  );

  static TextStyle titleS(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 15, fontWeight: FontWeight.w600,
    color: color, letterSpacing: 0.1,
  );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle bodyL(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 16, fontWeight: FontWeight.w400, color: color,
  );

  static TextStyle bodyM(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 14, fontWeight: FontWeight.w400, color: color,
  );

  static TextStyle bodyS(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 12, fontWeight: FontWeight.w400, color: color,
  );

  // ── Mono / Numbers ───────────────────────────────────────
  static TextStyle mono(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 16, fontWeight: FontWeight.w500, color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ── Caption ──────────────────────────────────────────────
  static TextStyle caption(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 11, fontWeight: FontWeight.w500, color: color,
    letterSpacing: 0.5,
  );

  // ── Section Header ───────────────────────────────────────
  static TextStyle sectionHeader(Color color) => TextStyle(
    fontFamily: _inter,
    fontSize: 11, fontWeight: FontWeight.w600, color: color,
    letterSpacing: 0.9,
  );
}

extension AppTypographyContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
