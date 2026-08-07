import 'package:flutter/material.dart';

import '../models/kitchen_order.dart';
import 'kitchen_timer.dart';

class KitchenOrderCard extends StatelessWidget {
  final KitchenOrder order;
  final VoidCallback? onPressed;
  final String buttonText;

  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(order.createdAt);

    Color borderColor = Colors.green;

    if (age.inMinutes >= 20) {
      borderColor = Colors.red;
    } else if (age.inMinutes >= 10) {
      borderColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.orderNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(order.customerName),

            const SizedBox(height: 8),

            KitchenTimer(
              createdAt: order.createdAt,
            ),

            const SizedBox(height: 12),

            ...order.items.map(
                  (e) => Text(
                "• $e",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}