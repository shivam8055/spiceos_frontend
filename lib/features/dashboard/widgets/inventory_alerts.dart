import 'package:flutter/material.dart';

class InventoryAlerts extends StatelessWidget {
  const InventoryAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      ('Paneer', 'Low Stock'),
      ('Rice', 'Restock Soon'),
      ('Cooking Oil', 'Critical'),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...alerts.map(
                  (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                title: Text(item.$1),
                subtitle: Text(item.$2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}