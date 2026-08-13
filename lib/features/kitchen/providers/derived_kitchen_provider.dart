import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';

final kitchenOrdersViewProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersProvider);

  return orders
      .where(
        (order) =>
            order.status == OrderStatus.created ||
            order.status == OrderStatus.preparing ||
            order.status == OrderStatus.ready,
      )
      .toList();
});
