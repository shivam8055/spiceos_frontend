import 'package:flutter/material.dart';

import '../models/order.dart';
import 'order_status_chip.dart';
import 'payment_status_chip.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  OrderStatusChip(status: order.status),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                order.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(order.primaryItem),

              const SizedBox(height: 12),

              Row(
                children: [

                  Text(
                    "₹${order.totalAmount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  PaymentStatusChip(
                    status: order.paymentStatus,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Icon(
                    Icons.storefront,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 6),

                  Text(order.orderSource),

                  const Spacer(),

                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}