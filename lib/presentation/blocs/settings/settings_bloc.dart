import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/presentation/blocs/settings/settings_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<SwitchRole>(_onSwitchRole);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    final box = HiveService.settingsBox;
    final isDark = box.get("isDarkMode", defaultValue: false) as bool;
    final langCode = box.get("languageCode", defaultValue: "en") as String;
    final userRole = box.get("userRole", defaultValue: "owner") as String;
    final selectedStitcherId = box.get("selectedStitcherId") as String?;
    final selectedStitcherName = box.get("selectedStitcherName") as String?;

    emit(SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
      userRole: userRole,
      selectedStitcherId: selectedStitcherId,
      selectedStitcherName: selectedStitcherName,
    ));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    HiveService.settingsBox.put("isDarkMode", newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  void _onChangeLocale(ChangeLocale event, Emitter<SettingsState> emit) {
    HiveService.settingsBox.put("languageCode", event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  void _onSwitchRole(SwitchRole event, Emitter<SettingsState> emit) {
    HiveService.settingsBox.put("userRole", event.role);
    HiveService.settingsBox.put("selectedStitcherId", event.stitcherId);
    HiveService.settingsBox.put("selectedStitcherName", event.stitcherName);
    emit(state.copyWith(
      userRole: event.role,
      selectedStitcherId: event.stitcherId,
      selectedStitcherName: event.stitcherName,
    ));
  }
}
