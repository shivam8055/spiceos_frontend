enum OrderStatus {
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentStatus {
  paid,
  pending,
  refunded,
}

class Order {
  final String id;
  final String orderNumber;

  final String customerId;
  final String customerName;

  final String primaryItem;

  final DateTime createdAt;

  final OrderStatus status;
  final PaymentStatus paymentStatus;

  final double totalAmount;

  final String orderSource;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.primaryItem,
    required this.createdAt,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderSource,
  });
}