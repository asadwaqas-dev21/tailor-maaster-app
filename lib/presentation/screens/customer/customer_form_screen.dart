import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/app_button.dart";
import "package:tailor_app/core/widgets/app_dropdown.dart";
import "package:tailor_app/core/widgets/app_text_field.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/presentation/blocs/customer/customer_bloc.dart";
import "package:tailor_app/presentation/blocs/customer/customer_event.dart";
import "package:uuid/uuid.dart";

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  Gender _gender = Gender.male;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer?.name ?? "");
    _phoneCtrl = TextEditingController(text: widget.customer?.phone ?? "");
    _addressCtrl = TextEditingController(text: widget.customer?.address ?? "");
    _notesCtrl = TextEditingController(text: widget.customer?.notes ?? "");
    _gender = widget.customer?.gender ?? Gender.male;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      gender: _gender,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<CustomerBloc>().add(UpdateCustomer(customer));
      context.showSnackBar(context.l10n.customerUpdated);
    } else {
      context.read<CustomerBloc>().add(AddCustomer(customer));
      context.showSnackBar(context.l10n.customerAdded);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCustomer : l10n.addCustomer),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: l10n.customerName,
              controller: _nameCtrl,
              prefixIcon: const Icon(Iconsax.user, size: 20),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.phone,
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Iconsax.call, size: 20),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            AppDropdown<Gender>(
              label: l10n.gender,
              value: _gender,
              items: [
                DropdownMenuItem(value: Gender.male, child: Text(l10n.male)),
                DropdownMenuItem(value: Gender.female, child: Text(l10n.female)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "${l10n.address} (${l10n.optional})",
              controller: _addressCtrl,
              prefixIcon: const Icon(Iconsax.location, size: 20),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "${l10n.notes} (${l10n.optional})",
              controller: _notesCtrl,
              prefixIcon: const Icon(Iconsax.note_1, size: 20),
              maxLines: 3,
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
