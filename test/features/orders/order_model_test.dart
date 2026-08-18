import 'package:flutter_test/flutter_test.dart';

import 'package:spiceos_frontend/features/orders/models/order.dart';

void main() {
  test('interprets backend naive timestamps as UTC', () {
    final order = Order.fromJson({
      'id': 1,
      'order_number': 'QR-TEST',
      'customer_id': null,
      'customer_name': 'QR Guest',
      'primary_item': 'Paneer Butter Masala',
      'created_at': '2026-08-18T10:00:00',
      'preparing_at': '2026-08-18T10:05:00',
      'status': 'preparing',
      'payment_status': 'paid',
      'total': 249,
      'order_source': 'qr_table',
    });

    expect(order.createdAt.isUtc, isTrue);
    expect(order.preparingAt?.isUtc, isTrue);
    expect(order.preparingAt!.difference(order.createdAt), const Duration(minutes: 5));
  });

  test('keeps explicit timezone offsets intact', () {
    final order = Order.fromJson({
      'id': 1,
      'order_number': 'QR-TEST',
      'customer_id': null,
      'customer_name': 'QR Guest',
      'primary_item': 'Paneer Butter Masala',
      'created_at': '2026-08-18T10:00:00Z',
      'preparing_at': '2026-08-18T10:05:00+00:00',
      'status': 'preparing',
      'payment_status': 'paid',
      'total': 249,
      'order_source': 'qr_table',
    });

    expect(order.createdAt.isUtc, isTrue);
    expect(order.preparingAt?.isUtc, isTrue);
    expect(order.preparingAt!.difference(order.createdAt), const Duration(minutes: 5));
  });
}
