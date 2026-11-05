import 'package:dio/dio.dart';

/// Az API hibája. A 422-es válasz `{message, errors: {mező: [üzenet]}}` alakú.
class ApiException implements Exception {
  ApiException({this.statusCode, this.message, this.fieldErrors = const {}, this.isNetwork = false});

  final int? statusCode;
  final String? message;
  final Map<String, List<String>> fieldErrors;
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;

  /// A mezőhibák közül az első, különben az általános üzenet.
  String? get firstMessage {
    for (final messages in fieldErrors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return message;
  }

  factory ApiException.from(DioException e) {
    final response = e.response;
    if (response == null) return ApiException(isNetwork: true);

    final data = response.data;
    var message = e.message;
    final errors = <String, List<String>>{};
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      final raw = data['errors'];
      if (raw is Map<String, dynamic>) {
        raw.forEach((key, value) {
          if (value is List) errors[key] = value.map((v) => '$v').toList();
        });
      }
    }
    return ApiException(statusCode: response.statusCode, message: message, fieldErrors: errors);
  }

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
