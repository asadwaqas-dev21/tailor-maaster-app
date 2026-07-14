// ignore_for_file: use_build_context_synchronously

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/core/widgets/status_badge.dart";
import "package:tailor_app/core/enums/staff_role.dart";
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

  void _openAddStaff() {
    Navigator.of(context)
        .pushNamed("/staff/form")
        .then((_) => context.read<StaffBloc>().add(const LoadStaff()));
  }

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;

    return Scaffold(
      backgroundColor: darzi.scaffold,
      floatingActionButton: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8, end: 4),
        child: GestureDetector(
          onTap: _openAddStaff,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: AppColors.brassGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brass.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 26, color: AppColors.pineDeep),
          ),
        ),
      ),
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
                    child: Column(
                      children: [
                        Text(
                          "Staff",
                          style: AppTypography.display(
                            size: 16,
                            weight: FontWeight.w700,
                            color: darzi.ink,
                          ),
                        ),
                        Text(
                          "Silai team",
                          style: AppTypography.ui(size: 12, color: darzi.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<StaffBloc, StaffState>(
                builder: (context, state) {
                  if (state is StaffLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.pine),
                    );
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: state.staffMembers.length,
                      itemBuilder: (context, index) {
                        return _StaffTile(staff: state.staffMembers[index]);
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

class _StaffTile extends StatelessWidget {
  final Staff staff;

  const _StaffTile({required this.staff});

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed("/staff/detail", arguments: staff.id)
          .then((_) => context.read<StaffBloc>().add(const LoadStaff())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: darzi.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darzi.line),
        ),
        child: Row(
          children: [
            _StaffAvatar(staff: staff),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: AppTypography.ui(
                      size: 14,
                      weight: FontWeight.w600,
                      color: darzi.ink,
                    ),
                  ),
                  Text(
                    staff.phone,
                    style: AppTypography.mono(
                      size: 11,
                      weight: FontWeight.w400,
                      color: darzi.muted,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: context.isUrdu ? staff.role.labelUr : staff.role.labelEn,
              color: staff.role.color,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: darzi.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  final Staff staff;

  const _StaffAvatar({required this.staff});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        staff.imagePath != null &&
        staff.imagePath!.isNotEmpty &&
        File(staff.imagePath!).existsSync();

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(44 * 0.3),
        child: Image.file(
          File(staff.imagePath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    return DarziAvatar(name: staff.name, size: 44);
  }
}
