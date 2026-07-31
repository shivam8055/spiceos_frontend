import 'package:go_router/go_router.dart';

import '../features/customers/screens/customers_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/delivery/screens/delivery_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/kitchen/screens/kitchen_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/orders/screens/new_order_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),

    GoRoute(
      path: '/orders/new',
      builder: (context, state) => const NewOrderScreen(),
    ),

    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),

    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),

    GoRoute(
      path: '/kitchen',
      builder: (context, state) => const KitchenScreen(),
    ),

    GoRoute(
      path: '/delivery',
      builder: (context, state) => const DeliveryScreen(),
    ),

    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);