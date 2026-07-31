import 'package:flutter/material.dart';

class KitchenQueue extends StatelessWidget {
  const KitchenQueue({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      ('#1024', 'Paneer Butter Masala', 'Preparing', Colors.orange),
      ('#1025', 'Chicken Biryani', 'Ready', Colors.green),
      ('#1026', 'Veg Fried Rice', 'Cooking', Colors.blue),
      ('#1027', 'Butter Naan', 'Waiting', Colors.red),
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
              'Kitchen Queue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...orders.map(
                  (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${order.$1} • ${order.$2}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(order.$3),
                      backgroundColor: (order.$4 as Color).withValues(alpha: 0.15),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: order.$4 as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}