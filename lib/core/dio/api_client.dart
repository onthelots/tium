import 'package:dio/dio.dart';

/// API 공통모델
/// Interceptor 포함 (api Key)

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.apiKey,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        responseType: ResponseType.plain,  // JSON 아님, String 그대로 받음
      ),
    )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (opts, handler) {
          opts.queryParameters.addAll({'serviceKey': apiKey});
          return handler.next(opts);
        },
      ),
    );
  }

  late final Dio _dio;
  final String baseUrl;
  final String apiKey;

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? query,
      }) async {
    final response = await _dio.get<T>(path, queryParameters: query);
    print('Response data type: ${response.data.runtimeType}');
    print('Response data: ${response.data}');
    return response;
  }
}
