import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/services/notification_service.dart";
import "package:tailor_app/core/widgets/app_button.dart";
import "package:tailor_app/core/widgets/app_dropdown.dart";
import "package:tailor_app/core/widgets/app_text_field.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
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

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.order != null;

  // Data
  List<Customer> _customers = [];
  List<Measurement> _measurements = [];
  List<Staff> _staffList = [];

  // Form values
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
  DateTime _orderDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _customers = CustomerRepositoryImpl().getAllCustomers();
    _staffList = StaffRepositoryImpl().getAllStaff();

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
      _orderDate = o.orderDate;
      _deliveryDate = o.deliveryDate;
      _loadMeasurements(o.customerId);
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
    _fabricCtrl.dispose();
    _notesCtrl.dispose();
    _quantityCtrl.dispose();
    _totalCtrl.dispose();
    _advanceCtrl.dispose();
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
    final remaining = total - advance;

    PaymentStatus paymentStatus;
    if (remaining <= 0) {
      paymentStatus = PaymentStatus.paid;
    } else if (advance > 0) {
      paymentStatus = PaymentStatus.partial;
    } else {
      paymentStatus = PaymentStatus.unpaid;
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
      designNotes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      totalAmount: total,
      advanceAmount: advance,
      status: widget.order?.status ?? OrderStatus.pending,
      paymentStatus: paymentStatus,
      orderDate: _orderDate,
      deliveryDate: _deliveryDate,
      photoPaths: widget.order?.photoPaths ?? [],
      createdAt: widget.order?.createdAt ?? DateTime.now(),
      assignedStaffId: _selectedStaffId,
      assignedStaffName: _selectedStaffName,
    );

    if (_isEditing) {
      context.read<OrderBloc>().add(UpdateOrder(order));
      context.showSnackBar(context.l10n.orderUpdated);
    } else {
      context.read<OrderBloc>().add(AddOrder(order));
      context.showSnackBar(context.l10n.orderAdded);

      // Schedule notification
      NotificationService.scheduleDeliveryReminder(
        notificationId: order.id.hashCode,
        customerName: order.customerName,
        garmentType: order.garmentType.replaceAll("_", " "),
        deliveryDate: order.deliveryDate,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editOrder : l10n.newOrder)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCustomerPicker(context),
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            AppButton(
              label: l10n.save,
              icon: Iconsax.tick_circle,
              onPressed: _onSave,
            ),
            const SizedBox(height: 16),
          ],
        ),
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
      ],
    );
  }
}
