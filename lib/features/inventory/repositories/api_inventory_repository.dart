import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/inventory_item.dart';
import 'inventory_repository.dart';

class ApiInventoryRepository implements InventoryRepository {
  final ApiClient api;

  ApiInventoryRepository(this.api);

  @override
  Future<List<InventoryItem>> getInventory() async {
    final response = await api.get(ApiEndpoints.inventory);
    final data = response.data as List;
    return data
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<InventoryItem>> getLowStock() async {
    final response = await api.get('${ApiEndpoints.inventory}low-stock');
    final data = response.data as List;
    return data
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    final response = await api.post(
      ApiEndpoints.inventory,
      item.toCreateJson(),
    );
    return InventoryItem.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<InventoryItem> adjustInventory({
    required int id,
    required double quantityDelta,
    required String reason,
  }) async {
    if (quantityDelta == 0) {
      throw ArgumentError('Quantity adjustment cannot be zero.');
    }

    final response = await api.post(
      '${ApiEndpoints.inventory}$id/adjust',
      {
        'quantity_delta': quantityDelta,
        'reason': reason,
      },
    );
    return InventoryItem.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<InventoryMovement>> getMovements(int id) async {
    final response = await api.get(
      '${ApiEndpoints.inventory}$id/movements',
    );
    final data = response.data as List;
    return data
        .map((e) => InventoryMovement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
