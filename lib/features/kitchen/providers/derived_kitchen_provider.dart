import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/kitchen_order.dart';

final kitchenOrdersViewProvider = Provider<List<KitchenOrder>>((ref) {
  final orders = ref.watch(ordersProvider);

  return orders
      .where(
        (order) =>
    order.status == OrderStatus.created ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.ready,
  )
      .map(
        (order) => KitchenOrder(
      id: order.id,
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      items: [
        order.primaryItem,
      ],
      createdAt: order.createdAt,
      status: switch (order.status) {
        OrderStatus.created => KitchenOrderStatus.waiting,
        OrderStatus.preparing => KitchenOrderStatus.cooking,
        OrderStatus.ready => KitchenOrderStatus.ready,

      // These should never be reached because of the filter above.
        _ => KitchenOrderStatus.waiting,
      },
    ),
  )
      .toList();
});