import '../../../core/network/api_client.dart';
import '../models/qr_table.dart';

class QRTableRepository {
  QRTableRepository(this._api);
  final ApiClient _api;

  Future<QRTable> create({
    required String restaurantId,
    required String branchId,
    required String tableId,
    required String tableName,
    required String sessionId,
  }) async {
    final response = await _api.post('/qr/admin/qr-tables', {
      'restaurant_id': restaurantId,
      'branch_id': branchId,
      'table_id': tableId,
      'table_name': tableName,
      'session_id': sessionId,
    });
    return QRTable.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
