import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";
import "package:tailor_app/presentation/blocs/order/order_state.dart";

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final darzi = context.darzi;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  DarziIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      "Sab orders",
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        size: 16,
                        weight: FontWeight.w700,
                        color: darzi.ink,
                      ),
                    ),
                  ),
                  DarziIconButton(
                    icon: Icons.add,
                    onTap: () => Navigator.of(context)
                        .pushNamed("/order/form")
                        .then(
                          (_) => context
                              .read<OrderBloc>()
                              .add(const LoadOrders()),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: "Sab",
                    on: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  ...OrderStatus.values.map(
                    (s) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 7),
                      child: _FilterChip(
                        label: s.labelEn,
                        on: _filter == s,
                        onTap: () => setState(() => _filter = s),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.pine),
                    );
                  }
                  if (state is OrderError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is OrderLoaded) {
                    final orders = _filter == null
                        ? state.orders
                        : state.orders
                            .where((o) => o.status == _filter)
                            .toList();
                    if (orders.isEmpty) {
                      return EmptyState(
                        title: l10n.noOrders,
                        subtitle: l10n.noOrdersSubtitle,
                        icon: Iconsax.clipboard_text,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return DarziOrderCard(
                          order: order,
                          onTap: () => Navigator.of(context)
                              .pushNamed(
                                "/order/detail",
                                arguments: order.id,
                              )
                              .then(
                                (_) => context
                                    .read<OrderBloc>()
                                    .add(const LoadOrders()),
                              ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: on ? AppColors.pine : darzi.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.ui(
            size: 11.5,
            weight: FontWeight.w500,
            color: on ? Colors.white : darzi.muted,
          ),
        ),
      ),
    );
  }
}
