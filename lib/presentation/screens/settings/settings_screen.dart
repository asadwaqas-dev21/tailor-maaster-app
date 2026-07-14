import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/services/shop_profile.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/data/repositories/staff_repository_impl.dart";
import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";

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
            "No stitchers found. Please add a stitcher first in Settings → Staff / Silai team.",
          ),
        ),
      );
      return;
    }

    final darzi = context.darzi;

    showModalBottomSheet(
      context: context,
      backgroundColor: darzi.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = context.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.selectStitcher,
                  style: AppTypography.ui(
                    size: 16,
                    weight: FontWeight.w600,
                    color: darzi.ink,
                  ),
                ),
              ),
              Divider(height: 1, color: darzi.line),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: staffList.length,
                  itemBuilder: (c, index) {
                    final staff = staffList[index];
                    return ListTile(
                      leading: DarziAvatar(name: staff.name, size: 36),
                      title: Text(
                        staff.name,
                        style: AppTypography.ui(
                          size: 14,
                          weight: FontWeight.w500,
                          color: darzi.ink,
                        ),
                      ),
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
    final darzi = context.darzi;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Aur",
                      style: AppTypography.display(
                        size: 22,
                        weight: FontWeight.w700,
                        color: darzi.ink,
                      ),
                    ),
                    Text(
                      "Settings · profile & preferences",
                      style: AppTypography.ui(
                        size: 12,
                        color: darzi.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionLabel(title: l10n.activeProfile),
                const SizedBox(height: 8),
                _DarziPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.userRole,
                            style: AppTypography.ui(
                              size: 13,
                              weight: FontWeight.w600,
                              color: darzi.ink,
                            ),
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
                        Divider(height: 24, color: darzi.line),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.stitcher,
                              style: AppTypography.ui(
                                size: 13,
                                weight: FontWeight.w600,
                                color: darzi.ink,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showStitcherSelector(context),
                              icon: Icon(Iconsax.user, size: 16, color: darzi.brass),
                              label: Text(
                                state.selectedStitcherName!,
                                style: AppTypography.ui(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: darzi.brass,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _ShopProfileCard(),
                if (state.isOwner) ...[
                  const SizedBox(height: 20),
                  _SectionLabel(title: "Team"),
                  const SizedBox(height: 8),
                  _DarziPanel(
                    child: _SettingsNavTile(
                      icon: Iconsax.people,
                      title: "Staff / Silai team",
                      subtitle: "Add & manage silai workers",
                      onTap: () => Navigator.pushNamed(context, "/staff/list"),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(title: l10n.settings),
                const SizedBox(height: 8),
                _DarziPanel(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          state.isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                          color: darzi.brass,
                        ),
                        title: Text(
                          l10n.darkMode,
                          style: AppTypography.ui(
                            size: 13,
                            weight: FontWeight.w600,
                            color: darzi.ink,
                          ),
                        ),
                        value: state.isDarkMode,
                        onChanged: (_) {
                          context.read<SettingsBloc>().add(const ToggleTheme());
                        },
                      ),
                      Divider(height: 1, indent: 56, color: darzi.line),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Iconsax.language_circle,
                          color: darzi.brass,
                        ),
                        title: Text(
                          l10n.language,
                          style: AppTypography.ui(
                            size: 13,
                            weight: FontWeight.w600,
                            color: darzi.ink,
                          ),
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
                const SizedBox(height: 20),
                _SectionLabel(title: l10n.smtpSettings),
                const SizedBox(height: 8),
                const SmtpSettingsCard(),
                const SizedBox(height: 20),
                _SectionLabel(title: l10n.appInfo),
                const SizedBox(height: 8),
                _DarziPanel(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Iconsax.info_circle,
                          color: darzi.brass,
                        ),
                        title: Text(
                          AppConstants.appName,
                          style: AppTypography.ui(
                            size: 13,
                            weight: FontWeight.w600,
                            color: darzi.ink,
                          ),
                        ),
                        subtitle: Text(
                          "Professional Tailor Management",
                          style: AppTypography.ui(
                            size: 12,
                            color: darzi.muted,
                          ),
                        ),
                      ),
                      Divider(height: 1, indent: 56, color: darzi.line),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Iconsax.code, color: darzi.brass),
                        title: Text(
                          l10n.version,
                          style: AppTypography.ui(
                            size: 13,
                            weight: FontWeight.w600,
                            color: darzi.ink,
                          ),
                        ),
                        trailing: Text(
                          AppConstants.appVersion,
                          style: AppTypography.mono(
                            size: 12,
                            color: darzi.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.ui(
        size: 13,
        weight: FontWeight.w600,
        color: context.darzi.muted,
      ),
    );
  }
}

class _DarziPanel extends StatelessWidget {
  final Widget child;

  const _DarziPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darzi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darzi.line),
      ),
      child: child,
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: darzi.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: darzi.brass),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.ui(
                    size: 14,
                    weight: FontWeight.w600,
                    color: darzi.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.ui(size: 11, color: darzi.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: darzi.muted),
        ],
      ),
    );
  }
}

