import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
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
          _buildProfileHeader(staff),
          const SizedBox(height: 24),
          _buildAssignedOrdersSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Staff staff) {
    final theme = context.theme;
    final initials = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : "?";

    final hasImage = staff.imagePath != null &&
        staff.imagePath!.isNotEmpty &&
        File(staff.imagePath!).existsSync();

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showPhotoPickerOptions(staff),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: staff.role.color.withValues(alpha: 0.12),
                  backgroundImage: hasImage ? FileImage(File(staff.imagePath!)) : null,
                  child: hasImage
                      ? null
                      : Text(
                          initials,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: staff.role.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
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

  Future<void> _pickAndSaveImage(ImageSource source, Staff staff) async {
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
      final directory = Directory(appDir.path);
      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();
        for (final FileSystemEntity file in files) {
          final filename = file.path.split(Platform.pathSeparator).last;
          if (filename.startsWith("staff_${staff.id}_") && filename.endsWith(".jpg")) {
            try {
              await file.delete();
            } catch (e) {
              debugPrint("Failed to delete old staff photo: $e");
            }
          }
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localImagePath = "${appDir.path}/staff_${staff.id}_$timestamp.jpg";

      final File imageFile = File(pickedFile.path);
      await imageFile.copy(localImagePath);

      final updatedStaff = staff.copyWith(imagePath: localImagePath);
      final staffRepo = StaffRepositoryImpl();
      await staffRepo.updateStaff(updatedStaff);

      if (!mounted) return;

      context.read<StaffBloc>().add(UpdateStaff(updatedStaff));
      context.showSnackBar("Profile picture updated successfully");
      _loadData();
    } catch (e) {
      debugPrint("Failed to update profile picture: $e");
      if (mounted) {
        context.showSnackBar("Failed to update profile picture", isError: true);
      }
    }
  }

  void _showPhotoPickerOptions(Staff staff) {
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
                  _pickAndSaveImage(ImageSource.camera, staff);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveImage(ImageSource.gallery, staff);
                },
              ),
              if (staff.imagePath != null && staff.imagePath!.isNotEmpty)
                ListTile(
                  leading: const Icon(Iconsax.trash, color: Colors.red),
                  title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);

                    final file = File(staff.imagePath!);
                    if (await file.exists()) {
                      await file.delete();
                    }

                    final updatedStaff = staff.copyWith(imagePath: "");
                    final staffRepo = StaffRepositoryImpl();
                    await staffRepo.updateStaff(updatedStaff);

                    if (!mounted) return;

                    context.read<StaffBloc>().add(UpdateStaff(updatedStaff));
                    context.showSnackBar("Profile picture removed");
                    _loadData();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
