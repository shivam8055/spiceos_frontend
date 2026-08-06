import 'order_stage.dart';

class OrderEvent {
  final String orderId;
  final OrderStage stage;
  final DateTime updatedAt;

  const OrderEvent({
    required this.orderId,
    required this.stage,
    required this.updatedAt,
  });
}