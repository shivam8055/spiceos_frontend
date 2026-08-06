import '../models/order_event.dart';
import '../models/order_stage.dart';

class OrderWorkflowService {
  OrderEvent createEvent({
    required String orderId,
    required OrderStage stage,
  }) {
    return OrderEvent(
      orderId: orderId,
      stage: stage,
      updatedAt: DateTime.now(),
    );
  }
}