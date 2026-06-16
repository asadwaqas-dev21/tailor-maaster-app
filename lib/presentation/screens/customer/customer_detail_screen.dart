import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/services/hive_service.dart";
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

    final settingsBox = HiveService.settingsBox;
    final userRole = settingsBox.get("userRole", defaultValue: "owner") as String;
    final isOwner = userRole == "owner";

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
        actions: isOwner
            ? [
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
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(customer),
          const SizedBox(height: 16),
          _buildInfoSection(context, customer),
          const SizedBox(height: 24),
          _buildMeasurementsSection(context),
          const SizedBox(height: 24),
          _buildOrdersSection(context),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              heroTag: "customerDetailOrderFab",
              onPressed: () => Navigator.of(context)
                  .pushNamed(
                    "/order/form",
                    arguments: customer.id,
                  )
                  .then((_) => _loadData()),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildProfileHeader(Customer customer) {
    final theme = context.theme;
    final settingsBox = HiveService.settingsBox;
    final isOwner = settingsBox.get("userRole", defaultValue: "owner") == "owner";

    final hasImage = customer.imagePath != null &&
        customer.imagePath!.isNotEmpty &&
        File(customer.imagePath!).existsSync();

    final initials = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : "?";

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: isOwner ? () => _showPhotoPickerOptions(customer) : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: hasImage ? FileImage(File(customer.imagePath!)) : null,
                  child: hasImage
                      ? null
                      : Text(
                          initials,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                if (isOwner)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                      child: const Icon(
                        Iconsax.camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
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

  Future<void> _pickAndSaveImage(ImageSource source, Customer customer) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final appDir = await getApplicationDocumentsDirectory();

      // Delete old photo files matching customer_<id>_*.jpg to save storage space
      final directory = Directory(appDir.path);
      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();
        for (final FileSystemEntity file in files) {
          final filename = file.path.split(Platform.pathSeparator).last;
          if (filename.startsWith("customer_${customer.id}_") && filename.endsWith(".jpg")) {
            try {
              await file.delete();
            } catch (e) {
              debugPrint("Failed to delete old customer photo: $e");
            }
          }
        }
      }

      // Copy to new unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localImagePath = "${appDir.path}/customer_${customer.id}_$timestamp.jpg";

      final File imageFile = File(pickedFile.path);
      await imageFile.copy(localImagePath);

      // Update customer object
      final updatedCustomer = customer.copyWith(imagePath: localImagePath);

      // Persist in Hive
      final customerRepo = CustomerRepositoryImpl();
      await customerRepo.updateCustomer(updatedCustomer);

      if (!mounted) return;

      // Trigger BLoC update to keep app synchronized
      context.read<CustomerBloc>().add(UpdateCustomer(updatedCustomer));
      context.showSnackBar("Profile picture updated successfully");

      // Reload UI state
      _loadData();
    } catch (e) {
      debugPrint("Failed to update profile picture: $e");
      if (mounted) {
        context.showSnackBar("Failed to update profile picture", isError: true);
      }
    }
  }

  void _showPhotoPickerOptions(Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveImage(ImageSource.camera, customer);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveImage(ImageSource.gallery, customer);
                },
              ),
              if (customer.imagePath != null && customer.imagePath!.isNotEmpty)
                ListTile(
                  leading: const Icon(Iconsax.trash, color: Colors.red),
                  title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);

                    // Delete the physical file
                    final file = File(customer.imagePath!);
                    if (await file.exists()) {
                      await file.delete();
                    }

                    // Reset path in DB
                    final updatedCustomer = customer.copyWith(imagePath: "");
                    final customerRepo = CustomerRepositoryImpl();
                    await customerRepo.updateCustomer(updatedCustomer);

                    if (!mounted) return;

                    // Notify BLoC
                    context.read<CustomerBloc>().add(UpdateCustomer(updatedCustomer));
                    context.showSnackBar("Profile picture removed");

                    // Reload
                    _loadData();
                  },
                ),
            ],
          ),
        ),
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
            if (customer.email != null && customer.email!.isNotEmpty)
              _infoRow(
                theme,
                Iconsax.sms,
                l10n.email,
                customer.email!,
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
    final isOwner = HiveService.settingsBox.get("userRole", defaultValue: "owner") == "owner";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.measurements, style: theme.textTheme.titleMedium),
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => Navigator.of(context)
                    .pushNamed(
                      "/measurement/form",
                      arguments: {"customerId": widget.customerId},
                    )
                    .then((_) => _loadData()),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_measurements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: isOwner
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(
                                "/measurement/form",
                                arguments: {"customerId": widget.customerId},
                              )
                              .then((_) => _loadData()),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.addMeasurement),
                        ),
                      ),
                    ],
                  )
                : Text(l10n.noMeasurements, style: theme.textTheme.bodySmall),
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
                trailing: isOwner ? const Icon(Icons.chevron_right_rounded) : null,
                onTap: isOwner
                    ? () => Navigator.of(context)
                        .pushNamed(
                          "/measurement/form",
                          arguments: {
                            "customerId": widget.customerId,
                            "measurement": m,
                          },
                        )
                        .then((_) => _loadData())
                    : null,
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
