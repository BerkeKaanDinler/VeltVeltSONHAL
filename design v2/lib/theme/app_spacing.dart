/// VELT — Spacing & Radius constants
/// 4pt base grid. Never use magic numbers in widgets.

abstract class AppSpacing {
  AppSpacing._();

  // Base grid
  static const double xxs  =  4;
  static const double xs   =  8;
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;

  // Screen-level
  static const double screenH      = 16;   // horizontal margin
  static const double sectionGap   = 22;   // gap between major sections
  static const double bottomNavPad = 100;  // bottom padding above tab bar
}

abstract class AppRadius {
  AppRadius._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;  // Cards, list rows
  static const double lg   = 16;
  static const double xl   = 20;  // Bottom sheet top corners
  static const double full = 999;
}

abstract class AppTouchTarget {
  AppTouchTarget._();

  static const double minimum    = 44;
  static const double primary    = 52;  // PrimaryButton
  static const double secondary  = 38;  // GhostButton md
  static const double small      = 32;  // chips, steppers
  static const double tabBar     = 64;
}
