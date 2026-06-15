import "package:flutter/material.dart";

class AppColors {
  AppColors._();

  // ── Light Theme Colors ──
  static const Color lightPrimary = Color(0xFF1A237E);
  static const Color lightPrimaryVariant = Color(0xFF283593);
  static const Color lightSecondary = Color(0xFF00897B);
  static const Color lightSecondaryVariant = Color(0xFF00695C);
  static const Color lightAccent = Color(0xFFFFB300);
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFD32F2F);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightInputFill = Color(0xFFF3F4F6);
  static const Color lightShimmer = Color(0xFFE0E0E0);

  // ── Dark Theme Colors ──
  static const Color darkPrimary = Color(0xFF5C6BC0);
  static const Color darkPrimaryVariant = Color(0xFF7986CB);
  static const Color darkSecondary = Color(0xFF26A69A);
  static const Color darkSecondaryVariant = Color(0xFF4DB6AC);
  static const Color darkAccent = Color(0xFFFFCA28);
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1E1E2C);
  static const Color darkCard = Color(0xFF2A2A3C);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFE8E8F0);
  static const Color darkOnSurface = Color(0xFFE8E8F0);
  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF374151);
  static const Color darkInputFill = Color(0xFF252536);
  static const Color darkShimmer = Color(0xFF374151);

  // ── Status Colors (Shared) ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF2A2A3C), Color(0xFF1E1E2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
