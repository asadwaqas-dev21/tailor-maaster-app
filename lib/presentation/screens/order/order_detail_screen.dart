import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/services/pdf_service.dart";
import "package:tailor_app/core/services/whatsapp_service.dart";
import "package:tailor_app/core/widgets/confirm_dialog.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";
import "package:tailor_app/presentation/blocs/order/order_state.dart";

/// Order Slip — matches Darzi mockup screen 04.
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  String? _customerPhone;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final order = OrderRepositoryImpl().getOrderById(widget.orderId);
    setState(() {
      _order = order;
      if (order != null) {
        _customerPhone =
            CustomerRepositoryImpl().getCustomerById(order.customerId)?.phone;
      }
    });
  }

  String get _token => _order?.displayToken ?? "DZ-1042";

  Future<void> _onUpdateStatus() async {
    if (_order == null) return;
    final nextStatus = _order!.status.next;
    if (nextStatus == null) return;

    // Completing (deliver): require payment entry first
    if (nextStatus == OrderStatus.delivered) {
      final paid = await _showCompletePaymentDialog(_order!);
      if (paid == null || !mounted) return;
      _completeOrderWithPayment(paid);
      return;
    }

    context.read<OrderBloc>().add(
          UpdateOrderStatus(orderId: _order!.id, status: nextStatus),
        );
    context.showSnackBar(context.l10n.statusUpdated);
    _loadData();
  }

  /// Returns payment amount entered, or null if cancelled.
  Future<double?> _showCompletePaymentDialog(Order order) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.darzi.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _CompletePaymentSheet(order: order),
    );
  }

  void _completeOrderWithPayment(double paymentAmount) {
    _applyPayment(paymentAmount, deliver: true);
  }

  Future<void> _showAdvancePaymentSheet() async {
    if (_order == null) return;
    final paid = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.darzi.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _AdvancePaymentSheet(order: _order!),
    );
    if (paid == null || !mounted) return;
    _applyPayment(paid, deliver: false);
  }

  void _applyPayment(double paymentAmount, {required bool deliver}) {
    final order = _order!;
    final newAdvance =
        (order.advanceAmount + paymentAmount).clamp(0.0, order.totalAmount);
    final remaining = order.totalAmount - newAdvance;

    final PaymentStatus paymentStatus;
    if (remaining <= 0) {
      paymentStatus = PaymentStatus.paid;
    } else if (newAdvance > 0) {
      paymentStatus = PaymentStatus.partial;
    } else {
      paymentStatus = PaymentStatus.unpaid;
    }

    final updated = order.copyWith(
      advanceAmount: newAdvance,
      paymentStatus: paymentStatus,
      status: deliver ? OrderStatus.delivered : order.status,
    );

    context.read<OrderBloc>().add(UpdateOrder(updated));
    if (deliver) {
      context.showSnackBar(
        paymentAmount > 0
            ? "Payment ${AppConstants.currencySymbol} ${paymentAmount.toStringAsFixed(0)} · Order deliver ho gaya"
            : "Order deliver ho gaya",
      );
    } else {
      context.showSnackBar(
        paymentAmount > 0
            ? "Advance ${AppConstants.currencySymbol} ${paymentAmount.toStringAsFixed(0)} save ho gaya"
            : "Payment update ho gaya",
      );
    }
    _loadData();
  }

  Future<void> _deleteOrder() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.delete,
      message: context.l10n.deleteOrderMessage,
      confirmText: context.l10n.delete,
      icon: Iconsax.trash,
    );
    if (confirmed && mounted) {
      context.read<OrderBloc>().add(DeleteOrder(widget.orderId));
      context.showSnackBar(context.l10n.orderDeleted);
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendReadyWhatsApp() async {
    if (_order == null || _customerPhone == null || _customerPhone!.isEmpty) {
      context.showSnackBar("Customer phone nahi mila", isError: true);
      return;
    }
    await WhatsAppService.sendReadyForPickup(
      phone: _customerPhone!,
      order: _order!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStitcher =
        HiveService.settingsBox.get("userRole", defaultValue: "owner") ==
            "stitcher";

    final darzi = context.darzi;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) _loadData();
      },
      child: _order == null
          ? Scaffold(
              backgroundColor: darzi.scaffold,
              appBar: AppBar(),
              body: const Center(child: Text("Order not found")),
            )
          : Scaffold(
              backgroundColor: darzi.scaffold,
              body: SafeArea(
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
                            child: Text(
                              "Order detail",
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                size: 16,
                                weight: FontWeight.w700,
                                color: darzi.ink,
                              ),
                            ),
                          ),
                          DarziIconButton(
                            icon: Iconsax.export_1,
                            onTap: () => _showOrderActions(isStitcher),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        children: [
                          _OrderHead(
                            token: _token,
                            order: _order!,
                            phone: _customerPhone,
                          ),
                          const SizedBox(height: 14),
                          _DesignFabricSection(order: _order!),
                          const SizedBox(height: 14),
                          _PayBox(order: _order!),
                        ],
                      ),
                    ),
                    if (!isStitcher &&
                        (_order!.remainingAmount > 0 &&
                                _order!.status != OrderStatus.delivered ||
                            _customerPhone != null))
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        decoration: BoxDecoration(
                          color: darzi.surface,
                          border:
                              Border(top: BorderSide(color: darzi.line)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_order!.remainingAmount > 0 &&
                                _order!.status != OrderStatus.delivered) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: _showAdvancePaymentSheet,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.pine,
                                    side: const BorderSide(
                                      color: AppColors.pine,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Iconsax.money, size: 18),
                                  label: Text(
                                    "Advance lein",
                                    style: AppTypography.ui(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: AppColors.pine,
                                    ),
                                  ),
                                ),
                              ),
                              if (_customerPhone != null)
                                const SizedBox(height: 10),
                            ],
                            if (_customerPhone != null)
                              DarziButton(
                                label: '"Ready hai" bhejein',
                                icon: Iconsax.message,
                                variant: DarziButtonVariant.whatsapp,
                                onPressed: _sendReadyWhatsApp,
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

  void _showOrderActions(bool isStitcher) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.darzi.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.export_1, color: AppColors.pine),
                title: const Text("Share / PDF"),
                onTap: () {
                  Navigator.pop(ctx);
                  PdfService.shareInvoice(_order!);
                },
              ),
              if (!isStitcher) ...[
                ListTile(
                  leading: const Icon(Iconsax.printer, color: AppColors.pine),
                  title: const Text("Print slip"),
                  onTap: () {
                    Navigator.pop(ctx);
                    PdfService.printInvoice(_order!);
                  },
                ),
                if (_order!.status != OrderStatus.delivered) ...[
                  ListTile(
                    leading: const Icon(Iconsax.money, color: AppColors.pine),
                    title: const Text("Advance record karein"),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAdvancePaymentSheet();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.brass,
                    ),
                    title: Text(
                      _order!.status.next == OrderStatus.delivered
                          ? "Complete · Payment + Deliver"
                          : "Status → ${_order!.status.next?.labelEn ?? ""}",
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _onUpdateStatus();
                    },
                  ),
                ],
                ListTile(
                  leading:
                      const Icon(Iconsax.trash, color: AppColors.crimson),
                  title: const Text("Order delete"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteOrder();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletePaymentSheet extends StatefulWidget {
  final Order order;

  const _CompletePaymentSheet({required this.order});

  @override
  State<_CompletePaymentSheet> createState() => _CompletePaymentSheetState();
}

class _CompletePaymentSheetState extends State<_CompletePaymentSheet> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  double get _remaining => widget.order.remainingAmount;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: _remaining > 0 ? _remaining.toStringAsFixed(0) : "0",
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_ctrl.text.trim()) ?? 0;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    final order = widget.order;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: darzi.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Order complete karein",
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: darzi.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Delivery se pehle payment enter karein",
                  style: AppTypography.ui(size: 13, color: darzi.muted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pine,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _PaySummaryRow(
                        label: "کل",
                        value:
                            "${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
                      ),
                      _PaySummaryRow(
                        label: "پیشگی",
                        value:
                            "${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}",
                      ),
                      const Divider(color: AppColors.pineLine, height: 18),
                      _PaySummaryRow(
                        label: "باقی",
                        value:
                            "${AppConstants.currencySymbol} ${_remaining.toStringAsFixed(0)}",
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Ab milne wali payment (PKR)",
                  style: AppTypography.ui(
                    size: 12,
                    weight: FontWeight.w600,
                    color: darzi.muted,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ctrl,
                  autofocus: _remaining > 0,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                  ],
                  style: AppTypography.mono(
                    size: 22,
                    weight: FontWeight.w700,
                    color: darzi.ink,
                  ),
                  decoration: InputDecoration(
                    prefixText: "${AppConstants.currencySymbol} ",
                    prefixStyle: AppTypography.mono(
                      size: 18,
                      color: darzi.muted,
                    ),
                    filled: true,
                    fillColor: darzi.panel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "0",
                  ),
                  validator: (v) {
                    final amount = double.tryParse(v?.trim() ?? "");
                    if (v == null || v.trim().isEmpty) {
                      return "Payment amount likhein";
                    }
                    if (amount == null) return "Payment amount likhein";
                    if (amount < 0) return "Amount galat hai";
                    if (_remaining > 0 && amount > _remaining + 0.01) {
                      return "Baqaya se zyada nahi le sakte";
                    }
                    return null;
                  },
                ),
                if (_remaining > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Poora clear: ${AppConstants.currencySymbol} ${_remaining.toStringAsFixed(0)}. "
                    "Kam diya to baqaya khata mein rahega.",
                    style: AppTypography.ui(size: 11, color: darzi.muted),
                  ),
                ],
                const SizedBox(height: 18),
                DarziButton(
                  label: "Payment save · Deliver",
                  icon: Icons.check_rounded,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: AppTypography.ui(color: darzi.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancePaymentSheet extends StatefulWidget {
  final Order order;

  const _AdvancePaymentSheet({required this.order});

  @override
  State<_AdvancePaymentSheet> createState() => _AdvancePaymentSheetState();
}

class _AdvancePaymentSheetState extends State<_AdvancePaymentSheet> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  double get _remaining => widget.order.remainingAmount;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: "0");
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_ctrl.text.trim()) ?? 0;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    final order = widget.order;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: darzi.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Advance record karein",
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: darzi.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Order chal rahi hai — sirf advance save hogi",
                  style: AppTypography.ui(size: 13, color: darzi.muted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pine,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _PaySummaryRow(
                        label: "کل",
                        value:
                            "${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
                      ),
                      _PaySummaryRow(
                        label: "پیشگی",
                        value:
                            "${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}",
                      ),
                      const Divider(color: AppColors.pineLine, height: 18),
                      _PaySummaryRow(
                        label: "باقی",
                        value:
                            "${AppConstants.currencySymbol} ${_remaining.toStringAsFixed(0)}",
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Nayi advance (PKR)",
                  style: AppTypography.ui(
                    size: 12,
                    weight: FontWeight.w600,
                    color: darzi.muted,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ctrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                  ],
                  style: AppTypography.mono(
                    size: 22,
                    weight: FontWeight.w700,
                    color: darzi.ink,
                  ),
                  decoration: InputDecoration(
                    prefixText: "${AppConstants.currencySymbol} ",
                    prefixStyle: AppTypography.mono(
                      size: 18,
                      color: darzi.muted,
                    ),
                    filled: true,
                    fillColor: darzi.panel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "0",
                  ),
                  validator: (v) {
                    final amount = double.tryParse(v?.trim() ?? "");
                    if (v == null || v.trim().isEmpty) {
                      return "Payment amount likhein";
                    }
                    if (amount == null) return "Payment amount likhein";
                    if (amount < 0) return "Amount galat hai";
                    if (_remaining > 0 && amount > _remaining + 0.01) {
                      return "Baqaya se zyada nahi le sakte";
                    }
                    return null;
                  },
                ),
                if (_remaining > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Baqaya: ${AppConstants.currencySymbol} ${_remaining.toStringAsFixed(0)}",
                    style: AppTypography.ui(size: 11, color: darzi.muted),
                  ),
                ],
                const SizedBox(height: 18),
                DarziButton(
                  label: "Payment save",
                  icon: Icons.check_rounded,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: AppTypography.ui(color: darzi.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaySummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PaySummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.urdu(
              size: 14,
              color: const Color(0xFFC4D5D1),
            ),
          ),
          Text(
            value,
            style: AppTypography.mono(
              size: highlight ? 16 : 13,
              weight: FontWeight.w700,
              color: highlight
                  ? const Color(0xFFF0A99A)
                  : const Color(0xFFEEF4F2),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHead extends StatelessWidget {
  final String token;
  final Order order;
  final String? phone;

  const _OrderHead({
    required this.token,
    required this.order,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: darzi.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: darzi.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "#$token",
            style: AppTypography.mono(
              size: 12,
              weight: FontWeight.w700,
              color: darzi.brass,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            order.garmentTitle,
            style: AppTypography.display(
              size: 18,
              weight: FontWeight.w700,
              color: darzi.ink,
            ),
          ),
          Text(
            "${order.customerName}${phone != null ? ' · $phone' : ''}",
            style: AppTypography.ui(size: 12, color: darzi.muted),
          ),
          const SizedBox(height: 16),
          OrderTrack(status: order.status, showLabels: true),
        ],
      ),
    );
  }
}



class _DesignFabricSection extends StatelessWidget {
  final Order order;

  const _DesignFabricSection({required this.order});

  bool get _visible {
    final fabric = order.fabricDetails?.trim();
    final notes = order.designNotes?.trim();
    return (fabric != null && fabric.isNotEmpty) ||
        (notes != null && notes.isNotEmpty) ||
        order.photoPaths.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final darzi = context.darzi;
    final fabric = order.fabricDetails?.trim();
    final notes = order.designNotes?.trim();
    final photos =
        order.photoPaths.where((p) => File(p).existsSync()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          "Design & fabric",
          style: AppTypography.display(
            size: 14,
            weight: FontWeight.w600,
            color: darzi.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: darzi.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: darzi.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fabric != null && fabric.isNotEmpty)
                Text(
                  fabric,
                  style: AppTypography.ui(size: 13, color: darzi.ink),
                ),
              if (fabric != null &&
                  fabric.isNotEmpty &&
                  notes != null &&
                  notes.isNotEmpty)
                const SizedBox(height: 8),
              if (notes != null && notes.isNotEmpty)
                Text(
                  notes,
                  style: AppTypography.ui(size: 12, color: darzi.muted),
                ),
              if (photos.isNotEmpty) ...[
                if ((fabric != null && fabric.isNotEmpty) ||
                    (notes != null && notes.isNotEmpty))
                  const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(photos[i]),
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PayBox extends StatelessWidget {
  final Order order;
  const _PayBox({required this.order});

  @override
  Widget build(BuildContext context) {
    Widget row(String urdu, String amt, {bool total = false, bool bal = false}) {
      return Padding(
        padding: EdgeInsets.only(top: total ? 11 : 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              urdu,
              style: AppTypography.urdu(
                size: 14,
                color: const Color(0xFFC4D5D1),
              ),
            ),
            Text(
              amt,
              style: AppTypography.mono(
                size: total ? 17 : 13,
                weight: FontWeight.w700,
                color: bal
                    ? const Color(0xFFF0A99A)
                    : total
                        ? AppColors.brassSoft
                        : const Color(0xFFEEF4F2),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.pine,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          row(
            "کل",
            "${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
          ),
          row(
            "پیشگی",
            "${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}",
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.only(top: 6),
            child: CustomPaint(
              painter: _DashPainter(color: AppColors.pineLine),
              size: const Size(double.infinity, 1),
            ),
          ),
          row(
            "باقی",
            "${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
            total: true,
            bal: order.remainingAmount > 0,
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
