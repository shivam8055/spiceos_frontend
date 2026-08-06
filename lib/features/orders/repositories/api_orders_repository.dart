import '../../../core/network/api_client.dart';

import '../models/order.dart';
import 'orders_repository.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this.api);

  final ApiClient api;

  @override
  List<Order> getOrders() {
    throw UnimplementedError();
  }

  @override
  Future<void> createOrder(Order order) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOrder(Order order) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteOrder(String id) {
    throw UnimplementedError();
  }
}