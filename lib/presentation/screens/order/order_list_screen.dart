import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";
import "package:tailor_app/presentation/blocs/order/order_state.dart";

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orders)),
      floatingActionButton: FloatingActionButton(
        heroTag: "orderFab",
        onPressed: () => Navigator.of(context)
            .pushNamed("/order/form")
            .then(
              // ignore: use_build_context_synchronously
              (_) => context.read<OrderBloc>().add(const LoadOrders()),
            ),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildStatusTabs(context),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OrderError) {
                  return Center(child: Text(state.message));
                }
                if (state is OrderLoaded) {
                  if (state.orders.isEmpty) {
                    return EmptyState(
                      title: l10n.noOrders,
                      subtitle: l10n.noOrdersSubtitle,
                      icon: Iconsax.clipboard_text,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      return _OrderTile(order: state.orders[index]);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final currentFilter = state is OrderLoaded ? state.filterStatus : null;

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _filterChip(
                context,
                label: l10n.all,
                isSelected: currentFilter == null,
                onTap: () =>
                    context.read<OrderBloc>().add(const FilterOrders()),
              ),
              ...OrderStatus.values.map(
                (status) => _filterChip(
                  context,
                  label: context.isUrdu ? status.labelUr : status.labelEn,
                  color: status.color,
                  isSelected: currentFilter == status,
                  onTap: () => context.read<OrderBloc>().add(
                    FilterOrders(status: status),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = context.theme;
    final chipColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor.withValues(alpha: 0.15),
        checkmarkColor: chipColor,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected ? chipColor : theme.colorScheme.onSurface,
        ),
        side: BorderSide(
          color: isSelected
              ? chipColor.withValues(alpha: 0.3)
              : theme.dividerColor,
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.of(context)
            .pushNamed("/order/detail", arguments: order.id)
            // ignore: use_build_context_synchronously
            .then((_) => context.read<OrderBloc>().add(const LoadOrders())),
        leading: CircleAvatar(
          backgroundColor: order.status.color.withValues(alpha: 0.12),
          child: Icon(order.status.icon, color: order.status.color, size: 20),
        ),
        title: Text(order.customerName, style: theme.textTheme.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              order.garmentType.replaceAll("_", " "),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              "${order.deliveryDate.formatted} • ${order.deliveryDate.relative}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: order.deliveryDate.isOverdue
                    ? theme.colorScheme.error
                    : null,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
              style: theme.textTheme.labelLarge?.copyWith(
                color: order.remainingAmount > 0
                    ? theme.colorScheme.error
                    : AppColors.success,
              ),
            ),
            const SizedBox(height: 4),
             StatusBadge(
               label: context.isUrdu ? order.status.labelUr : order.status.labelEn,
               color: order.status.color,
             ),
          ],
        ),
      ),
    );
  }
}
