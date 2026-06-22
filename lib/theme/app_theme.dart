import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Light and dark [ThemeData] for the admin portal.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.danger,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppFonts.textTheme(base.textTheme),
      cardTheme: _cardTheme(AppColors.lightSurface, AppColors.lightBorder),
      inputDecorationTheme: _inputTheme(AppColors.lightSurface, AppColors.lightBorder),
      elevatedButtonTheme: _buttonTheme,
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, space: 1),
      dataTableTheme: _dataTableTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.danger,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppFonts.textTheme(base.textTheme),
      cardTheme: _cardTheme(AppColors.darkSurface, AppColors.darkBorder),
      inputDecorationTheme: _inputTheme(AppColors.darkSurface, AppColors.darkBorder),
      elevatedButtonTheme: _buttonTheme,
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, space: 1),
      dataTableTheme: _dataTableTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
    );
  }

  static CardThemeData _cardTheme(Color surface, Color border) => CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      );

  static InputDecorationTheme _inputTheme(Color fill, Color border) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      );

  static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  static DataTableThemeData _dataTableTheme(Brightness brightness) {
    final header = brightness == Brightness.light
        ? AppColors.textSecondary
        : AppColors.textMutedOnDark;
    return DataTableThemeData(
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: header,
        fontSize: 13,
      ),
      dataTextStyle: const TextStyle(fontSize: 13.5),
    );
  }
}
