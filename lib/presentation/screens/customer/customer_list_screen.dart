// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/core/widgets/app_search_bar.dart";
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
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customers)),
      floatingActionButton: FloatingActionButton(
        heroTag: "customerFab",
        onPressed: () => Navigator.of(context)
            .pushNamed("/customer/form")
            .then(
              // ignore: duplicate_ignore
              // ignore: use_build_context_synchronously
              (_) => context.read<CustomerBloc>().add(const LoadCustomers()),
            ),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          AppSearchBar(
            hint: l10n.searchCustomers,
            onChanged: (query) {
              context.read<CustomerBloc>().add(SearchCustomers(query));
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerError) {
                  return Center(child: Text(state.message));
                }
                if (state is CustomerLoaded) {
                  if (state.customers.isEmpty) {
                    return EmptyState(
                      title: l10n.noCustomers,
                      subtitle: l10n.noCustomersSubtitle,
                      icon: Iconsax.people,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      return _CustomerTile(customer: state.customers[index]);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;

  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initials = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : "?";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.of(context)
            .pushNamed("/customer/detail", arguments: customer.id)
            .then(
              (_) => context.read<CustomerBloc>().add(const LoadCustomers()),
            ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            initials,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(customer.name, style: theme.textTheme.titleSmall),
        subtitle: Text(customer.phone, style: theme.textTheme.bodySmall),
        trailing: Icon(
          customer.gender == Gender.male ? Iconsax.man : Iconsax.woman,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
      ),
    );
  }
}
