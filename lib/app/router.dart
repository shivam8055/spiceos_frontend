import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/models/role_permissions.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/customers/screens/customers_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/delivery/screens/delivery_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/kitchen/screens/kitchen_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/orders/screens/new_order_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/qr/screens/qr_tables_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/settings_screen.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final user = authState.asData?.value;
      final location = state.matchedLocation;
      final loggingIn = location == '/login';
      if (authState.isLoading) return null;
      if (user == null && !loggingIn) return '/login';
      if (user != null && loggingIn) return '/';
      if (user != null && !RolePermissions.canAccess(location, user.role)) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(path: '/orders/new', builder: (context, state) => const NewOrderScreen()),
      GoRoute(path: '/customers', builder: (context, state) => const CustomersScreen()),
      GoRoute(path: '/inventory', builder: (context, state) => const InventoryScreen()),
      GoRoute(path: '/kitchen', builder: (context, state) => const KitchenScreen()),
      GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
      GoRoute(path: '/qr-tables', builder: (context, state) => const QRTablesScreen()),
      GoRoute(path: '/delivery', builder: (context, state) => const DeliveryScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
}
