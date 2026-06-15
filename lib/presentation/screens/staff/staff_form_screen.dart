import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/app_button.dart";
import "package:tailor_app/core/widgets/app_dropdown.dart";
import "package:tailor_app/core/widgets/app_text_field.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/presentation/blocs/staff/staff_bloc.dart";
import "package:tailor_app/presentation/blocs/staff/staff_event.dart";
import "package:uuid/uuid.dart";

class StaffFormScreen extends StatefulWidget {
  final Staff? staff;

  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  StaffRole _role = StaffRole.cutter;

  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.staff?.name ?? "");
    _phoneCtrl = TextEditingController(text: widget.staff?.phone ?? "");
    _role = widget.staff?.role ?? StaffRole.cutter;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final staff = Staff(
      id: widget.staff?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _role,
      isActive: widget.staff?.isActive ?? true,
      createdAt: widget.staff?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<StaffBloc>().add(UpdateStaff(staff));
      context.showSnackBar("Staff updated successfully");
    } else {
      context.read<StaffBloc>().add(AddStaff(staff));
      context.showSnackBar("Staff added successfully");
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isUrdu = context.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Staff" : "Add Staff"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: "Name",
              controller: _nameCtrl,
              prefixIcon: const Icon(Iconsax.user, size: 20),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "Phone",
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Iconsax.call, size: 20),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            AppDropdown<StaffRole>(
              label: "Role",
              value: _role,
              items: StaffRole.values.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(isUrdu ? r.labelUr : r.labelEn),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _role = v);
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              label: l10n.save,
              icon: Iconsax.tick_circle,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
