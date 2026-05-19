/// VELT — ThemeData builders for all 4 themes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData _build(AppColors c) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: c.surface,
    extensions: [c],

    colorScheme: ColorScheme(
      brightness:        Brightness.dark,
      primary:           c.accentIron,
      onPrimary:         Colors.white,
      secondary:         c.successLime,
      onSecondary:       c.surface,
      error:             c.errorRose,
      onError:           Colors.white,
      surface:           c.surface,
      onSurface:         c.textPrimary,
      surfaceContainer:  c.surfaceElevated,
      outline:           c.divider,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor:  c.surface,
      foregroundColor:  c.textPrimary,
      elevation:        0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      c.surface,
      selectedItemColor:    c.accentIron,
      unselectedItemColor:  c.textTertiary,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
      showSelectedLabels:   true,
      showUnselectedLabels: true,
    ),

    cardTheme: CardTheme(
      color:        c.surfaceElevated,
      elevation:    0,
      margin:       EdgeInsets.zero,
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side:         BorderSide(color: c.divider.withOpacity(0.5), width: 0.5),
      ),
    ),

    dividerTheme: DividerThemeData(
      color:     c.divider,
      thickness: 0.5,
      space:     0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: c.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide:   BorderSide(color: c.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide:   BorderSide(color: c.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide:   BorderSide(color: c.accentIron, width: 1.5),
      ),
      hintStyle: TextStyle(color: c.textTertiary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.accentIron,
        foregroundColor: Colors.white,
        minimumSize:     const Size(double.infinity, AppTouchTarget.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        elevation:   0,
        shadowColor: Colors.transparent,
      ),
    ),
  );

  static ThemeData get iron     => _build(AppColors.ironDark);
  static ThemeData get slate    => _build(AppColors.slateMono);
  static ThemeData get roseGold => _build(AppColors.roseGold);
  static ThemeData get emerald  => _build(AppColors.emerald);

  /// Build ThemeData for a given VeltTheme enum
  static ThemeData of(VeltTheme theme) => _build(theme.colors);
}
