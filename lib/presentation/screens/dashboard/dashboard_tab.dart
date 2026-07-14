import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_bloc.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_state.dart";

/// Orders home — matches Darzi mockup screen 01.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isStitcher =
            state is DashboardLoaded && state.userRole == "stitcher";

        return Scaffold(
          backgroundColor: context.darzi.scaffold,
          body: SafeArea(
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pine),
                  );
                }
                if (state is DashboardError) {
                  return Center(child: Text(state.message));
                }
                if (state is DashboardLoaded) {
                  return RefreshIndicator(
                    color: AppColors.brass,
                    onRefresh: () async {
                      context
                          .read<DashboardBloc>()
                          .add(const LoadDashboard());
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _OrdersHeader(
                            isStitcher: isStitcher,
                            shopName: "Chughtai Tailors",
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (isStitcher)
                                _StitcherStats(state: state)
                              else
                                _OwnerStats(state: state),
                              const StitchDivider(),
                              _SectionHead(
                                title: isStitcher ? "Mera kaam" : "Active orders",
                                action: isStitcher ? null : "Sab dekhein",
                                onAction: isStitcher
                                    ? null
                                    : () => Navigator.of(context)
                                        .pushNamed("/orders"),
                              ),
                              const SizedBox(height: 4),
                              ..._orderList(context, state, isStitcher),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _orderList(
    BuildContext context,
    DashboardLoaded state,
    bool isStitcher,
  ) {
    final orders = isStitcher
        ? state.stitcherAssignedOrders
        : [
            ...state.pendingOrders,
            ...state.recentOrders.where(
              (o) => !state.pendingOrders.any((p) => p.id == o.id),
            ),
          ];

    // Prefer active (not delivered) first
    final active = orders
        .where((o) => o.status != OrderStatus.delivered)
        .toList();
    final list = active.isNotEmpty ? active : orders;

    if (list.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: EmptyState(
            title: "Koi order nahi",
            subtitle: "Naya order banane ke liye + dabayein",
            icon: Iconsax.clipboard_close,
          ),
        ),
      ];
    }

    return list
        .take(12)
        .map(
          (o) => DarziOrderCard(
            order: o,
            onTap: () async {
              await Navigator.of(context)
                  .pushNamed("/order/detail", arguments: o.id);
              if (!context.mounted) return;
              context.read<DashboardBloc>().add(const LoadDashboard());
            },
          ),
        )
        .toList();
  }
}

class _OrdersHeader extends StatelessWidget {
  final bool isStitcher;
  final String shopName;

  const _OrdersHeader({required this.isStitcher, required this.shopName});

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: AppTypography.ui(size: 12, color: darzi.muted),
                    children: [
                      const TextSpan(text: "Assalam-o-alaikum "),
                      TextSpan(
                        text: "ماسٹر جی",
                        style: AppTypography.urdu(
                          size: 13,
                          color: darzi.brass,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isStitcher ? "Mera kaam" : shopName,
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: darzi.ink,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          if (!isStitcher)
            DarziIconButton(
              icon: Iconsax.notification,
              onTap: () => Navigator.of(context).pushNamed("/notification"),
            ),
        ],
      ),
    );
  }
}

class _OwnerStats extends StatelessWidget {
  final DashboardLoaded state;
  const _OwnerStats({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final newToday = state.recentOrders.where((o) {
      return o.orderDate.year == today.year &&
          o.orderDate.month == today.month &&
          o.orderDate.day == today.day;
    }).length;

    final readyCount = state.recentOrders
        .where((o) => o.status == OrderStatus.ready)
        .length;

    final baqayaK = state.totalUnpaid >= 1000
        ? "${(state.totalUnpaid / 1000).toStringAsFixed(0)}k"
        : state.totalUnpaid.toStringAsFixed(0);

    return Row(
      children: [
        Expanded(
          child: StatChip(
            label: "Naye orders",
            value: "$newToday",
            unit: "aaj",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: "Ready",
            value: "$readyCount",
            unit: "pickup ke liye",
            brass: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: "Baqaya",
            value: baqayaK,
            unit: "${AppConstants.currencyCode} total",
          ),
        ),
      ],
    );
  }
}

class _StitcherStats extends StatelessWidget {
  final DashboardLoaded state;
  const _StitcherStats({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatChip(
            label: "Assigned",
            value: "${state.totalOrders}",
            unit: "orders",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: "Complete",
            value: "${state.stitcherCompletedOrders}",
            unit: "kaam",
            brass: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: "Pending pay",
            value: state.stitcherPendingPayment >= 1000
                ? "${(state.stitcherPendingPayment / 1000).toStringAsFixed(0)}k"
                : state.stitcherPendingPayment.toStringAsFixed(0),
            unit: "PKR",
          ),
        ),
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHead({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.display(
              size: 14,
              weight: FontWeight.w600,
              color: darzi.ink,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTypography.ui(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: darzi.brass,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
