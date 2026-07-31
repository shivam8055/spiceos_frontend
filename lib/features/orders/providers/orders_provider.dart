import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_filter.dart';
import '../providers/order_filter_provider.dart';
import '../repositories/mock_orders_repository.dart';
import '../repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return MockOrdersRepository();
});

final ordersProvider = Provider<List<Order>>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.getOrders();
});

final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersProvider);
  final filter = ref.watch(orderFilterProvider);

  switch (filter) {
    case OrderFilter.all:
      return orders;

    case OrderFilter.preparing:
      return orders.where((o) => o.status == OrderStatus.preparing).toList();

    case OrderFilter.ready:
      return orders.where((o) => o.status == OrderStatus.ready).toList();

    case OrderFilter.delivery:
      return orders
          .where((o) => o.status == OrderStatus.outForDelivery)
          .toList();

    case OrderFilter.delivered:
      return orders.where((o) => o.status == OrderStatus.delivered).toList();
  }
});