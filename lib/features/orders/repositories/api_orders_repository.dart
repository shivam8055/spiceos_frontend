
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

    return data
        .map(
          (e) => Order.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<void> createOrder(Order order) async {
    await api.post(
      ApiEndpoints.orders,
      {
        "order_number": order.orderNumber,
        "customer_name": order.customerName,
        "total": order.totalAmount,
      },
    );
  }

  @override
  Future<void> updateOrder(Order order) async {
    // TODO: Implement when PATCH endpoint is available.
  }

  @override
  Future<void> deleteOrder(String id) async {
    // TODO: Implement when DELETE endpoint is available.
  }
}