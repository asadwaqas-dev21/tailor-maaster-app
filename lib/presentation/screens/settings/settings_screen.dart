import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/data/repositories/staff_repository_impl.dart";
import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";

import "package:tailor_app/core/services/hive_service.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showStitcherSelector(BuildContext context) {
    final staffList = StaffRepositoryImpl()
        .getAllStaff()
        .where((s) => s.role == StaffRole.stitcher)
        .toList();

    if (staffList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No stitchers found. Please add a stitcher first in the Staff tab.",
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = context.theme;
        final l10n = context.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.selectStitcher,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: staffList.length,
                  itemBuilder: (c, index) {
                    final staff = staffList[index];
                    return ListTile(
                      leading: const Icon(Iconsax.user),
                      title: Text(staff.name),
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          SwitchRole(
                            role: "stitcher",
                            stitcherId: staff.id,
                            stitcherName: staff.name,
                          ),
                        );
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
              _buildSectionTitle(theme, l10n.activeProfile),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.userRole,
                            style: theme.textTheme.titleSmall,
                          ),
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: "owner",
                                label: Text(l10n.owner),
                              ),
                              ButtonSegment(
                                value: "stitcher",
                                label: Text(l10n.stitcher),
                              ),
                            ],
                            selected: {state.userRole},
                            onSelectionChanged: (selected) {
                              final nextRole = selected.first;
                              if (nextRole == "owner") {
                                context.read<SettingsBloc>().add(
                                  const SwitchRole(role: "owner"),
                                );
                              } else {
                                _showStitcherSelector(context);
                              }
                            },
                          ),
                        ],
                      ),
                      if (state.userRole == "stitcher" &&
                          state.selectedStitcherName != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.stitcher,
                              style: theme.textTheme.titleSmall,
                            ),
                            TextButton.icon(
                              onPressed: () => _showStitcherSelector(context),
                              icon: const Icon(Iconsax.user, size: 16),
                              label: Text(
                                state.selectedStitcherName!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, l10n.smtpSettings),
              const SizedBox(height: 8),
              const SmtpSettingsCard(),
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

class SmtpSettingsCard extends StatefulWidget {
  const SmtpSettingsCard({super.key});

  @override
  State<SmtpSettingsCard> createState() => _SmtpSettingsCardState();
}

class _SmtpSettingsCardState extends State<SmtpSettingsCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _sendAutomatically = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final box = HiveService.settingsBox;
    _hostController = TextEditingController(
      text: box.get("smtpHost", defaultValue: "smtp.gmail.com") as String,
    );
    _portController = TextEditingController(
      text: box.get("smtpPort", defaultValue: 587).toString(),
    );
    _emailController = TextEditingController(
      text: box.get("senderEmail", defaultValue: "") as String,
    );
    _passwordController = TextEditingController(
      text: box.get("smtpAppPassword", defaultValue: "") as String,
    );
    _sendAutomatically = box.get("sendEmailsAutomatically", defaultValue: false) as bool;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final box = HiveService.settingsBox;
      box.put("smtpHost", _hostController.text.trim());
      box.put("smtpPort", int.tryParse(_portController.text.trim()) ?? 587);
      box.put("senderEmail", _emailController.text.trim());
      box.put("smtpAppPassword", _passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.setting_2, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.smtpSettings,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.sendAutomatically,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _sendAutomatically,
                onChanged: (val) {
                  setState(() {
                    _sendAutomatically = val;
                  });
                  HiveService.settingsBox.put("sendEmailsAutomatically", val);
                  _saveSettings();
                },
              ),
              if (_sendAutomatically) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    labelText: l10n.smtpHost,
                    prefixIcon: const Icon(Icons.dns_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? l10n.requiredField : null,
                  onChanged: (_) => _saveSettings(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.smtpPort,
                    prefixIcon: const Icon(Icons.tag, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.requiredField;
                    if (int.tryParse(val) == null) return l10n.invalidAmount;
                    return null;
                  },
                  onChanged: (_) => _saveSettings(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.senderEmail,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.requiredField;
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                  onChanged: (_) => _saveSettings(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.appPassword,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? l10n.requiredField : null,
                  onChanged: (_) => _saveSettings(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
