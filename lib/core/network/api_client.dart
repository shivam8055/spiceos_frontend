import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  final Dio _dio;

  Future<Response<dynamic>> get(String path) async {
    return _dio.get(path);
  }

  Future<Response<dynamic>> post(
      String path,
      Object? body,
      ) async {
    return _dio.post(
      path,
      data: body,
    );
  }

  Future<Response<dynamic>> put(
      String path,
      Object? body,
      ) async {
    return _dio.put(
      path,
      data: body,
    );
  }

  Future<Response<dynamic>> delete(String path) async {
    return _dio.delete(path);
  }
}

final apiClientProvider = Provider<ApiClient>(
      (ref) => ApiClient(),
);