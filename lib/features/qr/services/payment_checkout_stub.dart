class PaymentCheckout {
  Future<Map<String, dynamic>?> open({
    required String keyId,
    required String amount,
    required String currency,
    required String orderId,
    required String name,
    String? phone,
  }) async {
    throw UnsupportedError('Online payment checkout is currently available on the web app.');
  }
}
