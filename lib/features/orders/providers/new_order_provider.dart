import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_line_item.dart';

class NewOrderNotifier extends StateNotifier<List<OrderLineItem>> {
  NewOrderNotifier() : super([]);

  void addItem(OrderLineItem item) {
    final index = state.indexWhere((e) => e.id == item.id);

    if (index == -1) {
      state = [...state, item];
      return;
    }

    final updated = [...state];
    updated[index].quantity++;
    state = updated;
  }

  void increase(String id) {
    final updated = [...state];

    final index = updated.indexWhere((e) => e.id == id);

    if (index != -1) {
      updated[index].quantity++;
      state = updated;
    }
  }

  void decrease(String id) {
    final updated = [...state];

    final index = updated.indexWhere((e) => e.id == id);

    if (index == -1) return;

    if (updated[index].quantity == 1) {
      updated.removeAt(index);
    } else {
      updated[index].quantity--;
    }

    state = updated;
  }

  double get total =>
      state.fold(0, (sum, item) => sum + item.total);
}

final newOrderProvider =
StateNotifierProvider<NewOrderNotifier, List<OrderLineItem>>(
      (ref) => NewOrderNotifier(),
);