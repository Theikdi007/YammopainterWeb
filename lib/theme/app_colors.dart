import 'package:flutter/material.dart';

/// Brand palette for the admin portal. Kept independent of [ThemeData] so the
/// same tokens can be reused inside custom widgets and charts.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD4);
  static const Color secondary = Color(0xFF00B894);
  static const Color accent = Color(0xFFFD79A8);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Light surfaces
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFF1E1E2D);
  static const Color lightBorder = Color(0xFFE6E8F0);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF15151F);
  static const Color darkSurface = Color(0xFF1E1E2D);
  static const Color darkSidebar = Color(0xFF12121A);
  static const Color darkBorder = Color(0xFF2A2A3C);

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textOnDark = Color(0xFFECECEC);
  static const Color textMutedOnDark = Color(0xFF9A9AB0);

  /// Category accent colors used across SVG management.
  static const Map<String, Color> category = {
    'Drawing': Color(0xFF6C5CE7),
    'Painting': Color(0xFFFD79A8),
    'Puzzle': Color(0xFF00B894),
  };
}
