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
}
