import "package:flutter/material.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/core/widgets/empty_state.dart";

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
          // Show next 3 days of deliveries as upcoming
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
    final hasNotifications =
        _overdueOrders.isNotEmpty ||
        _todayOrders.isNotEmpty ||
        _upcomingOrders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: _isLoading
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
              padding: const EdgeInsets.all(16),
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
                  _buildHeader(l10n.upcomingDeliveries, AppColors.warning),
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
    );
  }

  Widget _buildHeader(String title, Color color) {
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
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
    final theme = context.theme;
    final l10n = context.l10n;
    final relativeTime = order.deliveryDate.relative;

    // Format the order ID to first 8 chars uppercase
    final formattedId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    // Localized body
    final body = l10n.notificationBody(
      formattedId,
      order.customerName,
      order.garmentType.replaceAll('_', ' '),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              relativeTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body, style: theme.textTheme.bodyMedium),
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed("/order/detail", arguments: order.id)
              .then((_) => _loadNotifications());
        },
      ),
    );
  }
}
