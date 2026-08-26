import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/providers/inventory_api_provider.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';

class AiInsights extends ConsumerWidget {
  const AiInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final inventory = ref.watch(inventoryItemsProvider).valueOrNull ?? const [];
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final todayOrders = orders.where((order) => !order.createdAt.toLocal().isBefore(start)).toList();
    final lowStock = inventory.where((item) => item.isLowStock).toList();
    final pending = todayOrders.where((order) => order.paymentStatus == PaymentStatus.pending).length;
    final preparing = todayOrders.where((order) => order.status == OrderStatus.preparing).length;
    final delivered = todayOrders.where((order) => order.status == OrderStatus.delivered).length;

    final insights = <String>[];
    if (lowStock.isNotEmpty) {
      insights.add('${lowStock.length} ingredient${lowStock.length == 1 ? '' : 's'} need replenishment.');
    }
    if (pending > 0) {
      insights.add('$pending order${pending == 1 ? '' : 's'} still have pending payment.');
    }
    if (preparing >= 5) {
      insights.add('Kitchen load is high with $preparing orders preparing right now.');
    }
    if (delivered >= 1 && todayOrders.isNotEmpty) {
      final rate = delivered / todayOrders.length * 100;
      insights.add('Today\'s completion rate is ${rate.toStringAsFixed(0)}%.');
    }
    if (insights.isEmpty) {
      insights.add('Operations look healthy. Keep monitoring stock and order flow.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('SpiceOS Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            const Text('LIVE'),
          ]),
          const SizedBox(height: 12),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6)),
                const SizedBox(width: 10),
                Expanded(child: Text(insight)),
              ]),
            ),
        ]),
      ),
    );
  }
}
