// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/darzi_widgets.dart";
import "package:tailor_app/core/widgets/empty_state.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/presentation/blocs/customer/customer_bloc.dart";
import "package:tailor_app/presentation/blocs/customer/customer_event.dart";
import "package:tailor_app/presentation/blocs/customer/customer_state.dart";

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return Scaffold(
      backgroundColor: darzi.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Grahak",
                          style: AppTypography.display(
                            size: 22,
                            weight: FontWeight.w700,
                            color: darzi.ink,
                          ),
                        ),
                        Text(
                          "Customers · history & re-order",
                          style: AppTypography.ui(
                            size: 12,
                            color: darzi.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DarziIconButton(
                    icon: Iconsax.user_add,
                    onTap: () => Navigator.of(context)
                        .pushNamed("/customer/form")
                        .then(
                          (_) => context
                              .read<CustomerBloc>()
                              .add(const LoadCustomers()),
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (q) =>
                    context.read<CustomerBloc>().add(SearchCustomers(q)),
                decoration: InputDecoration(
                  hintText: "Naam ya phone dhoondhein…",
                  prefixIcon: const Icon(Iconsax.search_normal_1, size: 18),
                  filled: true,
                  fillColor: darzi.panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.pine),
                    );
                  }
                  if (state is CustomerError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is CustomerLoaded) {
                    if (state.customers.isEmpty) {
                      return EmptyState(
                        title: context.l10n.noCustomers,
                        subtitle: context.l10n.noCustomersSubtitle,
                        icon: Iconsax.people,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: state.customers.length,
                      itemBuilder: (context, index) {
                        return _GrahakTile(customer: state.customers[index]);
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

class _GrahakTile extends StatelessWidget {
  final Customer customer;
  const _GrahakTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed("/customer/detail", arguments: customer.id),
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
            DarziAvatar(name: customer.name, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: AppTypography.ui(
                      size: 14,
                      weight: FontWeight.w600,
                      color: darzi.ink,
                    ),
                  ),
                  Text(
                    customer.phone,
                    style: AppTypography.mono(
                      size: 11,
                      weight: FontWeight.w400,
                      color: darzi.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: darzi.muted),
          ],
        ),
      ),
    );
  }
}
