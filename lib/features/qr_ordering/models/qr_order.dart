class QROrderConfirmation {
  final int orderId;
  final String orderNumber;
  final String status;
  final double total;
  final String currency;
  final String tableName;
  final String publicOrderToken;

  const QROrderConfirmation({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.currency,
    required this.tableName,
    required this.publicOrderToken,
  });

  factory QROrderConfirmation.fromJson(Map<String, dynamic> json) => QROrderConfirmation(
        orderId: json['order_id'] as int,
        orderNumber: json['order_number'].toString(),
        status: json['status'].toString(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'INR',
        tableName: json['table_name']?.toString() ?? 'Table',
        publicOrderToken: json['public_order_token'].toString(),
      );
}

class QROrderStatus {
  final String orderNumber;
  final String status;
  final double total;
  final String currency;
  final String tableName;
  final DateTime createdAt;

  const QROrderStatus({
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.currency,
    required this.tableName,
    required this.createdAt,
  });

  factory QROrderStatus.fromJson(Map<String, dynamic> json) => QROrderStatus(
        orderNumber: json['order_number'].toString(),
        status: json['status'].toString(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'INR',
        tableName: json['table_name']?.toString() ?? 'Table',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
}
