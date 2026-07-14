import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Darzi typography:
/// - Bricolage Grotesque — display / titles
/// - Inter — UI body
/// - Space Mono — naap numbers & PKR
/// - Noto Nastaliq Urdu — Urdu labels
class AppTypography {
  AppTypography._();

  static TextStyle display({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle urdu({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.notoNastaliqUrdu(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: display(size: 32, weight: FontWeight.w800, letterSpacing: -0.5),
      displayMedium: display(size: 28, weight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: display(size: 24, weight: FontWeight.w700),
      headlineLarge: display(size: 22, weight: FontWeight.w700),
      headlineMedium: display(size: 20, weight: FontWeight.w700),
      headlineSmall: display(size: 18, weight: FontWeight.w600),
      titleLarge: display(size: 18, weight: FontWeight.w600),
      titleMedium: ui(size: 16, weight: FontWeight.w500, letterSpacing: 0.1),
      titleSmall: ui(size: 14, weight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: ui(size: 16, letterSpacing: 0.15),
      bodyMedium: ui(size: 14, letterSpacing: 0.25),
      bodySmall: ui(size: 12, letterSpacing: 0.4),
      labelLarge: ui(size: 14, weight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: ui(size: 12, weight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: ui(size: 11, weight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static TextTheme get urduTextTheme {
    return TextTheme(
      displayLarge: urdu(size: 28, weight: FontWeight.w700),
      displayMedium: urdu(size: 24, weight: FontWeight.w700),
      displaySmall: urdu(size: 20, weight: FontWeight.w600),
      headlineLarge: urdu(size: 20, weight: FontWeight.w600),
      headlineMedium: urdu(size: 18, weight: FontWeight.w600),
      headlineSmall: urdu(size: 16, weight: FontWeight.w600),
      titleLarge: urdu(size: 16, weight: FontWeight.w500),
      titleMedium: urdu(size: 15, weight: FontWeight.w500),
      titleSmall: urdu(size: 14, weight: FontWeight.w500),
      bodyLarge: urdu(size: 15),
      bodyMedium: urdu(size: 14),
      bodySmall: urdu(size: 12),
      labelLarge: urdu(size: 14, weight: FontWeight.w600),
      labelMedium: urdu(size: 12, weight: FontWeight.w500),
      labelSmall: urdu(size: 11, weight: FontWeight.w500),
    );
  }
}
