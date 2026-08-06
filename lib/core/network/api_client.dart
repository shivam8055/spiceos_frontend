import 'package:flutter_riverpod/flutter_riverpod.dart';
class ApiClient {
  const ApiClient();

  Future<void> get(String path) {
    throw UnimplementedError();
  }

  Future<void> post(String path, Object? body) {
    throw UnimplementedError();
  }

  Future<void> put(String path, Object? body) {
    throw UnimplementedError();
  }

  Future<void> delete(String path) {
    throw UnimplementedError();
  }
}

final apiClientProvider = Provider<ApiClient>(
      (ref) => const ApiClient(),
);