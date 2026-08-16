import '../models/inventory_item.dart';

class InventoryMovement {
  final int id;
  final int inventoryItemId;
  final double quantityDelta;
  final String reason;
  final int createdByUserId;
  final DateTime createdAt;

  const InventoryMovement({
    required this.id,
    required this.inventoryItemId,
    required this.quantityDelta,
    required this.reason,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'] as int,
      inventoryItemId: json['inventory_item_id'] as int,
      quantityDelta: (json['quantity_delta'] as num).toDouble(),
      reason: json['reason'] as String,
      createdByUserId: json['created_by_user_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();

  Future<List<InventoryItem>> getLowStock();

  Future<InventoryItem> createInventoryItem(InventoryItem item);

  Future<InventoryItem> adjustInventory({
    required int id,
    required double quantityDelta,
    required String reason,
  });

  Future<List<InventoryMovement>> getMovements(int id);
}
