import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/inventory_api_item.dart';

final inventoryItemsProvider = FutureProvider.autoDispose<List<InventoryApiItem>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get(ApiEndpoints.inventory);
  final data = response.data as List<dynamic>;

  return data
      .map((item) => InventoryApiItem.fromJson(item as Map<String, dynamic>))
      .toList();
});

final lowStockItemsProvider = FutureProvider.autoDispose<List<InventoryApiItem>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('${ApiEndpoints.inventory}low-stock');
  final data = response.data as List<dynamic>;

  return data
      .map((item) => InventoryApiItem.fromJson(item as Map<String, dynamic>))
      .toList();
});

Future<InventoryApiItem> createInventoryItem(
  WidgetRef ref, {
  required String name,
  String? sku,
  required String unit,
  required double quantity,
  required double reorderLevel,
  required double costPerUnit,
}) async {
  final api = ref.read(apiClientProvider);
  final response = await api.post(
    ApiEndpoints.inventory,
    {
      'name': name,
      'sku': sku,
      'unit': unit,
      'quantity': quantity,
      'reorder_level': reorderLevel,
      'cost_per_unit': costPerUnit,
    },
  );

  final item = InventoryApiItem.fromJson(
    response.data as Map<String, dynamic>,
  );

  ref.invalidate(inventoryItemsProvider);
  ref.invalidate(lowStockItemsProvider);

  return item;
}
