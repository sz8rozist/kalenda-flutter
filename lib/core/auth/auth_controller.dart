import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../push/push_service.dart';

/// Be van-e lépve az ügyfél (van-e tárolt token). `null` = még töltődik.
class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final signedIn = (await ref.read(tokenStoreProvider).read()) != null;
    if (signedIn) {
      // Indításkor: az eszköz token frissítése, ha az engedély megvan.
      unawaited(Future.microtask(() => ref.read(pushServiceProvider).registerIfAllowed()));
    }
    return signedIn;
  }

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
    // Ha az értesítés-engedély már megvan, az eszköz token regisztrálása (az engedélyt az első foglalás után kérjük).
    unawaited(ref.read(pushServiceProvider).registerIfAllowed());
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

  /// `DELETE /customer/account`: a fiók törlése (az áruházak megkövetelik). Közelgő foglalással a szerver 422-t ad
  /// (az `ApiException` üzenete megmondja); sikernél a helyi munkamenet is megszűnik.
  Future<void> deleteAccount() async {
    final api = ref.read(apiClientProvider);
    await api.call((d) => d.delete('/customer/account'));
    await sessionExpired();
  }

  Future<void> sessionExpired() async {
    ref.read(pushServiceProvider).reset();
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(AuthController.new);
