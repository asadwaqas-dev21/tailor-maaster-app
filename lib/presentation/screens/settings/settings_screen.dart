import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(theme, l10n.settings),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        state.isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.darkMode,
                        style: theme.textTheme.titleSmall,
                      ),
                      value: state.isDarkMode,
                      onChanged: (_) {
                        context.read<SettingsBloc>().add(const ToggleTheme());
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(
                        Iconsax.language_circle,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.language,
                        style: theme.textTheme.titleSmall,
                      ),
                      trailing: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: "en", label: Text(l10n.english)),
                          ButtonSegment(value: "ur", label: Text(l10n.urdu)),
                        ],
                        selected: {state.locale.languageCode},
                        onSelectionChanged: (selected) {
                          context.read<SettingsBloc>().add(
                            ChangeLocale(Locale(selected.first)),
                          );
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, l10n.appInfo),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Iconsax.info_circle,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        "Professional Tailor Management",
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(
                        Iconsax.code,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.version,
                        style: theme.textTheme.titleSmall,
                      ),
                      trailing: Text(
                        AppConstants.appVersion,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
