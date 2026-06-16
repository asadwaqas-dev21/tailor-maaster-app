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
import "package:tailor_app/core/services/email_service.dart";
import "package:tailor_app/core/services/hive_service.dart";
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
import "package:tailor_app/presentation/blocs/order/order_state.dart";

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  String? _customerPhone;
  String? _customerEmail;
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
        final customer = customerRepo.getCustomerById(order.customerId);
        _customerPhone = customer?.phone;
        _customerEmail = customer?.email;
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

    final settingsBox = HiveService.settingsBox;
    final userRole = settingsBox.get("userRole", defaultValue: "owner") as String;
    final isStitcher = userRole == "stitcher";

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          _loadData();
        }
      },
      child: _order == null
          ? Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text("Order not found")),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(l10n.orderDetails),
                actions: isStitcher
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Iconsax.edit_2),
                          onPressed: () => Navigator.of(context)
                              .pushNamed("/order/form", arguments: _order)
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
                  _buildStatusTimeline(context, _order!),
                  const SizedBox(height: 16),
                  _buildOrderInfo(context, _order!),
                  if (_measurement != null) ...[
                    const SizedBox(height: 16),
                    _buildMeasurementInfo(context, _order!),
                  ],
                  const SizedBox(height: 16),
                  _buildPaymentInfo(context, _order!),
                  const SizedBox(height: 16),
                  _buildDatesInfo(context, _order!),
                  if (_order!.fabricDetails != null || _order!.designNotes != null) ...[
                    const SizedBox(height: 16),
                    _buildNotesInfo(context, _order!),
                  ],
                  if (!isStitcher) ...[
                    const SizedBox(height: 24),
                    _buildActionButtons(context, _order!),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
              floatingActionButton: _order!.status != OrderStatus.delivered
                  ? FloatingActionButton.extended(
                      onPressed: _onUpdateStatus,
                      backgroundColor:
                          _order!.status.next?.color ?? theme.colorScheme.primary,
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
                          _order!.status.next?.icon ?? Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        "${l10n.updateStatus}: ${context.isUrdu ? (_order!.status.next?.labelUr ?? '') : (_order!.status.next?.labelEn ?? '')}",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : null,
            ),
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
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                ),
                itemCount: fieldDefs.length,
                itemBuilder: (context, index) {
                  final def = fieldDefs[index];
                  final value = _measurement!.fields[def.key];
                  final valueStr = value != null ? "$value in" : "-";
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
    final settingsBox = HiveService.settingsBox;
    final userRole = settingsBox.get("userRole", defaultValue: "owner") as String;
    final isStitcher = userRole == "stitcher";

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
            if (order.assignedStaffId != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Text(l10n.stitchingCost, style: theme.textTheme.titleSmall),
                  const Spacer(),
                  StatusBadge(
                    label: order.isStitcherPaid ? l10n.paid : l10n.unpaid,
                    color: order.isStitcherPaid ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _detailRow(
                theme,
                l10n.stitchingCost,
                "${AppConstants.currencySymbol} ${order.stitchingCost.toStringAsFixed(0)}",
              ),
              if (!isStitcher && !order.isStitcherPaid) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<OrderBloc>().add(
                              UpdateOrder(order.copyWith(isStitcherPaid: true)),
                            );
                        context.showSnackBar("Stitcher marked as paid");
                        _loadData();
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(l10n.markAsPaid),
                    ),
                  ],
                ),
              ],
            ],
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
        if (_customerPhone != null || (_customerEmail != null && _customerEmail!.isNotEmpty)) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleNotification(order, isReadyForPickup: false),
                  icon: const Icon(Iconsax.message, size: 18),
                  label: Text(_getReceiptLabel(l10n)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleNotification(order, isReadyForPickup: true),
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

  String _getReceiptLabel(dynamic l10n) {
    final hasPhone = _customerPhone != null && _customerPhone!.isNotEmpty;
    final hasEmail = _customerEmail != null && _customerEmail!.isNotEmpty;

    if (hasPhone && hasEmail) {
      return l10n.sendReceipt;
    } else if (hasEmail) {
      return l10n.emailReceipt;
    } else {
      return l10n.whatsappReceipt;
    }
  }

  Future<void> _handleNotification(Order order, {required bool isReadyForPickup}) async {
    final hasPhone = _customerPhone != null && _customerPhone!.isNotEmpty;
    final hasEmail = _customerEmail != null && _customerEmail!.isNotEmpty;

    if (hasPhone && hasEmail) {
      await _showNotificationDialog(order, isReadyForPickup: isReadyForPickup);
    } else if (hasEmail) {
      await _sendEmailAndShowFeedback(
        order,
        isReadyForPickup: isReadyForPickup,
        email: _customerEmail!,
      );
    } else if (hasPhone) {
      if (isReadyForPickup) {
        await WhatsAppService.sendReadyForPickup(
          phone: _customerPhone!,
          order: order,
        );
      } else {
        await WhatsAppService.sendOrderConfirmation(
          phone: _customerPhone!,
          order: order,
        );
      }
    }
  }

  Future<void> _sendEmailAndShowFeedback(
    Order order, {
    required bool isReadyForPickup,
    required String email,
  }) async {
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator in snackbar
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text("Sending email..."),
          ],
        ),
        duration: Duration(days: 1), // Keeps SnackBar active until dismissed
      ),
    );

    try {
      final EmailSendResult result;
      if (isReadyForPickup) {
        result = await EmailService.sendReadyForPickup(
          email: email,
          order: order,
        );
      } else {
        result = await EmailService.sendOrderConfirmation(
          email: email,
          order: order,
        );
      }

      scaffoldMessenger.hideCurrentSnackBar();

      if (result == EmailSendResult.sentAutomatically) {
        if (mounted) {
          context.showSnackBar(l10n.emailSentSuccess);
        }
      } else if (result == EmailSendResult.openedMailClient) {
        // Fallback email client launched
      } else {
        if (mounted) {
          context.showSnackBar("Could not send email", isError: true);
        }
      }
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      if (mounted) {
        final errText = l10n.emailSendFailed(e.toString());
        context.showSnackBar(errText, isError: true);
      }
    }
  }

  Future<void> _showNotificationDialog(Order order, {required bool isReadyForPickup}) async {
    final l10n = context.l10n;
    final theme = context.theme;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isReadyForPickup ? Iconsax.tick_circle : Iconsax.message,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.notifyCustomer,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectNotificationMethod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              if (_customerPhone != null && _customerPhone!.isNotEmpty)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                    child: const Icon(Icons.phone_android_rounded, color: Colors.green),
                  ),
                  title: Text(
                    l10n.sendViaWhatsApp,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _customerPhone!,
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (isReadyForPickup) {
                      WhatsAppService.sendReadyForPickup(
                        phone: _customerPhone!,
                        order: order,
                      );
                    } else {
                      WhatsAppService.sendOrderConfirmation(
                        phone: _customerPhone!,
                        order: order,
                      );
                    }
                  },
                ),
              if (_customerEmail != null && _customerEmail!.isNotEmpty) ...[
                if (_customerPhone != null && _customerPhone!.isNotEmpty)
                  const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.15),
                    child: const Icon(Icons.email_outlined, color: Colors.blue),
                  ),
                  title: Text(
                    l10n.sendViaEmail,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _customerEmail!,
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendEmailAndShowFeedback(
                      order,
                      isReadyForPickup: isReadyForPickup,
                      email: _customerEmail!,
                    );
                  },
                ),
              ],
              if (_customerPhone != null &&
                  _customerPhone!.isNotEmpty &&
                  _customerEmail != null &&
                  _customerEmail!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withValues(alpha: 0.15),
                    child: const Icon(Icons.send_rounded, color: Colors.purple),
                  ),
                  title: Text(
                    l10n.sendViaBoth,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "WhatsApp & Email",
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (isReadyForPickup) {
                      await WhatsAppService.sendReadyForPickup(
                        phone: _customerPhone!,
                        order: order,
                      );
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (mounted) {
                        await _sendEmailAndShowFeedback(
                          order,
                          isReadyForPickup: true,
                          email: _customerEmail!,
                        );
                      }
                    } else {
                      await WhatsAppService.sendOrderConfirmation(
                        phone: _customerPhone!,
                        order: order,
                      );
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (mounted) {
                        await _sendEmailAndShowFeedback(
                          order,
                          isReadyForPickup: false,
                          email: _customerEmail!,
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
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
