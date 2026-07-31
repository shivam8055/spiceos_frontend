import 'package:flutter/material.dart';

import '../models/order.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/payment_status_chip.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNumber),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Customer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(order.customerName),
                subtitle: Text(order.customerId),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Order",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Text(order.primaryItem),
                        const Spacer(),
                        Text("₹${order.totalAmount.toStringAsFixed(0)}"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Text("Source"),
                        const Spacer(),
                        Text(order.orderSource),
                      ],
                    ),

                    const Divider(),

                    Row(
                      children: [
                        const Text("Payment"),
                        const Spacer(),
                        PaymentStatusChip(
                          status: order.paymentStatus,
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      children: [
                        const Text("Status"),
                        const Spacer(),
                        OrderStatusChip(
                          status: order.status,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_shipping),
                label: const Text("Assign Delivery Rider"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print),
                label: const Text("Print Invoice"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat),
                label: const Text("WhatsApp Customer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}