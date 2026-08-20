import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_icons.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/transactions/presentation/screens/cashier_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Router configuration dengan adaptive navigation shell sesuai ARCHITECTURE.md §6 & §7
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/pos',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdaptiveNavigationShell(
            currentLocation: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/pos',
            builder: (context, state) => const CashierScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class AdaptiveNavigationShell extends StatelessWidget {
  final String currentLocation;
  final Widget child;

  const AdaptiveNavigationShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  int _calculateSelectedIndex() {
    if (currentLocation.startsWith('/products')) return 1;
    if (currentLocation.startsWith('/transactions')) return 2;
    if (currentLocation.startsWith('/dashboard')) return 3;
    if (currentLocation.startsWith('/settings')) return 4;
    return 0; // /pos
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/pos');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/dashboard');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isExpanded = screenWidth >= 840;

    final destinations = [
      const NavigationDestination(
        icon: Icon(AppIcons.pos),
        selectedIcon: Icon(AppIcons.posActive),
        label: 'Kasir',
      ),
      const NavigationDestination(
        icon: Icon(AppIcons.products),
        selectedIcon: Icon(AppIcons.productsActive),
        label: 'Produk',
      ),
      const NavigationDestination(
        icon: Icon(AppIcons.history),
        selectedIcon: Icon(AppIcons.historyActive),
        label: 'Riwayat',
      ),
      const NavigationDestination(
        icon: Icon(AppIcons.dashboard),
        selectedIcon: Icon(AppIcons.dashboardActive),
        label: 'Laporan',
      ),
      const NavigationDestination(
        icon: Icon(AppIcons.settings),
        selectedIcon: Icon(AppIcons.settingsActive),
        label: 'Pengaturan',
      ),
    ];

    if (isExpanded) {
      // Tablet Landscape / Expanded width: NavigationRail di sebelah kiri
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(AppIcons.pos),
                  selectedIcon: Icon(AppIcons.posActive),
                  label: Text('Kasir'),
                ),
                NavigationRailDestination(
                  icon: Icon(AppIcons.products),
                  selectedIcon: Icon(AppIcons.productsActive),
                  label: Text('Produk'),
                ),
                NavigationRailDestination(
                  icon: Icon(AppIcons.history),
                  selectedIcon: Icon(AppIcons.historyActive),
                  label: Text('Riwayat'),
                ),
                NavigationRailDestination(
                  icon: Icon(AppIcons.dashboard),
                  selectedIcon: Icon(AppIcons.dashboardActive),
                  label: Text('Laporan'),
                ),
                NavigationRailDestination(
                  icon: Icon(AppIcons.settings),
                  selectedIcon: Icon(AppIcons.settingsActive),
                  label: Text('Pengaturan'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone Portrait / Compact width: Bottom NavigationBar
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: destinations,
      ),
    );
  }
}
