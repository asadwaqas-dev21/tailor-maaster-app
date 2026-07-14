import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/constants/measurement_fields.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/widgets/confirm_dialog.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/customer/customer_bloc.dart";
import "package:tailor_app/presentation/blocs/customer/customer_event.dart";

/// Grahak profile — matches Darzi mockup screen 03.
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

  double get _baqaya =>
      _orders.fold(0.0, (sum, o) => sum + o.remainingAmount);

  int get _garmentTypes =>
      _measurements.map((m) => m.category).toSet().length;

  @override
  Widget build(BuildContext context) {
    final isOwner =
        HiveService.settingsBox.get("userRole", defaultValue: "owner") ==
            "owner";

    final darzi = context.darzi;

    if (_customer == null) {
      return Scaffold(
        backgroundColor: darzi.scaffold,
        appBar: AppBar(),
        body: const Center(child: Text("Customer not found")),
      );
    }

    final customer = _customer!;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Row(
                children: [
                  DarziIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      "Grahak",
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        size: 16,
                        weight: FontWeight.w700,
                        color: darzi.ink,
                      ),
                    ),
                  ),
                  if (isOwner)
                    GestureDetector(
                      onLongPress: _deleteCustomer,
                      child: DarziIconButton(
                        icon: Iconsax.edit_2,
                        onTap: () => Navigator.of(context)
                            .pushNamed("/customer/form", arguments: customer)
                            .then((_) => _loadData()),
                      ),
                    )
                  else
                    const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _ProfileHeader(
                    customer: customer,
                    totalOrders: _orders.length,
                    garmentTypes: _garmentTypes,
                    baqaya: _baqaya,
                    onPhotoTap: isOwner
                        ? () => _showPhotoPickerOptions(customer)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        "Saved naap",
                        style: AppTypography.display(
                          size: 14,
                          weight: FontWeight.w600,
                          color: darzi.ink,
                        ),
                      ),
                      const Spacer(),
                      if (isOwner)
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(
                                "/measurement/form",
                                arguments: {"customerId": widget.customerId},
                              )
                              .then((_) => _loadData()),
                          child: Text(
                            "Sab",
                            style: AppTypography.ui(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: darzi.brass,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_measurements.isEmpty)
                    Text(
                      "Abhi koi naap save nahi",
                      style: AppTypography.ui(size: 12, color: darzi.muted),
                    )
                  else
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: _measurements.take(4).map((m) {
                        final ur =
                            MeasurementFields.categoryLabelsUr[m.category] ??
                                m.category;
                        final en =
                            MeasurementFields.categoryLabelsEn[m.category] ??
                                m.category;
                        final vals = m.fields.values.take(3).toList();
                        return GestureDetector(
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
                          child: Container(
                            width: (MediaQuery.sizeOf(context).width - 41) / 2,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darzi.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: darzi.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ur,
                                  style: AppTypography.urdu(
                                    size: 14,
                                    color: darzi.ink,
                                  ),
                                ),
                                Text(
                                  en,
                                  style: AppTypography.ui(
                                    size: 10,
                                    color: darzi.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  vals.isEmpty
                                      ? "—"
                                      : vals
                                          .map((v) => v % 1 == 0
                                              ? v.toInt().toString()
                                              : v.toString())
                                          .join(" · "),
                                  style: AppTypography.mono(
                                    size: 11,
                                    color: AppColors.pine,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 18),
                  Text(
                    "Naap history",
                    style: AppTypography.display(
                      size: 14,
                      weight: FontWeight.w600,
                      color: darzi.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: darzi.panel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _measurements.isEmpty
                        ? Text(
                            "History khali hai",
                            style: AppTypography.ui(
                              size: 12,
                              color: darzi.muted,
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0;
                                  i < _measurements.take(3).length;
                                  i++)
                                _HistoryItem(
                                  title:
                                      "${MeasurementFields.categoryLabelsEn[_measurements[i].category] ?? _measurements[i].category} · ${_measurements[i].createdAt == _customer!.createdAt ? 'added' : 'updated'}",
                                  subtitle:
                                      _measurements[i].createdAt.formatted,
                                  isLast: i ==
                                      _measurements.take(3).length - 1,
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 18),
                  if (isOwner)
                    DarziButton(
                      label: "Naya order — same as last",
                      icon: Icons.refresh_rounded,
                      variant: DarziButtonVariant.pine,
                      onPressed: () => Navigator.of(context)
                          .pushNamed(
                            "/order/form",
                            arguments: customer.id,
                          )
                          .then((_) => _loadData()),
                    ),
                ],
              ),
            ),
          ],
        ),
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
      final directory = Directory(appDir.path);
      if (await directory.exists()) {
        for (final file in directory.listSync()) {
          final filename = file.path.split(Platform.pathSeparator).last;
          if (filename.startsWith("customer_${customer.id}_") &&
              filename.endsWith(".jpg")) {
            try {
              await file.delete();
            } catch (_) {}
          }
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localImagePath =
          "${appDir.path}/customer_${customer.id}_$timestamp.jpg";
      await File(pickedFile.path).copy(localImagePath);

      final updatedCustomer = customer.copyWith(imagePath: localImagePath);
      await CustomerRepositoryImpl().updateCustomer(updatedCustomer);
      if (!mounted) return;
      context.read<CustomerBloc>().add(UpdateCustomer(updatedCustomer));
      context.showSnackBar("Profile picture updated");
      _loadData();
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Failed to update picture", isError: true);
      }
    }
  }

  void _showPhotoPickerOptions(Customer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.darzi.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Customer customer;
  final int totalOrders;
  final int garmentTypes;
  final double baqaya;
  final VoidCallback? onPhotoTap;

  const _ProfileHeader({
    required this.customer,
    required this.totalOrders,
    required this.garmentTypes,
    required this.baqaya,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pine,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brass.withValues(alpha: 0.14),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onPhotoTap,
                    child: DarziAvatar(
                      name: customer.name,
                      size: 52,
                      gradient: AppColors.brassGradient,
                      textColor: AppColors.pineDeep,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTypography.display(
                            size: 19,
                            weight: FontWeight.w700,
                            color: const Color(0xFFEEF4F2),
                            letterSpacing: -0.1,
                          ),
                        ),
                        Text(
                          customer.phone.replaceAllMapped(
                            RegExp(r"^(\d{4})(\d+)"),
                            (m) => "${m[1]}·${m[2]}",
                          ),
                          style: AppTypography.mono(
                            size: 12,
                            weight: FontWeight.w400,
                            color: const Color(0xFFA9C4BF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(n: "$totalOrders", l: "Total orders"),
                  const SizedBox(width: 20),
                  _Stat(n: "$garmentTypes", l: "Garment types"),
                  const SizedBox(width: 20),
                  _Stat(
                    n: "${AppConstants.currencySymbol} ${baqaya.toStringAsFixed(0)}",
                    l: "Baqaya",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String n;
  final String l;
  const _Stat({required this.n, required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          n,
          style: AppTypography.mono(
            size: 18,
            weight: FontWeight.w700,
            color: AppColors.brassSoft,
          ),
        ),
        Text(
          l,
          style: AppTypography.ui(size: 10, color: const Color(0xFF9DB6B1)),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLast;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: AppColors.brass,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 26,
                  color: darzi.line,
                ),
            ],
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.ui(
                    size: 12,
                    weight: FontWeight.w600,
                    color: darzi.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.mono(
                    size: 10.5,
                    weight: FontWeight.w400,
                    color: darzi.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
