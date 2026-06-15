import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Urdu-optimized text theme using Noto Nastaliq
  static TextTheme get urduTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.notoNastaliqUrdu(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.notoNastaliqUrdu(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: GoogleFonts.notoNastaliqUrdu(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.notoNastaliqUrdu(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.notoNastaliqUrdu(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.notoNastaliqUrdu(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.notoNastaliqUrdu(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.notoNastaliqUrdu(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.notoNastaliqUrdu(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.notoNastaliqUrdu(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.notoNastaliqUrdu(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.notoNastaliqUrdu(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.notoNastaliqUrdu(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.notoNastaliqUrdu(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.notoNastaliqUrdu(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
