import "package:equatable/equatable.dart";
import "package:flutter/material.dart";

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale("en"),
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isUrdu => locale.languageCode == "ur";

  @override
  List<Object?> get props => [themeMode, locale];
}
