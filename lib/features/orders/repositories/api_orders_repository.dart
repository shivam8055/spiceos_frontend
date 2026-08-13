import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/order.dart';
import 'orders_repository.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this.api);

  final ApiClient api;

  @override
  Future<List<Order>> getOrders() async {
    final response = await api.get(ApiEndpoints.orders);
    final data = response.data as List;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createOrder(Order order) async {
    await api.post(ApiEndpoints.orders, {
      'order_number': order.orderNumber,
      'customer_id': order.customerId,
      'customer_name': order.customerName,
      'primary_item': order.primaryItem,
      'total': order.totalAmount,
      'payment_status': order.paymentStatus.name,
      'order_source': order.orderSource,
    });
  }

  @override
  Future<void> updateOrder(Order order) async {
    await api.patch('${ApiEndpoints.orders}${order.id}', {
      'customer_id': order.customerId,
      'customer_name': order.customerName,
      'primary_item': order.primaryItem,
      'total': order.totalAmount,
      'status': order.status.name,
      'payment_status': order.paymentStatus.name,
      'order_source': order.orderSource,
    });
  }

  @override
  Future<void> deleteOrder(String id) async {
    await api.delete('${ApiEndpoints.orders}$id');
  }
}
