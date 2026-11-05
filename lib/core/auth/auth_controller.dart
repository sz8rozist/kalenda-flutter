import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Be van-e lépve az ügyfél (van-e tárolt token). `null` = még töltődik.
class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => (await ref.read(tokenStoreProvider).read()) != null;

  /// `POST /customer/login-link`: a válasz mindig ugyanaz (nem derül ki, ki ügyfél).
  Future<void> requestLink(String email) async {
    final api = ref.read(apiClientProvider);
    await api.call((d) => d.post('/customer/login-link', data: {'email': email}));
  }

  /// `POST /customer/login`: a levélben kapott kód → ügyfél-token.
  Future<void> signIn(String code) async {
    final api = ref.read(apiClientProvider);
    final response = await api.call((d) => d.post('/customer/login', data: {
          'token': code.trim(),
          'device_name': 'Kalenda app (${Platform.operatingSystem})',
        }));
    await ref.read(tokenStoreProvider).write(response.data['token'] as String);
    state = const AsyncData(true);
  }

  Future<void> signOut() async {
    try {
      final api = ref.read(apiClientProvider);
      await api.call((d) => d.post('/customer/logout'));
    } catch (_) {
      // Hálózati hiba esetén is töröljük a helyi tokent.
    }
    await sessionExpired();
  }

  Future<void> sessionExpired() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(AuthController.new);
