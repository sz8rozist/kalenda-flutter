import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_store.dart';
import '../../../core/providers.dart';
import '../../../core/push/push_service.dart';
import '../data/customer_auth_repository.dart';

/// Az ügyfél munkamenete: be van-e lépve (van-e tárolt token). Betöltés közben `loading`.
class CustomerSessionViewModel extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final signedIn = (await ref.read(tokenStoreProvider).read(TokenKind.customer)) != null;
    if (signedIn) {
      // Indításkor: az eszköz token frissítése, ha az értesítés-engedély megvan.
      unawaited(Future.microtask(() => ref.read(pushServiceProvider).registerIfAllowed()));
    }
    return signedIn;
  }

  /// A levélben kapott kóddal belép; a token a biztonságos tárba kerül.
  Future<void> signIn(String code) async {
    final token = await ref.read(customerAuthRepositoryProvider).login(code);
    await ref.read(tokenStoreProvider).write(token, TokenKind.customer);
    state = const AsyncData(true);
    unawaited(ref.read(pushServiceProvider).registerIfAllowed());
  }

  Future<void> signOut() async {
    try {
      await ref.read(customerAuthRepositoryProvider).logout();
    } catch (_) {
      // Hálózati hiba esetén is töröljük a helyi tokent.
    }
    await sessionExpired();
  }

  /// Fiók törlése; sikernél a helyi munkamenet is megszűnik, hibánál a kivétel a hívóhoz kerül.
  Future<void> deleteAccount() async {
    await ref.read(customerAuthRepositoryProvider).deleteAccount();
    await sessionExpired();
  }

  Future<void> sessionExpired() async {
    ref.read(pushServiceProvider).reset();
    await ref.read(tokenStoreProvider).clear(TokenKind.customer);
    state = const AsyncData(false);
  }
}

final customerSessionProvider = AsyncNotifierProvider<CustomerSessionViewModel, bool>(CustomerSessionViewModel.new);
