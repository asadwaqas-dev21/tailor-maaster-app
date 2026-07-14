import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/presentation/blocs/report/report_bloc.dart";
import "package:tailor_app/presentation/blocs/report/report_event.dart";
import "package:tailor_app/presentation/blocs/report/report_state.dart";

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportBloc(orderRepository: OrderRepositoryImpl())
            ..add(const LoadReport(period: ReportPeriod.monthly)),
      child: const _ReportScreenContent(),
    );
  }
}

class _ReportScreenContent extends StatelessWidget {
  const _ReportScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final darzi = context.darzi;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Khata",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: darzi.ink,
                        ),
                  ),
                  Text(
                    l10n.salesReport,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: darzi.muted,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.pine),
                    );
                  }
                  if (state is ReportError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is ReportLoaded) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        _buildPeriodSelector(context, state.period),
                        const SizedBox(height: 24),
                        _buildSummaryCards(context, state),
                        const SizedBox(height: 24),
                        Text("Sales Trend", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildChart(context, state),
                      ],
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

  Widget _buildPeriodSelector(
    BuildContext context,
    ReportPeriod currentPeriod,
  ) {
    final l10n = context.l10n;
    return SegmentedButton<ReportPeriod>(
      segments: [
        ButtonSegment(value: ReportPeriod.daily, label: Text(l10n.daily)),
        ButtonSegment(value: ReportPeriod.weekly, label: Text(l10n.weekly)),
        ButtonSegment(value: ReportPeriod.monthly, label: Text(l10n.monthly)),
      ],
      selected: {currentPeriod},
      onSelectionChanged: (selected) {
        context.read<ReportBloc>().add(LoadReport(period: selected.first));
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportLoaded state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                title: "Total Sales",
                value:
                    "${AppConstants.currencySymbol} ${state.totalSales.toStringAsFixed(0)}",
                icon: Iconsax.money_tick,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                title: "Orders Delivered",
                value: "${state.totalOrdersCompleted}",
                icon: Iconsax.box_tick,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                title: "Advances",
                value:
                    "${AppConstants.currencySymbol} ${state.totalAdvance.toStringAsFixed(0)}",
                icon: Iconsax.wallet_add,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                title: "Pending Balance",
                value:
                    "${AppConstants.currencySymbol} ${state.totalRemaining.toStringAsFixed(0)}",
                icon: Iconsax.money_remove,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, ReportLoaded state) {
    final theme = context.theme;
    final maxVal = state.chartData.isEmpty
        ? 1.0
        : state.chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.chartData.map((data) {
          final factor = maxVal > 0 ? data.value / maxVal : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data.value > 0
                    ? "${(data.value / 1000).toStringAsFixed(1)}k"
                    : "",
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 32,
                height: 150 * factor,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
