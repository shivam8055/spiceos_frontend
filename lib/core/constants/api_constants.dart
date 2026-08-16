class ApiConstants {
  ApiConstants._();

  // Production is the safe default for deployed SpiceOS builds.
  // Local development can still override this with:
  // flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://spiceosbackend-production.up.railway.app',
  );

  static const String orders = '/orders/';
  static const String inventory = '/inventory/';
  static const String authMe = '/auth/me';
}
