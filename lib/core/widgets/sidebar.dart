import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1F2937),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Icon(
            Icons.restaurant,
            color: Colors.orange,
            size: 60,
          ),
          const SizedBox(height: 10),
          const Text(
            "SpiceBox",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24),

          menuItem(Icons.dashboard, "Dashboard"),
          menuItem(Icons.shopping_bag, "Orders"),
          menuItem(Icons.restaurant_menu, "Menu"),
          menuItem(Icons.inventory, "Inventory"),
          menuItem(Icons.kitchen, "Kitchen"),
          menuItem(Icons.delivery_dining, "Delivery"),
          menuItem(Icons.people, "Customers"),
          menuItem(Icons.bar_chart, "Reports"),
          menuItem(Icons.settings, "Settings"),
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {},
    );
  }
}