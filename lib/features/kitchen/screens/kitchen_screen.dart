import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_shell.dart';
import '../models/kitchen_order.dart';
import '../providers/kitchen_provider.dart';
import '../widgets/kitchen_order_card.dart';
import '../providers/derived_kitchen_provider.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(kitchenOrdersViewProvider);

    final waiting = orders
        .where((e) => e.status == KitchenOrderStatus.waiting)
        .toList();

    final cooking = orders
        .where((e) => e.status == KitchenOrderStatus.cooking)
        .toList();

    final ready = orders
        .where((e) => e.status == KitchenOrderStatus.ready)
        .toList();

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
                    color: Colors.red,
                    buttonText: 'Start Cooking',
                    orders: waiting,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _KitchenColumn(
                    title: 'Cooking',
                    color: Colors.orange,
                    buttonText: 'Mark Ready',
                    orders: cooking,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _KitchenColumn(
                    title: 'Ready',
                    color: Colors.green,
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
  final Color color;
  final String buttonText;
  final List<KitchenOrder> orders;

  const _KitchenColumn({
    required this.title,
    required this.color,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return KitchenOrderCard(
                    order: order,
                    buttonText: buttonText,
                    onPressed: () {
                      final notifier =
                      ref.read(kitchenOrdersProvider.notifier);

                      switch (order.status) {
                        case KitchenOrderStatus.waiting:
                          notifier.startCooking(order.id);
                          break;

                        case KitchenOrderStatus.cooking:
                          notifier.markReady(order.id);
                          break;

                        case KitchenOrderStatus.ready:
                          notifier.dispatch(order.id);
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