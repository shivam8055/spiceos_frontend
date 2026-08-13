import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_shell.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../providers/derived_kitchen_provider.dart';
import '../widgets/kitchen_order_card.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(kitchenOrdersViewProvider);
    final waiting = orders.where((e) => e.status == OrderStatus.created).toList();
    final cooking = orders.where((e) => e.status == OrderStatus.preparing).toList();
    final ready = orders.where((e) => e.status == OrderStatus.ready).toList();

    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Kitchen Display',
            subtitle: 'Manage kitchen orders in real time',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _KitchenColumn(
                    title: 'Waiting',
                    buttonText: 'Start Cooking',
                    orders: waiting,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _KitchenColumn(
                    title: 'Cooking',
                    buttonText: 'Mark Ready',
                    orders: cooking,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _KitchenColumn(
                    title: 'Ready',
                    buttonText: 'Dispatch',
                    orders: ready,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenColumn extends ConsumerWidget {
  final String title;
  final String buttonText;
  final List<Order> orders;

  const _KitchenColumn({
    required this.title,
    required this.buttonText,
    required this.orders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$title (${orders.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return KitchenOrderCard(
                    order: order,
                    buttonText: buttonText,
                    onPressed: () async {
                      final notifier = ref.read(ordersProvider.notifier);
                      switch (order.status) {
                        case OrderStatus.created:
                          await notifier.startPreparing(order.id);
                          break;
                        case OrderStatus.preparing:
                          await notifier.markReady(order.id);
                          break;
                        case OrderStatus.ready:
                          await notifier.dispatch(order.id);
                          break;
                        case OrderStatus.outForDelivery:
                        case OrderStatus.delivered:
                        case OrderStatus.cancelled:
                          break;
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
