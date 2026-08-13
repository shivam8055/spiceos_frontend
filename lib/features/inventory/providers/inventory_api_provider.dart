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