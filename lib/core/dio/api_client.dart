import 'package:dio/dio.dart';

/// API 공통모델
/// Interceptor 포함 (api Key)

import 'dart:async';
import 'package:dio/dio.dart';

// 2. ApiClient (shared)
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final Map<String, String> defaultHeaders; // 헤더 방식
  final Map<String, String> defaultQuery; // 쿼리 방식

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.defaultQuery = const {},
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        responseType: ResponseType.plain,
      ),
    )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (opts, handler) {
          opts.headers.addAll(defaultHeaders);
          opts.queryParameters.addAll(defaultQuery);
          handler.next(opts);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        int retryCount = 2,
        Duration retryDelay = const Duration(seconds: 1),
      }) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await _dio.get<T>(
          path,
          queryParameters: {...?query},
          options: Options(headers: {...?headers}),
        );
        return response;
      } catch (e) {
        attempt++;
        if (attempt > retryCount) rethrow;
        await Future.delayed(retryDelay);
      }
    }
  }
}