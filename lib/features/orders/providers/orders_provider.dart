import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_filter.dart';
import 'order_filter_provider.dart';

final demoOrdersProvider = Provider<List<Order>>((ref) {
  return [
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
});

final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(demoOrdersProvider);
  final filter = ref.watch(orderFilterProvider);

  switch (filter) {
    case OrderFilter.all:
      return orders;

    case OrderFilter.preparing:
      return orders
          .where((o) => o.status == OrderStatus.preparing)
          .toList();

    case OrderFilter.ready:
      return orders
          .where((o) => o.status == OrderStatus.ready)
          .toList();

    case OrderFilter.delivery:
      return orders
          .where((o) => o.status == OrderStatus.outForDelivery)
          .toList();

    case OrderFilter.delivered:
      return orders
          .where((o) => o.status == OrderStatus.delivered)
          .toList();
  }
});