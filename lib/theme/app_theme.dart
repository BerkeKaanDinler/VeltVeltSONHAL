// VELT — AppTheme
// Usage:
//   MaterialApp(
//     theme: AppTheme.darkIron,
//     darkTheme: AppTheme.darkIron,
//   )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData _build(AppColors c) => ThemeData(
    useMaterial3: true,
    brightness: c.surface.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light,
    scaffoldBackgroundColor: c.surface,
    extensions: [c],

    // Color scheme — mapped from VELT tokens
    colorScheme: ColorScheme(
      brightness: c.surface.computeLuminance() < 0.5
          ? Brightness.dark : Brightness.light,
      primary:          c.accentIron,
      onPrimary:        Colors.white,
      secondary:        c.successLime,
      onSecondary:      c.ink,
      error:            c.errorRose,
      onError:          Colors.white,
      surface:          c.surface,
      onSurface:        c.textPrimary,
      surfaceContainer: c.surfaceElevated,
      outline:          c.divider,
    ),

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor:  c.surface,
      foregroundColor:  c.textPrimary,
      elevation:        0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            c.surface.computeLuminance() < 0.5 ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            c.surface.computeLuminance() < 0.5 ? Brightness.light : Brightness.dark,
      ),
    ),

    // Bottom nav bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      c.surface,
      selectedItemColor:    c.accentIron,
      unselectedItemColor:  c.textTertiary,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
      showSelectedLabels:   false,   // VELT uses icon-only nav
      showUnselectedLabels: false,
    ),

    // Cards
    cardTheme: CardThemeData(
      color:        c.surfaceElevated,
      elevation:    0,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.zero,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color:     c.divider,
      thickness: 0.5,
      space:     0,
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled:           true,
      fillColor:        c.surfaceElevated,
      border:           OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide:   BorderSide.none,
      ),
      hintStyle: TextStyle(color: c.textTertiary),
    ),

    // Elevated button → PrimaryButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:    c.accentIron,
        foregroundColor:    Colors.white,
        minimumSize:        const Size(double.infinity, AppTouchTarget.primaryButton),
        shape:              RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation:          0,
        shadowColor:        Colors.transparent,
      ),
    ),
  );

  // ── Public theme getters ──────────────────────────────────
  static ThemeData get darkIron        => _build(AppColors.ironDark);
  static ThemeData get warmPaper       => _build(AppColors.warmPaper);
  static ThemeData get midnightSteel   => _build(AppColors.midnightSteel);
  static ThemeData get forestIron      => _build(AppColors.forestIron);
  static ThemeData get bloodOrange     => _build(AppColors.bloodOrange);
  static ThemeData get espresso        => _build(AppColors.espresso);
  static ThemeData get arctic          => _build(AppColors.arctic);
  static ThemeData get obsidian        => _build(AppColors.obsidian);
  static ThemeData get military        => _build(AppColors.military);

  static const Map<String, AppColors> allThemes = {
    'iron':          AppColors.ironDark,
    'warmPaper':     AppColors.warmPaper,
    'midnightSteel': AppColors.midnightSteel,
    'forestIron':    AppColors.forestIron,
    'bloodOrange':   AppColors.bloodOrange,
    'espresso':      AppColors.espresso,
    'arctic':        AppColors.arctic,
    'obsidian':      AppColors.obsidian,
    'military':      AppColors.military,
  };
}
