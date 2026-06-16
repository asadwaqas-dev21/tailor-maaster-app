import "package:equatable/equatable.dart";
import "package:flutter/material.dart";

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

class ChangeLocale extends SettingsEvent {
  final Locale locale;

  const ChangeLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

class SwitchRole extends SettingsEvent {
  final String role;
  final String? stitcherId;
  final String? stitcherName;

  const SwitchRole({
    required this.role,
    this.stitcherId,
    this.stitcherName,
  });

  @override
  List<Object?> get props => [role, stitcherId, stitcherName];
}
