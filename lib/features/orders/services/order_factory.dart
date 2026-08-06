import '../models/order.dart';

class OrderFactory {
  const OrderFactory._();

  static Order createWalkInOrder({
    required String orderId,
    required String orderNumber,
    required String customerName,
    required List<String> items,
    required double totalAmount,
  }) {
    return Order(
      id: orderId,
      orderNumber: orderNumber,
      customerId: orderId,
      customerName: customerName,
      primaryItem: items.isNotEmpty ? items.first : 'Order',
      createdAt: DateTime.now(),
      status: OrderStatus.created,
      paymentStatus: PaymentStatus.pending,
      totalAmount: totalAmount,
      orderSource: 'Walk-in',
    );
  }
}