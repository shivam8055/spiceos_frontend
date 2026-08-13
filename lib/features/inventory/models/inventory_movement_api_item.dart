class InventoryMovementApiItem {
  final int id;
  final int inventoryItemId;
  final double quantityDelta;
  final String reason;
  final int createdByUserId;
  final DateTime createdAt;

  const InventoryMovementApiItem({
    required this.id,
    required this.inventoryItemId,
    required this.quantityDelta,
    required this.reason,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory InventoryMovementApiItem.fromJson(Map<String, dynamic> json) {
    return InventoryMovementApiItem(
      id: (json['id'] as num).toInt(),
      inventoryItemId: (json['inventory_item_id'] as num).toInt(),
      quantityDelta: (json['quantity_delta'] as num).toDouble(),
      reason: json['reason'] as String,
      createdByUserId: (json['created_by_user_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
