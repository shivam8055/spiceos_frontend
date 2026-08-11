
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
        .map(
          (e) => InventoryItem.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<InventoryItem> createInventoryItem(
      InventoryItem item,
      ) async {
    final response = await api.post(
      ApiEndpoints.inventory,
      item.toJson(),
    );

    return InventoryItem.fromJson(response.data);
  }

  @override
  Future<void> updateInventoryItem(
      InventoryItem item,
      ) async {
    await api.put(
      '${ApiEndpoints.inventory}${item.id}',
      item.toJson(),
    );
  }

  @override
  Future<void> deleteInventoryItem(
      int id,
      ) async {
    await api.delete(
      '${ApiEndpoints.inventory}$id',
    );
  }
}