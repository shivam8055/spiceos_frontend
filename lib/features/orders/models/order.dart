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
  final DateTime? preparingAt;
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
    required this.preparingAt,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderSource,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      orderNumber: json['order_number']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      primaryItem: json['primary_item']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      preparingAt: _parseNullableDateTime(json['preparing_at']),
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      totalAmount: (json['total'] as num?)?.toDouble() ?? 0,
      orderSource: json['order_source']?.toString() ?? 'Unknown',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static OrderStatus _parseOrderStatus(dynamic value) {
    switch (value?.toString()) {
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'outForDelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'created':
      default:
        return OrderStatus.created;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    switch (value?.toString()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'primary_item': primaryItem,
      'created_at': createdAt.toIso8601String(),
      'preparing_at': preparingAt?.toIso8601String(),
      'status': status.name,
      'payment_status': paymentStatus.name,
      'total': totalAmount,
      'order_source': orderSource,
    };
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? primaryItem,
    DateTime? createdAt,
    DateTime? preparingAt,
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
      preparingAt: preparingAt ?? this.preparingAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      orderSource: orderSource ?? this.orderSource,
    );
  }
}
