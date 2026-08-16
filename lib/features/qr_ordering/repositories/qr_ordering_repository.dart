import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/qr_menu.dart';
import '../models/qr_order.dart';

class QROrderingRepository {
  QROrderingRepository(this._api);

  final ApiClient _api;

  Future<QRMenu> getMenu(String token) async {
    final response = await _api.get('${ApiEndpoints.qrPublic}/$token/menu');
    return QRMenu.fromJson(response.data as Map<String, dynamic>);
  }

  Future<QROrderConfirmation> createOrder({
    required String token,
    required String idempotencyKey,
    required List<QRCartLine> lines,
    String? customerName,
    String? customerPhone,
  }) async {
    final response = await _api.postWithHeaders(
      '${ApiEndpoints.qrPublic}/$token/orders',
      {
        'items': lines
            .map((line) => {
                  'menu_item_id': line.item.id,
                  'quantity': line.quantity,
                  'modifier_ids': line.modifiers.map((modifier) => modifier.id).toList(),
                  if (line.note.trim().isNotEmpty) 'note': line.note.trim(),
                })
            .toList(),
        if (customerName?.trim().isNotEmpty == true) 'customer_name': customerName!.trim(),
        if (customerPhone?.trim().isNotEmpty == true) 'customer_phone': customerPhone!.trim(),
      },
      headers: {'Idempotency-Key': idempotencyKey},
    );
    return QROrderConfirmation.fromJson(response.data as Map<String, dynamic>);
  }

  Future<QROrderStatus> getOrderStatus(String publicOrderToken) async {
    final response = await _api.get('${ApiEndpoints.qrOrderStatus}/$publicOrderToken');
    return QROrderStatus.fromJson(response.data as Map<String, dynamic>);
  }
}

String qrErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['detail'] != null) {
      return data['detail'].toString();
    }
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
