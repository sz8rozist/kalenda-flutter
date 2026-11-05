import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/token_store.dart';
import '../../core/providers.dart';
import 'staff_models.dart';

/// A munkatársi / vállalkozói fiók munkamenete. Az érték a bejelentkezett felhasználó, `null` = nincs belépve.
class StaffAuth extends AsyncNotifier<StaffUser?> {
  @override
  Future<StaffUser?> build() async {
    final store = ref.read(tokenStoreProvider);
    if (await store.read(TokenKind.staff) == null) return null;

    try {
      return await _loadMe();
    } catch (_) {
      // Lejárt token vagy hálózati hiba: belépés nélküliként indulunk (hálózati hibánál a token megmarad).
      return null;
    }
  }

  Future<StaffUser> _loadMe() async {
    final api = ref.read(apiClientProvider);
    final response = await api.call((d) => d.get('/me'));
    return StaffUser.fromJson(response.data as Map<String, dynamic>);
  }

  /// `POST /auth/login` (mobilon a `device_name` kötelező) → token + felhasználó.
  Future<void> signIn(String email, String password) async {
    final api = ref.read(apiClientProvider);
    final response = await api.call((d) => d.post('/auth/login', data: {
          'email': email.trim(),
          'password': password,
          'device_name': 'Kalenda app (${Platform.operatingSystem})',
        }));
    final data = response.data as Map<String, dynamic>;
    await ref.read(tokenStoreProvider).write(data['token'] as String, TokenKind.staff);
    state = AsyncData(StaffUser.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<void> signOut() async {
    try {
      final api = ref.read(apiClientProvider);
      await api.call((d) => d.post('/auth/logout'));
    } catch (_) {
      // Hálózati hiba esetén is töröljük a helyi tokent.
    }
    await sessionExpired();
  }

  Future<void> sessionExpired() async {
    await ref.read(tokenStoreProvider).clear(TokenKind.staff);
    state = const AsyncData(null);
  }
}

final staffAuthProvider = AsyncNotifierProvider<StaffAuth, StaffUser?>(StaffAuth.new);
