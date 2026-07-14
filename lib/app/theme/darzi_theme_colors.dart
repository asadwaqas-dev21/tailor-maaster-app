import "package:flutter/material.dart";
import "package:tailor_app/app/theme/app_colors.dart";

/// Theme-aware Darzi surfaces — use instead of hardcoded light tokens.
class DarziThemeColors {
  final bool isDark;

  const DarziThemeColors._(this.isDark);

  factory DarziThemeColors.of(BuildContext context) {
    return DarziThemeColors._(
      Theme.of(context).brightness == Brightness.dark,
    );
  }

  Color get scaffold => isDark ? AppColors.darkBackground : AppColors.paper;
  Color get surface => isDark ? AppColors.darkCard : Colors.white;
  Color get panel => isDark ? AppColors.darkInputFill : AppColors.paperPanel;
  Color get ink => isDark ? AppColors.darkTextPrimary : AppColors.ink;
  Color get muted => isDark ? AppColors.darkTextSecondary : AppColors.muted;
  Color get line => isDark ? AppColors.pineLine : AppColors.line;
  Color get navBar => isDark ? AppColors.darkSurface : Colors.white;
  Color get iconBtn => isDark ? AppColors.darkInputFill : AppColors.paperPanel;
  Color get pine => AppColors.pine;
  Color get brass => isDark ? AppColors.brassSoft : AppColors.brass;
}
