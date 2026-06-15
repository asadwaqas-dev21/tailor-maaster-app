import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/app_button.dart";
import "package:tailor_app/core/widgets/app_dropdown.dart";
import "package:tailor_app/core/widgets/photo_picker_widget.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_bloc.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_event.dart";
import "package:uuid/uuid.dart";

class MeasurementFormScreen extends StatefulWidget {
  final String customerId;
  final Measurement? measurement;

  const MeasurementFormScreen({
    super.key,
    required this.customerId,
    this.measurement,
  });

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.measurement != null;

  String? _selectedCategory;
  final Map<String, TextEditingController> _fieldControllers = {};
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final m = widget.measurement!;
      _selectedCategory = m.category;
      _photoPaths = List.from(m.photoPaths);
      _initFieldControllers(m.category, m.fields);
    }
  }

  void _initFieldControllers(String category, [Map<String, double>? values]) {
    _fieldControllers.forEach((_, c) => c.dispose());
    _fieldControllers.clear();

    final fields = MeasurementFields.categories[category] ?? [];
    for (final field in fields) {
      _fieldControllers[field.key] = TextEditingController(
        text: values?[field.key]?.toString() ?? "",
      );
    }
  }

  @override
  void dispose() {
    _fieldControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    setState(() {
      _selectedCategory = category;
      _initFieldControllers(category);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      context.showSnackBar(context.l10n.requiredField, isError: true);
      return;
    }

    final fields = <String, double>{};
    _fieldControllers.forEach((key, ctrl) {
      final value = double.tryParse(ctrl.text);
      if (value != null) {
        fields[key] = value;
      }
    });

    final measurement = Measurement(
      id: widget.measurement?.id ?? const Uuid().v4(),
      customerId: widget.customerId,
      category: _selectedCategory!,
      fields: fields,
      photoPaths: _photoPaths,
      createdAt: widget.measurement?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<MeasurementBloc>().add(UpdateMeasurement(measurement));
      context.showSnackBar(context.l10n.measurementUpdated);
    } else {
      context.read<MeasurementBloc>().add(AddMeasurement(measurement));
      context.showSnackBar(context.l10n.measurementAdded);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditing ? l10n.editMeasurement : l10n.addMeasurement),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppDropdown<String>(
              label: l10n.selectCategory,
              value: _selectedCategory,
              hint: l10n.selectCategory,
              items: MeasurementFields.categoryLabelsEn.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: _onCategoryChanged,
              validator: (v) => v == null ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            if (_selectedCategory != null) ...[
              Text(
                MeasurementFields.categoryLabelsEn[_selectedCategory!] ?? "",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildMeasurementFields(context),
              const SizedBox(height: 20),
              PhotoPickerWidget(
                photoPaths: _photoPaths,
                onPhotoAdded: (path) {
                  setState(() => _photoPaths.add(path));
                },
                onPhotoRemoved: (index) {
                  setState(() => _photoPaths.removeAt(index));
                },
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: l10n.save,
              icon: Iconsax.tick_circle,
              onPressed: _selectedCategory != null ? _onSave : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementFields(BuildContext context) {
    final fields = MeasurementFields.categories[_selectedCategory] ?? [];
    final isUrdu = context.isUrdu;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        final label = isUrdu ? field.labelUr : field.labelEn;
        return TextFormField(
          controller: _fieldControllers[field.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
          ],
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context).textTheme.bodySmall,
            suffixText: "in",
          ),
        );
      },
    );
  }
}
