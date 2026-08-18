import 'package:flutter_test/flutter_test.dart';

import 'package:spicebox/features/orders/models/order.dart';

Map<String, dynamic> baseOrderJson() {
  return {
    'id': 1,
    'order_number': 'QR-TEST',
    'customer_id': null,
    'customer_name': 'QR Guest',
    'primary_item': 'Paneer Butter Masala',
    'created_at': '2026-08-18T10:00:00',
    'preparing_at': '2026-08-18T10:05:00',
    'ready_at': '2026-08-18T10:25:00',
    'out_for_delivery_at': '2026-08-18T10:35:00',
    'delivered_at': '2026-08-18T10:50:00',
    'status': 'delivered',
    'payment_status': 'paid',
    'total': 249,
    'order_source': 'qr_table',
  };
}

void main() {
  test('interprets backend naive timestamps as UTC', () {
    final order = Order.fromJson(baseOrderJson());

    expect(order.createdAt.isUtc, isTrue);
    expect(order.preparingAt?.isUtc, isTrue);
    expect(order.readyAt?.isUtc, isTrue);
    expect(order.outForDeliveryAt?.isUtc, isTrue);
    expect(order.deliveredAt?.isUtc, isTrue);
    expect(order.preparingAt!.difference(order.createdAt), const Duration(minutes: 5));
    expect(order.totalDeliveryTime, const Duration(minutes: 50));
  });

  test('parses the complete status timeline', () {
    final order = Order.fromJson(baseOrderJson());

    expect(order.status, OrderStatus.delivered);
    expect(order.readyAt!.difference(order.preparingAt!), const Duration(minutes: 20));
    expect(order.outForDeliveryAt!.difference(order.readyAt!), const Duration(minutes: 10));
    expect(order.deliveredAt!.difference(order.outForDeliveryAt!), const Duration(minutes: 15));
  });

  test('keeps explicit timezone offsets intact', () {
    final json = baseOrderJson()
      ..['created_at'] = '2026-08-18T10:00:00Z'
      ..['preparing_at'] = '2026-08-18T10:05:00+00:00';
    final order = Order.fromJson(json);

    expect(order.createdAt.isUtc, isTrue);
    expect(order.preparingAt?.isUtc, isTrue);
    expect(order.preparingAt!.difference(order.createdAt), const Duration(minutes: 5));
  });
}
