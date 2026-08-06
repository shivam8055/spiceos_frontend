import '../models/order.dart';
import 'orders_repository.dart';

class MockOrdersRepository implements OrdersRepository {
  final List<Order> _orders = [
    Order(
      id: '1',
      orderNumber: '#1001',
      customerId: 'C001',
      customerName: 'Rahul Kumar',
      primaryItem: 'Chicken Biryani',
      createdAt: DateTime.now(),
      status: OrderStatus.preparing,
      paymentStatus: PaymentStatus.paid,
      totalAmount: 349,
      orderSource: 'WhatsApp',
    ),
    Order(
      id: '2',
      orderNumber: '#1002',
      customerId: 'C002',
      customerName: 'Anjali Singh',
      primaryItem: 'Paneer Butter Masala',
      createdAt: DateTime.now(),
      status: OrderStatus.outForDelivery,
      paymentStatus: PaymentStatus.paid,
      totalAmount: 420,
      orderSource: 'Website',
    ),
    Order(
      id: '3',
      orderNumber: '#1003',
      customerId: 'C003',
      customerName: 'Amit Raj',
      primaryItem: 'Veg Thali',
      createdAt: DateTime.now(),
      status: OrderStatus.delivered,
      paymentStatus: PaymentStatus.paid,
      totalAmount: 280,
      orderSource: 'Walk-in',
    ),
  ];

  @override
  List<Order> getOrders() => _orders;

  @override
  Future<void> createOrder(Order order) async {
    _orders.add(order);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final index = _orders.indexWhere((e) => e.id == order.id);

    if (index == -1) {
      throw Exception('Order not found: ${order.id}');
    }

    _orders[index] = order;
  }

  @override
  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((e) => e.id == id);
  }
}