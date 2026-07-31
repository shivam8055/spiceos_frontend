import '../models/order.dart';

abstract class OrdersRepository {
  List<Order> getOrders();

  Future<void> createOrder(Order order);

  Future<void> updateOrder(Order order);

  Future<void> deleteOrder(String id);
}