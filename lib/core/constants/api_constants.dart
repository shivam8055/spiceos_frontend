class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String orders = '/orders/';
  static const String inventory = '/inventory/';
  static const String authMe = '/auth/me';
}