class _ShopProfileCard extends StatefulWidget {
  const _ShopProfileCard();

  @override
  State<_ShopProfileCard> createState() => _ShopProfileCardState();
}

class _ShopProfileCardState extends State<_ShopProfileCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ShopProfile.load();
    _nameCtrl = TextEditingController(text: profile.name);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _addressCtrl = TextEditingController(text: profile.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final darzi = context.darzi;
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.ui(size: 12, color: darzi.muted),
      filled: true,
      fillColor: darzi.panel,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ShopProfile.save(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      address: _addressCtrl.text,
    );
    if (mounted) {
      setState(() => _saving = false);
      context.showSnackBar("Dukan ki maloomat save ho gayi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;

    return _DarziPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.shop, size: 20, color: darzi.brass),
              const SizedBox(width: 8),
              Text(
                "Dukan ki maloomat",
                style: AppTypography.ui(
                  size: 14,
                  weight: FontWeight.w600,
                  color: darzi.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDecoration(context, "Dukan ka naam"),
            style: AppTypography.ui(size: 14, color: darzi.ink),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(context, "Phone"),
            style: AppTypography.ui(size: 14, color: darzi.ink),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            maxLines: 2,
            decoration: _inputDecoration(context, "Pata / Address"),
            style: AppTypography.ui(size: 14, color: darzi.ink),
          ),
          const SizedBox(height: 16),
          DarziButton(
            label: _saving ? "Saving…" : "Save",
            icon: Iconsax.tick_circle,
            onPressed: _saving ? null : _save,
            expanded: true,
          ),
        ],
      ),
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
    _sendAutomatically =
        box.get("sendEmailsAutomatically", defaultValue: false) as bool;
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

  InputDecoration _inputDecoration(BuildContext context, String label, {Widget? suffixIcon, IconData? prefixIcon}) {
    final darzi = context.darzi;
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.ui(size: 12, color: darzi.muted),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: darzi.panel,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final darzi = context.darzi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darzi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darzi.line),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.setting_2, color: darzi.brass),
                const SizedBox(width: 8),
                Text(
                  l10n.smtpSettings,
                  style: AppTypography.ui(
                    size: 14,
                    weight: FontWeight.w600,
                    color: darzi.ink,
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: darzi.line),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.sendAutomatically,
                style: AppTypography.ui(
                  size: 13,
                  weight: FontWeight.w500,
                  color: darzi.ink,
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
                decoration: _inputDecoration(context, l10n.smtpHost, prefixIcon: Icons.dns_outlined),
                style: AppTypography.ui(size: 14, color: darzi.ink),
                validator: (val) =>
                    val == null || val.isEmpty ? l10n.requiredField : null,
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(context, l10n.smtpPort, prefixIcon: Icons.tag),
                style: AppTypography.ui(size: 14, color: darzi.ink),
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
                decoration: _inputDecoration(context, l10n.senderEmail, prefixIcon: Icons.email_outlined),
                style: AppTypography.ui(size: 14, color: darzi.ink),
                validator: (val) {
                  if (val == null || val.isEmpty) return l10n.requiredField;
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                decoration: _inputDecoration(
                  context,
                  l10n.appPassword,
                  prefixIcon: Icons.lock_outline,
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
                ),
                style: AppTypography.ui(size: 14, color: darzi.ink),
                validator: (val) =>
                    val == null || val.isEmpty ? l10n.requiredField : null,
                onChanged: (_) => _saveSettings(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
