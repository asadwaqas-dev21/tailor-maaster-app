import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_bloc.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_state.dart";
import "package:tailor_app/presentation/screens/dashboard/widgets/summary_card.dart";

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isStitcher = state is DashboardLoaded && state.userRole == "stitcher";

        return Scaffold(
          appBar: AppBar(
            title: Text(isStitcher ? "${AppConstants.appName} (${l10n.stitcher})" : AppConstants.appName),
            actions: isStitcher
                ? null
                : [
                    IconButton(
                      icon: const Icon(Iconsax.chart_21),
                      onPressed: () => Navigator.of(context).pushNamed("/report"),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.notification),
                      onPressed: () => Navigator.of(context).pushNamed("/notification"),
                    ),
                  ],
          ),
          floatingActionButton: isStitcher
              ? null
              : FloatingActionButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed("/order/form")
                      .then(
                        // ignore: use_build_context_synchronously
                        (_) => context.read<DashboardBloc>().add(const LoadDashboard()),
                      ),
                  child: const Icon(Icons.add_rounded),
                ),
          body: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DashboardError) {
                return Center(child: Text(state.message));
              }
              if (state is DashboardLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(const LoadDashboard());
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryGrid(context, state),
                      const SizedBox(height: 24),
                      if (isStitcher) ...[
                        _buildSectionHeader(
                          context,
                          title: l10n.myWork,
                          count: state.stitcherAssignedOrders.length,
                        ),
                        const SizedBox(height: 8),
                        if (state.stitcherAssignedOrders.isEmpty)
                          _buildMiniEmpty(context, l10n.myWork)
                        else
                          ...state.stitcherAssignedOrders.map(
                            (o) => _buildOrderTile(context, o),
                          ),
                      ] else ...[
                        _buildSectionHeader(
                          context,
                          title: l10n.recentOrders,
                          count: state.recentOrders.length,
                        ),
                        const SizedBox(height: 8),
                        if (state.recentOrders.isEmpty)
                          _buildMiniEmpty(context, l10n.recentOrders)
                        else
                          ...state.recentOrders.map(
                            (o) => _buildOrderTile(context, o),
                          ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          context,
                          title: l10n.pendingOrders,
                          count: state.pendingOrders.length,
                        ),
                        const SizedBox(height: 8),
                        if (state.pendingOrders.isEmpty)
                          _buildMiniEmpty(context, l10n.pendingOrders)
                        else
                          ...state.pendingOrders
                              .take(5)
                              .map((o) => _buildOrderTile(context, o)),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(BuildContext context, DashboardLoaded state) {
    final l10n = context.l10n;

    if (state.userRole == "stitcher") {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          SummaryCard(
            title: l10n.completedWork,
            value: "${state.stitcherCompletedOrders}",
            icon: Iconsax.box_tick,
            color: AppColors.success,
          ),
          SummaryCard(
            title: l10n.totalOrders,
            value: "${state.totalOrders}",
            icon: Iconsax.clipboard_text,
            color: AppColors.info,
          ),
          CurrencySummaryCard(
            title: l10n.paymentPending,
            amount: state.stitcherPendingPayment,
            icon: Iconsax.money_remove,
            color: AppColors.danger,
          ),
          CurrencySummaryCard(
            title: l10n.paymentReceived,
            amount: state.stitcherReceivedPayment,
            icon: Iconsax.money_tick,
            color: AppColors.success,
          ),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        SummaryCard(
          title: l10n.customers,
          value: "${state.totalCustomers}",
          icon: Iconsax.people,
          color: AppColors.info,
        ),
        SummaryCard(
          title: l10n.pendingOrders,
          value: "${state.pendingOrders.length}",
          icon: Iconsax.clock,
          color: AppColors.warning,
        ),
        CurrencySummaryCard(
          title: l10n.totalUnpaid,
          amount: state.totalUnpaid,
          icon: Iconsax.money_remove,
          color: AppColors.danger,
        ),
        SummaryCard(
          title: l10n.totalOrders,
          value: "${state.totalOrders}",
          icon: Iconsax.clipboard_tick,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
  }) {
    final theme = context.theme;
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$count",
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniEmpty(BuildContext context, String section) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: EmptyState(title: "No $section", icon: Iconsax.clipboard_close),
    );
  }

  Widget _buildOrderTile(BuildContext context, Order order) {
    final theme = context.theme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.of(context)
            .pushNamed("/order/detail", arguments: order.id)
            .then(
              // ignore: use_build_context_synchronously
              (_) => context.read<DashboardBloc>().add(const LoadDashboard()),
            ),
        leading: CircleAvatar(
          backgroundColor: order.status.color.withValues(alpha: 0.12),
          child: Icon(order.status.icon, color: order.status.color, size: 20),
        ),
        title: Text(order.customerName, style: theme.textTheme.titleSmall),
        subtitle: Text(
          "${order.garmentType.replaceAll('_', ' ')} • ${order.deliveryDate.relative}",
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
              style: theme.textTheme.labelLarge?.copyWith(
                color: order.remainingAmount > 0
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
            StatusBadge(
              label: context.isUrdu
                  ? order.status.labelUr
                  : order.status.labelEn,
              color: order.status.color,
            ),
          ],
        ),
      ),
    );
  }
}
