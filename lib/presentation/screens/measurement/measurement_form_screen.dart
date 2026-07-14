import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/photo_picker_widget.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_bloc.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_event.dart";
import "package:uuid/uuid.dart";

/// Naap Book — matches Darzi mockup screen 02.
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
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _customer = CustomerRepositoryImpl().getCustomerById(widget.customerId);
    if (_isEditing) {
      final m = widget.measurement!;
      _selectedCategory = m.category;
      _photoPaths = List.from(m.photoPaths);
      _initFieldControllers(m.category, m.fields);
    } else {
      _selectedCategory = "shalwar_kameez";
      _initFieldControllers(_selectedCategory!);
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

  void _onCategoryChanged(String category) {
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
      if (value != null) fields[key] = value;
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
    final categories = MeasurementFields.primaryCategories
        .map((k) => MapEntry(k, MeasurementFields.categoryLabelsEn[k]!))
        .toList();

    String formatPhone(String phone) {
      final d = phone.replaceAll(RegExp(r"\D"), "");
      if (d.length >= 10) {
        return "${d.substring(0, 4)}-${d.substring(4)}";
      }
      return phone;
    }

    final darzi = context.darzi;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: Row(
                  children: [
                    DarziIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Naya Order",
                            style: AppTypography.display(
                              size: 16,
                              weight: FontWeight.w700,
                              color: darzi.ink,
                            ),
                          ),
                          Text(
                            "ناپ درج کریں",
                            style: AppTypography.urdu(
                              size: 13,
                              color: darzi.brass,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DarziIconButton(
                      icon: Iconsax.user,
                      onTap: () {
                        if (_customer != null) {
                          Navigator.of(context).pushNamed(
                            "/customer/detail",
                            arguments: _customer!.id,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: categories.map((e) {
                        final on = e.key == _selectedCategory;
                        return GestureDetector(
                          onTap: () => _onCategoryChanged(e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: on ? AppColors.pine : darzi.panel,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              e.value,
                              style: AppTypography.ui(
                                size: 11.5,
                                weight: FontWeight.w500,
                                color: on ? Colors.white : darzi.muted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (_customer != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: darzi.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: darzi.line),
                        ),
                        child: Row(
                          children: [
                            DarziAvatar(name: _customer!.name, size: 34),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _customer!.name,
                                    style: AppTypography.ui(
                                      size: 13,
                                      weight: FontWeight.w600,
                                      color: darzi.ink,
                                    ),
                                  ),
                                  Text(
                                    formatPhone(_customer!.phone),
                                    style: AppTypography.ui(
                                      size: 10.5,
                                      color: darzi.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_customer!.isRegular)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pillReadyBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Regular",
                                  style: AppTypography.ui(
                                    size: 9.5,
                                    weight: FontWeight.w600,
                                    color: AppColors.pillReadyFg,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    const MeasuringTapeBar(),
                    const SizedBox(height: 14),
                    if (_selectedCategory != null) _buildFields(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: AppTypography.ui(
                                size: 11,
                                color: darzi.muted,
                              ),
                              children: [
                                TextSpan(
                                  text: "پرانی ناپ",
                                  style: AppTypography.urdu(
                                    size: 12.5,
                                    color: darzi.muted,
                                  ),
                                ),
                                TextSpan(
                                  text: _isEditing
                                      ? " · update mode"
                                      : " · naya entry",
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_customer != null) {
                              Navigator.of(context).pushNamed(
                                "/customer/detail",
                                arguments: _customer!.id,
                              );
                            }
                          },
                          child: Text(
                            "History dekhein",
                            style: AppTypography.ui(
                              size: 11,
                              weight: FontWeight.w600,
                              color: darzi.brass,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                decoration: BoxDecoration(
                  color: darzi.surface,
                  border: Border(top: BorderSide(color: darzi.line)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: darzi.panel,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.mic_none_rounded,
                        color: AppColors.pine,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DarziButton(
                        label: "Naap save karein",
                        icon: Icons.check_rounded,
                        onPressed:
                            _selectedCategory != null ? _onSave : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    final darzi = context.darzi;
    final fields = MeasurementFields.categories[_selectedCategory] ?? [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.55,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: darzi.panel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTypography.ui(size: 10.5, color: darzi.muted),
                  children: [
                    TextSpan(text: "${field.labelEn} "),
                    TextSpan(
                      text: field.labelUr,
                      style: AppTypography.urdu(
                        size: 12,
                        color: darzi.ink,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: TextFormField(
                  controller: _fieldControllers[field.key],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                  ],
                  style: AppTypography.mono(
                    size: 19,
                    weight: FontWeight.w700,
                    color: AppColors.pine,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixText: "in",
                    suffixStyle: AppTypography.ui(
                      size: 10,
                      color: darzi.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
