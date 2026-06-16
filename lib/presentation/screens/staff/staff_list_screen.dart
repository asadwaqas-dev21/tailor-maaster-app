// ignore_for_file: use_build_context_synchronously

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/presentation/blocs/staff/staff_bloc.dart";
import "package:tailor_app/presentation/blocs/staff/staff_event.dart";
import "package:tailor_app/presentation/blocs/staff/staff_state.dart";

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const LoadStaff());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Members")),
      floatingActionButton: FloatingActionButton(
        heroTag: "staffFab",
        onPressed: () => Navigator.of(context)
            .pushNamed("/staff/form")
            .then((_) => context.read<StaffBloc>().add(const LoadStaff())),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StaffError) {
            return Center(child: Text(state.message));
          }
          if (state is StaffLoaded) {
            if (state.staffMembers.isEmpty) {
              return const EmptyState(
                title: "No Staff Yet",
                subtitle: "Add your first staff member",
                icon: Iconsax.people,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 16),
              itemCount: state.staffMembers.length,
              itemBuilder: (context, index) {
                return _StaffTile(staff: state.staffMembers[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final Staff staff;

  const _StaffTile({required this.staff});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initials = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : "?";

    final hasImage = staff.imagePath != null &&
        staff.imagePath!.isNotEmpty &&
        File(staff.imagePath!).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.of(context)
            .pushNamed("/staff/detail", arguments: staff.id)
            .then((_) => context.read<StaffBloc>().add(const LoadStaff())),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          backgroundImage: hasImage ? FileImage(File(staff.imagePath!)) : null,
          child: hasImage
              ? null
              : Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        title: Text(staff.name, style: theme.textTheme.titleSmall),
        subtitle: Text(staff.phone, style: theme.textTheme.bodySmall),
        trailing: StatusBadge(
          label: context.isUrdu ? staff.role.labelUr : staff.role.labelEn,
          color: staff.role.color,
        ),
      ),
    );
  }
}
