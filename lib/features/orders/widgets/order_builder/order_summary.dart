import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/new_order_provider.dart';
import '../../providers/pricing_provider.dart';
import 'discount_card.dart';
import 'payment_selector.dart';
import '../../../shared/models/order_stage.dart';
import '../../../shared/providers/order_workflow_provider.dart';
import '../../services/order_factory.dart';
import '../../providers/orders_provider.dart';

class OrderSummary extends ConsumerWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(newOrderProvider.notifier);
    final items = ref.watch(newOrderProvider);

    final subtotal = notifier.total;
    final discount = ref.watch(discountProvider);
    final deliveryCharge = ref.watch(deliveryChargeProvider);
    final gstRate = ref.watch(gstRateProvider);

    final taxableAmount = subtotal - discount;
    final gst = taxableAmount * gstRate;
    final grandTotal = taxableAmount + gst + deliveryCharge;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...items.map(
                  (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text("Qty ${item.quantity}"),
                trailing: Text(
                  "₹${item.total.toStringAsFixed(0)}",
                ),
              ),
            ),

            const Divider(height: 32),

            const DiscountCard(),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: deliveryCharge.toStringAsFixed(0),
              decoration: const InputDecoration(
                labelText: "Delivery Charge",
                prefixText: "₹ ",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(deliveryChargeProvider.notifier).state =
                    double.tryParse(value) ?? 0;
              },
            ),

            const SizedBox(height: 16),

            const PaymentSelector(),

            const Divider(height: 32),

            _priceRow(
              "Subtotal",
              subtotal,
            ),

            _priceRow(
              "Discount",
              -discount,
              color: Colors.red,
            ),

            _priceRow(
              "Delivery",
              deliveryCharge,
            ),

            _priceRow(
              "GST",
              gst,
            ),

            const Divider(),

            _priceRow(
              "Grand Total",
              grandTotal,
              isBold: true,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final orderId =
                      'ORD-${DateTime.now().millisecondsSinceEpoch}';

                  // Publish workflow event
                  ref.read(orderWorkflowProvider.notifier).publish(
                    orderId: orderId,
                    stage: OrderStage.created,
                  );

                  // Add order to Kitchen queue
                  final order = OrderFactory.createWalkInOrder(
                    orderId: orderId,
                    orderNumber: '#${DateTime.now().millisecondsSinceEpoch % 10000}',
                    customerName: 'Walk-in Customer',
                    items: items
                        .map((item) => '${item.name} x${item.quantity}')
                        .toList(),
                    totalAmount: grandTotal,
                  );

                  ref.read(ordersProvider.notifier).createOrder(order);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order $orderId created successfully'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
      String title,
      double amount, {
        Color? color,
        bool isBold = false,
      }) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 15,
      fontWeight:
      isBold ? FontWeight.bold : FontWeight.w500,
      color: color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: style,
          ),
        ],
      ),
    );
  }
}