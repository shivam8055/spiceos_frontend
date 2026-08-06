import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_event.dart';
import '../models/order_stage.dart';
import '../services/order_workflow_service.dart';

class OrderWorkflowNotifier
    extends StateNotifier<List<OrderEvent>> {
  OrderWorkflowNotifier() : super([]);

  final _service = OrderWorkflowService();

  void publish({
    required String orderId,
    required OrderStage stage,
  }) {
    final event = _service.createEvent(
      orderId: orderId,
      stage: stage,
    );

    state = [...state, event];
  }

  List<OrderEvent> eventsForStage(OrderStage stage) {
    return state.where((e) => e.stage == stage).toList();
  }
}

final orderWorkflowProvider =
StateNotifierProvider<
    OrderWorkflowNotifier,
    List<OrderEvent>>(
      (ref) => OrderWorkflowNotifier(),
);