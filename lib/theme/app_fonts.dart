import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for the portal, built on top of Google Fonts (Poppins).
class AppFonts {
  AppFonts._();

  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.poppins(textStyle: base.bodyMedium),
      labelLarge: GoogleFonts.poppins(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
