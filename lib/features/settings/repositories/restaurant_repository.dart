import '../../../core/network/api_client.dart';
import '../models/restaurant.dart';

class RestaurantRepository {
  RestaurantRepository(this._api);

  final ApiClient _api;

  Future<Restaurant?> getCurrent() async {
    try {
      final response = await _api.get('/qr/admin/restaurant');
      return Restaurant.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<Restaurant> create({required String name, String? logoUrl}) async {
    final response = await _api.post('/qr/admin/restaurant', {
      'name': name,
      'logo_url': logoUrl?.trim().isEmpty == true ? null : logoUrl?.trim(),
    });
    return Restaurant.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> createMenuItem({
    required String restaurantId,
    required String branchId,
    required String category,
    required String name,
    required String description,
    required double price,
  }) async {
    await _api.post('/qr/admin/menu-items', {
      'restaurant_id': restaurantId,
      'branch_id': branchId,
      'category': category,
      'name': name,
      'description': description.trim().isEmpty ? null : description.trim(),
      'price': price,
      'available': true,
      'modifiers': <Map<String, dynamic>>[],
    });
  }
}
