import 'package:flutter/material.dart';

import '../../orders/models/order.dart';
import 'kitchen_timer.dart';

class KitchenOrderCard extends StatelessWidget {
  final Order order;
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
    // Waiting time starts at order creation. Once cooking begins, the kitchen
    // timer switches to the server-recorded preparation start time and stays
    // anchored there through Ready/Dispatch and browser refreshes.
    final timerStart = order.status == OrderStatus.created
        ? order.createdAt
        : (order.preparingAt ?? order.createdAt);
    final age = DateTime.now().difference(timerStart);

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
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            KitchenTimer(startedAt: timerStart),
            if (order.primaryItem.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '• ${order.primaryItem}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
            if (order.transactionCode != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Txn: ${order.transactionCode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
