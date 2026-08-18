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
  final DateTime? readyAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final String orderSource;
  final String? transactionCode;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.primaryItem,
    required this.createdAt,
    this.preparingAt,
    this.readyAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderSource,
    this.transactionCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      orderNumber: json['order_number']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      primaryItem: json['primary_item']?.toString() ?? '',
      createdAt: _parseBackendUtcDateTime(json['created_at']) ?? DateTime.now(),
      preparingAt: _parseBackendUtcDateTime(json['preparing_at']),
      readyAt: _parseBackendUtcDateTime(json['ready_at']),
      outForDeliveryAt: _parseBackendUtcDateTime(json['out_for_delivery_at']),
      deliveredAt: _parseBackendUtcDateTime(json['delivered_at']),
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      totalAmount: (json['total'] as num?)?.toDouble() ?? 0,
      orderSource: json['order_source']?.toString() ?? 'Unknown',
      transactionCode: _nullableString(json['transaction_code']),
    );
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _parseBackendUtcDateTime(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;

    // The current FastAPI/SQLAlchemy backend stores UTC timestamps as naive
    // datetimes. Dart treats a timestamp without an offset as local time, so
    // explicitly mark those responses as UTC to avoid an India +05:30 drift.
    final hasTimezone = value.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value);
    if (hasTimezone) return parsed;

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
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

  Duration? get totalDeliveryTime {
    if (deliveredAt == null) return null;
    final duration = deliveredAt!.difference(createdAt);
    return duration.isNegative ? null : duration;
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
      'ready_at': readyAt?.toIso8601String(),
      'out_for_delivery_at': outForDeliveryAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'status': status.name,
      'payment_status': paymentStatus.name,
      'total': totalAmount,
      'order_source': orderSource,
      'transaction_code': transactionCode,
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
    DateTime? readyAt,
    DateTime? outForDeliveryAt,
    DateTime? deliveredAt,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? totalAmount,
    String? orderSource,
    String? transactionCode,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      primaryItem: primaryItem ?? this.primaryItem,
      createdAt: createdAt ?? this.createdAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      outForDeliveryAt: outForDeliveryAt ?? this.outForDeliveryAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      orderSource: orderSource ?? this.orderSource,
      transactionCode: transactionCode ?? this.transactionCode,
    );
  }
}
