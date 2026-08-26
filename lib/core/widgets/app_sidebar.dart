import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_notifier.dart';
import '../models/navigation_item.dart';
import 'responsive_layout.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  static const List<NavigationItem> items = [
    NavigationItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/'),
    NavigationItem(title: 'Orders', icon: Icons.receipt_long_outlined, route: '/orders'),
    NavigationItem(title: 'Customers', icon: Icons.people_outline, route: '/customers'),
    NavigationItem(title: 'Inventory', icon: Icons.inventory_2_outlined, route: '/inventory'),
    NavigationItem(title: 'Kitchen', icon: Icons.restaurant_outlined, route: '/kitchen'),
    NavigationItem(title: 'Menu', icon: Icons.restaurant_menu_outlined, route: '/menu'),
    NavigationItem(title: 'QR Tables', icon: Icons.qr_code_2_outlined, route: '/qr-tables'),
    NavigationItem(title: 'Delivery', icon: Icons.delivery_dining_outlined, route: '/delivery'),
    NavigationItem(title: 'Accounting & GST', icon: Icons.account_balance_outlined, route: '/accounting'),
    NavigationItem(title: 'Reports', icon: Icons.bar_chart_outlined, route: '/reports'),
    NavigationItem(title: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final user = ref.watch(authNotifierProvider).asData?.value;
    final mobile = ResponsiveLayout.isMobile(context);
    final visible = items.where((item) {
      if (item.route == '/accounting' || item.route == '/reports' || item.route == '/delivery') {
        return user?.role == 'owner' || user?.role == 'manager';
      }
      if (item.route == '/settings' || item.route == '/qr-tables') return user?.role == 'owner';
      return true;
    }).toList();

    return Container(
      width: mobile ? double.infinity : 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, mobile ? 20 : 32, 20, 18),
            child: Row(
              children: [
                const Text('🌶', style: TextStyle(fontSize: 25)),
                const SizedBox(width: 8),
                Text(
                  'SpiceOS',
                  style: TextStyle(
                    fontSize: mobile ? 24 : 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final item = visible[index];
                final selected = currentRoute == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: !mobile,
                      minVerticalPadding: mobile ? 10 : 8,
                      leading: Icon(
                        item.icon,
                        color: selected ? Colors.deepOrange : Colors.grey.shade600,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      selected: selected,
                      selectedTileColor: const Color(0xFFFFF1EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        if (mobile) Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                dense: !mobile,
                leading: const Icon(Icons.logout_outlined, color: Colors.grey),
                title: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () async {
                  if (mobile) Navigator.of(context).pop();
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
