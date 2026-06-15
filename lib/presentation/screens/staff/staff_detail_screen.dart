import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/widgets/confirm_dialog.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/data/repositories/staff_repository_impl.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/presentation/blocs/staff/staff_bloc.dart";
import "package:tailor_app/presentation/blocs/staff/staff_event.dart";

class StaffDetailScreen extends StatefulWidget {
  final String staffId;

  const StaffDetailScreen({super.key, required this.staffId});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  Staff? _staff;
  List<Order> _assignedOrders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final staffRepo = StaffRepositoryImpl();
    final orderRepo = OrderRepositoryImpl();

    final staff = staffRepo.getStaffById(widget.staffId);
    final allOrders = orderRepo.getAllOrders();

    setState(() {
      _staff = staff;
      _assignedOrders =
          allOrders.where((o) => o.assignedStaffId == widget.staffId).toList()
            ..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
    });
  }

  Future<void> _deleteStaff() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: "Delete Staff",
      message: "Are you sure you want to remove this staff member?",
      confirmText: "Delete",
      icon: Iconsax.trash,
    );
    if (confirmed && mounted) {
      context.read<StaffBloc>().add(DeleteStaff(widget.staffId));
      context.showSnackBar("Staff deleted");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (_staff == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Staff not found")),
      );
    }

    final staff = _staff!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Details"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () => Navigator.of(context)
                .pushNamed("/staff/form", arguments: staff)
                .then((_) => _loadData()),
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
            onPressed: _deleteStaff,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, staff),
          const SizedBox(height: 24),
          _buildAssignedOrdersSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Staff staff) {
    final theme = context.theme;
    final initials = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : "?";

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: staff.role.color.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: theme.textTheme.displaySmall?.copyWith(
                color: staff.role.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(staff.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(staff.phone, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          StatusBadge(
            label: context.isUrdu ? staff.role.labelUr : staff.role.labelEn,
            color: staff.role.color,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedOrdersSection(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assigned Workload", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_assignedOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No orders assigned yet",
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          ..._assignedOrders.map(
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
                  "${order.customerName} - ${order.garmentType.replaceAll("_", " ")}",
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  "Deliver by: ${order.deliveryDate.formatted}",
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
