import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/order.dart';
import '../models/order_filter.dart';
import '../providers/order_filter_provider.dart';
import '../repositories/api_orders_repository.dart';
import '../repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return ApiOrdersRepository(ref.watch(apiClientProvider));
});

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier(this._repository) : super([]) {
    loadOrders();
  }

  final OrdersRepository _repository;

  bool isLoading = false;
  String? error;

  Future<void> loadOrders() async {
    try {
      isLoading = true;
      error = null;
      final orders = await _repository.getOrders();
      state = List<Order>.from(orders);
    } catch (e, stackTrace) {
      error = e.toString();
      debugPrint('Orders Error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
    }
  }

  Future<void> refresh() => loadOrders();

  Future<void> createOrder(Order order) async {
    await _repository.createOrder(order);
    await loadOrders();
  }

  Future<void> updateOrder(Order order) async {
    await _repository.updateOrder(order);
    await loadOrders();
  }

  Future<void> deleteOrder(String id) async {
    await _repository.deleteOrder(id);
    await loadOrders();
  }

  Future<void> startPreparing(String orderId) => _transition(
        orderId,
        from: OrderStatus.created,
        to: OrderStatus.preparing,
      );

  Future<void> markReady(String orderId) => _transition(
        orderId,
        from: OrderStatus.preparing,
        to: OrderStatus.ready,
      );

  Future<void> dispatch(String orderId) => _transition(
        orderId,
        from: OrderStatus.ready,
        to: OrderStatus.outForDelivery,
      );

  Future<void> _transition(
    String orderId, {
    required OrderStatus from,
    required OrderStatus to,
  }) async {
    final index = state.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw StateError('Order $orderId was not found.');
    }

    final order = state[index];
    if (order.status != from) {
      throw StateError(
        'Invalid order transition: ${order.status.name} → ${to.name}.',
      );
    }

    await updateOrder(order.copyWith(status: to));
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>(
  (ref) => OrdersNotifier(ref.watch(ordersRepositoryProvider)),
);

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
      return orders.where((o) => o.status == OrderStatus.outForDelivery).toList();
    case OrderFilter.delivered:
      return orders.where((o) => o.status == OrderStatus.delivered).toList();
  }
});