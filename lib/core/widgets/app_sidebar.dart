import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_notifier.dart';
import '../models/navigation_item.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  static const List<NavigationItem> items = [
    NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/',
    ),
    NavigationItem(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
      route: '/orders',
    ),
    NavigationItem(
      title: 'Customers',
      icon: Icons.people_outline,
      route: '/customers',
    ),
    NavigationItem(
      title: 'Inventory',
      icon: Icons.inventory_2_outlined,
      route: '/inventory',
    ),
    NavigationItem(
      title: 'Kitchen',
      icon: Icons.restaurant_outlined,
      route: '/kitchen',
    ),
    NavigationItem(
      title: 'Delivery',
      icon: Icons.delivery_dining_outlined,
      route: '/delivery',
    ),
    NavigationItem(
      title: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
    NavigationItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),

          const Text(
            '🌶 SpiceOS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = currentRoute == item.route;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: selected
                          ? Colors.deepOrange
                          : Colors.grey,
                    ),
                    title: Text(item.title),
                    selected: selected,
                    selectedTileColor: const Color(0xFFFFF1EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => context.go(item.route),
                  ),
                );
              },
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(
                Icons.logout_outlined,
                color: Colors.grey,
              ),
              title: const Text('Sign Out'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}