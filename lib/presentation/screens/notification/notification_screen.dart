import "package:flutter/material.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/order.dart";

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Order> _overdueOrders = [];
  List<Order> _todayOrders = [];
  List<Order> _upcomingOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() => _isLoading = true);
    try {
      final orderRepo = OrderRepositoryImpl();
      final allOrders = orderRepo.getPendingOrders();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<Order> overdue = [];
      final List<Order> todayList = [];
      final List<Order> upcoming = [];

      for (final order in allOrders) {
        final date = order.deliveryDate.toLocal();
        final orderDay = DateTime(date.year, date.month, date.day);
        final difference = orderDay.difference(today).inDays;

        if (difference < 0) {
          overdue.add(order);
        } else if (difference == 0) {
          todayList.add(order);
        } else if (difference <= 3) {
          upcoming.add(order);
        }
      }

      setState(() {
        _overdueOrders = overdue;
        _todayOrders = todayList;
        _upcomingOrders = upcoming;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final darzi = context.darzi;
    final hasNotifications =
        _overdueOrders.isNotEmpty ||
        _todayOrders.isNotEmpty ||
        _upcomingOrders.isNotEmpty;

    return Scaffold(
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
                    child: Column(
                      children: [
                        Text(
                          "Alerts",
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            size: 16,
                            weight: FontWeight.w700,
                            color: darzi.ink,
                          ),
                        ),
                        Text(
                          "Deliveries",
                          textAlign: TextAlign.center,
                          style: AppTypography.ui(size: 11, color: darzi.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !hasNotifications
                  ? Center(
                      child: EmptyState(
                        title: l10n.noNotifications,
                        subtitle: l10n.noNotificationsSubtitle,
                        icon: Iconsax.notification_status,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (_overdueOrders.isNotEmpty) ...[
                          _buildHeader(l10n.overdueDeliveries, AppColors.danger),
                          const SizedBox(height: 8),
                          ..._overdueOrders.map(
                            (o) => _buildNotificationCard(
                              o,
                              l10n.overdueReminder,
                              AppColors.danger,
                              Iconsax.info_circle,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_todayOrders.isNotEmpty) ...[
                          _buildHeader(l10n.dueToday, AppColors.info),
                          const SizedBox(height: 8),
                          ..._todayOrders.map(
                            (o) => _buildNotificationCard(
                              o,
                              l10n.deliveryDueToday,
                              AppColors.info,
                              Iconsax.clock,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_upcomingOrders.isNotEmpty) ...[
                          _buildHeader(
                            l10n.upcomingDeliveries,
                            AppColors.warning,
                          ),
                          const SizedBox(height: 8),
                          ..._upcomingOrders.map(
                            (o) => _buildNotificationCard(
                              o,
                              l10n.upcomingDelivery,
                              AppColors.warning,
                              Iconsax.calendar_1,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, Color color) {
    final darzi = context.darzi;
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.display(
            size: 14,
            weight: FontWeight.w600,
            color: darzi.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    Order order,
    String title,
    Color color,
    IconData icon,
  ) {
    final darzi = context.darzi;
    final l10n = context.l10n;
    final relativeTime = order.deliveryDate.relative;
    final body = l10n.notificationBody(
      order.garmentType.replaceAll("_", " "),
      order.displayToken,
      order.customerName,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: darzi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darzi.line),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed("/order/detail", arguments: order.id)
              .then((_) => _loadNotifications());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.ui(
                              size: 13,
                              weight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        Text(
                          relativeTime,
                          style: AppTypography.mono(
                            size: 11,
                            weight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: AppTypography.ui(size: 12, color: darzi.muted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "#${order.displayToken}",
                      style: AppTypography.mono(
                        size: 11,
                        weight: FontWeight.w700,
                        color: darzi.brass,
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
}
