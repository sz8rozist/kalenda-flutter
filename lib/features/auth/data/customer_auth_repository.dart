import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';

/// Az ügyfélfiók hitelesítése: e-mailes belépő link → kód → ügyfél-token.
class CustomerAuthRepository {
  CustomerAuthRepository(this._api);

  final ApiClient _api;

  /// A válasz mindig ugyanaz (nem derül ki, ki ügyfél).
  Future<void> requestLoginLink(String email) => _api.call((d) => d.post('/customer/login-link', data: {'email': email}));

  /// A levélben kapott kód → ügyfél-token.
  Future<String> login(String code) async {
    final response = await _api.call((d) => d.post('/customer/login', data: {
          'token': code.trim(),
          'device_name': 'Kalenda app (${Platform.operatingSystem})',
        }));
    return response.data['token'] as String;
  }

  Future<void> logout() => _api.call((d) => d.post('/customer/logout'));

  /// A fiók törlése; közelgő foglalással a szerver 422-t ad.
  Future<void> deleteAccount() => _api.call((d) => d.delete('/customer/account'));
}

final customerAuthRepositoryProvider = Provider<CustomerAuthRepository>((ref) => CustomerAuthRepository(ref.watch(apiClientProvider)));
