import 'package:dio/dio.dart';

import '../config.dart';
import 'api_exception.dart';

/// Közös Dio-kliens: Bearer-token, JSON, verziófejléc. A token az útvonaltól függ: a `/customer/…` kérések az
/// ügyfél-tokent, a többi védett (`/auth`, `/me`, `/staff-portal`, `/businesses`) a munkatársi tokent kapják; a
/// `/public/…` kérések token nélkül mennek. A 401-re az `onUnauthorized` fut az érintett útvonallal.
class ApiClient {
  ApiClient({required this.readCustomerToken, required this.readStaffToken, this.onUnauthorized})
      : dio = Dio(BaseOptions(
          baseUrl: '${AppConfig.apiBaseUrl}/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json', 'X-App-Version': AppConfig.appVersion},
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        final String? token;
        if (path.startsWith('/customer/') && !path.startsWith('/customer/login')) {
          token = await readCustomerToken();
        } else if (path.startsWith('/public/') || path == '/customer/login-link' || path == '/customer/login' || path == '/auth/login') {
          token = null;
        } else {
          token = await readStaffToken();
        }
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) onUnauthorized?.call(e.requestOptions.path);
        handler.next(e);
      },
    ));
  }

  final Dio dio;
  final Future<String?> Function() readCustomerToken;
  final Future<String?> Function() readStaffToken;
  final void Function(String path)? onUnauthorized;

  /// A Dio-hibát [ApiException]-né alakítja.
  Future<T> call<T>(Future<T> Function(Dio dio) request) async {
    try {
      return await request(dio);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
