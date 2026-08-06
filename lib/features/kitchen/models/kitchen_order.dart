enum KitchenOrderStatus {
  waiting,
  cooking,
  ready,
}

class KitchenOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final List<String> items;
  final DateTime createdAt;
  final KitchenOrderStatus status;

  const KitchenOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.items,
    required this.createdAt,
    required this.status,
  });
}