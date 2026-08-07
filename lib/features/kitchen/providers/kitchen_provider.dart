import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_order.dart';
import '../../orders/providers/orders_provider.dart';

class KitchenNotifier extends StateNotifier<List<KitchenOrder>> {
  KitchenNotifier(this.ref)
      : super([
    KitchenOrder(
      id: '1',
      orderNumber: '#1001',
      customerName: 'Rahul Kumar',
      items: [
        'Chicken Biryani x2',
        'Coke x1',
      ],
      createdAt: DateTime.now(),
      status: KitchenOrderStatus.waiting,
    ),
    KitchenOrder(
      id: '2',
      orderNumber: '#1002',
      customerName: 'Priya Singh',
      items: [
        'Paneer Tikka',
      ],
      createdAt: DateTime.now(),
      status: KitchenOrderStatus.cooking,
    ),
    KitchenOrder(
      id: '3',
      orderNumber: '#1003',
      customerName: 'Aman Verma',
      items: [
        'Veg Thali',
      ],
      createdAt: DateTime.now(),
      status: KitchenOrderStatus.ready,
    ),
  ]);


  final Ref ref;

  void startPreparing(String id) {
    ref.read(ordersProvider.notifier).startPreparing(id);
  }

  void markReady(String id) {
    ref.read(ordersProvider.notifier).markReady(id);
  }

  void dispatch(String id) {
    ref.read(ordersProvider.notifier).dispatch(id);
  }
}

final kitchenOrdersProvider =
StateNotifierProvider<KitchenNotifier, List<KitchenOrder>>(
(ref) => KitchenNotifier(ref),
);