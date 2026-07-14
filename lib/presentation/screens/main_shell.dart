import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/extensions/context_extensions.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_bloc.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";
import "package:tailor_app/presentation/screens/customer/customer_list_screen.dart";
import "package:tailor_app/presentation/screens/dashboard/dashboard_tab.dart";
import "package:tailor_app/presentation/screens/report/report_screen.dart";
import "package:tailor_app/presentation/screens/settings/settings_screen.dart";

/// Bottom nav: Orders · Grahak · [FAB] · Khata · Aur
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

  Future<void> _openNewOrder() async {
    await Navigator.of(context).pushNamed("/order/form");
    if (!mounted) return;
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
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
                  CustomerListScreen(),
                  ReportScreen(),
                  SettingsScreen(),
                ]
              : const [
                  DashboardTab(),
                  SettingsScreen(),
                ];

          // Map nav slots → screen index (FAB is not a screen)
          int screenForNav(int navIndex) {
            if (!isOwner) return navIndex.clamp(0, 1);
            switch (navIndex) {
              case 0:
                return 0; // Orders
              case 1:
                return 1; // Grahak
              case 3:
                return 2; // Khata
              case 4:
                return 3; // Aur
              default:
                return 0;
            }
          }

          int navForScreen(int screenIndex) {
            if (!isOwner) return screenIndex;
            switch (screenIndex) {
              case 0:
                return 0;
              case 1:
                return 1;
              case 2:
                return 3;
              case 3:
                return 4;
              default:
                return 0;
            }
          }

          final navIndex = navForScreen(_currentIndex);

          return Scaffold(
            backgroundColor: context.darzi.scaffold,
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: _DarziBottomNav(
              currentIndex: navIndex,
              isOwner: isOwner,
              onTap: (i) {
                if (isOwner && i == 2) {
                  _openNewOrder();
                  return;
                }
                if (!isOwner && i == 1) {
                  // stitcher: second tab is settings; no FAB
                }
                setState(() => _currentIndex = screenForNav(i));
                if (screenForNav(i) == 0) {
                  context.read<DashboardBloc>().add(const LoadDashboard());
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _DarziBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isOwner;
  final ValueChanged<int> onTap;

  const _DarziBottomNav({
    required this.currentIndex,
    required this.isOwner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final darzi = context.darzi;
    if (!isOwner) {
      final l10n = context.l10n;
      return Container(
        decoration: BoxDecoration(
          color: darzi.navBar,
          border: Border(top: BorderSide(color: darzi.line)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _NavItem(
                icon: Iconsax.home_2,
                label: l10n.navOrders,
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Iconsax.setting_2,
                label: l10n.navMore,
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      );
    }

    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: darzi.navBar,
        border: Border(top: BorderSide(color: darzi.line)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: Iconsax.home_2,
              label: l10n.navOrders,
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Iconsax.people,
              label: l10n.navCustomers,
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _FabSlot(onTap: () => onTap(2)),
            _NavItem(
              icon: Iconsax.book,
              label: l10n.navLedger,
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Iconsax.menu,
              label: l10n.navMore,
              active: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (context.isDarkMode ? AppColors.brassSoft : AppColors.pine)
        : context.darzi.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelOf(
                  context,
                  size: 9.5,
                  weight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabSlot extends StatelessWidget {
  final VoidCallback onTap;
  const _FabSlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: const Offset(0, -26),
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
    );
  }
}
