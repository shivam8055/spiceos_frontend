class ApiEndpoints {
  ApiEndpoints._();

  // Keep the collection endpoint without a trailing slash so browser API
  // requests do not receive FastAPI's 307 slash redirect.
  static const String orders = '/orders';
  static const String inventory = '/inventory/';
  static const String authMe = '/auth/me';
}
