import "package:flutter/material.dart";

/// Darzi design tokens — matches the product UI mockup.
class AppColors {
  AppColors._();

  // ── Brand ──
  static const Color pine = Color(0xFF0E3B38);
  static const Color pineDeep = Color(0xFF092A28);
  static const Color pineLine = Color(0xFF1C524E);
  static const Color brass = Color(0xFFC99A3C);
  static const Color brassSoft = Color(0xFFE7CD8A);
  static const Color brassDark = Color(0xFFA97E28);
  static const Color crimson = Color(0xFFC0442F);
  static const Color paper = Color(0xFFFBF8F1);
  static const Color paperPanel = Color(0xFFF1EADA);
  static const Color ink = Color(0xFF173230);
  static const Color muted = Color(0xFF6E7E79);
  static const Color line = Color(0xFFE6DECC);
  static const Color ready = Color(0xFF2E9E6B);
  static const Color whatsapp = Color(0xFF25D366);

  // ── Status pills ──
  static const Color pillCutBg = Color(0xFFFCF1DC);
  static const Color pillCutFg = Color(0xFFA9791B);
  static const Color pillStitchBg = Color(0xFFE2EFEC);
  static const Color pillStitchFg = Color(0xFF1D6F62);
  static const Color pillReadyBg = Color(0xFFE2F3EA);
  static const Color pillReadyFg = Color(0xFF1F7A4D);

  // ── Light Theme (mapped for Material) ──
  static const Color lightPrimary = pine;
  static const Color lightPrimaryVariant = pineDeep;
  static const Color lightSecondary = brass;
  static const Color lightSecondaryVariant = brassDark;
  static const Color lightAccent = brass;
  static const Color lightBackground = paper;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightError = crimson;
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = pineDeep;
  static const Color lightOnBackground = ink;
  static const Color lightOnSurface = ink;
  static const Color lightTextPrimary = ink;
  static const Color lightTextSecondary = muted;
  static const Color lightDivider = line;
  static const Color lightInputFill = paperPanel;
  static const Color lightShimmer = Color(0xFFE0D8C8);

  // ── Dark Theme (pine-forward) ──
  static const Color darkPrimary = brass;
  static const Color darkPrimaryVariant = brassSoft;
  static const Color darkSecondary = Color(0xFF2E9E6B);
  static const Color darkSecondaryVariant = Color(0xFF1D6F62);
  static const Color darkAccent = brassSoft;
  static const Color darkBackground = pineDeep;
  static const Color darkSurface = pine;
  static const Color darkCard = Color(0xFF134441);
  static const Color darkError = Color(0xFFE07060);
  static const Color darkOnPrimary = pineDeep;
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFEEF4F2);
  static const Color darkOnSurface = Color(0xFFEEF4F2);
  static const Color darkTextPrimary = Color(0xFFEEF4F2);
  static const Color darkTextSecondary = Color(0xFF9DB6B1);
  static const Color darkDivider = pineLine;
  static const Color darkInputFill = Color(0xFF0C1918);
  static const Color darkShimmer = pineLine;

  // ── Status Colors (Shared) ──
  static const Color success = ready;
  static const Color warning = brass;
  static const Color info = Color(0xFF1D6F62);
  static const Color danger = crimson;

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [pine, pineDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [pine, Color(0xFF051A18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brassGradient = LinearGradient(
    colors: [brass, brassDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = brassGradient;

  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), paper],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF134441), pine],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarCrimson = LinearGradient(
    colors: [Color(0xFFC0442F), Color(0xFF8F2F21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarPine = LinearGradient(
    colors: [Color(0xFF1D6F62), pine],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarBrass = LinearGradient(
    colors: [brass, brassDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
