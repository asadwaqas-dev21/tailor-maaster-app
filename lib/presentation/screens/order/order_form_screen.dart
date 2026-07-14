import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/services/notification_service.dart";
import "package:tailor_app/core/services/whatsapp_service.dart";
import "package:tailor_app/core/widgets/app_dropdown.dart";
import "package:tailor_app/core/widgets/app_text_field.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/photo_picker_widget.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/data/repositories/staff_repository_impl.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";
import "package:uuid/uuid.dart";

class OrderFormScreen extends StatefulWidget {
  final Order? order;
  final String? customerId;

  const OrderFormScreen({super.key, this.order, this.customerId});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.order != null;

  List<Customer> _customers = [];
  List<Measurement> _measurements = [];
  List<Staff> _staffList = [];

  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedMeasurementId;
  String? _selectedGarmentType;
  String? _selectedStaffId;
  String? _selectedStaffName;
  final _fabricCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: "1");
  final _totalCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController(text: "0");
  final _stitchingCostCtrl = TextEditingController();
  DateTime _orderDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));

  List<String> _photoPaths = [];
  bool _isRush = false;
  double _baqayaPreview = 0;

  void _onTotalChanged() {
    if (_isEditing) return;
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    _stitchingCostCtrl.text = (total * 0.40).toStringAsFixed(0);
    _updateBaqayaPreview();
  }

  void _updateBaqayaPreview() {
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final advance = double.tryParse(_advanceCtrl.text) ?? 0;
    setState(() => _baqayaPreview = (total - advance).clamp(0, double.infinity));
  }

  @override
  void initState() {
    super.initState();
    _customers = CustomerRepositoryImpl().getAllCustomers();
    _staffList = StaffRepositoryImpl().getAllStaff();
    _totalCtrl.addListener(_onTotalChanged);
    _advanceCtrl.addListener(_updateBaqayaPreview);

    if (_isEditing) {
      final o = widget.order!;
      _selectedCustomerId = o.customerId;
      _selectedCustomerName = o.customerName;
      _selectedMeasurementId = o.measurementId;
      _selectedGarmentType = o.garmentType;
      _selectedStaffId = o.assignedStaffId;
      _selectedStaffName = o.assignedStaffName;
      _fabricCtrl.text = o.fabricDetails ?? "";
      _notesCtrl.text = o.designNotes ?? "";
      _quantityCtrl.text = "${o.quantity}";
      _totalCtrl.text = o.totalAmount.toStringAsFixed(0);
      _advanceCtrl.text = o.advanceAmount.toStringAsFixed(0);
      _stitchingCostCtrl.text = o.stitchingCost.toStringAsFixed(0);
      _orderDate = o.orderDate;
      _deliveryDate = o.deliveryDate;
      _photoPaths = List.from(o.photoPaths);
      _isRush = o.isRush;
      _baqayaPreview = o.remainingAmount;
      _loadMeasurements(o.customerId);
    } else if (widget.customerId != null) {
      _selectedCustomerId = widget.customerId;
      final customer = _customers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => Customer(
          id: "",
          name: "",
          phone: "",
          gender: Gender.male,
          createdAt: DateTime.now(),
        ),
      );
      if (customer.id.isNotEmpty) {
        _selectedCustomerName = customer.name;
        _loadMeasurements(customer.id);
      }
    }
  }

  void _loadMeasurements(String customerId) {
    setState(() {
      _measurements = MeasurementRepositoryImpl().getMeasurementsByCustomerId(
        customerId,
      );
    });
  }

  @override
  void dispose() {
    _totalCtrl.removeListener(_onTotalChanged);
    _advanceCtrl.removeListener(_updateBaqayaPreview);
    _fabricCtrl.dispose();
    _notesCtrl.dispose();
    _quantityCtrl.dispose();
    _totalCtrl.dispose();
    _advanceCtrl.dispose();
    _stitchingCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isDelivery) async {
    final initial = isDelivery ? _deliveryDate : _orderDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isDelivery) {
          _deliveryDate = date;
        } else {
          _orderDate = date;
        }
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null || _selectedGarmentType == null) {
      context.showSnackBar(context.l10n.requiredField, isError: true);
      return;
    }

    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final advance = double.tryParse(_advanceCtrl.text) ?? 0;
    final stitchingCost =
        double.tryParse(_stitchingCostCtrl.text) ?? (total * 0.40);
    final remaining = total - advance;

    PaymentStatus paymentStatus;
    if (remaining <= 0) {
      paymentStatus = PaymentStatus.paid;
    } else if (advance > 0) {
      paymentStatus = PaymentStatus.partial;
    } else {
      paymentStatus = PaymentStatus.unpaid;
    }

    final notes = _notesCtrl.text.trim();
    final notesLower = notes.toLowerCase();
    final isRush = _isRush ||
        notesLower.contains("rush") ||
        notesLower.contains("shaadi") ||
        notesLower.contains("eid");

    String tokenCode = widget.order?.tokenCode ?? "";
    if (tokenCode.isEmpty) {
      final existing = OrderRepositoryImpl().getAllOrders();
      var maxN = 1000;
      for (final o in existing) {
        final m = RegExp(r"(\d+)").firstMatch(o.tokenCode);
        if (m != null) {
          final n = int.tryParse(m.group(1)!) ?? 0;
          if (n > maxN) maxN = n;
        }
      }
      tokenCode = "DZ-${maxN + 1}";
    }

    final order = Order(
      id: widget.order?.id ?? const Uuid().v4(),
      customerId: _selectedCustomerId!,
      customerName: _selectedCustomerName ?? "",
      measurementId: _selectedMeasurementId,
      garmentType: _selectedGarmentType!,
      fabricDetails: _fabricCtrl.text.trim().isEmpty
          ? null
          : _fabricCtrl.text.trim(),
      designNotes: notes.isEmpty ? null : notes,
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      totalAmount: total,
      advanceAmount: advance,
      status: widget.order?.status ?? OrderStatus.pending,
      paymentStatus: paymentStatus,
      orderDate: _orderDate,
      deliveryDate: _deliveryDate,
      photoPaths: _photoPaths,
      createdAt: widget.order?.createdAt ?? DateTime.now(),
      assignedStaffId: _selectedStaffId,
      assignedStaffName: _selectedStaffName,
      stitchingCost: stitchingCost,
      isStitcherPaid: widget.order?.isStitcherPaid ?? false,
      tokenCode: tokenCode,
      isRush: isRush,
    );

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    if (_isEditing) {
      context.read<OrderBloc>().add(UpdateOrder(order));
      messenger.showSnackBar(SnackBar(content: Text(context.l10n.orderUpdated)));
      nav.pop();
    } else {
      context.read<OrderBloc>().add(AddOrder(order));

      NotificationService.scheduleDeliveryReminder(
        notificationId: order.id.hashCode,
        customerName: order.customerName,
        garmentType: order.garmentType.replaceAll("_", " "),
        deliveryDate: order.deliveryDate,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.orderAdded),
          action: SnackBarAction(
            label: "WhatsApp bhejein",
            onPressed: () async {
              final phone = CustomerRepositoryImpl()
                  .getCustomerById(order.customerId)
                  ?.phone;
              if (phone != null) {
                await WhatsAppService.sendOrderConfirmation(
                  phone: phone,
                  order: order,
                );
              }
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                            _isEditing ? l10n.editOrder : "Naya Order",
                            style: AppTypography.display(
                              size: 16,
                              weight: FontWeight.w700,
                              color: darzi.ink,
                            ),
                          ),
                          Text(
                            "آرڈر درج کریں",
                            style: AppTypography.urdu(
                              size: 13,
                              color: darzi.brass,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    _buildCustomerPicker(context),
                    const SizedBox(height: 16),
                    if (_selectedCustomerId != null && _measurements.isEmpty) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(
                                "/measurement/form",
                                arguments: {"customerId": _selectedCustomerId!},
                              )
                              .then((_) {
                                _loadMeasurements(_selectedCustomerId!);
                              });
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.addMeasurement),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildGarmentTypePicker(context),
                    const SizedBox(height: 16),
                    if (_measurements.isNotEmpty) ...[
                      _buildMeasurementPicker(context),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: "${l10n.fabricDetails} (${l10n.optional})",
                      controller: _fabricCtrl,
                      prefixIcon: const Icon(Iconsax.colorfilter, size: 20),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: "${l10n.designNotes} (${l10n.optional})",
                      controller: _notesCtrl,
                      prefixIcon: const Icon(Iconsax.note_1, size: 20),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Design photos",
                      style: AppTypography.ui(
                        size: 12,
                        weight: FontWeight.w600,
                        color: darzi.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhotoPickerWidget(
                      photoPaths: _photoPaths,
                      onPhotoAdded: (path) {
                        setState(() => _photoPaths.add(path));
                      },
                      onPhotoRemoved: (index) {
                        setState(() => _photoPaths.removeAt(index));
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Rush · Eid / Shaadi",
                        style: AppTypography.ui(
                          size: 14,
                          weight: FontWeight.w600,
                          color: darzi.ink,
                        ),
                      ),
                      subtitle: Text(
                        "Urgent delivery mark karein",
                        style: AppTypography.ui(size: 11, color: darzi.muted),
                      ),
                      value: _isRush,
                      activeThumbColor: AppColors.crimson,
                      onChanged: (v) => setState(() => _isRush = v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.quantity,
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Iconsax.box_1, size: 20),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? l10n.requiredField : null,
                    ),
                    const SizedBox(height: 16),
                    _buildStaffPicker(context),
                    const SizedBox(height: 16),
                    _buildDatePickers(context),
                    const SizedBox(height: 16),
                    _buildPaymentSection(context),
                    const SizedBox(height: 16),
                    _buildBaqayaPreview(context),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                decoration: BoxDecoration(
                  color: darzi.surface,
                  border: Border(top: BorderSide(color: darzi.line)),
                ),
                child: DarziButton(
                  label: l10n.save,
                  icon: Icons.check_rounded,
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaqayaPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.pine,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Baqaya",
            style: AppTypography.urdu(
              size: 15,
              color: const Color(0xFFC4D5D1),
            ),
          ),
          Text(
            "${AppConstants.currencySymbol} ${_baqayaPreview.toStringAsFixed(0)}",
            style: AppTypography.mono(
              size: 20,
              weight: FontWeight.w700,
              color: _baqayaPreview > 0
                  ? AppColors.brassSoft
                  : const Color(0xFFEEF4F2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerPicker(BuildContext context) {
    final l10n = context.l10n;
    return AppDropdown<String>(
      label: l10n.selectCustomer,
      value: _selectedCustomerId,
      hint: l10n.selectCustomer,
      items: _customers.map((c) {
        return DropdownMenuItem(
          value: c.id,
          child: Text("${c.name} - ${c.phone}"),
        );
      }).toList(),
      onChanged: (id) {
        if (id == null) return;
        final customer = _customers.firstWhere((c) => c.id == id);
        setState(() {
          _selectedCustomerId = id;
          _selectedCustomerName = customer.name;
          _selectedMeasurementId = null;
        });
        _loadMeasurements(id);
      },
      validator: (v) => v == null ? l10n.requiredField : null,
    );
  }

  Widget _buildGarmentTypePicker(BuildContext context) {
    final l10n = context.l10n;
    return AppDropdown<String>(
      label: l10n.garmentType,
      value: _selectedGarmentType,
      hint: l10n.selectCategory,
      items: MeasurementFields.categoryLabelsEn.entries.map((e) {
        return DropdownMenuItem(value: e.key, child: Text(e.value));
      }).toList(),
      onChanged: (v) => setState(() => _selectedGarmentType = v),
      validator: (v) => v == null ? l10n.requiredField : null,
    );
  }

  Widget _buildMeasurementPicker(BuildContext context) {
    final l10n = context.l10n;
    return AppDropdown<String>(
      label: "${l10n.selectMeasurement} (${l10n.optional})",
      value: _selectedMeasurementId,
      hint: l10n.selectMeasurement,
      items: _measurements.map((m) {
        final label =
            MeasurementFields.categoryLabelsEn[m.category] ?? m.category;
        return DropdownMenuItem(
          value: m.id,
          child: Text(
            "$label - ${m.createdAt.day}/${m.createdAt.month}/${m.createdAt.year}",
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedMeasurementId = v),
    );
  }

  Widget _buildStaffPicker(BuildContext context) {
    final l10n = context.l10n;
    return AppDropdown<String>(
      label: "${l10n.staff} (${l10n.optional})",
      value: _selectedStaffId,
      hint: l10n.staff,
      items: _staffList.map((s) {
        return DropdownMenuItem(
          value: s.id,
          child: Text(
            "${s.name} - ${context.isUrdu ? s.role.labelUr : s.role.labelEn}",
          ),
        );
      }).toList(),
      onChanged: (id) {
        if (id == null) return;
        final staff = _staffList.firstWhere((s) => s.id == id);
        setState(() {
          _selectedStaffId = id;
          _selectedStaffName = staff.name;
        });
      },
    );
  }

  Widget _buildDatePickers(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            label: l10n.orderDate,
            hint: "${_orderDate.day}/${_orderDate.month}/${_orderDate.year}",
            readOnly: true,
            prefixIcon: const Icon(Iconsax.calendar_1, size: 20),
            onTap: () => _pickDate(context, false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextField(
            label: l10n.deliveryDate,
            hint:
                "${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}",
            readOnly: true,
            prefixIcon: const Icon(Iconsax.calendar_tick, size: 20),
            onTap: () => _pickDate(context, true),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.totalAmount,
                controller: _totalCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Iconsax.money_2, size: 20),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.requiredField : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: l10n.advanceAmount,
                controller: _advanceCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Iconsax.money_send, size: 20),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.stitchingCost,
          controller: _stitchingCostCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Iconsax.wallet_money, size: 20),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
        ),
      ],
    );
  }
}
