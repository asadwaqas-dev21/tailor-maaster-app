import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/order_status.dart";
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

    // Allow delivery with baqaya — common in tailor shops; warn first.
    if (nextStatus == OrderStatus.delivered && _order!.remainingAmount > 0) {
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: "Baqaya ke sath deliver?",
        message:
            "Baqaya ${AppConstants.currencySymbol} ${_order!.remainingAmount.toStringAsFixed(0)} baqi hai. "
            "Order deliver karein? Khata mein baqaya rehne dega.",
        confirmText: "Haan, deliver",
        confirmColor: AppColors.pine,
        icon: Icons.local_shipping_rounded,
      );
      if (!confirmed || !mounted) return;
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
                            icon: Icons.chevron_left_rounded,
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
                          _TokenSlip(token: _token),
                          const SizedBox(height: 14),
                          _PayBox(order: _order!),
                        ],
                      ),
                    ),
                    if (!isStitcher && _customerPhone != null)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        decoration: BoxDecoration(
                          color: darzi.surface,
                          border:
                              Border(top: BorderSide(color: darzi.line)),
                        ),
                        child: DarziButton(
                          label: '"Ready hai" bhejein',
                          icon: Iconsax.message,
                          variant: DarziButtonVariant.whatsapp,
                          onPressed: _sendReadyWhatsApp,
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
                if (_order!.status != OrderStatus.delivered)
                  ListTile(
                    leading: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.brass,
                    ),
                    title: Text(
                      "Status → ${_order!.status.next?.labelEn ?? ""}",
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _onUpdateStatus();
                    },
                  ),
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

class _TokenSlip extends StatelessWidget {
  final String token;
  const _TokenSlip({required this.token});

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
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: darzi.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(painter: _QrPainter(inkColor: darzi.ink)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Token slip",
                  style: AppTypography.ui(
                    size: 13,
                    weight: FontWeight.w600,
                    color: darzi.ink,
                  ),
                ),
                Text(
                  "Customer scan karke status dekhe",
                  style: AppTypography.ui(size: 11, color: darzi.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  token,
                  style: AppTypography.mono(
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.pine,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final Color inkColor;

  _QrPainter({required this.inkColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = inkColor;
    const cell = 6.0;
    for (double y = 8; y < size.height - 8; y += cell) {
      for (double x = 8; x < size.width - 8; x += cell) {
        if (((x + y) ~/ cell) % 3 != 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell - 1.5, cell - 1.5), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
