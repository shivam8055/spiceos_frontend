import '../models/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();

  Future<InventoryItem> createInventoryItem(
    InventoryItem item,
  );

  Future<void> updateInventoryItem(
    InventoryItem item,
  );

  Future<void> deleteInventoryItem(
    int id,
  );
}
