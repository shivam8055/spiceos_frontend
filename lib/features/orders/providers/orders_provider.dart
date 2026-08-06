import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_filter.dart';
import '../providers/order_filter_provider.dart';
import '../repositories/mock_orders_repository.dart';
import '../repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  // TODO: Switch to ApiOrdersRepository when backend is ready.
  return MockOrdersRepository();
});

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier(this._repository)
      : super(List<Order>.from(_repository.getOrders()));

  final OrdersRepository _repository;

  Future<void> refresh() async {
    state = List<Order>.from(_repository.getOrders());
  }

  Future<void> createOrder(Order order) async {
    await _repository.createOrder(order);
    await refresh();
  }

  Future<void> updateOrder(Order order) async {
    await _repository.updateOrder(order);
    await refresh();
  }

  Future<void> deleteOrder(String id) async {
    await _repository.deleteOrder(id);
    await refresh();
  }

  Future<void> startCooking(String orderId) async {
    final order = state.firstWhere((o) => o.id == orderId);

    await updateOrder(
      order.copyWith(
        status: OrderStatus.preparing,
      ),
    );
  }

  Future<void> markReady(String orderId) async {
    final order = state.firstWhere((o) => o.id == orderId);

    await updateOrder(
      order.copyWith(
        status: OrderStatus.ready,
      ),
    );
  }

  Future<void> dispatch(String orderId) async {
    final order = state.firstWhere((o) => o.id == orderId);

    await updateOrder(
      order.copyWith(
        status: OrderStatus.outForDelivery,
      ),
    );
  }
}

final ordersProvider =
StateNotifierProvider<OrdersNotifier, List<Order>>(
      (ref) => OrdersNotifier(
    ref.watch(ordersRepositoryProvider),
  ),
);

final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersProvider);
  final filter = ref.watch(orderFilterProvider);

  switch (filter) {
    case OrderFilter.all:
      return orders;

    case OrderFilter.preparing:
      return orders
          .where((o) => o.status == OrderStatus.preparing)
          .toList();

    case OrderFilter.ready:
      return orders
          .where((o) => o.status == OrderStatus.ready)
          .toList();

    case OrderFilter.delivery:
      return orders
          .where((o) => o.status == OrderStatus.outForDelivery)
          .toList();

    case OrderFilter.delivered:
      return orders
          .where((o) => o.status == OrderStatus.delivered)
          .toList();
  }
});