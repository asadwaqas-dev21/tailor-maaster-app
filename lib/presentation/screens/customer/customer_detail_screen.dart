import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/widgets/confirm_dialog.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/customer/customer_bloc.dart";
import "package:tailor_app/presentation/blocs/customer/customer_event.dart";

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  List<Order> _orders = [];
  List<Measurement> _measurements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final customerRepo = CustomerRepositoryImpl();
    final orderRepo = OrderRepositoryImpl();
    final measurementRepo = MeasurementRepositoryImpl();

    setState(() {
      _customer = customerRepo.getCustomerById(widget.customerId);
      _orders = orderRepo.getOrdersByCustomerId(widget.customerId);
      _measurements = measurementRepo.getMeasurementsByCustomerId(
        widget.customerId,
      );
    });
  }

  Future<void> _deleteCustomer() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.delete,
      message: context.l10n.deleteCustomerMessage,
      confirmText: context.l10n.delete,
      icon: Iconsax.trash,
    );
    if (confirmed && mounted) {
      context.read<CustomerBloc>().add(DeleteCustomer(widget.customerId));
      context.showSnackBar(context.l10n.customerDeleted);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Customer not found")),
      );
    }

    final customer = _customer!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerDetails),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () => Navigator.of(context)
                .pushNamed("/customer/form", arguments: customer)
                .then((_) => _loadData()),
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
            onPressed: _deleteCustomer,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, customer),
          const SizedBox(height: 16),
          _buildInfoSection(context, customer),
          const SizedBox(height: 24),
          _buildMeasurementsSection(context),
          const SizedBox(height: 24),
          _buildOrdersSection(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .pushNamed(
              "/measurement/form",
              arguments: {"customerId": customer.id},
            )
            .then((_) => _loadData()),
        icon: const Icon(Iconsax.ruler),
        label: Text(l10n.addMeasurement),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Customer customer) {
    final theme = context.theme;
    final initials = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : "?";

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(customer.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(customer.phone, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Customer customer) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (customer.address != null && customer.address!.isNotEmpty)
              _infoRow(
                theme,
                Iconsax.location,
                l10n.address,
                customer.address!,
              ),
            _infoRow(
              theme,
              Iconsax.user,
              l10n.gender,
              customer.gender.name == "male" ? l10n.male : l10n.female,
            ),
            if (customer.notes != null && customer.notes!.isNotEmpty)
              _infoRow(theme, Iconsax.note_1, l10n.notes, customer.notes!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text("$label: ", style: theme.textTheme.labelMedium),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.measurements, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_measurements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.noMeasurements, style: theme.textTheme.bodySmall),
          )
        else
          ..._measurements.map((m) {
            final categoryLabel =
                MeasurementFields.categoryLabelsEn[m.category] ?? m.category;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Iconsax.ruler, size: 20),
                title: Text(categoryLabel, style: theme.textTheme.titleSmall),
                subtitle: Text(
                  "${m.fields.length} measurements • ${m.createdAt.formatted}",
                  style: theme.textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context)
                    .pushNamed(
                      "/measurement/form",
                      arguments: {
                        "customerId": widget.customerId,
                        "measurement": m,
                      },
                    )
                    .then((_) => _loadData()),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildOrdersSection(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.orderHistory, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.noOrders, style: theme.textTheme.bodySmall),
          )
        else
          ..._orders.map(
            (order) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.of(context)
                    .pushNamed("/order/detail", arguments: order.id)
                    .then((_) => _loadData()),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: order.status.color.withValues(alpha: 0.12),
                  child: Icon(
                    order.status.icon,
                    color: order.status.color,
                    size: 16,
                  ),
                ),
                title: Text(
                  order.garmentType.replaceAll("_", " "),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  "${order.deliveryDate.formatted} • ${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
                  style: theme.textTheme.bodySmall,
                ),
                trailing: StatusBadge(
                  label: order.status.labelEn,
                  color: order.status.color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
