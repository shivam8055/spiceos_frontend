import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_timeline.dart';
import '../widgets/payment_status_chip.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    const reasons = [
      'Item(s) out of stock',
      'Unable to prepare order',
      'Equipment / kitchen issue',
      'Customer requested cancellation',
      'Other',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select a cancellation reason. The order will be marked cancelled.'),
            const SizedBox(height: 12),
            ...reasons.map((r) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(r),
              onTap: () => Navigator.pop(dialogContext, r),
            )),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Keep order'))],
      ),
    );
    if (reason == null || !context.mounted) return;
    try {
      await ref.read(ordersProvider.notifier).updateOrder(
        order.copyWith(status: OrderStatus.cancelled),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order cancelled: $reason')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not cancel order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(order.orderNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(order.customerName),
              subtitle: Text(order.customerId),
            )),
            const SizedBox(height: 24),
            const Text('Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (order.items.isNotEmpty) ...[
                  Row(children: [
                    const Expanded(child: Text('ORDER ITEMS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.6))),
                    Text('${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(width: 12),
                      Text('× ${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 16),
                      SizedBox(width: 76, child: Text('₹${item.total.toStringAsFixed(0)}', textAlign: TextAlign.end)),
                    ]),
                  )),
                  const Divider(),
                  Row(children: [
                    const Expanded(child: Text('Order total', style: TextStyle(fontWeight: FontWeight.w700))),
                    Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                ] else
                  Row(children: [Expanded(child: Text(order.primaryItem)), Text('₹${order.totalAmount.toStringAsFixed(0)}')]),
                const SizedBox(height: 20),
                Row(children: [const Text('Source'), const Spacer(), Text(order.orderSource)]),
                const Divider(),
                Row(children: [const Text('Payment'), const Spacer(), PaymentStatusChip(status: order.paymentStatus)]),
                const Divider(),
                Row(children: [const Text('Status'), const Spacer(), OrderStatusChip(status: order.status)]),
                if (order.transactionCode != null) ...[
                  const Divider(),
                  Row(children: [const Text('Transaction'), const Spacer(), Flexible(child: Text(order.transactionCode!, overflow: TextOverflow.ellipsis))]),
                ],
              ]),
            )),
            const SizedBox(height: 24),
            OrderTimeline(order: order),
            if (order.totalDeliveryTime != null) ...[
              const SizedBox(height: 16),
              Card(child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Total delivery time'),
                trailing: Text(_formatDuration(order.totalDeliveryTime!), style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ],
            const SizedBox(height: 30),
            if (order.status != OrderStatus.cancelled &&
                order.status != OrderStatus.delivered &&
                order.status != OrderStatus.outForDelivery) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  onPressed: () => _cancelOrder(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Order'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping),
              label: const Text('Assign Delivery Rider'),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print),
              label: const Text('Print Invoice'),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp Customer'),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '${duration.inSeconds}s';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${duration.inMinutes}m';
  }
}
