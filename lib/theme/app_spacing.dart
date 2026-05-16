// VELT — AppSpacing + AppRadius
// 4pt base grid. Use ONLY these constants — never magic numbers.

abstract class AppSpacing {
  AppSpacing._();

  static const double xxs  =  4;
  static const double xs   =  8;
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 48;
  static const double xxxl = 64;

  /// Screen horizontal edge margin (20pt — more breathing room on modern iPhones)
  static const double screenH = 20;

  /// Content top offset below safe area
  static const double safeAreaTopPad = 16;

  /// Space above tab bar
  static const double aboveTabBar = 16;
}

abstract class AppRadius {
  AppRadius._();

  static const double xs   =  6;  // Pills, tags, small chips
  static const double sm   = 10;  // Input fields, small buttons
  static const double md   = 16;  // Standard cards, list rows ← 16px
  static const double lg   = 20;  // Bottom sheets, modals
  static const double xl   = 28;  // Paywall hero, onboarding cards
  static const double full = 999; // Circular buttons, FAB, avatar
}

abstract class AppTouchTarget {
  AppTouchTarget._();

  /// Apple HIG minimum — non-negotiable
  static const double minimum = 44;

  /// Primary CTA buttons
  static const double primaryButton = 56;

  /// Set completion checkbox (gym gloves)
  static const double setCheckbox = 48;

  /// Number steppers +/-
  static const double stepper = 48;

  /// Tab bar item
  static const double tabBar = 48;
}
