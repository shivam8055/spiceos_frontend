enum OrderStatus {
  created,
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

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? primaryItem,
    DateTime? createdAt,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? totalAmount,
    String? orderSource,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      primaryItem: primaryItem ?? this.primaryItem,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      orderSource: orderSource ?? this.orderSource,
    );
  }
}