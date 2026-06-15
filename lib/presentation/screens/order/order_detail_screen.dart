import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/services/pdf_service.dart";
import "package:tailor_app/core/services/whatsapp_service.dart";
import "package:tailor_app/core/widgets/confirm_dialog.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  String? _customerPhone;
  Measurement? _measurement;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final orderRepo = OrderRepositoryImpl();
    final customerRepo = CustomerRepositoryImpl();
    final measurementRepo = MeasurementRepositoryImpl();
    final order = orderRepo.getOrderById(widget.orderId);
    setState(() {
      _order = order;
      if (order != null) {
        _customerPhone = customerRepo.getCustomerById(order.customerId)?.phone;
        if (order.measurementId != null) {
          _measurement = measurementRepo.getMeasurementById(
            order.measurementId!,
          );
        } else {
          _measurement = null;
        }
      }
    });
  }

  Future<void> _onUpdateStatus() async {
    if (_order == null) return;
    final nextStatus = _order!.status.next;
    if (nextStatus == null) return;

    if (nextStatus == OrderStatus.delivered && _order!.remainingAmount > 0) {
      context.showSnackBar(
        context.l10n.paymentRequiredBeforeDelivery,
        isError: true,
      );
      return;
    }

    context.read<OrderBloc>().add(
      UpdateOrderStatus(orderId: _order!.id, status: nextStatus),
    );
    context.showSnackBar(context.l10n.statusUpdated);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Order not found")),
      );
    }

    final order = _order!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetails),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () => Navigator.of(context)
                .pushNamed("/order/form", arguments: order)
                .then((_) => _loadData()),
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusTimeline(context, order),
          const SizedBox(height: 16),
          _buildOrderInfo(context, order),
          if (_measurement != null) ...[
            const SizedBox(height: 16),
            _buildMeasurementInfo(context, order),
          ],
          const SizedBox(height: 16),
          _buildPaymentInfo(context, order),
          const SizedBox(height: 16),
          _buildDatesInfo(context, order),
          if (order.fabricDetails != null || order.designNotes != null) ...[
            const SizedBox(height: 16),
            _buildNotesInfo(context, order),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(context, order),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: order.status != OrderStatus.delivered
          ? FloatingActionButton.extended(
              onPressed: _onUpdateStatus,
              backgroundColor:
                  order.status.next?.color ?? theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  order.status.next?.icon ?? Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              label: Text(
                "${l10n.updateStatus}: ${context.isUrdu ? (order.status.next?.labelUr ?? '') : (order.status.next?.labelEn ?? '')}",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusTimeline(BuildContext context, Order order) {
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: OrderStatus.values.map((status) {
            final isActive = status.index <= order.status.index;
            final isCurrent = status == order.status;
            return Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? status.color.withValues(alpha: isCurrent ? 1 : 0.7)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: status.color.withValues(alpha: 0.3),
                            width: 3,
                          )
                        : null,
                  ),
                  child: Icon(
                    status.icon,
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.isUrdu ? status.labelUr : status.labelEn,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: isActive
                        ? status.color
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    final l10n = context.l10n;
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(theme, l10n.customerName, order.customerName),
            _detailRow(
              theme,
              l10n.garmentType,
              order.garmentType.replaceAll("_", " "),
            ),
            _detailRow(theme, l10n.quantity, "${order.quantity}"),
            if (order.assignedStaffName != null)
              _detailRow(theme, "Assigned Staff", order.assignedStaffName!),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInfo(BuildContext context, Order order) {
    if (_measurement == null) return const SizedBox.shrink();

    final theme = context.theme;
    final l10n = context.l10n;
    final categoryLabel = context.isUrdu
        ? (MeasurementFields.categoryLabelsUr[_measurement!.category] ??
              _measurement!.category)
        : (MeasurementFields.categoryLabelsEn[_measurement!.category] ??
              _measurement!.category);

    final fieldDefs =
        MeasurementFields.categories[_measurement!.category] ?? [];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.ruler, size: 20),
                const SizedBox(width: 8),
                Text(
                  "${l10n.measurementDetails} ($categoryLabel)",
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const Divider(height: 20),
            if (fieldDefs.isEmpty)
              Text("No fields defined.", style: theme.textTheme.bodyMedium)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                ),
                itemCount: fieldDefs.length,
                itemBuilder: (context, index) {
                  final def = fieldDefs[index];
                  final value = _measurement!.fields[def.key];
                  final valueStr = value != null ? "$value in" : "-";
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.isUrdu ? def.labelUr : def.labelEn,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          valueStr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, Order order) {
    final l10n = context.l10n;
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.paymentStatus, style: theme.textTheme.titleSmall),
                const Spacer(),
                StatusBadge(
                  label: context.isUrdu
                      ? order.paymentStatus.labelUr
                      : order.paymentStatus.labelEn,
                  color: order.paymentStatus.color,
                  icon: order.paymentStatus.icon,
                ),
              ],
            ),
            const Divider(height: 20),
            _detailRow(
              theme,
              l10n.totalAmount,
              "${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
            ),
            _detailRow(
              theme,
              l10n.advanceAmount,
              "${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}",
            ),
            _detailRow(
              theme,
              l10n.remainingBalance,
              "${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
              valueColor: order.remainingAmount > 0
                  ? AppColors.danger
                  : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesInfo(BuildContext context, Order order) {
    final l10n = context.l10n;
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _detailRow(theme, l10n.orderDate, order.orderDate.formatted),
            _detailRow(
              theme,
              l10n.deliveryDate,
              "${order.deliveryDate.formatted} (${order.deliveryDate.relative})",
              valueColor: order.deliveryDate.isOverdue
                  ? AppColors.danger
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInfo(BuildContext context, Order order) {
    final l10n = context.l10n;
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.fabricDetails != null && order.fabricDetails!.isNotEmpty)
              _detailRow(theme, l10n.fabricDetails, order.fabricDetails!),
            if (order.designNotes != null && order.designNotes!.isNotEmpty)
              _detailRow(theme, l10n.designNotes, order.designNotes!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    final l10n = context.l10n;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => PdfService.printInvoice(order),
                icon: const Icon(Iconsax.printer, size: 18),
                label: Text(l10n.printInvoice),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => PdfService.shareInvoice(order),
                icon: const Icon(Iconsax.share, size: 18),
                label: Text(l10n.sharePdf),
              ),
            ),
          ],
        ),
        if (_customerPhone != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => WhatsAppService.sendOrderConfirmation(
                    phone: _customerPhone!,
                    order: order,
                  ),
                  icon: const Icon(Iconsax.message, size: 18),
                  label: Text(l10n.whatsappReceipt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => WhatsAppService.sendReadyForPickup(
                    phone: _customerPhone!,
                    order: order,
                  ),
                  icon: const Icon(Iconsax.tick_circle, size: 18),
                  label: Text(l10n.readyForPickup),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _detailRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
