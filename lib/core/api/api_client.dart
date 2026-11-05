import 'package:dio/dio.dart';

import '../config.dart';
import 'api_exception.dart';

/// Közös Dio-kliens: Bearer-token, JSON, verziófejléc. A 401-re az `onUnauthorized` fut.
class ApiClient {
  ApiClient({required this.readToken, this.onUnauthorized})
      : dio = Dio(BaseOptions(
          baseUrl: '${AppConfig.apiBaseUrl}/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json', 'X-App-Version': AppConfig.appVersion},
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await readToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) onUnauthorized?.call();
        handler.next(e);
      },
    ));
  }

  final Dio dio;
  final Future<String?> Function() readToken;
  final void Function()? onUnauthorized;

  /// A Dio-hibát [ApiException]-né alakítja.
  Future<T> call<T>(Future<T> Function(Dio dio) request) async {
    try {
      return await request(dio);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
