import "package:equatable/equatable.dart";
import "package:flutter/material.dart";

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final String userRole; // "owner" or "stitcher"
  final String? selectedStitcherId;
  final String? selectedStitcherName;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale("en"),
    this.userRole = "owner",
    this.selectedStitcherId,
    this.selectedStitcherName,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? userRole,
    String? selectedStitcherId,
    String? selectedStitcherName,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      userRole: userRole ?? this.userRole,
      selectedStitcherId: selectedStitcherId ?? this.selectedStitcherId,
      selectedStitcherName: selectedStitcherName ?? this.selectedStitcherName,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isUrdu => locale.languageCode == "ur";
  bool get isOwner => userRole == "owner";

  @override
  List<Object?> get props => [
        themeMode,
        locale,
        userRole,
        selectedStitcherId,
        selectedStitcherName,
      ];
}
