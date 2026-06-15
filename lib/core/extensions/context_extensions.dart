import "package:flutter/material.dart";
import "package:tailor_app/l10n/gen/app_localizations.dart";

extension ContextExtensions on BuildContext {
  /// Access localization strings
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Access current theme
  ThemeData get theme => Theme.of(this);

  /// Access color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Check if current locale is Urdu
  bool get isUrdu => Localizations.localeOf(this).languageCode == "ur";

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
