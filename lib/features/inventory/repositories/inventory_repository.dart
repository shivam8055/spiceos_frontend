import '../models/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();

  Future<List<InventoryItem>> getLowStock();
}