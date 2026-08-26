class ApiEndpoints {
  ApiEndpoints._();

  // Use canonical collection URLs without a trailing slash. This avoids
  // FastAPI's 307 redirect in Flutter Web, which can turn an authenticated
  // cross-origin request into a browser-level CORS/connection failure.
  static const String orders = '/orders';
  static const String inventory = '/inventory';
  static const String authMe = '/auth/me';
}
