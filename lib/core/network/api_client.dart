import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _dio = Dio(
         BaseOptions(
           baseUrl: ApiConstants.baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 90),
           headers: const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = _firebaseAuth.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
            handler.next(options);
          } catch (error) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
              ),
            );
          }
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  Future<Response<dynamic>> get(String path) => _dio.get(path);

  Future<Response<dynamic>> post(String path, Object? body) =>
      _dio.post(path, data: body);

  Future<Response<dynamic>> postMultipart(String path, FormData body) =>
      _dio.post(path, data: body, options: Options(contentType: 'multipart/form-data'));

  Future<Response<dynamic>> patch(String path, Object? body) =>
      _dio.patch(path, data: body);

  Future<Response<dynamic>> put(String path, Object? body) =>
      _dio.put(path, data: body);

  Future<Response<dynamic>> delete(String path) => _dio.delete(path);
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    firebaseAuth: FirebaseAuth.instance,
  ),
);
