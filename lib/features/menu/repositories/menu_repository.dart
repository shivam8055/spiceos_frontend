import '../../../core/network/api_client.dart';
import '../models/menu_item.dart';

class MenuRepository {
  MenuRepository(this._api);
  final ApiClient _api;

  Future<List<MenuItem>> list({required String restaurantId, required String branchId}) async {
    final response = await _api.get('/admin/menu-items?restaurant_id=$restaurantId&branch_id=$branchId');
    final data = response.data;
    if (data is List) {
      return data.map((item) => MenuItem.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((item) => MenuItem.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    }
    return const [];
  }

  Future<MenuItem> update({required int itemId, String? branchId, String? category, String? name, String? description, double? price, bool? available}) async {
    final payload = <String, dynamic>{};
    if (branchId != null) payload['branch_id'] = branchId;
    if (category != null) payload['category'] = category;
    if (name != null) payload['name'] = name;
    if (description != null) payload['description'] = description;
    if (price != null) payload['price'] = price;
    if (available != null) payload['available'] = available;
    final response = await _api.patch('/admin/menu-items/$itemId', payload);
    return MenuItem.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> delete({required int itemId}) async {
    await _api.delete('/admin/menu-items/$itemId');
  }
}
