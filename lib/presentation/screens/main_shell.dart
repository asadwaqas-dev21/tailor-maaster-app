import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_bloc.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/screens/customer/customer_list_screen.dart";
import "package:tailor_app/presentation/screens/dashboard/dashboard_tab.dart";
import "package:tailor_app/presentation/screens/order/order_list_screen.dart";
import "package:tailor_app/presentation/screens/staff/staff_list_screen.dart";
import "package:tailor_app/presentation/screens/settings/settings_screen.dart";

import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) =>
          prev.userRole != curr.userRole ||
          prev.selectedStitcherId != curr.selectedStitcherId,
      listener: (context, state) {
        setState(() => _currentIndex = 0);
        context.read<DashboardBloc>().add(const LoadDashboard());
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isOwner = state.isOwner;

          final screens = isOwner
              ? const [
                  DashboardTab(),
                  OrderListScreen(),
                  CustomerListScreen(),
                  StaffListScreen(),
                  SettingsScreen(),
                ]
              : const [
                  DashboardTab(),
                  SettingsScreen(),
                ];

          final items = isOwner
              ? [
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.home_2),
                    label: l10n.dashboard,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.clipboard_text),
                    label: l10n.orders,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.people),
                    label: l10n.customers,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.profile_2user),
                    label: l10n.staff,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.setting_2),
                    label: l10n.settings,
                  ),
                ]
              : [
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.home_2),
                    label: l10n.myWork,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Iconsax.setting_2),
                    label: l10n.settings,
                  ),
                ];

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 0) {
                  context.read<DashboardBloc>().add(const LoadDashboard());
                }
              },
              items: items,
              type: BottomNavigationBarType.fixed,
            ),
          );
        },
      ),
    );
  }
}
